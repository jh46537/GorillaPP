#pragma once
#include <stddef.h>

namespace PRIMATE {
    // Add your code here
    template<typename T>
    #pragma primate blue IO 1 1
    T input(size_t size = sizeof(T));

    template<typename T>
    #pragma primate blue IO 1 1
    void output(T out, size_t size = sizeof(T));

    #pragma primate blue IO 1 1
    void input_done();

    #pragma primate blue IO 1 1
    void output_done();
}