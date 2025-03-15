#ifndef myBigInt_288_H
#define myBigInt_288_H

#define OPENSSL_API_COMPAT 0x10100000L

#include <iostream>
#include <math.h>
#include <cstring>
#include <iomanip>
#include <vector>
#include <algorithm>

#include <fstream>
#include <chrono>
#include <vector>
using namespace std;
using namespace std::chrono;

#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/ec.h>

typedef long NUM;
typedef unsigned short ushort;
using namespace std;
typedef unsigned long long uint64;

#ifndef CURVE
#define CURVE NID_secp521r1
#endif

#ifndef INTS
#if CURVE==NID_secp128r1
#define INTS 5
#endif

#if CURVE==NID_secp256k1
#define INTS 9
#endif

#if CURVE==NID_secp384r1
#define INTS 13
#endif

#if CURVE==NID_secp521r1
#define INTS 17
#endif
#endif

#define MAX_2 ((32 * INTS))
#define MAX_3 (int(20.19 * INTS))

#ifndef DBL_COST
#define DBL_COST 70
#endif

#ifndef ADD_COST
#define ADD_COST 150
#endif

#ifndef TPL_COST
#define TPL_COST 126
#endif

template <int N>
struct myBigInt
{
	unsigned int data[INTS];

	myBigInt(std::initializer_list<unsigned int> list)
	{
		int i = 0;
		for (auto it = list.begin(); it != list.end(); ++it, ++i)
		{
			if (i >= N)
				break; // 防止超出数组范围
			data[i] = *it;
		}
	}

	myBigInt()
	{
		for (int i = 0; i < INTS; i++)
			data[i] = 0;
	}

	// myBigInt(BIGNUM* n);
	myBigInt(char *c)
	{
		for (int i = 0; i < INTS; i++)
			data[i] = 0;
		int len = strlen(c);
		int level = len / 8;
		int first = len % 8;
		for (int i = 0; i < first; i++)
		{
			data[INTS - 1 - level] <<= 4;
			if (c[i] <= '9')
				data[INTS - 1 - level] += c[i] - '0';
			else if (c[i] <= 'F')
				data[INTS - 1 - level] += c[i] - 'A' + 10;
			else
				data[INTS - 1 - level] += c[i] - 'a' + 10;
		}
		int flag = first;
		for (int i = INTS - level; i < INTS; i++)
		{
			for (int j = 0; j < 8; j++)
			{
				data[i] <<= 4;

				if (c[flag] <= '9')
					data[i] += c[flag] - '0';
				else if (c[flag] <= 'F')
					data[i] += c[flag] - 'A' + 10;
				else
					data[i] += c[flag] - 'a' + 10;
				flag++;
			}
		}
	}

	myBigInt(unsigned char *ushorts, int n)
	{
		for (int i = 0; i < INTS; i++)
			data[i] = 0;
		int first = n % 4;
		int len = n / 4;
		int flag = 0;
		for (int i = 0; i < first; i++)
		{
			data[INTS - 1 - len] <<= 8;
			data[INTS - 1 - len] = ushorts[i];
		}
		flag = first;
		for (int i = INTS - len; i < INTS; i++)
		{
			for (int j = 0; j < 4; j++)
			{
				data[i] <<= 8;
				data[i] += ushorts[flag];
				flag++;
			}
		}
	}

	void rshift_32()
	{
		for (int i = INTS - 1; i > 0; i--)
		{
			data[i] = data[i - 1];
		}
		data[0] = 0;
	}

	void rshift_32(myBigInt<N> &a)
	{
		for (int i = INTS - 1; i > 0; i--)
		{
			a.data[i] = data[i - 1];
		}
		a.data[0] = 0;
	}

	void div_3_18()
	{
		uint64 temp1;
		uint64 temp2 = data[0] % 387420489; // 3^18=387420489
		data[0] /= 387420489;
		for (int i = 1; i < INTS; i++)
		{
			temp1 = (temp2 << 32) + data[i];
			temp2 = temp1 % 387420489;
			data[i] = temp1 / 387420489;
		}
	}

	void div_3()
	{
		uint64 temp1;
		uint64 temp2 = data[0] % 3;
		data[0] /= 3;
		for (int i = 1; i < INTS; i++)
		{
			temp1 = (temp2 << 32) + data[i];
			temp2 = temp1 % 3;
			data[i] = temp1 / 3;
		}
	}

	myBigInt<N> mul_2()
	{
		myBigInt<N> ret;
		ret.data[INTS - 1] = data[INTS - 1] << 1;
		for (int i = INTS - 1; i > 0; i--)
		{
			ret.data[i - 1] = (((uint64)data[i] & 4294967295) >> 31) + ((uint64)data[i - 1] << 1);
		}
		return ret;
	}

	myBigInt<N> mul_3()
	{
		myBigInt<N> ret;
		uint64 temp[INTS];
		for (int i = INTS - 1; i >= 0; i--)
		{
			temp[i] = (uint64)data[i] * 3;
		}
		ret.data[INTS - 1] = (temp[INTS - 1] & 4294967295);

		for (int i = INTS - 2; i >= 0; i--)
		{
			ret.data[i] = (temp[i + 1] >> 32) + (temp[i] & 4294967295);
		}
		return ret;
	}

	long long mod_2_33_3_19()
	{
		myBigInt<N> a;
		rshift_32(a);
		uint64 ret = 0;
		const uint64 mul_num[20] = {// 2^(32*i)%(2*3^19)
									1ull, 1970444362ull, 1644176284ull, 848770120ull, 475253032ull,
									468402244ull, 1309631158ull, 1742236222ull, 569278114ull, 2119856536ull,
									199572574ull, 112215616ull, 2150738470ull, 1699047148ull, 1138432246ull,
									344572318ull, 1173799390ull, 1485158506ull, 1162871614ull, 1183015876ull};
		for (int i = 1; i < INTS; i++)
			ret += (uint64)a.data[i] * mul_num[INTS - 1 - i] % 2324522934;
		ret %= 2324522934;
		ret = (ret << 32) + data[INTS - 1];
		return ret;
	}

	void print(int type)
	{
		if (type == 0)
		{
			for (int i = N - 1; i >= 0; i--)
			{
				cout << data[i] << ' ';
			}
			cout << endl;
		}
		if (type == 1)
		{
			for (int i = 0; i < N; i++)
			{
				std::cout << std::setw(8) << std::setfill('0') << std::hex << data[i];
			}
			cout << endl;
		}
	}

	double to_double()
	{
		double ret = 0;
		for (int i = 0; i < INTS; i++)
		{
			ret *= 4294967296ull;
			ret += data[i];
		}
		return ret;
	}

	bool iszero()
	{
		int temp = 0;
		for (int i = 0; i < INTS; i++)
			temp |= data[i];
		return temp == 0;
	}
};

template <int N>
bool operator>=(myBigInt<N> a, myBigInt<N> b)
{
	for (int i = 0; i < INTS; i++)
	{
		if (a.data[i] < b.data[i])
			return false;
		if (a.data[i] > b.data[i])
			return true;
	}
	return true;
}

template <int N>
myBigInt<N> operator-(myBigInt<N> a, myBigInt<N> b)
{
	myBigInt<N> ret = a;
	if (N == 1)
	{
		ret.data[0] = a.data[0] - b.data[0];
		return ret;
	}
	// 判断是否有退位
	if (ret.data[INTS - 1] < b.data[INTS - 1])
		ret.data[INTS - 2]--;
	for (int i = INTS - 2; i > 0; i--)
	{
		if (ret.data[i] < b.data[i] || ret.data[i] == 4294967295)
			ret.data[i - 1]--;
	}
	for (int i = INTS - 1; i >= 0; i--)
		ret.data[i] -= b.data[i];

	return ret;
}

// istream& operator >>(istream& in, BIGNUM*& b);
//
// ostream& operator << (ostream& out, BIGNUM*& b);
template <int N>
bool operator>=(myBigInt<N> a, myBigInt<N> b);

extern uint64 pow2[64];
extern uint64 pow3[40];
extern uint64 pow23_1[33][19];
extern myBigInt<INTS> pow23_all[MAX_2][MAX_3];
extern double d_pow23_all[MAX_2][MAX_3];

#endif