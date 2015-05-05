# Requires FUSE to be installed for compilation.

CSRCS=  main.c nalla_wrapper.c network.c tsc.c

CC = cc
CFLAGS= -c -O3 -Wall -DLINUX -fPIC\
        -I/usr/local/nallatech/FUSE/redist

COBJS=$(patsubst %.c,%.o,$(CSRCS))

APP=h100bist.exe

all: $(APP) 

$(APP): $(COBJS) 
	$(CC) -o$(APP) $(COBJS) -ldimesdl -ldl -ldimetalk 

$(COBJS): %.o : %.c nalla_wrapper.h
	$(CC) $(CFLAGS) -o $@ $< 

clean:
	rm -f core $(APP) $(COBJS) $(CPPOBJS) *~

depend:
	mkdep $(CFLAGS) $(CSRCS) $(CPPSRCS)

