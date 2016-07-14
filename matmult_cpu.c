#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#define MAT_SIZE 1024

void MatMult(float *,float *, float *);
double gettimeofday_sec();

int main() {
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
  MatMult(A, B, C);
  t2 = gettimeofday_sec();
  free(A);
  free(B);
  free(C);
  printf("Run Time: %f[s]", t2 - t1);
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

double gettimeofday_sec(){
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec + (double)tv.tv_usec*1e-6;
}
