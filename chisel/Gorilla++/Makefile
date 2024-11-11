
waves:
	make -C ./emulator verilator

clean-all: clean-test clean-hw

clean-test:

clean-hw:
# delete all generated files, and all test outputs
	rm primate_pgm.bin memInit.txt input.txt || true
	rm ./src/main/scala/*.scala              || true

.PHONY: clean-hw waves clean-test clean-all
