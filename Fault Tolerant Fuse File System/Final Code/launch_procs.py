#!/usr/bin/env python
import sys, os
from sys import argv, exit
import time

def launch_simpleht(port_id):
    args = ['xterm', '-e', 'python' , 'simpleht.py', '--port=%s' % port_id]
    os.execvp('xterm', args)

if __name__ == '__main__':
    if len(argv) < 2:
        print( "usage: python launch_procs.py <num_server>")
        sys.exit(1)
    starting_port_id1 = 8000
    starting_port_id2 = 7000
    starting_port_id3 = 9000
    sid = []
    sid.append(starting_port_id1)
    sid.append(starting_port_id2)
    sid.append(starting_port_id3)
    num_servers = int(argv[1])
    print num_servers
    for s in sid:	
	for num in range(num_servers):
		pid = os.fork()
		if pid == 0:
             		if num < num_servers:
               			launch_simpleht(s + num)
    	   		break
