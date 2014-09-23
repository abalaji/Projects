/*
===============================================================
Author:Lalitha Geddapu & Anusha Balaji
Name:mt_mkl.c
Description: Matrix Transposition in OpenMP using MKL functions
===============================================================
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <math.h>
#include <omp.h>
#include <mkl.h>

double timerval()
{
struct timeval st;
gettimeofday(&st,NULL);
return st.tv_sec+st.tv_usec*1e-6;
}

/* Main Program */
int main()
{
 double *A, *C, *offset, *D, *At;
 int numelem,m,i,j,k,s,l,q,p,r,keep,stride,avgrows,threads,extra,TID;
 double n,rows,alpha;
 double st,et;
 FILE *mtmkl;

alpha = 1.00;
omp_set_num_threads(4);
threads=4;
double res_time[60];
p=0;
 
for(k=1,q=20; k<20,q>0;k++,q--)
{
	m = pow(2,k);
	n = pow(2,q); 
 
	/*Allocating memory for matrices*/
 
	A =(double*)mkl_malloc(m*n*sizeof(double),64);
	At=(double*)mkl_malloc(m*n*sizeof(double),64);
 
	/*initializing matrix data*/
	for(i=0;i<(m*n);i++)
	{
		A[i]=(double)(i+1);
	}

	offset =(double*)mkl_malloc(threads*sizeof(double),64);

	avgrows = m/threads;
	extra = m%threads;

	for(i=0;i<threads;i++)
	{
		offset[i] = i<extra ? (avgrows+1)*n : (avgrows)*n;
	}
	
	st=dsecnd();
	for(r=0; r<10; r++)
	{
		#pragma omp parallel for private(j,k,q,s,keep,stride,numelem,TID,C,D,rows)  
		for(i=0;i<threads;i++)
		{
			C =(double*)mkl_malloc(m*n*sizeof(double),64);
			D =(double*)mkl_malloc(m*n*sizeof(double),64);
			stride = 0;
			TID=omp_get_thread_num(); 
			numelem = TID<extra ? (avgrows+1)*n : (avgrows)*n;
			rows = TID<extra ? (avgrows+1) : (avgrows);
			
			for(k=0;k<TID;k++)
			{
				stride+=offset[k];
			}
		   
		   for(j=0;j< numelem ;j++)
			{
				C[j] = A[j+stride];	
			}
			
			mkl_domatcopy('r','t',rows,n,alpha,C,n,D,rows);
			
			for(s=0;s<n;s++)
			{
			 keep=s*(m-rows);
			 for(q=0;q< rows ;q++)
				{
					At[keep+s*(int)rows+q+(stride/(int)n)]=D[s*(int)rows+q];
				}
			}	
		mkl_free(C);
		mkl_free(D);
		}
	}
	et=dsecnd();
	
	res_time[p]= m;
	res_time[p+1]=n;
	res_time[p+2]=et-st;
	p=p+3;
}

mtmkl=fopen("mtmkl.csv","w");

/* Calculation Of time */
for(p=0;p<60;p=p+3)
{
fprintf(mtmkl,"%f,%f,%f \n ",res_time[p],res_time[p+1],res_time[p+2]);
}

	/*printf("Matrix Transpose At: \n");
	for(j=0;j<m*n;j++)
	{
	printf("%f ",At[j]);
	}*/
 
 /*deallocating memory*/
 mkl_free(A);
 mkl_free(offset);
 mkl_free(At);
 fclose(mtmkl);
 return 0;

}

