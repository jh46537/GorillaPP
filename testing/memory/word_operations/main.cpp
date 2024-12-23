#include "primate-hardware.hpp"

// dummy struct so arch-gen doesn't fall over :P
struct input_t {
  int a;
  int b;
  int c;
  int d;

  int e;
  int f;
  int g;
  int h;
};

struct output_t {
  int a;
  int b;
};

const volatile int sum_buffer[10] = {1,2,4,8,16,32,64,128,256,512};
// const volatile int sum_buffer[10] = {1,2,3,4,5,6,7,8,9,10};
  
void primate_main() {

  PRIMATE::input<input_t>(); // spawn thread and send input to the VOID;

  // do real work here
  int sum = 0;
  for(int i=0; i < 10; i++) {
    sum += sum_buffer[i];
  }
  if(sum > 0)
    PRIMATE::output<output_t>({0, sum});
  else {
    PRIMATE::input<input_t>();
    PRIMATE::output<output_t>({sum, 0});
  }
}
