#include "DBC.h"
#include "variables.h"
#include "functions.h"
#include <fstream>
#include <chrono>
#include <vector>
using namespace std;
using namespace std::chrono;

myBigInt<INTS> n;
myBigInt<INTS> B;
myBigInt<INTS> six_n;
myBigInt<INTS> record_outer;
myBigInt<INTS> temp_outer;
uint64 n0;
int bBound[MAX_2];
int getOptimalDBC(myBigInt<INTS> n)
{
	w_min = n;
	B = n.mul_2();
	six_n = B.mul_3();
	record_outer = B;
	int log2B = log2(B.to_double());
	int log3B = log(B.to_double()) / log(3);
	int i_outer = 0, j_outer = 0, i_inner = 0, j_inner = 0;
	int t = 0, b = 0;

	bBound[0] = log2B;
	int i = bBound[0];
	for (t = 1; t <= log3B; t++)
	{
		for (; i >= 0; i--)
		{
			if (B >= pow23_all[i][t])
			{
				bBound[t] = i;
				break;
			}
		}
		i--;
	}

	// alpha=32,beta=18
	int count = 0;
	record_outer = six_n;
	for (j_outer = 0; j_outer <= log3B / 18 + 1; j_outer++)
	{
		// cout << j_outer << endl;
		temp_outer = record_outer;
		for (i_outer = 0; i_outer <= bBound[j_outer * 18] / 32 + 1; i_outer++)
		{
			n0 = temp_outer.mod_2_33_3_19();
			for (j_inner = 0; j_inner <= 17; j_inner++)
			{
				t = j_outer * 18 + j_inner;
				if (t > log3B) // 若满足此条件，则继续进行本层循环后续均有t>log3B，因此直接break
					break;
				for (i_inner = 0; i_inner <= 31; i_inner++)
				{
					count++;
					b = i_outer * 32 + i_inner;
					if (b > log2B)
						break;
					if (b + t > 0 && b <= bBound[t])
					{
						int quot = (n0 / pow23_1[i_inner][j_inner]) % 6;
						if (quot < 2)
						{
							w(b, t) = minL(w(b - 1, t), w(b, t - 1), w_(b, t - 1).add(b, t - 1, 1));
							w_(b, t) = w_(b - 1, t).add(b - 1, t, -1);
						}
						else if (quot == 2)
						{
							w(b, t) = minL(w(b - 1, t), w_(b - 1, t).add(b - 1, t, 1), w(b, t - 1).add(b, t - 1, 1));
							w_(b, t) = w_(b - 1, t).add(b - 1, t, -1);
						}
						else if (quot == 3)
						{
							w(b, t) = w(b - 1, t).add(b - 1, t, 1);
							w_(b, t) = minL(w(b - 1, t).add(b - 1, t, -1), w_(b - 1, t), w_(b, t - 1).add(b, t - 1, -1));
						}
						else
						{
							w(b, t) = w(b - 1, t).add(b - 1, t, 1);
							w_(b, t) = minL(w_(b - 1, t), w(b, t - 1).add(b, t - 1, -1), w_(b, t - 1));
						}
					}
					if (b == bBound[t])
					{
						if (n >= pow23_all[b][t]) // n>=pow23[b][t]  ->  n>nbt
						{
							w_min = minV(w(b, t).add(b, t, 1), w_min);
						}
						else // n=nbt
						{
							w_min = minV(w(b, t), w_(b, t).add(b, t, 1), w_min);
						}
					}
				}
			}
			temp_outer.rshift_32(temp_outer);
		}
		record_outer.div_3_18();
	}
	w_min.simDBC();

	return 0;
}
// inline int EC_POINT_tpl(const EC_GROUP* group, EC_POINT* r, const EC_POINT* a, BN_CTX* ctx)
// {
// 	EC_POINT* temp = EC_POINT_new(group);
// 	EC_POINT_dbl(group, temp, a, ctx);
// 	EC_POINT_add(group, r, temp, a, ctx);
// 	return 0;
// }
#ifndef TEST_TIMES
#define TEST_TIMES 10000
#endif
char hexwords[TEST_TIMES][INTS * 8 + 1] = {0};

void DBC_POINT_mul(EC_POINT *r, EC_POINT *a)
{
	// 计算椭圆曲线倍点
	EC_POINT *mult_points = EC_POINT_new(group);
	//EC_POINT_copy(mult_points, a);
	EC_POINT_add(group, mult_points, a, a, ctx);
	EC_POINT_invert(group, mult_points, ctx);
	EC_POINT_add(group, mult_points, mult_points, a, ctx);
	EC_POINT_invert(group, mult_points, ctx);
	int now_dbl = 0, now_tpl = 0;
	if (w_min.isNULL || w_min.length == 0)
	{
		cout << 0 << endl;
	}
	else
	{
		bool first = true;
		for (int i = 0; i < w_min.length; i++)
		{
			while (1)
			{
				if (now_dbl < now_DBC[i].dbl)
				{
					EC_POINT_dbl(group, mult_points, mult_points, ctx);
					now_dbl++;
				}
				else if (now_tpl < now_DBC[i].tpl)
				{
					EC_POINT_tpl(group, mult_points, mult_points, ctx);
					now_tpl++;
				}
				else
					break;
			}
			if (now_DBC[i].minus)
			{
				EC_POINT_invert(group, mult_points, ctx);
			}
			if (first)
			{
				EC_POINT_copy(r, mult_points);
				first = false;
			}
			else
			{
				EC_POINT_add(group, r, r, mult_points, ctx);
			}
			if (now_DBC[i].minus)
			{
				EC_POINT_invert(group, mult_points, ctx);
			}
		}
	}
}

int main()
{
	// char hexwords[72]={0};
	// 预计算2^i3^j
	init();
	// cout << "请输入倍点的倍数：";
	for (int i = 0; i < TEST_TIMES; i++)
		cin >> hexwords[i];

	// 生成椭圆曲线上的一个点
	EC_POINT *base = (EC_POINT *)EC_KEY_get0_public_key(key);

	vector<EC_POINT *> a(TEST_TIMES);
	vector<EC_POINT *> r1(TEST_TIMES);
	vector<EC_POINT *> r2(TEST_TIMES);

	for (int i = 0; i < TEST_TIMES; i++)
	{
		a[i] = base;
		r1[i] = EC_POINT_new(group);
		r2[i] = EC_POINT_new(group);
	}

	EC_POINT *r3 = EC_POINT_new(group);
	EC_POINT_tpl(group, r3, base, ctx);
	print_point(r3);

	BIGNUM *n1 = BN_new();
	BN_hex2bn(&n1, "3");
	EC_POINT_mul(group, r3, NULL, base, n1, ctx);
	print_point(r3);

	BIGNUM *n = BN_new();
	auto start = chrono::high_resolution_clock::now();
	for (int i = 0; i < TEST_TIMES; i++)
	{
		myBigInt<INTS> u(hexwords[i]);
		getOptimalDBC(u);
		DBC_POINT_mul(r1[i], a[i]);
		BN_hex2bn(&n, hexwords[i]);
		EC_POINT_mul(group, r2[i], NULL, a[i], n, ctx);
		cout << hexwords[i] << endl;
		w_min.print(1);
		print_point(r1[i]);
		print_point(r2[i]);
	}
	auto end = chrono::high_resolution_clock::now();

	return 0;
}