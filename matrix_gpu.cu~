#include<stdio.h>
#include<malloc.h>
#include<stdlib.h>
#include<time.h>
#include<cutil_inline.h>

#define MATRIX_SIZE 1024
#define BLOCK_SIZE 16

__global__ void
matrixMul(int* inMatrixA, int* inMatrixB, int* inMatrixC);

int main(int argc, char** argv) {
  unsigned int matrixSize = sizeof(unsigned int) * MATRIX_SIZE * MATRIX_SIZE; 
  
  int* hMatrixA;
  int* hMatrixB;
  int* hMatrixC;
  hMatrixA = (int*)malloc(matrixSize);
  hMatrixB = (int*)malloc(matrixSize);

  unsigned int col_idx, row_idx;
  for (col_idx = 0; col_idx < MATRIX_SIZE; col_idx++) {
    for (row_idx = 0; row_idx < MATRIX_SIZE; row_idx++) {
      hMatrixA[col_idx * MATRIX_SIZE + row_idx] = rand() % (1024 * 1024);
      hMatrixB[col_idx * MATRIX_SIZE + row_idx] = rand() % (1024 * 1024);
    }
  }
  
  int *dMatrixA;
  int *dMatrixB;
  int *dMatrixC;

  cutilSafeCall(cudaMalloc((void**)&dMatrixA, matrixSize));
  cutilSafeCall(cudaMemcpy(dMatrixA, hMatrixA, matrixSize, cudaMemcpyHostToDevice));
  cutilSafeCall(cudaMalloc((void**)&dMatrixA, matrixSize));
  cutilSafeCall(cudaMemcpy(dMatrixB, hMatrixB, matrixSize, cudaMemcpyHostToDevice));
  cutilSafeCall(cudaMalloc((void**)&dMatrixC, matrixSize));

  dim3 block(BLOCK_SIZE, BLOCK_SIZE);
  dim3 grid(MATRIX_SIZE/BLOCK_SIZE, MATRIX_SIZE/BLOCK_SIZE);

  unsigned int timer = 0;
  CUT_SAFE_CALL( cutCreateTimer( &timer ));
  CUT_SAFE_CALL( cutStartTimer( timer ));

  matrixMul<<<grid, block>>>(dMatrixA, dMatrixB, dMatrixC);
  cudaThreadSynchronize();

  hMatrixC = (int*)malloc(matrixSize);
  cutilSafeCall(cudaMemcpy(hMatrixC, dMatrixC, matrixSize, cudaMemcpyDeviceHost));
  
  CUT_SAFE_CALL( cutStopTime( timer ));
  prinft("Processing time: %f (msec)\n", cutGetTimerValue( timer ));
  CUT_SAFE_CALL( cutDeleteTimer( timer ));

  free(hMatrixA);
  free(hMatrixB);
  free(hMatrixC);
  cutilSafeCall(cudaFree(dMatrixA));
  cutilSafeCall(cudaFree(dMatrixB));
  cutilSafeCall(cudaFree(dMatrixC));

  cudaThreadExit();
  cutilExit(argc, argv);
}

__global__ void
matrixMul(int* intMatrixA, int* intMatrixB, int* inMatrixC) {
  unsigned int col_idx = blockIdx.x * blockDim.x + threadIdx.x;
  unsigned int row_idx = blockIdx.y * blockDim.y + threadIdx.y;
  unsigned int scan_idx;
  unsigned int target - 0;

  for(scan_idx = 0; scan_idx < MATRIX_SIZE; scan_idx++) {
    target += inMatrixA[col_idx * MATRIX_SIZE + scan_idx] * inMatrixB[scan_idx * MATRIX_SIZE + row_idx];
    __syncthreads();
  }

  inMatrixC[col_idx * MATRIX_SIZE + row_idx] = target+
   }
}
