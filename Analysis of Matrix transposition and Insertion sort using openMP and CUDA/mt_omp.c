/*
=============================================
Author:Lalitha Geddapu & Anusha Balaji
Name:mt_omp_ifelse.c
Description: Matrix Transposition in OpenMP
=============================================
*/

#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>

double timerval()
{
struct timeval st;
gettimeofday(&st,NULL);
return st.tv_sec+st.tv_usec*1e-6;
}
/* Main Program */

int main()
{
int m, n, i, j, k,q,r,p;
int **Matrix, **transpose;
double st,et;
FILE *mtompifelse;

omp_set_num_threads(4);
double res_time[60];
p=0;

for(k=1,q=20; k<20,q>0;k++,q--)
{
m = pow(2,k);
n = pow(2,q);

/* Matrix Elements */

Matrix = (int **) malloc(sizeof(*(Matrix)) * m);
for (i = 0; i < m; i++) {
Matrix[i] = (int *) malloc(sizeof(*(Matrix[i])) * n);
for (j = 0; j < n; j++)
Matrix[i][j] = rand()%100;
}

/* Dynamic Memory Allocation */

transpose = (int **) malloc(sizeof(*(transpose)) * n);

/* Initializing The Output Matrices Elements As Zero */

for (i = 0; i < n; i++) 
{
transpose[i] = (int *) malloc(sizeof(*(transpose[i])) * m);
for (j = 0; j < m; j++) 
{
transpose[i][j] = 0;
}
}

st=timerval();
for(r=0; r<100; r++){
/*parallel region*/
if(m>=n)
{
#pragma omp parallel for private(j) 
for (i = 0; i < m; i = i + 1)
for (j = 0; j < n; j = j + 1)
transpose[j][i] = Matrix[i][j];
}
else(m<n)
{
#pragma omp parallel for private(i)
for (j = 0; j < n; j = j + 1) 
for (i = 0; i < m; i = i + 1)
transpose[j][i] = Matrix[i][j];
}
}
et=timerval();

res_time[p]= m;
res_time[p+1]=n;
res_time[p+2]=et-st;
p=p+3;

}


mtompifelse=fopen("mtompifelse.csv","w+");

/* Calculation Of time */
for(p=0;p<60;p=p+3)
{
fprintf(mtompifelse,"\n %f,%f,%f \n ",res_time[p],res_time[p+1],res_time[p+2]);
}

/* Freeing Allocated Memory */

for (i=0; i<m; i++){
free(Matrix[i]);}
free(Matrix);

for (j=0; j<n; j++){
free(transpose[j]);}
free(transpose);

fclose(mtompifelse);

return 0;
}
