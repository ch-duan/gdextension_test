#include <iostream>
#include <string>
#include <thread>

#include "dll_project.h"

void cb(char* projectId, char* stepId, char* result) {
  std::cout << "ProgressCallback: " << projectId << ", " << stepId << ", " << result << std::endl;
}

int main() {
  std::cout << "Hello World!" << std::endl;

  while (1) {
    const char* projectFilePath = "../test_file/s1891.xml";

    Execute((char*) projectFilePath, (char*) "", 1, cb);
    std::this_thread::sleep_for(std::chrono::milliseconds(10000));
  }
  return 0;
}