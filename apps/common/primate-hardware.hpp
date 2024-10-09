#pragma once

namespace PRIMATE {
    // Add your code here
    template<typename T>
    #pragma primate blue IO 1 1
    __attribute__((always_inline)) T input() {
      return *((T*)__primate_input(sizeof(T)));
    }

    template<typename T>
    #pragma primate blue IO 1 1
    __attribute__((always_inline)) void output(T out) {
      __primate_output((const void*)&out, sizeof(T));
    }

    #pragma primate blue IO 1 1
    __attribute__((always_inline)) void input_done() {
      __primate_input_done();
    }

    #pragma primate blue IO 1 1
    __attribute__((always_inline)) void output_done() {
      __primate_output_done();
    }
}
