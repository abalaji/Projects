/*
=============================================
Author:Anusha Balaji & Lalitha Geddapu
Name:insertion_omp.c
Description: Insertion Sort in CUDA
=============================================
*/
#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#define MAX 32678

void ms(int a[],int l,int m,int h);
void part(int a[],int l,int h);
int checkError(int a[], int c[], int n);

__global__ void insert(int *a, int n)
{
int i = blockIdx.x *n;
int c,d,p,t,size;
size = (blockIdx.x+1)*n;

	for(c=i;c<size;c++)
	{
	d=c;
	while(d>i&&a[d]<a[d-1])
	{
	t=a[d];
	a[d]=a[d-1];
	a[d-1]=t;
	d--;
	}
	}

}	

		
int main()
{
int i,p,k,r;
int num_elem, num_bytes;
int *device_aay, *host_aay, *checkaay;
double res_time[45];
p=0;
FILE *insertcuda;
int block_size;

for(k=1; k<15; k++)
{	
	num_elem=pow(2,k);
	
	//computing the size in bytes
	num_bytes=num_elem * sizeof(int);

	//malloc host_aay
	host_aay=(int*)malloc(num_bytes);
	checkaay=(int*)malloc(num_bytes);

	//cudaMalloc device aay
	cudaMalloc((void**)&device_aay,num_bytes);

		//initialising host aay
		for (i=0;i<num_elem;i++)
		{
			host_aay[i]=rand()%num_elem;
			checkaay[i]=host_aay[i];
		}
		
		block_size=8;
		cudaMemcpy(device_aay,host_aay,num_bytes,cudaMemcpyHostToDevice);
		cudaEvent_t start_insert, stop_insert, start_merge, stop_merge;
		cudaEventCreate(&start_insert);
		cudaEventCreate(&start_merge);
		cudaEventCreate(&stop_insert);
		cudaEventCreate(&stop_merge);
		
		cudaEventRecord(start_insert,0);
		
		for (r = 0; r < 1000; r++)
		{
		insert<<<block_size,1>>>(device_aay,num_elem/block_size);
		}
		
		cudaEventRecord(stop_insert,0);
		cudaEventSynchronize(stop_insert);
		float elapsedTimeInsert;
		cudaEventElapsedTime(&elapsedTimeInsert, start_insert,stop_insert);
		
		cudaMemcpy(host_aay,device_aay,num_bytes,cudaMemcpyDeviceToHost);
		
		cudaEventRecord(start_merge,0);
		
		part(host_aay,0,num_elem-1);
		
		cudaEventRecord(stop_merge,0);
		cudaEventSynchronize(stop_merge);
		float elapsedTimeMerge;
		cudaEventElapsedTime(&elapsedTimeMerge, start_merge,stop_merge);

		part(checkaay,0,num_elem-1);

	/*printf("\n\n");
	
	printf ("Time for the insertion sort: %f ms\n", elapsedTimeInsert);
	printf ("Time for the merge sort: %f ms\n", elapsedTimeMerge);
	
	printf("\n\n");*/
	
	/*missorted = checkError(host_aay,checkaay,num_elem);
    if (missorted != 0) printf("%d missorted nubmers\n",missorted);*/

	res_time[p]= num_elem;
	res_time[p+1]=elapsedTimeInsert;
	res_time[p+2]=elapsedTimeMerge;
	p=p+3;
	
	//deallocate memory
	free(host_aay);
	free(checkaay);
	cudaFree(device_aay);
}

	insertcuda=fopen("insertcuda.csv","w");
	if(!insertcuda)
	{
		printf("file opening failed");
		fclose(insertcuda);
	}

	/* Calculation Of time */
	for(p=0;p<45;p=p+3)
	{
	fprintf(insertcuda,"n=%f,insert=%f,merge=%f \n ",res_time[p],res_time[p+1],res_time[p+2]);
	}
	
	fclose(insertcuda);
	
return 0;
}

void part(int a[],int l,int h){

    int m;

    if(l<h){
         m=(l+h)/2;
         part(a,l,m);
         part(a,m+1,h);
         ms(a,l,m,h);
    }
}

void ms(int a[],int l,int m,int h){

    int i,m,k,l,temp[MAX];

    l=l;
    i=l;
    m=m+1;

    while((l<=m)&&(m<=h)){

         if(a[l]<=a[m]){
             temp[i]=a[l];
             l++;
         }
         else{
             temp[i]=a[m];
             m++;
         }
         i++;
    }

    if(l>m){
         for(k=m;k<=h;k++){
             temp[i]=a[k];
             i++;
         }
    }
    else{
         for(k=l;k<=m;k++){
             temp[i]=a[k];
             i++;
         }
    }
   
    for(k=l;k<=h;k++){
         a[k]=temp[k];
    }
}

int checkError(int a[], int c[], int n) {
    int result = 0;
    for (int i=0; i<n; i++) {
        if (a[i] != c[i]) {
            result++;
        }
    }
    return result;
}
