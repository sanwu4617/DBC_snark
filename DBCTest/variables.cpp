#include "variables.h"
#include "functions.h"
// BN_CTX* ctx;
DBCGroup<INTS> w, w_;
optimal_DBC<INTS> w_min;
Chain now_DBC[MAX_2];

uint64 pow2[64];
uint64 pow3[40];
uint64 pow23_1[33][19];
myBigInt<INTS> pow23_all[MAX_2][MAX_3];
double d_pow23_all[MAX_2][MAX_3];
BN_CTX *ctx;
EC_GROUP *group;
EC_KEY *key;

int DBC_store[2][MAX_2][3]; // 第1维：不同的DBC，第2维：一个DBC的不同项，第3维：符号，2的次数，3的次数
int DBC_len[2];

myBigInt<INTS> n;
myBigInt<INTS> B;
myBigInt<INTS> six_n;
myBigInt<INTS> record_outer;
myBigInt<INTS> temp_outer;
uint64 n0;
int bBound[MAX_2];

void init()
{
	// 初始化全局ctx
	ctx = BN_CTX_new();

	key = EC_KEY_new();
	group = EC_GROUP_new_by_curve_name(CURVE);
	EC_KEY_set_group(key, group);
	EC_KEY_generate_key(key);

	// 为DBC代码运行提供基础环境
	w(0, 0) = 0;
	w_(0, 0).setNULL();
	for (int i = 0; i < MAX_2; i++)
	{
		w(i, -1).setNULL();
		w_(i, -1).setNULL();
	}
	for (int j = 0; j < MAX_3; j++)
	{
		w(-1, j).setNULL();
		w_(-1, j).setNULL();
	}
	pow2[0] = 1;
	pow3[0] = 1;
	for (int i = 1; i < 64; i++)
	{
		pow2[i] = pow2[i - 1] * 2;
	}
	for (int i = 1; i < 40; i++)
	{
		pow3[i] = pow3[i - 1] * 3;
	}
	for (int i = 0; i < 33; i++)
	{
		for (int j = 0; j < 19; j++)
		{
			pow23_1[i][j] = pow2[i] * pow3[j];
		}
	}
	pow23_all[0][0].data[INTS - 1] = 1;
	for (int i = 0; i < MAX_2; i++)
	{
		if (i > 0)
			pow23_all[i][0] = pow23_all[i - 1][0].mul_2();
		for (int j = 1; j < MAX_3; j++)
		{
			if (i + j * (log2(3)) > MAX_2)
				break;
			pow23_all[i][j] = pow23_all[i][j - 1].mul_3();
		}
	}
	for (int i = 0; i < MAX_2; i++)
	{
		for (int j = 0; j < MAX_3; j++)
		{
			d_pow23_all[i][j] = pow23_all[i][j].to_double();
		}
	}
}
