#include "primate-hardware.hpp"

// dummy struct so arch-gen doesn't fall over :P
struct input_t {
  int a;
};

struct output_t {
  int a;
};

const volatile int sum_buffer[1] = {1};
  
void primate_main() {

  PRIMATE::input<input_t>();
  PRIMATE::output<output_t>({sum_buffer[0]});
}
