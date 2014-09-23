//Ingress from ingress
//Author: Anusha Balaji
//Edits based on the Tilegx documentation
//
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
#include <pthread.h>
#include <tmc/cpus.h>
#include <tmc/mem.h>
#include <tmc/spin.h>
#include <tmc/sync.h>
#include <tmc/task.h>
#include <tmc/perf.h>

#define PACKET_SIZE 256

// Define this to verify a bunch of facts about each packet.
#define PARANOIA
// Align "p" mod "align", assuming "p" is a "void*".
#define ALIGN(p, align) 			\
	do { 					\
		(p) += -(long)(p) & ((align) - 1);\
	} while(0)			

		
#define VERIFY(VAL, WHAT)                                       \
  do {                                                          \
    long long __val = (VAL);                                    \
    if (__val < 0)                                              \
      tmc_task_die("Failure in '%s': %lld: %s.",                \
                   (WHAT), __val, gxio_strerror(__val));        \
  } while (0)

static tmc_sync_barrier_t barrier;
static int num_workers;
static gxio_mpipe_iqueue_t** iqueues;
static	cpu_set_t cpus;
size_t num_packets = 1000;
static int server = 0;

static gxio_mpipe_equeue_t equeue_body;
static gxio_mpipe_equeue_t* const equeue = &equeue_body;

static void egress_loop(gxio_mpipe_context_t* context, int stack_idx, size_t num_packets)
{
	size_t slot = 0;
	size_t i = 0;
	while (num_packets < 0 || slot < num_packets) {
		unsigned char* buf = gxio_mpipe_pop_buffer(context, stack_idx);
		memset(buf, '+', PACKET_SIZE);
		uint16_t size = PACKET_SIZE;
		// Prepare to egress the packet.
		gxio_mpipe_edesc_t edesc = {{
				.bound = 1,
				.xfer_size = size,
				.va = (long)buf,
				.stack_idx = stack_idx,
				.hwb= 1,
				.size = GXIO_MPIPE_BUFFER_SIZE_1664
		}};
		
		// Reserve slots in batches of 128 (for efficiency).  This will
		// block, since we blast faster than the hardware can egress.
		if ((slot & (128 - 1)) == 0)
			gxio_mpipe_equeue_reserve(equeue, 128);

		gxio_mpipe_equeue_put_at(equeue, edesc,slot++);
	}
	gxio_mpipe_equeue_flush(equeue);	
	fprintf(stdout,"egress done\n");
	return NULL;
}


static void* main_aux(void* arg)
{	
	int handled = 0;
	int result;
	int rank = (long)arg;
	fprintf(stdout,"rank is %d\n", rank);
	//bind to a single cpu
	result = tmc_cpus_set_my_cpu(tmc_cpus_find_nth_cpu(&cpus, rank));
	VERIFY(result, "tmc_cpus_set_my_cpu()");
	tmc_sync_barrier_wait(&barrier);
	double size;
	gxio_mpipe_iqueue_t* iqueue = iqueues[rank];
	while (handled < (num_packets/num_workers)) {
		gxio_mpipe_idesc_t idesc;
		result = gxio_mpipe_iqueue_get(iqueue, &idesc);
		VERIFY(result, "gxio_mpipe_iqueue_get()");	
		size += idesc.l2_size;
		gxio_mpipe_iqueue_drop(iqueue, &idesc);
		handled++;
	}
	tmc_sync_barrier_wait(&barrier);	
	fprintf(stdout,"rank %d handled %d\n", rank, handled);	
	tmc_sync_barrier_wait(&barrier);
	return (void*)NULL;
}	

int main(int argc, char** argv)
{
	char* link_name;	
	int instance;
	int result;
	int link_flags = GXIO_MPIPE_LINK_WAIT;
	
	// Parse args.
	for (int i = 1; i < argc; i++) {
		char* arg = argv[i];

		if (!strcmp(arg, "--link") && i + 1 < argc) {
			link_name = argv[++i];
		} else if (!strcmp(arg, "-n") && i + 1 < argc) {
			num_packets = atoi(argv[++i]);
		} else if (!strcmp(arg, "-w") && i + 1 < argc) { 
			num_workers = atoi(argv[++i]);
		} else if(!strcmp(arg,"-s")) {
			server = 1;
		} else {
		tmc_task_die("Unknown option '%s'.", arg);
		}
	}	
	
	printf("\n finished parsing args");
	
	gxio_mpipe_context_t context_body;
	gxio_mpipe_context_t* const context = &context_body;	

	// Bind to a single cpu.
	result = tmc_cpus_get_my_affinity(&cpus);
	VERIFY(result, "tmc_cpus_get_my_affinity()");
	result = tmc_cpus_set_my_cpu(tmc_cpus_find_first_cpu(&cpus));
	VERIFY(result, "tmc_cpus_set_my_cpu()");

	//check if sufficient cpus are there
	if(tmc_cpus_count(&cpus) < num_workers)
		tmc_task_die("insufficient cpus");
			
	// Get	 the instance.
	instance = gxio_mpipe_link_instance(link_name);
	if (instance < 0)
		tmc_task_die("Link '%s' does not exist.", link_name);
	
	// Start the driver.
	result = gxio_mpipe_init(context, instance);
	VERIFY(result, "gxio_mpipe_init()");
	
	gxio_mpipe_link_t link;
	if (!server)
		result = gxio_mpipe_link_open(&link, context, link_name, 0);
	else
		result = gxio_mpipe_link_open(&link, context, link_name, link_flags);
	VERIFY(result, "gxio_mpipe_link_open()");
	int channel = gxio_mpipe_link_channel(&link);	
	printf("\n channel is %d", channel);

	if(server)
		printf("\n link egressing is %s", link_name);
	else	
		printf("\ link ingressing is %s", link_name);
	
	//Allocating some iqueues;
	iqueues = calloc(num_workers, sizeof(*iqueues));
	if(iqueues == NULL)
		tmc_task_die("\n failure in calloc");
		
	// Allocate a NotifRing.
	result = gxio_mpipe_alloc_notif_rings(context, num_workers, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_notif_rings()");
	int ring = result;

	// Init the NotifRing.
	size_t notif_ring_entries = 512;
	size_t notif_ring_size = notif_ring_entries * sizeof(gxio_mpipe_idesc_t);
	size_t needed = notif_ring_size + sizeof(gxio_mpipe_iqueue_t);
	for (int i = 0; i < num_workers; i++) {
		tmc_alloc_t alloc = TMC_ALLOC_INIT;
		tmc_alloc_set_home(&alloc, tmc_cpus_find_nth_cpu(&cpus, i));
		tmc_alloc_set_pagesize(&alloc, notif_ring_size);
		void* iqueue_mem = tmc_alloc_map(&alloc, needed);
		if(iqueue_mem == NULL)
			tmc_task_die("\n failure in tmc_alloc_map()");
		gxio_mpipe_iqueue_t* iqueue = iqueue_mem + notif_ring_size;
		result = gxio_mpipe_iqueue_init(iqueue, context, ring + i, iqueue_mem, notif_ring_size, 0);
		VERIFY(result, "gxio_mpipe_iqueue_init()");
		iqueues[i] = iqueue;
	}

	//page declarations
	tmc_alloc_t alloc = TMC_ALLOC_INIT;
	size_t page_size = tmc_alloc_get_huge_pagesize();
	tmc_alloc_set_huge(&alloc);
	void* page = tmc_alloc_map(&alloc, page_size);
	void* mem = page;

	// Allocate a NotifGroup.
	result = gxio_mpipe_alloc_notif_groups(context, num_workers, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_notif_groups()");
	int group = result;

	// Allocate a bucket.
	int num_buckets = 1;
	result = gxio_mpipe_alloc_buckets(context, num_buckets, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_buckets()");
	int bucket = result;
	
	// Init group and bucket.
	gxio_mpipe_bucket_mode_t mode = GXIO_MPIPE_BUCKET_ROUND_ROBIN;
	result = gxio_mpipe_init_notif_group_and_buckets(context, group, ring, num_workers, bucket, num_buckets, mode);
	VERIFY(result, "gxio_mpipe_init_notif_group_and_buckets()");
	
	// alloc our edma ring.
	result = gxio_mpipe_alloc_edma_rings(context, 1, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_edma_rings");
	uint edma = result;

	//init edma 
	unsigned int equeue_entries = 2048;
	size_t edma_ring_size = equeue_entries * sizeof(gxio_mpipe_edesc_t);
	result = gxio_mpipe_equeue_init(equeue, context, edma, channel, mem, edma_ring_size, 0);
	VERIFY(result, "gxio_mpipe_equeue_init()");
	mem += edma_ring_size;

	// Allocate a buffer stack.
	result = gxio_mpipe_alloc_buffer_stacks(context, 1, 0, 0);
	VERIFY(result, "gxio_mpipe_alloc_buffer_stacks()");
	int stack_idx = result;

	// Total number of buffers.
	unsigned int num_buffers = notif_ring_entries * num_workers + equeue_entries;
	
	// Initialize the buffer stack.  Must be aligned mod 64K.
	ALIGN(mem, 0x10000);
	size_t stack_bytes = gxio_mpipe_calc_buffer_stack_bytes(num_buffers);
	gxio_mpipe_buffer_size_enum_t buf_size = GXIO_MPIPE_BUFFER_SIZE_1664;
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
		mem += 1664;
	}
	
	// Register for packets.
	gxio_mpipe_rules_t rules;
	gxio_mpipe_rules_init(&rules, context);
	gxio_mpipe_rules_begin(&rules, bucket, num_buckets, NULL);
	result = gxio_mpipe_rules_commit(&rules);
	VERIFY(result, "gxio_mpipe_rules_commit()");
	

	tmc_sync_barrier_init(&barrier, num_workers);
	
	/* Server does the work for loading and egressing the packets.
	 * Client does the ingress of packets. There may be multiple workers on the client side to
	 * receive the packets in the mode we want ( round robin, dynamic flow affinity)
	 */
	if (server) {
		egress_loop(context, stack_idx, num_packets);
	} else if (num_workers > 1) {
		pthread_t threads[num_workers];
		for (int i = 0; i < num_workers ; i++) {
			printf("\n thread creation %d", i);
			if(pthread_create(&threads[i], NULL, main_aux, (void*)(intptr_t)i)!= 0)
					tmc_task_die("\n failure in pthread_create()");
		}
		for (int i = 0; i < num_workers ; i++) {
			if(pthread_join(threads[i],NULL) != 0)
				tmc_task_die("\n failure in joining threads");
		}
	} else {
		(void)main_aux((void*)(intptr_t)0);
	}
	

return 0;	
}
