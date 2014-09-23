/* Ping Pong with jumbo packets */
//Author:Anusha Balaji
#include <inttypes.h>
#include <stdbool.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

#include <sys/mman.h>
#include <sys/dataplane.h>

#include <tmc/alloc.h>

#include <arch/atomic.h>
#include <arch/cycle.h>

#include <gxio/mpipe.h>

#include <tmc/cpus.h>
#include <tmc/mem.h>
#include <tmc/spin.h>
#include <tmc/sync.h>
#include <tmc/task.h>
#include <tmc/perf.h>
#include <time.h>

// Define this to verify a bunch of facts about each packet.
#define PARANOIA

// Align "p" mod "align", assuming "p" is a "void*".
#define ALIGN(p, align) 				\
	do {						\
		(p) += -(long)(p) & ((align) - 1);	\
	} while(0)				 

#define PACKET_SIZE 512

#define VERIFY(VAL, WHAT)                               	\
	do {							\
		long long __val = (VAL);			\
		if (__val < 0)					\
		tmc_task_die("Failure in '%s': %lld: %s.",	\
				(WHAT), __val, gxio_strerror(__val));	\
	} while (0)

static int server = 0;
static bool jumbo;

int main(int argc, char** argv)
{
	char *link_name= "xgbe1";	
	size_t num_packets = 1000;
	int instance;
	int result;	
	for (int i = 1; i < argc; i++){
		char* arg = argv[i];
		if (!strcmp(arg, "--link") && i + 1 < argc) {
			link_name = argv[++i];
		} else if (!strcmp(arg, "-n") && i + 1 < argc) {
			num_packets = atoi(argv[++i]);
		} else if ((!strcmp(arg,"-s")) || (!strcmp(arg,"-l"))) {
			server = 1;
		} else if (!strcmp(arg,"--jumbo")) {
			jumbo = true;
		} else if ((!strcmp(arg,"-c"))) {
			server = 0;
		} else {
			tmc_task_die("Unknown option '%s'.", arg);
		}
	}
	printf("\n finished parsing");	
	if (server) 
		printf("\n link egressing is %s", link_name);
	else	
		printf("\n link ingressing is %s", link_name);

	// Get the instance.
	instance = gxio_mpipe_link_instance(link_name);
	if (instance < 0)  
		tmc_task_die("Link '%s' does not exist.", link_name);

	gxio_mpipe_context_t context_body;
	gxio_mpipe_context_t* const context = &context_body;

	gxio_mpipe_iqueue_t iqueue_body;
	gxio_mpipe_iqueue_t* iqueue = &iqueue_body;

	gxio_mpipe_equeue_t equeue_body;
	gxio_mpipe_equeue_t* const equeue = &equeue_body;

	// Bind to a single cpu.
	cpu_set_t cpus;
	result = tmc_cpus_get_my_affinity(&cpus);
	VERIFY(result, "tmc_cpus_get_my_affinity()");
	result = tmc_cpus_set_my_cpu(tmc_cpus_find_first_cpu(&cpus));
	VERIFY(result, "tmc_cpus_set_my_cpu()");

	// Start the driver.
	result = gxio_mpipe_init(context, instance);
	VERIFY(result, "gxio_mpipe_init()");

	gxio_mpipe_link_t link;
	if (!server) {
		result = gxio_mpipe_link_open(&link, context, link_name, 0);
	} else {
		result = gxio_mpipe_link_open(&link, context, link_name, GXIO_MPIPE_LINK_WAIT );
	}
	VERIFY(result, "gxio_mpipe_link_open()");
	int channel = gxio_mpipe_link_channel(&link);

	//allow the link to receive jumbo packets
	if (jumbo) 
		gxio_mpipe_link_set_attr(&link, GXIO_MPIPE_LINK_RECEIVE_JUMBO, 1);

	// Allocate a NotifRing.
	result = gxio_mpipe_alloc_notif_rings(context, 1, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_notif_rings()");
	int ring = result;

	// Allocate one huge page to hold our buffer stack, notif ring, and group
	tmc_alloc_t alloc = TMC_ALLOC_INIT;
	tmc_alloc_set_huge(&alloc);
	tmc_alloc_set_home(&alloc, tmc_cpus_find_nth_cpu(&cpus, 0)); 
	size_t page_size = tmc_alloc_get_huge_pagesize();
	void* page = tmc_alloc_map(&alloc, page_size);
	assert(page!= NULL);
	void* mem = page;

	// Init the NotifRing.
	size_t notif_ring_entries = 128;
	size_t notif_ring_size = notif_ring_entries * sizeof(gxio_mpipe_idesc_t);
	result = gxio_mpipe_iqueue_init(iqueue, context, ring, mem, notif_ring_size, 0);
	VERIFY(result, "gxio_mpipe_iqueue_init()");
	mem += notif_ring_size;

	// Allocate a NotifGroup.
	result = gxio_mpipe_alloc_notif_groups(context, 1, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_notif_groups()");
	int group = result;

	// Allocate a bucket.
	int num_buckets = 128;
	result = gxio_mpipe_alloc_buckets(context, num_buckets, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_buckets()");
	int bucket = result;

	// Init group and bucket.
	gxio_mpipe_bucket_mode_t mode = GXIO_MPIPE_BUCKET_DYNAMIC_FLOW_AFFINITY;
	result = gxio_mpipe_init_notif_group_and_buckets(context, group, ring, 1,  bucket, num_buckets, mode);
	VERIFY(result, "gxio_mpipe_init_notif_group_and_buckets()");

	// Alloc edma rings
	result = gxio_mpipe_alloc_edma_rings(context, 1, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_edma_rings");
	int edma = result;

	// Init edma ring.
	int edma_ring_entries = 512;
	size_t edma_ring_size = edma_ring_entries * sizeof(gxio_mpipe_edesc_t);
	result = gxio_mpipe_equeue_init(equeue, context, edma, channel, mem, edma_ring_size, 0);
	VERIFY(result, "gxio_mpipe_equeue_init()");
	mem += edma_ring_size;

	// Allocate a buffer stack.
	result = gxio_mpipe_alloc_buffer_stacks(context, 1, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_buffer_stacks()");
	int stack_idx = result;

	// Total number of buffers.
	unsigned int num_buffers = (int)(edma_ring_entries + notif_ring_entries);

	// Initialize the buffer stack.  Must be aligned mod 64K.
	ALIGN(mem, 0x10000);
	size_t stack_bytes = gxio_mpipe_calc_buffer_stack_bytes(num_buffers);	
	gxio_mpipe_buffer_size_enum_t buf_size = GXIO_MPIPE_BUFFER_SIZE_16384;
	result = gxio_mpipe_init_buffer_stack(context, stack_idx, buf_size, mem, stack_bytes, 0);
	VERIFY(result, "gxio_mpipe_init_buffer_stack()");
	mem += stack_bytes;
	ALIGN(mem, 0x10000);

	// Register the entire huge page of memory which contains all the buffers.
	result = gxio_mpipe_register_page(context, stack_idx, page, page_size, 0);
	VERIFY(result, "gxio_mpipe_register_page()");

	// Push some buffers onto the stack.
	for (int i = 0; i < num_buffers; i++) {
		gxio_mpipe_push_buffer(context, stack_idx, mem);
		mem += 16384;
	}

	// Register for packets.
	gxio_mpipe_rules_t rules;
	gxio_mpipe_rules_init(&rules, context);
	gxio_mpipe_rules_begin(&rules, bucket, num_buckets, NULL);
	result = gxio_mpipe_rules_commit(&rules);
	VERIFY(result, "gxio_mpipe_rules_commit()");

	double start, end, exec_time, throughput;
	start = 0.00;		
	uint64_t cpu_speed;
	cpu_speed = tmc_perf_get_cpu_speed();

	/*Server will initiate the egress and ingress the packets and display the round trip time
	 * Client will ingress the packet, copy it to the edesc and egress it
	 */
	if (server) {	
		int send_packets = 0;
		size_t size_e = 0;
		struct timespec req_start, req_end;
		while (send_packets < num_packets) {
			char* buf = gxio_mpipe_pop_buffer(context, stack_idx);
			if(buf == NULL)
				tmc_task_die("Could not allocate initial buffer");
			memset(buf,'+',PACKET_SIZE);
			// Prepare to egress the packet.
			gxio_mpipe_edesc_t edesc = {{
				.bound = 1,
					.xfer_size = PACKET_SIZE,
					.stack_idx = stack_idx,
					.hwb = 1,
					.size = GXIO_MPIPE_BUFFER_SIZE_16384
			}};
			gxio_mpipe_edesc_set_va(&edesc, buf);
			result = gxio_mpipe_equeue_put(equeue, edesc);
			VERIFY(result, "gxio_mpipe_equeue_put()");
			if (send_packets == 0)
				clock_gettime(CLOCK_REALTIME, &req_start);

			gxio_mpipe_idesc_t idesc;
			result = gxio_mpipe_iqueue_get(iqueue,&idesc);
			VERIFY(result, "gxio_mpipe_iqueue_get()");	
			size_e += idesc.l2_size;		
			gxio_mpipe_iqueue_drop(iqueue, &idesc);
			gxio_mpipe_equeue_flush(equeue);
			send_packets++;		
		}	
		clock_gettime(CLOCK_REALTIME, &req_end);
		exec_time = ((req_end.tv_sec - req_start.tv_sec)+(req_end.tv_nsec - req_start.tv_nsec)/1E9);
		fprintf(stdout,"round trip time = %lf\n", exec_time);
		fprintf(stdout,"latency is %f\n", exec_time/(2 * num_packets ));
		fprintf(stdout,"size is %zd b\n", size_e);
		throughput = size_e * 8 * 2 / exec_time;
		fprintf(stdout,"throughput = %f Mbps\n",throughput/pow(1000, 2));
		gxio_mpipe_edesc_t ns = {{ .ns = 1 }};
		result = gxio_mpipe_equeue_put(equeue,ns);
		VERIFY(result, "gxio_mpipe_equeue_put()");
		fprintf(stdout,"completed packets %d\n", send_packets);		
	} else {
		int rcv_packets = 0;	
		while (rcv_packets < num_packets) {
			gxio_mpipe_idesc_t idesc;
			result = gxio_mpipe_iqueue_get(iqueue, &idesc);
			VERIFY(result, "gxio_mpipe_iqueue_get()");

			gxio_mpipe_edesc_t edesc;
			gxio_mpipe_edesc_copy_idesc(&edesc, &idesc);		
			// Egress the packets.
			result = gxio_mpipe_equeue_put(equeue,edesc);
			VERIFY(result, "gxio_mpipe_equeue_put()");	
			rcv_packets++;
			gxio_mpipe_iqueue_drop(iqueue, &idesc);			
			gxio_mpipe_equeue_flush(equeue);
		}
	}
	return 0;
}
