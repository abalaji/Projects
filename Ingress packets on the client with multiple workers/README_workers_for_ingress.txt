Function:
Egress side blasts the packet (Single cpu for egress)
Ingress side consists of multiple workers to receive the packets
PACKET_SIZE hardcoded. 
number of packets can be passed as an argument.

Note:
Testing proved successful, the contents of idesc and edesc on both server and client side was tested

Issue:
Packet size limited to 1664. 
Did not implement jumbo packet functionality here.

To execute the program:
1. Open two terminal 
2. In one terminal type
	make u0_server
3. In the other terminal type
	make u1_client
