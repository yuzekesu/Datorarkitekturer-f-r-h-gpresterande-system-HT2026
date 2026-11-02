#include <arm_neon.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_THREADS 64  // the most threads the program can start
struct work {           // everything one thread needs
  float *a, *b, *r;     // start of this thread's part
  int count;            // number of elements in the part
  int reps;             // number of passes
};

void helper_mult_vect(float* a, float* b, float* r, int num) {
  float32x4_t va, vb, vr;
  int managed = 0;
  for (int i = 0; i < num; i += 4, managed += 4) {
    va = vld1q_f32(&a[i]);
    vb = vld1q_f32(&b[i]);
    vr = vmulq_f32(va, vb);
    vst1q_f32(&r[i], vr);
  }
  // handle rest.
  for (int i = managed; i < num; i++) {
    r[i] = a[i] * b[i];
  }
}

void* worker(void* arg) {
  struct work* w = (struct work*)arg;
  // TODO: repeat w->reps times: mult_std(w->a, w->b, w->r, w->count);
  // logic.
  for (int i = 0; i < w->reps; ++i)
    helper_mult_vect(w->a, w->b, w->r, w->count);
  pthread_exit(NULL);
  return NULL;
}

int main(int argc, char* argv[]) {
  // in main: read the settings from the command line, as in multiply.c
  int nthreads = (argc > 1) ? atoi(argv[1]) : 6;     // number of threads
  int num = (argc > 2) ? atoi(argv[2]) : 100000000;  // array length
  int reps = (argc > 3) ? atoi(argv[3]) : 1;         // passes
  // ... allocate and fill a, b and r as in multiply.c ...

  float* a = (float*)aligned_alloc(16, num * sizeof(float));
  float* b = (float*)aligned_alloc(16, num * sizeof(float));
  float* r = (float*)aligned_alloc(16, num * sizeof(float));

  pthread_t th[MAX_THREADS];
  struct work w[MAX_THREADS];  // one struct per thread: never pass &t
  int part = num / nthreads;
  int remainder = num % nthreads;
  int offset = 0;

  struct timespec ts_start;
  struct timespec ts_end;
  /*
   */
  clock_gettime(CLOCK_MONOTONIC, &ts_start);
  for (int t = 0; t < nthreads; ++t) {
    int count = part + (t < remainder ? 1 : 0);

    w[t].a = a + offset;
    w[t].b = b + offset;
    w[t].r = r + offset;
    w[t].count = count;
    w[t].reps = reps;

    int rc = pthread_create(&th[t], NULL, worker, &w[t]);
    if (rc != 0) {
      fprintf(stderr, "pthread_create failed: %d\n", rc);
      return EXIT_FAILURE;
    }

    offset += count;
  }

  // TODO: pthread_join all threads, THEN take the end time
  for (int t = 0; t < nthreads; ++t) {
    pthread_join(th[t], NULL);
  }
  clock_gettime(CLOCK_MONOTONIC, &ts_end_1);
  /*
   */
  printf("Success terminate, duration: %fs\n",
         (ts_end.tv_sec - ts_start.tv_sec) +
             (ts_end.tv_nsec - ts_start.tv_nsec) * 1e-9);
  return 0;
}