#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "gettimeofday_sec.c"
#define  N       64
#define  WIDTH 1024
#define  HEIGHT 768
#define  BLOCK_SIZE 32

__global__ void ssd(int *, int *, int *);

int main(){
  double t1, t2;
  int i, j, l, m;
  FILE *fp;

  int size = (WIDTH - N) * (HEIGHT - N);
  int *ref = (int*)malloc(sizeof(int)*N*N);
  int *im  = (int*)malloc(sizeof(int)*WIDTH*HEIGHT);
  int *dif = (int*)malloc(sizeof(int)*size);
  int min = 0;
  
  int *d_im, *d_ref, *d_dif;

  fp = fopen("template.dat","r");
  for(i = 0; i < N * N; i++) {
    fscanf(fp, "%d", &ref[i]);
  }
  fclose(fp);
  fp = fopen("image.dat","r");
  for(i = 0; i < size; i++) {
    fscanf(fp, "%d", &im[i]);
  }
  fclose(fp);

  cudaMalloc((void**)&d_im, WIDTH*HEIGHT);
  cudaMalloc((void**)&d_ref, N*N);
  cudaMalloc((void**)&d_dif, size);

  cudaMemcpy(d_im, im, WIDTH*HEIGHT, cudaMemcpyHostToDevice);
  cudaMemcpy(d_ref, ref, N*N, cudaMemcpyHostToDevice);

  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid((WIDTH-N)/BLOCK_SIZE, (HEIGHT-N)/BLOCK_SIZE);
  t1 = gettimeofday_sec();
  ssd <<<dimGrid, dimBlock>>>(d_im, d_ref, d_dif);
  t2 = gettimeofday_sec();
  cudaMemcpy(dif, d_dif, size, cudaMemcpyDeviceToHost);

  for(i = 0; i < HEIGHT - N; i++) {
    for(j = 0; j < WIDTH - N; j++) {
      int tmp = 0;
      int diff = 0;
      for(l = 0; l < N; l++) {
        for(m = 0; m < N; m++) {
          diff = im[(i+m)*WIDTH+j+l] - ref[m*N+l];
          tmp += diff * diff;
        }
      }
      //printf("%d\n", i*(WIDTH-N)+j);
      dif[i*(WIDTH-N)+j] = tmp;
    }
  }

  for(i = 0; i < size; i++) {
    if(dif[min] > dif[i]) {
      min = i;
    }
  }
  printf("x = %d, y = %d\n", min % (WIDTH - HEIGHT),
         min / (WIDTH - HEIGHT));

  printf("Run Time: %.3le[s]", t2 - t1);

  fp = fopen("tmpout.dat","w");
  for(i = 0; i < size; i++) {
    fprintf(fp, "%d\n", dif[i]);
  }
  fclose(fp);

  free(dif);
  free(im);
  free(ref);
  cudaFree(d_dif);
  cudaFree(d_ref);
  cudaFree(d_im);

  return 0;
}

__global__ void ssd(int *d_im, int *d_ref, int *d_dif) {
  int i = blockIdx.y * blockDim.y + threadIdx.y;
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int l, m, diff, tmp;
  for(l = 0; l < N; l++) {
    for(m = 0; m < N; m++) {
      diff = d_im[(i+m)*WIDTH+j+l] - d_ref[m*N+l];
      tmp += diff * diff;
    }
  }
  d_dif[i*(WIDTH - N)+j] = tmp;
}

