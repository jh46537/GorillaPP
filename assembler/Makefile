CC=g++
CFLAGS=-std=c++11

.PHONY: primate_assembler clean clean_all

primate_assembler: primate_assembler.cpp
	$(CC) -o $@ $< $(CFLAGS)

clean:
	rm -f primate_assembler

clean_all:
	rm -f primate_assembler *.bin
