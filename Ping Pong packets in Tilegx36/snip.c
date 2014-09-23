		struct timespec req_start, req_end;
		while (send_packets < num_packets) {
			char* buf = gxio_mpipe_pop_buffer(context, stack_idx);
			if(buf == NULL)
				tmc_task_die("Could not allocate initial buffer");
			memset(buf,'+',PACKET_SIZE);
			
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
			send_packets++;		
		}	
		clock_gettime(CLOCK_REALTIME, &req_end);
		round_trip_time = ((req_end.tv_sec - req_start.tv_sec)+(req_end.tv_nsec - req_start.tv_nsec))/1E9;
		throughput = size_e * 8 / (round_trip_time/2);

