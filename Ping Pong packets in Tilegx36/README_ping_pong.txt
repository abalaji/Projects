Function:
Ping pong the packets between the server and the client.
The server initiates by loading and egressing the packets, the client receives the packet and sends it back to the server.
Once the server receives the packet, it drops it and proceeds to send the next packet.
PACKET_SIZE hardcoded. 
number of packets can be passed as an argument.

Note:
I tested the correctness of the functionality, by loading packets inside the loop after being popped.
Testing proved successful, the contents of idesc and edesc on both server and client side was tested

Issue:
Packet size limited to 10230. Could not figure out why this number. (but, came across gxio_mpipe_set_snf_size(), might work, did not check it though! )

To execute the program:
1. Open two terminal 
2. In one terminal type
	make u0_server
3. In the other terminal type
	make u1_client
