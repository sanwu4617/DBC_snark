#ifndef UINT_288_H
#define UINT_288_H
#include <iostream>
#include <math.h>
#include <cstring>
#include <iomanip>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/ec.h>
typedef long NUM;
typedef unsigned short byte;
using namespace std;
typedef unsigned long long uint64;
struct uint288 {
	unsigned int data[9];
	uint288();
	uint288(char* c);
	uint288(unsigned char* bytes, int n);
	uint288& operator =(uint288 a);
	//void rshift_32();
	void rshift_32(uint288& a);
	void div_3_18();
	void div_3();
	double to_double();
	uint288 mul_2();
	uint288 mul_3();
	long long mod_2_33_3_19();
	bool iszero();
};
bool operator >= (const uint288& a, const uint288& b);
uint288 operator - (uint288 a,uint288 b);
extern uint64 pow2[64];
extern uint64 pow3[40];
extern uint64 pow23_1[33][19];
extern uint288 pow23_256[260][165];
#endif