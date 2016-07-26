#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "gettimeofday_sec.c"
#define  WIDTH 1024
#define  HEIGHT 768
#define  BLOCK_SIZE 32

__global__ void bailateral(int*, int*);

int main() { 
  double t1, t2;
  int i;
  int size = sizeof(int)*WIDTH*HEIGHT;
  FILE *fp;

  int *d_im, *d_out;

  //cudaMallocHost((void**)&im,  size);
  //cudaMallocHost((void**)&out, size);
  int *im = (int*)malloc(size);
  int *out = (int*)malloc(size);


  fp = fopen("photo.dat", "r");
  for(i = 0; i < HEIGHT * WIDTH; i++) {
    fscanf(fp, "%d", &im[i]);
    }
  fclose(fp);

  cudaMalloc((void**)&d_im,  size);
  cudaMalloc((void**)&d_out, size);

  cudaMemcpy(d_im, im, size, cudaMemcpyHostToDevice);

  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid(WIDTH/BLOCK_SIZE, HEIGHT/BLOCK_SIZE);
  t1 = gettimeofday_sec();
  bailateral<<<dimGrid, dimBlock>>>(d_im, d_out);
  t2 = gettimeofday_sec();

  cudaMemcpy(out, d_out, size, cudaMemcpyDeviceToHost);
  cudaFree(d_im);
  cudaFree(d_out);

  fp = fopen("out.dat", "w");
  for(i = 0; i < HEIGHT*WIDTH; i++) {
    fprintf(fp, "%d\n", out[i]);
    }
  fclose(fp);

  free(im);
  free(out);
  
  printf("Run Time: %f[s]", t2 - t1);

  return 0;
}


__global__ void bailateral(int *d_im, int *d_out) {
  
  int m, n;
  
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  int j = blockIdx.y*blockDim.y + threadIdx.y;

  const int w = 3;
  const int sigma1 = 30;
  const int sigma2 = 30;

  float num = 0;
  float denom = 0;
  for(m = -w; m <= w; m++) {
    for(n = -w; n <= w; n++) {
      if(j + n < 0 || j + n >= HEIGHT || 
         i + m < 0 || i + m >= WIDTH)
        continue;
      float t = d_im[WIDTH*j + i] - d_im[WIDTH*(j + n) + (i + m)];
      float s = expf(-(m * m + n * n) / (2 * sigma1 * sigma1)) * 
        expf(-(t * t) / (2 * sigma2 * sigma2));
      num += d_im[WIDTH*(j + n) + (i + m)] * s;
      denom += s;
    }
  }
  if(denom == 0)
    denom = 1;
  d_out[WIDTH*j+i] = num / denom;
 }





