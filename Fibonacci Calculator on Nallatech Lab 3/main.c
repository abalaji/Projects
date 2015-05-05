
//------------------------------------------------------------------------------
//                                                                            --
//     USE OF SOFTWARE. This software contains elements of software code      --
//     which is the property of Nallatech Limited (the "Nallatech Software"). --
//     Use of the Nallatech Software by you is permitted only if you hold a   --
//     valid license from Nallatech Limited or a valid sub-license from a     --
//     licensee of Nallatech Limited. Use of such software shall be governed  --
//     by the terms of such license or sub-license agreement.                 --
//                                                                            --
//     This Nallatech Software is protected by copyright law, patent law and  --
//     international treaties. Unauthorized reproduction or distribution of   --
//     this software, or any portion of it, may result in severe civil and    --
//     criminal penalties, and will be prosecuted to the maximum extent       --
//     possible under law.                                                    --
//                                                                            --
//     (c) Copyright 2001 - 2005 Nallatech Limited.                           --
//     All rights reserved.                                                   --
//                                                                            --
//------------------------------------------------------------------------------
//
// DIMEtalk Project : D:\gdrivetemp\H100DIMEtalkTesting\newtests\BasicEdgeClockBramTest\BasicEdgeClockBramTest.dt3
//
// Filename : D:\gdrivetemp\H100DIMEtalkTesting\newtests\BasicEdgeClockBramTest\ExampleC\example.c
//
// Creator : DIMEtalk V3.1
//
// Created : 09/10/2006 12:00:30
//
// Requires import libraries and headers.
// dimesdl.lib imports dimesdl functions from dimesdl.dll
// dimetalk.lib imports dimetalk functions from dimetalk.dll
// dimesdl.h contains prototypes for FUSE API functions.
// dimetalk.h contains prototypes for DIMETalk API functions.
// All of these files can both be found in the FUSE\include directory

#include <stdio.h>
#include <time.h>
#include "nalla_wrapper.h"
#include "tsc.h"


// NODE NUMBERS
#define GO_ADDR 0
#define N_ADDR 1
#define RESULT_ADDR 2
#define DONE_ADDR 3
#define MEMORY_MAP_ID 1

double timerval()
{
    struct timeval st;
    gettimeofday(&st,NULL);
    return st.tv_sec + st.tv_usec*1e-6;
}

int main(int argc, char* argv[])
{

    //#########################################################################
    //USER PARAMETERS
    //#########################################################################
    char *myfile = "h101_pcixm_0.bit";
    double CLKA = 150.0;
    double CLKB = 150.0;
    double CLKC = 150.0;

    //#########################################################################
    //NALLATECH FUNCTIONS (WRAPPED)
    //#########################################################################
    FPGA_init(CLKA, CLKB, CLKC);
    FPGA_config(myfile);

    //#########################################################################
    //USER CODE BEGINS HERE
    //#########################################################################

   
    int x,y;
    	//int x,y,z;
	
	int z;
	int i;
	
    int a=1;
	
int *temp=&y;
//int *temp1= &z;
int q[30];
q[1]=1;
q[2]=1;
for(i=1;i<31;i++)
{
x=i;
a=1;
q[i+2]=q[i]+q[i+1];
FPGA_write( &x, 1, N_ADDR, MEMORY_MAP_ID,1000);
FPGA_write( &a, 1, GO_ADDR, MEMORY_MAP_ID,1000);
FPGA_read( (DWORD*) temp, 1, N_ADDR, MEMORY_MAP_ID,1000);

FPGA_read(&z,1,RESULT_ADDR, MEMORY_MAP_ID,1000);


printf("%d: ",y);
printf("HW = %d,",z);
printf(" SW = %d\n",q[i]);

a=0;
FPGA_write( &a, 1, GO_ADDR, MEMORY_MAP_ID,1000);

}



    //#########################################################################
    //CLEANUP
    //#########################################################################
    
    //free(ibuf);
    //free(obuf);
    FPGA_release();
    return 0;
}
