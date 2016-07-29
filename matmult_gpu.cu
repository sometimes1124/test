#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include "gettimeofday_sec.c"

__global__ void MatMultKernel(float *, float *, int , float *);


int main(int argc, char *argv[]){
  int MAT_SIZE = atoi(argv[1]);
  int iter = atoi(argv[2]);
  int BLOCK_SIZE = atoi(argv[3]);
  int i;
  int size = sizeof(float)*MAT_SIZE*MAT_SIZE;
  double t1, t2;
  float *A, *B, *C;
  cudaMallocHost((void**)&A ,size);
  cudaMallocHost((void**)&B ,size);
  cudaMallocHost((void**)&C ,size);
  
  srand((unsigned) time(NULL));
  for(i = 0; i < MAT_SIZE * MAT_SIZE; i++){
    A[i] = rand();
    B[i] = rand();
  }
  
  float *d_A, *d_B, *d_C;
  cudaMalloc((void**)&d_A, size);
  cudaMalloc((void**)&d_B, size);
  cudaMalloc((void**)&d_C, size);

  cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid(MAT_SIZE/BLOCK_SIZE, MAT_SIZE/BLOCK_SIZE);
  t1 = gettimeofday_sec();
  for(i = 0; i < iter; i++){
    MatMultKernel<<<dimGrid, dimBlock>>>(d_A, d_B, MAT_SIZE, d_C);
  }
  t2 = gettimeofday_sec();

  cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);

  cudaFreeHost(A);
  cudaFreeHost(B);
  cudaFreeHost(C);
  printf("Run Time: %.3le[s]", (t2 - t1)/iter);
}

__global__ void MatMultKernel(float *d_A, float *d_B, int MAT_SIZE,float *d_C) {
  int i;
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  int idy = blockIdx.y * blockDim.y + threadIdx.y;

  d_C[idy*MAT_SIZE+idy] = 0.0;
  for(i = 0; i < MAT_SIZE; i++) {
    d_C[idy*MAT_SIZE+idx] = d_A[idy*MAT_SIZE+i] * d_B[i*MAT_SIZE+idx];
  }
}
