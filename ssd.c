#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "gettimeofday_sec.c"
#define  N       64
#define  WIDTH 1024
#define  HEIGHT 768

int main(){
  double t1, t2;
  int i, j, l, m;
  FILE *fp;

  int size = (WIDTH - N) * (HEIGHT - N);
  int *ref = (int*)malloc(sizeof(int)*N*N);
  int *im  = (int*)malloc(sizeof(int)*WIDTH*HEIGHT);
  int *dif = (int*)malloc(sizeof(int)*size);
  int min = 0;

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
  
  t1 = gettimeofday_sec();
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
  t2 = gettimeofday_sec();

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

  free(ref);
  free(im);
  free(dif);

  return 0;
}
