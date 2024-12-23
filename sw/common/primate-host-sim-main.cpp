/////////////////////////////////////////////////////////////////
/// File: primate-host-sim-main.cpp
/// 
/// This hosts the main function for running a primate program 
/// on the host machine. Currently its just a main stub, but 
/// init code would go here. 
/// 
/////////////////////////////////////////////////////////////////
#include "primate-hardware.hpp"
void primate_main();

int main(int argc, char** argv) {
    #ifndef PRIMATE_HOST_SIM
    static_assert(false, "This file should only be included in the host simulation build"); 
    #endif

    PRIMATE::_IO_INIT();
    primate_main();
    return 0;
}