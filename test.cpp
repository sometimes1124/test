#include<iostream>
#include<vector>

__global__
void vecadd(float *a, float *b, float *c, int num)
{
  c[threadIdx.x] = a[threadIdx.x] + b[threadIdx.x];
}


int main(int argc, char *argv[])
{
  const int num = 16;
  std::vector<float> a(num, 1);
  std::vector<float> b(num, 2);
  std::vector<float> c(num, 0);
  
  float *d_a;
  float *d_b;
  float *d_c;

  cudaMalloc(&d_a, num * sizeof(float));
  cudaMalloc(&d_b, num * sizeof(float));
  cudaMalloc(&d_c, num * sizeof(float));

  cudaMemcpy(d_a, &a[0], num*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_a, &b[0], num*sizeof(float), cudaMemcpyHostToDevice);

  
  cudaMemcpy(&c[0], d_c, num*sizeof(float), cudaMemcpyDeviceToHost);
  
  for(int i=0; i < num; ++i) std::cout << c[i]  << std::endl;
  
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);
  
  

  return 0;
}
