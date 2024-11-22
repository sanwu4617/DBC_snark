#include "DBC.h"
#include "variables.h"
#include "functions.h"
#include <fstream>
using namespace std;
uint288 n;
uint288 B;
uint288 six_n;
uint288 record_outer;
uint288 temp_outer;
uint64 n0;
int bBound[MAX_2] = { 0 };
int getDBC(uint288 n)
{
	w_min=n;
	B=n.mul_2();
	six_n=B.mul_3();
	record_outer = B;
	int log2B = 0;
	int log3B = 0;
	int i_outer = 0, j_outer = 0, i_inner = 0, j_inner = 0;
	int t = 0, b = 0;
	for (int i = 257; i >= 0; i--)
	{
		if (B >= pow23_256[i][0])
		{
			log2B = i;
			break;
		}
	}
	for (int i = 162; i >= 0; i--)
	{
		if (B >= pow23_256[0][i])
		{
			log3B = i;
			break;
		}
	}
	bBound[0] = log2B;
	int i = 256;
	for (t = 1; t <= log3B; t++)
	{
		for (; i >= 0; i--)
		{
			if (B >= pow23_256[i][t])
			{
				bBound[t] = i;
				break;
			}
		}
		i--;
	}
	//alpha=32,beta=18
	int count = 0;
	record_outer = six_n;
	for (j_outer = 0; j_outer <= log3B / 18 + 1; j_outer++)
	{
		temp_outer = record_outer;
		for (i_outer = 0; i_outer <= bBound[j_outer * 18] / 32 + 1; i_outer++)
		{
			n0 = temp_outer.mod_2_33_3_19();
			for (j_inner = 0; j_inner <= 17; j_inner++)
			{
				t = j_outer * 18 + j_inner;
				if (t > log3B)    //若满足此条件，则继续进行本层循环后续均有t>log3B，因此直接break
					break;
				for (i_inner = 0; i_inner <= 31; i_inner++)
				{
					count++;
					b = i_outer * 32 + i_inner;
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
						if (n >= pow23_256[b][t])    //n>=pow23[b][t]  ->  n>nbt
						{
							w_min = minV(w(b, t).add(b, t, 1), w_min);
						}
						else            //n=nbt
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
int main()
{
	char hexwords[72]={0};
	//预计算2^i3^j
	init();
	cout << "请输入倍点的倍数：";
	cin >> hexwords;
	uint288 u(hexwords);
	BN_CTX* ctx = BN_CTX_new();
	int ret;
	//生成椭圆曲线上的一个点
	EC_GROUP* group;
	EC_KEY* key;
	EC_POINT* a;
	EC_POINT* r;
	key = EC_KEY_new();
	group = EC_GROUP_new_by_curve_name(NID_secp256k1);
	ret = EC_KEY_set_group(key, group);
	ret = EC_KEY_generate_key(key);
	a = (EC_POINT*)EC_KEY_get0_public_key(key);
	r = EC_POINT_new(group);
	clock_t flag_1 = clock();
	for (int z = 0; z < 1000; z++)
	{
		getDBC(u);
		//计算椭圆曲线倍点
		EC_POINT* mult_points = EC_POINT_new(group);
		EC_POINT_copy(mult_points, a);
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
	clock_t flag_2 = clock();
	cout << "最优DBC：";
	w_min.print();
	cout << "DBC加法数量：" << w_min.length - 1 << endl;
	//输出结果
	BIGNUM* x = BN_new();
	BIGNUM* y = BN_new();
	if (EC_POINT_get_affine_coordinates_GFp(group, a, x, y, NULL)) {
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
	if (EC_POINT_get_affine_coordinates_GFp(group, r, x, y, NULL)) {
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
	//对照实验
	BN_CTX_free(ctx);
	cout << "DBC计算时间：" << flag_2 - flag_1 << endl;
	return 0;
}