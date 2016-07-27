#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#define  WIDTH 1024
#define  HEIGHT 768

int main() {
  int i, j, m, n;
  FILE *fp;

  int *im = (int*)malloc(sizeof(int)*WIDTH*HEIGHT);
  int *out = (int*)malloc(sizeof(int)*WIDTH*HEIGHT);

  fp = fopen("photo.dat", "r");
  for(i = 0; i < HEIGHT * WIDTH; i++) {
    fscanf(fp, "%d", &im[i]);
  }
  fclose(fp);

  //Filtering
  const int w = 3;
  const int sigma1 = 30;
  const int sigma2 = 30;

  for(i = 0; i < WIDTH; i++) {
    for(j = 0; j < HEIGHT; j++) { 
      float num = 0;
      float denom = 0;
      for(m = -w; m <= w; m++) {
        for(n = -w; n <= w; n++) { 
          if(j + n < 0 || j + n >= HEIGHT|| 
             i + m < 0 || i + m >= WIDTH)
            continue;
          float t = im[WIDTH*j + i] - im[WIDTH*(j + n) + (i + m)];
          float s = exp(-(m * m + n * n)/(2 * sigma1 * sigma1)) *
            exp(-(t * t)/(2 * sigma2 * sigma2));
          num += im[WIDTH*(j + n) + (i + m)] * s;
          denom += s;
        }
      }
      //if(denom == 0)
      // denom = 1;
      out[WIDTH*j+i] = num / denom;
    }
  }

  fp = fopen("out.dat", "w");
  for(i = 0; i < HEIGHT * WIDTH; i++) {
    fprintf(fp, "%d\n", out[i]);
  }
  fclose(fp);

  free(im);
  free(out);

  return 0;
}
