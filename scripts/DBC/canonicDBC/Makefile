CXXFLAGS = -std=c++0x -O3 -I/home/zfsn4617/Desktop/openssl/include
LIBS = -L/home/zfsn4617/Desktop/openssl/lib64 -Wl,-rpath=/home/zfsn4617/Desktop/openssl/lib64 -lcrypto

test: DBC.h functions.h variables.h uint288.h DBC.cpp variables.cpp main.cpp uint288.cpp
	$(CXX) $^ $(CXXFLAGS) $(LIBS) -w -o $@.exec

clean:
	rm -f test.exec