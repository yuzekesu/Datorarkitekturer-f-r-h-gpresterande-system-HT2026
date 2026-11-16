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

__device__ void helper(uchar4* image, size_t index) {
  const float r = static_cast<float>(image[index].x) * 0.299f;
  const float g = static_cast<float>(image[index].y) * 0.587f;
  const float b = static_cast<float>(image[index].z) * 0.114f;
  const unsigned char gray = static_cast<unsigned char>(r + g + b);

  uchar4& cur = image[index];
  cur.x = cur.y = cur.z = gray;
}

__global__ void rgb2grayKernel(uchar4* image, int width, int height) {
  const int x = threadIdx.x + blockDim.x * blockIdx.x;
  const int y = threadIdx.y + blockDim.y * blockIdx.y;
  if (x >= width || y >= height) return;

  const int index = x + y * width;
  helper(image, index);
}

#ifdef debug
__global__ void rgb2grayKernel_one_dim(uchar4* image, int width, int height) {
  const int anchor = threadIdx.x + blockDim.x * blockIdx.x;
  const int stride = blockDim.x * gridDim.x;

  for (int i = anchor; i < width * height; i += stride) {
    if (i >= height * width) break;
    helper(image, i);
  }
}

__global__ void rgb2grayKernel_two_dim(uchar4* image, int width, int height) {
  const int x = threadIdx.x + blockDim.x * blockIdx.x;
  const int y = threadIdx.y + blockDim.y * blockIdx.y;
  const int stride_x = blockDim.x * gridDim.x;
  const int stride_y = blockDim.y * gridDim.y;

  for (int i = y; i < height; i += stride_y) {
    if (y >= height) break;
    for (int u = x; u < width; u += stride_x) {
      if (x >= width) break;
      const int index = x + y * width;
      helper(image, index);
    }
  }
}

#endif

int main(int argc, char** argv) {
  // create input/output streams
  videoSource* input = videoSource::Create(argc, argv, ARG_POSITION(0));
  videoOutput* output = videoOutput::Create(argc, argv, ARG_POSITION(1));
  if (!input) return 0;
  // capture/display loop
  while (true) {
    uchar4* image = NULL;  // can be uchar3, uchar4, float3, float4
    int status = 0;        // see videoSource::Status
    if (!input->Capture(&image, 1000, &status))  // 1000ms timeout (default)
    {
      if (status == videoSource::TIMEOUT) continue;
      break;  // EOS
    }
    if (output != NULL) {
      // Launch the kernel
      // const dim3 gridsize = 1;
      // const dim3 blocksize = 255;

      const dim3 gridsize = {40, 90};
      const dim3 blocksize = {32, 8};

      // const dim3 gridsize = {80, 45};
      // const dim3 blocksize = {16, 16};

      // const dim3 gridsize = {160, 90};
      // const dim3 blocksize = {8, 8};

      // const dim3 gridsize = {40, 23};
      // const dim3 blocksize = {32, 32};

      rgb2grayKernel<<<gridsize, blocksize>>>(image, input->GetWidth(),
                                              input->GetHeight());
      cudaDeviceSynchronize();

      output->Render(image, input->GetWidth(), input->GetHeight());
      // Update status bar
      char str[256];
      sprintf(str, "Camera Viewer (%ux%u) | %0.1f FPS", input->GetWidth(),
              input->GetHeight(), output->GetFrameRate());
      output->SetStatus(str);
      if (!output->IsStreaming())  // check if the user quit
        break;
    }
  }
}
