/*
=============================================
Author:Anusha Balaji & Lalitha Geddapu
Name:insertion_omp.c
Description: Matrix Transposition in CUDA
=============================================
*/
#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#define ThPBlck 16

__global__ void transpose(float* A,float* At,int rows,int cols)
{
	int c = blockIdx.x * blockDim.x + threadIdx.x;
	int r = blockIdx.y * blockDim.x + threadIdx.y;
	
	if(c < cols && r < rows)
	{
	At[c*rows+r]=A[c+r*cols];
	}
}


//Matrix transpose Host code
int main()
{
	int i,k,q,p,r,rows,cols ;
	float* A;
	float* At;	
	float* A_d;
	float* At_d;
	float elapsedTimeTrans;
	double res_time[60];
	p=0;
	FILE *mtcuda;
	
for(k=1,q=20; k<20,q>0;k++,q--)
{
	rows = pow(2,k);
	cols = pow(2,q);
	
	size_t size = rows*cols* sizeof(float);
	
	A = (float*)malloc(size);
	At = (float*)malloc(size);
	
	cudaMalloc((float**)&A_d,size);
	cudaMalloc((float**)&At_d,size);
	
	/*initialize matrix in host memory*/
	for( i=0; i < rows*cols; i++)
	{
		A[i] = rand() % (rows*cols);
	}
	
	/*copy matrix from Host to device memory*/
	cudaMemcpy(A_d,A,size,cudaMemcpyHostToDevice);
	
	/*calculating size of grid*/
	int grid_rows = (rows + ThPBlck - 1) / ThPBlck;
    int grid_cols = (cols + ThPBlck - 1) / ThPBlck;
 
    dim3 blockSize(ThPBlck, ThPBlck);
	dim3 gridSize(grid_cols, grid_rows);	
	
	/*CUDA timer declarations*/
	cudaEvent_t start_transpose, stop_transpose;
	cudaEventCreate(&start_transpose);
	cudaEventCreate(&stop_transpose);
	
	cudaEventRecord(start_transpose,0); /*start timer*/
	
	for (r = 0; r < 1000; r++)
	{
	transpose<<<gridSize,blockSize>>>(A_d,At_d,rows,cols);
	}
	
	cudaEventRecord(stop_transpose,0); /*stop timer*/
	cudaEventSynchronize(stop_transpose);
	cudaEventElapsedTime(&elapsedTimeTrans, start_transpose,stop_transpose);
	
	/*copy output from device to host memory*/
	cudaMemcpy(At,At_d, size, cudaMemcpyDeviceToHost);
	
	//printf ("\n Time for transpose: %f ms \n", elapsedTimeTrans);
	
	res_time[p]= rows;
	res_time[p+1]=cols;
	res_time[p+2]=elapsedTimeTrans;
	p=p+3;
	
	free(A);
	free(At);
	cudaFree(A_d);
	cudaFree(At_d);
}
	
	mtcuda=fopen("mtcuda.csv","w");
	if(!mtcuda)
	{
		printf("file opening failed");
		fclose(mtcuda);
	}

	/* Calculation Of time */
	for(p=0;p<60;p=p+3)
	{
	fprintf(mtcuda,"m=%f,n=%f,%f \n ",res_time[p],res_time[p+1],res_time[p+2]);
	}
	
	fclose(mtcuda);
	
	
return 0;
}
