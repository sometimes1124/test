#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#define VEC_SIZE 10
#define BLOCK_SIZE 16

double gettimeofday_sec();

__global__ void VecAddKernel(float *, float *, float *);

int main(){
  double t1, t2;
  float *A, *B, *C;
  cudaMallocHost((void**)&A ,sizeof(float)*VEC_SIZE);
  cudaMallocHost((void**)&B ,sizeof(float)*VEC_SIZE);
  cudaMallocHost((void**)&C ,sizeof(float)*VEC_SIZE);

  float *d_A, *d_B, *d_C;
  cudaMalloc((void**)&d_A, sizeof(float)*VEC_SIZE);
  cudaMalloc((void**)&d_B, sizeof(float)*VEC_SIZE);
  cudaMalloc((void**)&d_C, sizeof(float)*VEC_SIZE);

  cudaMemcpy(d_A, A, sizeof(float)*VEC_SIZE, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, sizeof(float)*VEC_SIZE, cudaMemcpyHostToDevice);

  dim3 dimBlock(BLOCK_SIZE, 1);
  dim3 dimGrid(VEC_SIZE/BLOCK_SIZE, 1);
  VecAddKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);
  
  t1 = gettimeofday_sec();
  cudaMemcpy(C, d_C, sizeof(float)*VEC_SIZE, cudaMemcpyDeviceToHost);
  t2 = gettimeofday_sec();
  
  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);

  cudaFreeHost(A);
  cudaFreeHost(B);
  cudaFreeHost(C);
  printf("Run Time: %f[s]", t2 - t1);
}

__global__ void VecAddKernel(float *d_A, float *d_B, float *d_C) {
  
  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  d_C[tid] = d_A[tid] + d_B[tid];
}

double gettimeofday_sec(){
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec + (double)tv.tv_usec*1e-6;
}
