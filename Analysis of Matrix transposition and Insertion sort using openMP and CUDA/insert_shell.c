/*
=============================================
Author:Anusha Balaji & Lalitha Geddapu
Name:insertion_omp.c
Description: Insertion Sort in OpenMP
=============================================
*/

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <omp.h>
#include <math.h>

double timerval()
{
struct timeval st;
gettimeofday(&st,NULL);
return st.tv_sec+st.tv_usec*1e-6;
}

void insertion(int array[], int n, int offset) { int j;
    for (j=offset; j<n; j+=offset) {
        int k = array[j];
        int i = j - offset;
        while (i >= 0 && array[i] > k) {
            array[i+offset] = array[i];
            i-=offset;
        }
        array[i+offset] = k;
    }
}

void merge(int array[], int n)
{
     int i, m;

    for(m = n/2; m > 0; m /= 2)
    {
            #pragma omp parallel for shared(array,m,n) private (i) default(none) num_threads(4)
            for(i = 0; i < m; i++)
                insertion(&(array[i]), n-i, m);
    }
}

int main() 
{
    int n;
    int *array;
    int i,j,k,p;
    double st,et;
    FILE *insertomp;

double res_time[40];
p=0;
    
for(j=0;j<20;j++)
{
  n=pow(2,j);
  

    array = (int *)malloc(n*sizeof(int));
    for (i=0; i<n; i++)
        array[i] = i;

    for (i=0; i<n; i++) {
        int num1 = rand() % n;
        int num2 = rand() % n;
        int t = array[num1];
        array[num1] = array[num2];
        array[num2] = t;
    }

st=timerval();
for(k=0;k<1000;k++)
{
    merge(array,n);
}
et=timerval();

res_time[p]=n;
res_time[p+1] = et-st;
p=p+2;
}

insertomp= fopen("insertomp.txt","w+");
for(j=0;j<40;j=j+2)
{
fprintf(insertomp,"\n n=%f time=%f seconds ",res_time[j],res_time[j+1]);
}
/* Freeing Allocated Memory */
free(array);
fclose(insertomp);

return 0;
}
