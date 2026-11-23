/*
 * check if the camera is detacted.
 * $ v4l2-ctl --list-devices
 */

/*
 * captures an image into a buffer and then views this buffer in a window.
 * $ nvcc ex1.cu -o ex1 -ljetson-utils
 * $ ./ex1 /dev/video0
 */

#include <jetson-utils/videoOutput.h>
#include <jetson-utils/videoSource.h>
#include <stdio.h>

#define hist_t int

__global__ void plotHistogramKernel(uchar4* image, hist_t* histogram, int width,
                                    int height, int max_freq) {
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  uchar4 white_pixel = make_uchar4(255, 255, 255, 255);
  // uchar4 black_pixel = make_uchar4(0, 0, 0, 255);

  if (index < 256) {
    int freq = histogram[index] * 256 / max_freq;
    for (int i = 0; i < 256; i++) {
      int row = height - i - 1;
      uchar4 black_pixel = image[row * width + 2 * index];
      black_pixel.x /= 2;
      black_pixel.y /= 2;
      black_pixel.z /= 2;
      if (i <= freq) {
        image[row * width + 2 * index] = white_pixel;
        image[row * width + 2 * index + 1] = white_pixel;
      } else {
        image[row * width + 2 * index] = black_pixel;
        image[row * width + 2 * index + 1] = black_pixel;
      }
    }
  }
}

__global__ void calcHistogramKernel(uchar4* gray, hist_t* array, int width,
                                    int height) {
  __shared__ hist_t histo_local[256];
  const int x = threadIdx.x + blockDim.x * blockIdx.x;
  const int y = threadIdx.y + blockDim.y * blockIdx.y;
  if (x >= width || y >= height) return;

  const int index = x + y * width;
  const int gray_value = gray[index].x;

  // let the first 256 threads to clear to the global array.
  if (index < 256) {
    histo_local[index] = 0;
  }
  __syncthreads();

  // atomicAdd(array + gray_value, 1);
  // ++array[gray_value];
  // histo_local[gray_value] += 1;
  atomicAdd(histo_local + gray_value, 1);
  __syncthreads();

  // let the first 256 threads to write to the global array.
  if (index < 256) {
    array[index] = histo_local[index];
  }
}

__device__ void helper(uchar4* image, uchar4* grayscaled, size_t index) {
  const float r = static_cast<float>(image[index].x) * 0.299f;
  const float g = static_cast<float>(image[index].y) * 0.587f;
  const float b = static_cast<float>(image[index].z) * 0.114f;
  const unsigned char gray = static_cast<unsigned char>(r + g + b);

  uchar4& cur = grayscaled[index];
  cur.x = cur.y = cur.z = gray;

  // alpha here.
  cur.w = 128;
}

__global__ void rgb2grayKernel(uchar4* image, uchar4* grayscaled, int width,
                               int height) {
  const int x = threadIdx.x + blockDim.x * blockIdx.x;
  const int y = threadIdx.y + blockDim.y * blockIdx.y;
  if (x >= width || y >= height) return;

  const int index = x + y * width;
  helper(image, grayscaled, index);
}

int main(int argc, char** argv) {
  uchar4 *grayscaled = new uchar4[1280 * 720], *grayscaled_gpu;
  cudaHostAlloc(&grayscaled, 1280 * 720 * sizeof(uchar4), cudaHostAllocMapped);
  cudaHostGetDevicePointer(&grayscaled_gpu, grayscaled, 0);

  // create input/output streams
  videoSource* input = videoSource::Create(argc, argv, ARG_POSITION(0));
  // videoOutput* output = videoOutput::Create(argc, argv, ARG_POSITION(1));
  videoOutput* output_gray = videoOutput::Create("display://0");
  if (!input) return 0;

  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  // lab4 initialize:
  hist_t *array = new hist_t[256], *g_array;
  // cudaHostAlloc(&array, 256 * sizeof(hist_t), cudaHostAllocMapped);
  // cudaHostGetDevicePointer(&g_array, array, 0);
  cudaMalloc(&g_array, 256 * sizeof(hist_t));

  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////

  // capture/display loop
  while (true) {
    uchar4* image = NULL;  // can be uchar3, uchar4, float3, float4
    int status = 0;        // see videoSource::Status
    if (!input->Capture(&image, 1000, &status))  // 1000ms timeout (default)
    {
      if (status == videoSource::TIMEOUT) continue;
      break;  // EOS
    }
    if (output_gray != NULL) {
      // Launch the kernel
      {
        const dim3 gridsize = {40, 90};
        const dim3 blocksize = {32, 8};
        rgb2grayKernel<<<gridsize, blocksize>>>(
            image, grayscaled_gpu, input->GetWidth(), input->GetHeight());
        cudaDeviceSynchronize();
      }

      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////
      // lab4 here:
      cudaMemset((void*)g_array, 0, 256 * sizeof(hist_t));
      {
        const dim3 gridsize = {40, 90};
        const dim3 blocksize = {32, 8};
        calcHistogramKernel<<<gridsize, blocksize>>>(
            grayscaled_gpu, g_array, input->GetWidth(), input->GetHeight());
        cudaDeviceSynchronize();
        cudaMemcpy(array, g_array, 256 * sizeof(hist_t),
                   cudaMemcpyDeviceToHost);
      }

      // print result.
      char str[256];
      int sum = 0;
      for (int i = 0; i < 256; ++i) {
        sum += array[i];
      }
      sprintf(str, "%d", sum);
      output_gray->SetStatus(str);

      // graph:
      {
        plotHistogramKernel<<<256, 1>>>(grayscaled_gpu, g_array,
                                        input->GetWidth(), input->GetHeight(),
                                        20000);
      }
      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////

      // output->Render(image, input->GetWidth(), input->GetHeight());
      output_gray->Render(grayscaled_gpu, input->GetWidth(),
                          input->GetHeight());
      // Update status bar
      if (!output_gray->IsStreaming())  // check if the
                                        // user quit
        break;
    }
  }
  cudaFreeHost(grayscaled);
  cudaFreeHost(g_array);
}
