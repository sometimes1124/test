#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>
#include"util.c"

//プロトタイプ宣言
__global__ void matrixProductKernel(float *, float *, float *, int);
void matrixProduct(float *, float *, float *, int);

/**
   n次正方行列の積を計算
   CPU実装とGPU実装それぞれの実行時間を測定

   引数(デフォルト)
   [1]: 正方行列の次数(32)
   [2]: ブロックの次数(16)
   [3]: 各方式の試行回数(3)
 */
int main(int argc, char **argv){
  int i;

  //パラメータ設定
  int n = 32;         //正方行列の次数
  int blockSize = 16; //ブロックの次数
  int n_trial = 3;    //試行回数
  switch(argc){
  case 4: sscanf(argv[3], "%d", &n_trial);
  case 3: sscanf(argv[2], "%d", &blockSize);
  case 2: sscanf(argv[1], "%d", &n);
  case 1: break;
  default:
    fprintf(stderr, "usage:\n[1]n (32)\n[2]block_size (16)\n[3]n_trial (3)\n");
    exit(1);
  }
  int size = n*n;

  //ホストメモリの確保
  float *A = (float *)malloc(sizeof(float) * size); 
  float *B = (float *)malloc(sizeof(float) * size); 
  float *C = (float *)malloc(sizeof(float) * size); 

  //行列データ格納(乱数)
  srand((unsigned) time(NULL));
  for(i = 0; i < n*n; i++){
    A[i] = rand();
    B[i] = rand();
  }

  //デバイスメモリの確保
  float *d_A, *d_B, *d_C;
  cudaMalloc((void **)&d_A, sizeof(float) * size);
  cudaMalloc((void **)&d_B, sizeof(float) * size);
  cudaMalloc((void **)&d_C, sizeof(float) * size);
  
  //ホストからデバイスへデータ転送
  cudaMemcpy(d_A, A, sizeof(float) * size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, sizeof(float) * size, cudaMemcpyHostToDevice);

  //CPU実装の実行時間測定
  double tmp = 0.0;
  double c_tb, c_te;
  printf("(n: %d, bsize: %d, trial: %d)\n", n, blockSize, n_trial);
  for(i = 0; i < n_trial; i++){
    c_tb = gettimeofday_sec();
    matrixProduct(A, B, C, n);
    c_te = gettimeofday_sec();
    tmp += c_te - c_tb;
    printf(".");
  }
  printf("CPU_time = %.3le\n", tmp/n_trial);

  //GPU実装の実行時間測定
  dim3 dimBlock(blockSize, blockSize);
  dim3 dimGrid(n/blockSize, n/blockSize);
  double g_tb, g_te;
  tmp = 0.0;
  for(i = 0; i < n_trial; i++){
    g_tb = gettimeofday_sec();
    matrixProductKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, n);
    cudaThreadSynchronize();
    g_te = gettimeofday_sec();
    tmp += g_te - g_tb;
    printf(".");
  }
  printf("GPU_time = %.3le\n", tmp/n_trial);

  //デバイスからホストへデータ転送
  cudaMemcpy(C, d_C, sizeof(float) * size, cudaMemcpyDeviceToHost);

  //メモリ解放
  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);
  free(A);
  free(B);
  free(C);
}

//正方行列の積(GPU)
__global__ void matrixProductKernel(float *d_A, float *d_B, float *d_C, int n){
  int i;

  int tidx = blockIdx.x * blockDim.x + threadIdx.x;
  int tidy = blockIdx.y * blockDim.y + threadIdx.y;

  d_C[tidy*n+tidx] = 0.0;
  for(i = 0; i < n; i++){
      d_C[tidy*n+tidx] += d_A[tidy*n+i] * d_B[i*n+tidx];
  }
 
}

//正方行列の積(CPU)
void matrixProduct(float *d_A, float *d_B, float *d_C, int n){
  int i, x, y, yn, ynx;

  for(y = 0; y < n; y++){
    yn = y*n;
    for(x = 0; x < n; x++){
      ynx = yn + x;
      d_C[ynx] = 0.0;
      for(i = 0; i < n; i++){
        d_C[ynx] += d_A[yn+i] * d_B[i*n+x];
      }
    }
  }

}
