// ex5.cu - CPU or GPU? K multiply-adds per element, in a register.

// gcc -O2 -c fma_cpu.c -o fma_cpu.o
// nvcc ex5.cu fma_cpu.o -o ex5 -lpthread
// ./ex5
#include <chrono>
#include <cmath>
#include <cstdio>
const int N = 1 << 22;  // about 4 million elements
const float M = -1e-4f;
__global__ void fmaKernel(int n, int K, float* a, float* c) {
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride) {
    float x = a[i];
    for (int k = 0; k < K; k++)
      x = fmaf(x, M, x);  // x = x * M + x: one multiply-add
    c[i] = x;
  }
}
// In fma_cpu.c: the same work on 6 CPU cores with NEON. Returns ms.
extern "C" double cpu_ms(const float* a, float* c, int n, int K);
int main() {
  float *h_a = new float[N], *h_c = new float[N], *h_g = new float[N];
  float *d_a, *d_c;
  cudaMalloc(&d_a, N * sizeof(float));
  cudaMalloc(&d_c, N * sizeof(float));
  for (int i = 0; i < N; i++) h_a[i] = (i % 1000) * 0.001f;
  cudaMemcpy(d_a, h_a, N * sizeof(float), cudaMemcpyHostToDevice);
  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;
  fmaKernel<<<numBlocks, blockSize>>>(N, 1, d_a, d_c);  // warm-up
  cudaDeviceSynchronize();
  printf("%5s %8s %11s %8s %11s %8s %9s\n", "K", "CPU ms", "CPU GFLOP/s",
         "GPU ms", "GPU GFLOP/s", "GPU/CPU", "max diff");
  for (int K : {1, 4, 16, 64, 256, 1024}) {
    double cpu = cpu_ms(h_a, h_c, N, K);
    double gpu = 1e30;
    for (int rep = 0; rep < 3; rep++) {  // best of 3 runs
      auto t0 = std::chrono::steady_clock::now();
      fmaKernel<<<numBlocks, blockSize>>>(N, K, d_a, d_c);
      cudaDeviceSynchronize();
      auto t1 = std::chrono::steady_clock::now();
      std::chrono::duration<double, std::milli> ms = t1 - t0;
      if (ms.count() < gpu) gpu = ms.count();
    }
    // CPU and GPU must get the same answer
    cudaMemcpy(h_g, d_c, N * sizeof(float), cudaMemcpyDeviceToHost);
    float diff = 0;
    for (int i = 0; i < N; i++) diff = fmax(diff, fabs(h_c[i] - h_g[i]));
    double flops = 2.0 * K * N;  // multiply + add
    printf("%5d %8.2f %11.1f %8.2f %11.1f %8.1f %9.2g\n", K, cpu,
           flops / cpu / 1e6, gpu, flops / gpu / 1e6, cpu / gpu, diff);
  }
  cudaFree(d_a);
  cudaFree(d_c);
  delete[] h_a;
  delete[] h_c;
  delete[] h_g;
  return 0;
}
