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

__global__ void rgb2grayKernel(uchar4* image, int width, int height) {
  const int x = threadidx.x + blockDim.x * blockIdx.x;
  const int y = threadidx.y + blockDim.y * blockidx.y;
  if (x >= width || y >= height) return;

  const float r = static_cast<float>(image[index].x) * 0.299f;
  const float g = static_cast<float>(image[index].y) * 0.587f;
  const float b = static_cast<float>(image[index].z) * 0.114f;
  const unsigned char gray = static_cast<unsigned char>(r + g + b);
  const int index = x + y * width;
  uchar4& cur = image[index];
  cur.x = cur.y = cur.z = gray;
}

int main(int argc, char** argv) {
  // create input/output streams
  videoSource* input = videoSource::Create(argc, argv, ARG_POSITION(0));
  videoOutput* output = videoOutput::Create(argc, argv, ARG_POSITION(1));
  if (!input) return 0;
  // capture/display loop
  while (true) {
    uchar3* image = NULL;  // can be uchar3, uchar4, float3, float4
    int status = 0;        // see videoSource::Status
    if (!input->Capture(&image, 1000, &status))  // 1000ms timeout (default)
    {
      if (status == videoSource::TIMEOUT) continue;
      break;  // EOS
    }
    if (output != NULL) {
      // Launch the kernel
      int blockSize = 256;
      int numBlocks = (N + blockSize - 1) / blockSize;
      multKernel<<<numBlocks, blockSize>>>(N, d_a, d_b, d_c);
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
