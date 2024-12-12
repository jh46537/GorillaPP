#pragma once

#ifndef PRIMATE_HOST_SIM

namespace PRIMATE {
    using size_t = decltype(sizeof(char));

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

#else

#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <sstream> 

namespace PRIMATE {

    inline std::vector<char> IO_BUFFER; 
    inline bool IO_INITED = false;
    inline size_t IO_BUFFER_INDEX = 0;

    // not in the std lib????
    inline int _hex_char_to_int( char ch ) {
        switch (ch) {
            // NOTE: Non standard extension to c++
            case '0' ... '9': return ch - '0'; 
            case 'A' ... 'F': return ch - 'A' + 10;
            case 'a' ... 'f': return ch - 'a' + 10;
        }
        std::cerr << "Error: invalid hex character (probably in input.txt)\n";
        std::exit(-1);
    }

    inline void _IO_INIT() {
        std::ifstream infile;
        infile.open("input.txt");
        if (!infile.is_open()) {
            std::cerr << "Error: could not open input.txt\n";
            exit(-1);
        }

        std::cout << "[IO INIT]: File open\n";
        std::string line;
        while (std::getline(infile, line)) {
            std::cout << "line: " << line << "\n";
            // split the line based on spaces
            std::istringstream iss(line);
            int is_term;
            int has_data;
            std::string payload;
            if(!(iss >> is_term >> has_data >> payload)) {
                std::cerr << "Error: could not parse input.txt\n";
                exit(-1);
            }

            // first number is if the packet is a terminator
            // second number is the "fullness" of the packet
            // third number is the payload
            if (has_data == 1) {
                // endianess is a thing
                for (int i = payload.size()-1; i >= 0 ; i-=2) {
                    char bot_nib = _hex_char_to_int(payload[i]);
                    char top_nib = _hex_char_to_int(payload[i-1]);
                    IO_BUFFER.push_back((top_nib << 4) | bot_nib);
                }
            }
        }
        IO_INITED = true;
    }

    using size_t = decltype(sizeof(char));
    
    template<typename T>
    inline T input(size_t size=sizeof(T)) {
        T ret; 
        std::cout << "[IO]: Reading " << size << " bytes\n";

        std::vector<char> side_buffer;
        for(int i = IO_BUFFER_INDEX; i < IO_BUFFER_INDEX + size; i++) {
            side_buffer.push_back(IO_BUFFER[i]);
        }
        IO_BUFFER_INDEX += size;

        // !!! MEM HACK: copy raw bytes into the struct !!!
        char* raw_bytes = (char*)&ret;
        for(int i = 0; i < size; i++) {
            raw_bytes[i] = side_buffer[i];
        }

        return ret;
    }

    template<typename T>
    inline void output(T out, size_t size=sizeof(T)) {
        std::cout << "[IO]: Writing " << size << " bytes\n";

        // write the struct to the file output.txt
        std::ofstream outfile("output.txt", std::ios::app);

        // !!! MEM HACK: print raw bytes. !!!
        char* raw_bytes = (char*)&out;
        // endianess is a thing
        outfile << std::hex;
        for(int i = size-1; i >= 0; i--) {
            outfile << (int)(raw_bytes[i] >> 4);
            outfile << (int)(raw_bytes[i] & 0xf);
        }
        outfile << std::dec;

        outfile.close();
    }

    // idfk what this is supposed to do
    inline void input_done() {

    }

    // idfk what this is supposed to do
    inline void output_done() {

    }
}


#endif