#ifndef __NALLA_WRAPPER_
#define __NALLA_WRAPPER_

#include <dimesdl.h> 
#include <dimetalk.h>
#include "network.h" 

/* Function Prototypes */
int DPRINT(FILE* logfile, char* Message);

int FPGA_release();
int FPGA_config(char *ffile);
int FPGA_reset2();
int FPGA_reset();
int FPGA_gethandle();
int FPGA_setclocks(double CLKA, double CLKB, double CLKC);

/* Useful Functions */
void FPGA_init(double a, double b, double c);
void FPGA_write(DWORD *az, int size, int addr, int node, int timeout);
void FPGA_read(DWORD *az, int size, int addr, int node, int timeout);

#endif
