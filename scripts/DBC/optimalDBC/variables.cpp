#include "variables.h"
#include "functions.h"
BN_CTX* ctx;
DBCGroup w, w_;
DBC w_min;
Chain now_DBC[MAX_2];
void init()
{
	//初始化全局ctx
	ctx = BN_CTX_new();
	//为DBC代码运行提供基础环境
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
	pow23_256[0][0].data[8] = 1;
	for (int i = 0; i < 260; i++)
	{
		if (i > 0)
			pow23_256[i][0] = pow23_256[i - 1][0].mul_2();
		for (int j = 1; j < 165; j++)
		{
			if (i + j * log2(3) > 260)
				break;
			pow23_256[i][j] = pow23_256[i][j - 1].mul_3();
		}
	}
}
