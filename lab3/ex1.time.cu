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

#include <chrono>
#include <iostream>
#include <numeric>
#include <ratio>
#include <vector>

void helper(uchar4* image, size_t index) {
  const float r = static_cast<float>(image[index].x) * 0.299f;
  const float g = static_cast<float>(image[index].y) * 0.587f;
  const float b = static_cast<float>(image[index].z) * 0.114f;
  const unsigned char gray = static_cast<unsigned char>(r + g + b);

  uchar4& cur = image[index];
  cur.x = cur.y = cur.z = gray;
}

int main(int argc, char** argv) {
  std::vector<float> result{};

  // create input/output streams
  videoSource* input = videoSource::Create(argc, argv, ARG_POSITION(0));
  videoOutput* output = videoOutput::Create(argc, argv, ARG_POSITION(1));
  if (!input) return 0;
  // capture/display loop
  while (true) {
    // uchar3* image = NULL;  // can be uchar3, uchar4, float3, float4
    uchar4* image = NULL;  // can be uchar3, uchar4, float3, float4
    int status = 0;        // see videoSource::Status
    if (!input->Capture(&image, 1000, &status))  // 1000ms timeout (default)
    {
      if (status == videoSource::TIMEOUT) continue;
      break;  // EOS
    }

    auto start = std::chrono::steady_clock::now();
    for (int i = 0; i < input->GetWidth() * input->GetHeight(); ++i)
      helper(image, i);
    auto duration = std::chrono::steady_clock::now() - start;
    // result.push_back(std::chrono::duration<float,
    // std::nano>(duration).count());
    std::cout << std::chrono::duration<float, std::nano>(duration).count()
              << '\n';

    if (output != NULL) {
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
  // auto f_acc = [](float a, float b) { return (a + b) / 2; };
  // std::cout << std::accumulate(result.begin(), result.end(), f_acc);
  return 0;
}
