basedir = ..
include $(basedir)/Makefrag
#SBTARGS = --backend c --vcd --compile --test --targetDir ../emulator --genHarness
#SBTARGS = --backend v --compile --test --targetDir ../emulator --genHarness

prj_out = $(addsuffix .out, $(prjs))


all: $(prj_out)
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /(PASSED|FAILED)/' $(prj_out); echo

rm: 
	rm -f ../src/main/scala/*.scala
	cp ../src/main/scala/run.scala.orig ../src/main/scala/run.scala
	cp ../Gorilla++/* ../src/main/scala/
 

$(prjs): %: $(basedir)/src/main/scala/%.scala
	@#cd $(basedir); $(SBT) "project KmeansAndMesh" "run $@ $(SBTARGS)"
	@#cd $(basedir); $(SBT) "run $@ $(SBTARGS)"
	cd $(basedir); $(SBT) clean && $(SBT) test

$(prj_out): %.out: $(basedir)/src/main/scala/%.scala
	@#cd $(basedir); $(SBT) "project KmeansAndMesh" "run $* $(SBTARGS)" | tee emulator/$@
	@#cd $(basedir); $(SBT) "run $* $(SBTARGS)" | tee emulator/$@
	cd $(basedir); $(SBT) clean && $(SBT) test | tee emulator/$@

clean: 
	rm -f *.out *.o emulator.h *-emulator.* $(prjs) $(addsuffix .h, $(prjs)) $(addsuffix .cpp, $(prjs))

.PHONY: all clean
