#include "primate-hardware.hpp"

int buffer[] = {1,2,3,4,5,6,7,8,9,10};

void primate_main() {
  volatile int a;
  for(int i = 0; i < 10; i++) {
    a += buffer[i];
  }
}
