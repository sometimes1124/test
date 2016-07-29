#include <stdio.h>
#include <stdlib.h>
#define VEC_SIZE 8
#define BLOCK_SIZE 4

__global__ void VecAddKernel(float *, float *, float *);

int main(){
  int i;
  float *A, *B, *C;
  cudaMallocHost((void**)&A ,sizeof(float)*VEC_SIZE);
  cudaMallocHost((void**)&B ,sizeof(float)*VEC_SIZE);
  cudaMallocHost((void**)&C ,sizeof(float)*VEC_SIZE);

  srand((unsigned int)time(NULL));
  for(i = 0; i < VEC_SIZE; i++) {
    A[i] = rand();
    B[i] = rand();
  }

  float *d_A, *d_B, *d_C;
  cudaMalloc((void**)&d_A, sizeof(float)*VEC_SIZE);
  cudaMalloc((void**)&d_B, sizeof(float)*VEC_SIZE);
  cudaMalloc((void**)&d_C, sizeof(float)*VEC_SIZE);

  cudaMemcpy(d_A, A, sizeof(float)*VEC_SIZE, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, sizeof(float)*VEC_SIZE, cudaMemcpyHostToDevice);

  dim3 dimBlock(BLOCK_SIZE, 1);
  dim3 dimGrid(VEC_SIZE/BLOCK_SIZE, 1);
  VecAddKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);

  cudaMemcpy(C, d_C, sizeof(float)*VEC_SIZE, cudaMemcpyDeviceToHost);
  
  for(i = 0; i < VEC_SIZE; i++){
    printf("%.0f + %.0f = %.0f\n", A[i], B[i], C[i]);
  }

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);

  cudaFreeHost(A);
  cudaFreeHost(B);
  cudaFreeHost(C);
}

__global__ void VecAddKernel(float *d_A, float *d_B, float *d_C) {
  
  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  d_C[tid] = d_A[tid] + d_B[tid];
}
