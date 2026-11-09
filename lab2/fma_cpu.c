// fma_cpu.c - the CPU half of ex5: 6 threads, NEON, 8 registers at once.
#include <arm_neon.h>
#include <pthread.h>
#include <time.h>
#define NUM_THREADS 6
static const float M = -1e-4f;
struct Job {
  const float* a;
  float* c;
  int lo, hi, K;
};
static void* worker(void* arg) {
  struct Job* j = (struct Job*)arg;
  const float* a = j->a;
  float* c = j->c;
  float32x4_t m = vdupq_n_f32(M);
  for (int i = j->lo; i < j->hi; i += 32) {
    float32x4_t x0 = vld1q_f32(a + i), x1 = vld1q_f32(a + i + 4);
    float32x4_t x2 = vld1q_f32(a + i + 8), x3 = vld1q_f32(a + i + 12);
    float32x4_t x4 = vld1q_f32(a + i + 16), x5 = vld1q_f32(a + i + 20);
    float32x4_t x6 = vld1q_f32(a + i + 24), x7 = vld1q_f32(a + i + 28);
    for (int k = 0; k < j->K; k++) {
      x0 = vfmaq_f32(x0, x0, m);
      x1 = vfmaq_f32(x1, x1, m);
      x2 = vfmaq_f32(x2, x2, m);
      x3 = vfmaq_f32(x3, x3, m);
      x4 = vfmaq_f32(x4, x4, m);
      x5 = vfmaq_f32(x5, x5, m);
      x6 = vfmaq_f32(x6, x6, m);
      x7 = vfmaq_f32(x7, x7, m);
    }
    vst1q_f32(c + i, x0);
    vst1q_f32(c + i + 4, x1);
    vst1q_f32(c + i + 8, x2);
    vst1q_f32(c + i + 12, x3);
    vst1q_f32(c + i + 16, x4);
    vst1q_f32(c + i + 20, x5);
    vst1q_f32(c + i + 24, x6);
    vst1q_f32(c + i + 28, x7);
  }
  return 0;
}
static double now_ms(void) {
  struct timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  return t.tv_sec * 1e3 + t.tv_nsec * 1e-6;
}
double cpu_ms(const float* a, float* c, int n, int K)  // best of 3 runs
{
  double best = 1e30;
  int chunk = n / NUM_THREADS / 32 * 32;
  for (int rep = 0; rep < 3; rep++) {
    pthread_t th[NUM_THREADS];
    struct Job job[NUM_THREADS];
    double t0 = now_ms();
    for (int t = 0; t < NUM_THREADS; t++) {
      int hi = (t == NUM_THREADS - 1) ? n : (t + 1) * chunk;
      struct Job one = {a, c, t * chunk, hi, K};
      job[t] = one;
      pthread_create(&th[t], 0, worker, &job[t]);
    }
    for (int t = 0; t < NUM_THREADS; t++) pthread_join(th[t], 0);
    double ms = now_ms() - t0;
    if (ms < best) best = ms;
  }
  return best;
}