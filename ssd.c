#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define N       64
#define WIDTH 1024
#define HEIGHT 768

int main(){
  int i, j, l, m;
  FILE *fp;

  int size = (WIDTH - N) * (HEIGHT - N);
  int *ref = (int*)malloc(sizeof(int)*N*N);
  int *im  = (int*)malloc(sizeof(int)*size);
  double *dif = (double*)malloc(sizeof(double)*size);
  int max = 0;

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
  
  for(j = 0; j < HEIGHT - N; j++) {
    for(i = 0; i < WIDTH - N; i++) {
      printf("(%d,%d)\n", i,j);
      int tmp = 0;
      int diff = 0;
      for(l = 0; l < N; l++) {
        for(m = 0; m < N; m++) {
          diff = im[(j+m)*WIDTH+i+l] - ref[m*N+l];
          tmp += diff * diff;
        }
      }
      dif[j*WIDTH+i] = tmp;
    }
  }
  for(i = 0; i < size; i++) {
    if(max < dif[i]) {
      max = dif[i];
    }
  }
  
  fp = fopen("out.dat","w");
  for(i = 0; i < size; i++) {
    fprintf(fp, "%d\n", (int)abs(((dif[i]/max)*255)));
  }
  fclose(fp);

  return 0;
}
