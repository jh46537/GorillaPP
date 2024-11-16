#include "primate-hardware.hpp"

struct input_t {
    int a;
    int b;
    int c;
    int d;

    int a1;
    int b1;
    int c1;
    int d1;
};

struct output_t {
    int a;
    int b;
    int c;
};

void primate_main() {
    input_t a = PRIMATE::input<input_t>();
    output_t b = {a.a, a.b, a.a + a.b};
    PRIMATE::output(b);
}
