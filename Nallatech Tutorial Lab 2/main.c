
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
#define BRAM1 1
#define BRAM2 2
#define BRAM3 3

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

    int N=10;
    int *dat1,*dat2,*dat3;
    int i;
   
   
    dat1 = malloc( N * sizeof(int) );
    dat2 = malloc( N * sizeof(int) );
    dat3 = malloc( N * sizeof(int) );

  
    for(i=0; i < N; i++) {
  
       dat1[i]=i+1;
       dat2[i]=i+11;
    }

    /* 
       Remarks: FPGA_write and FPGA_read take a DWORD pointer. A DWORD
       on delta is 64 bits. However, for some unknown reason, the API
       only transfers 32 bits instead of 64. Therefore, the easiest
       solution is to use integer pointers (which are 32 bits on this machine)
       and then cast the integer pointer to a DWORD pointer. NORMALLY,
       THIS WOULD BE A VERY BAD IDEA, but it is a useful workaround for the
       API. You can alternatively leave out the cast, but doing so will
       result in a bunch of warnings.
     
       Parameters:
       dat1: pointer to the data to write to the FPGA
       N: the number of 32 bit words to transfer
       0: the starting address to write to
       BRAM1: the id of the node in the FPGA you are writing to
       1000: timeout in milliseconds
    */
	
	FPGA_write( (DWORD*) dat1, N, 0, BRAM1, 1000 );

    
    FPGA_write( (DWORD*) dat2, N, 0, BRAM2, 1000 );
    
    

    for (i=0; i < 10; i++){ 
		FPGA_read( (DWORD*) dat1, 1, i, BRAM1, 1000 );		
		printf("%d\n",(int) dat1[i]);
		FPGA_read( (DWORD*) dat2, 1, i, BRAM2, 1000 );
		printf("%d\n",(int) dat2[i]);
		dat3[i] = dat1[i]*dat2[i]; 
		FPGA_write( (DWORD*) dat3, 1, i, BRAM3, 1000 );}


    
 

    for(i=0; i<10; i++) { 
	FPGA_read( (DWORD*) dat3, 1, i, BRAM3, 1000 );
	printf("%d\n",(int) dat3[i]); }
  
 
  

    //#########################################################################
    //CLEANUP
    //#########################################################################
    
    //free(ibuf);
    //free(obuf);
    FPGA_release();
    return 0;
}