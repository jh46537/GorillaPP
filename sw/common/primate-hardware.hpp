#pragma once

namespace PRIMATE {
    using size_t = decltype(sizeof(char));
    // Add your code here
    template<typename T>
    #pragma primate blue IO input 1 1
    T input(size_t size=sizeof(T));

    template<typename T>
    #pragma primate blue IO output 1 1
    void output(T out, size_t size=sizeof(T));

    #pragma primate blue IO input_done 1 1
    void input_done();

    #pragma primate blue IO output_done 1 1
    void output_done();
}
