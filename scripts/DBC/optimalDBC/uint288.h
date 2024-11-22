#ifndef UINT_288_H
#define UINT_288_H
#include <iostream>
#include <math.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/ec.h>
#include <cstring>
#include <iomanip>
typedef long NUM;
using namespace std;
typedef unsigned long long uint64;
struct uint288 {
	unsigned int data[9];
	uint288();
    uint288(BIGNUM* n);
	uint288(char* c);
	uint288(unsigned char* bytes,int n);
	void rshift_32();
	void rshift_32(uint288& a);
	void div_3_18();
	void div_3();
	uint288 mul_2();
	uint288 mul_3();
	long long mod_2_33_3_19();
};
istream& operator >>(istream& in, BIGNUM*& b);

ostream& operator << (ostream& out, BIGNUM*& b);
bool operator >= (uint288 a, uint288 b);
extern uint64 pow2[64];
extern uint64 pow3[40];
extern uint64 pow23_1[33][19];
extern uint288 pow23_256[260][165];
#endif