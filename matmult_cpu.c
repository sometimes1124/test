#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include "gettimeofday_sec.c"
void MatMult(float *,float *, float *);
int MAT_SIZE;

int main(int argc, char *argv[]) {
  
  MAT_SIZE = atoi(argv[1]);
  int iter = atoi(argv[2]);
  int i;
  int size = sizeof(float)*MAT_SIZE*MAT_SIZE;
  double t1, t2;
  float *A, *B, *C;
  A = (void*)malloc(size);
  B = (void*)malloc(size);
  C = (void*)malloc(size);

  srand((unsigned) time(NULL));
  for(i = 0; i < MAT_SIZE * MAT_SIZE; i++) {
    A[i] = rand();
    B[i] = rand();
  }
  t1 = gettimeofday_sec();
  for(i = 0; i < iter; i++) {
    MatMult(A, B, C);
  }
  t2 = gettimeofday_sec();
  free(A);
  free(B);
  free(C);
  printf("Run Time: %.3le[s]", (t2 - t1)/iter);
  return 0;
};

void MatMult(float *A, float *B, float *C) {
  int i, j;

  for(i = 0;i < MAT_SIZE; i++) {
    for(j = 0; j < MAT_SIZE; j++) {
      C[i*MAT_SIZE+j] += A[i*MAT_SIZE+j] * B[j*MAT_SIZE+i];
    }
  }
}
