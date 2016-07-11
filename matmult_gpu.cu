#define MAT_SIZE 32 

__global__ void MatrixMult(float *, float *, float *);

int main(){
  float *A, *B, *C;
  cudaMallocHost((void**)&A ,sizeof(float)*MAT_SIZE*MAT_SIZE);
  cudaMallocHost((void**)&B ,sizeof(float)*MAT_SIZE*MAT_SIZE);
  cudaMallocHost((void**)&C ,sizeof(float)*MAT_SIZE*MAT_SIZE);

  float *d_A, *d_B, *d_C;
  cudaMalloc((void**)&d_A, sizeof(float)*MAT_SIZE*MAT_SIZE);
  cudaMalloc((void**)&d_B, sizeof(float)*MAT_SIZE*MAT_SIZE);
  cudaMalloc((void**)&d_C, sizeof(float)*MAT_SIZE*MAT_SIZE);

  cudaMemcpy(d_A, A, sizeof(float)*MAT_SIZE*MAT_SIZE, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, sizeof(float)*MAT_SIZE*MAT_SIZE, cudaMemcpyHostToDevice);

  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid(MAT_SIZE/4, MAT_SIZE/4);
  MatrixMult<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);

  cudaMemcpy(C, d_C, sizeof(float)*MAT_SIZE*MAT_SIZE, cudaMemcpyDeviceToHost);

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);

  cudaFreeHost(A);
  cudaFreeHost(B);
  cudaFreeHost(C);
}

__global__ void MatrixMult(float *d_A, float *d_B, float *d_C) {
  int i;

  unsigned int row_idx = blockDim.x * blockIdx.x + threadIdx.x;
  unsigned int col_idx = blockDim.y * blockIdx.y * threadIdx.y;


  for(i = 0, i < MAT_SIZE; i++) {
     

}
