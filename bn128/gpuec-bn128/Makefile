NVCC = nvcc
ARCHFLAG = -arch=sm_35
RP_LIB_FLAG = -std=c++11 -lcrypto -lgmp -lm
DBC_FLAG = -std=c++11 -lm

p256:gpuec256.o test256.cu
	$(NVCC) $(ARCHFLAG) -std=c++11 -rdc=true test256.cu gpuec256.o -o test256

p512:
	$(NVCC) $(ARCHFLAG) -dc  gpuec.cu -o gpuec.o
	$(NVCC) $(ARCHFLAG)  -rdc=true test.cu gpuec.o -o test512

gmp:
	gcc gmptest.cpp -lgmp -lm -o smptest

rp:rp.cu gpuec256.o
	$(NVCC) $(ARCHFLAG) rp.cu gpuec256.o -rdc=true $(RP_LIB_FLAG) -o rp

cuv:cuverify.cu gpuec256.o
	$(NVCC) $(ARCHFLAG) cuverify.cu gpuec256.o -rdc=true $(RP_LIB_FLAG) -o cuv

Test256: gpuec256.o uint288.o constants.o test256.cu
	$(NVCC) $(ARCHFLAG) test256.cu gpuec256.o uint288.o constants.o -rdc=true $(DBC_FLAG) -o test256

DBCTest: gpuec256.o uint288.o constants.o
	$(NVCC) $(ARCHFLAG) DBCTest.cu gpuec256.o uint288.o constants.o  -rdc=true $(DBC_FLAG) -o DBCTest

DBC.o:DBC.cu DBC.h constants.h
	$(NVCC) $(ARCHFLAG)  -dc  DBC.cu -o DBC.o

uint288.o:uint288.cu uint288.h
	$(NVCC) $(ARCHFLAG)  -dc  uint288.cu -o uint288.o

constants.o:constants.cu constants.cuh uint288.h
	$(NVCC) $(ARCHFLAG)  -dc  constants.cu -o constants.o

gpuec256.o:gpuec256.cu gpuec256.h
	$(NVCC) $(ARCHFLAG)  -dc  gpuec256.cu -o gpuec256.o

curveTest:gpuec256.o uint288.o constants.o
	$(NVCC) $(ARCHFLAG) curveTest.cu gpuec256.o uint288.o constants.o  -rdc=true $(DBC_FLAG) -o curveTest

cleanTest:
	rm curveTest

clean: 
	rm DBCTest gpuec256.o

cleanref:
	rm DBC.o uint288.o DBCTest 

cleanDBC:
	rm DBC.o uint288.o