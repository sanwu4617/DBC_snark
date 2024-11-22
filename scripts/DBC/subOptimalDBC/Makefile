CXXFLAGS = -std=c++0x -O3 -I/home/zfsn4617/Desktop/openssl/include
LIBS = -L/home/zfsn4617/Desktop/openssl/lib64 -Wl,-rpath=/home/zfsn4617/Desktop/openssl/lib64 -lcrypto

test: uint288.h constant.h uint288.cpp main.cpp
	$(CXX) $^ $(CXXFLAGS) $(LIBS) -w -o $@.exec

clean:
	rm -f test.exec