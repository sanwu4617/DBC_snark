#include "DBC.h"
#include "variables.h"
#include "functions.h"

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
	for (int i = 0; i < w_min.length; i++)
	{
		DBC_store[0][w_min.length - i - 1][0] = 1-2*now_DBC[i].minus;
		DBC_store[0][w_min.length - i - 1][1] = now_DBC[i].dbl;
		DBC_store[0][w_min.length - i - 1][2] = now_DBC[i].tpl;
	}
	DBC_len[0] = w_min.length;

	return 0;
}

// #ifndef TEST_TIMES
// #define TEST_TIMES 10000
// #endif
// char hexwords[TEST_TIMES][INTS * 8 + 1] = {0};


// int main()
// {
// 	// char hexwords[72]={0};
// 	// 预计算2^i3^j
// 	init();
// 	// cout << "请输入倍点的倍数：";
// 	for (int i = 0; i < TEST_TIMES; i++)
// 		cin >> hexwords[i];

// 	// 生成椭圆曲线上的一个点
// 	EC_POINT *base = (EC_POINT *)EC_KEY_get0_public_key(key);

// 	vector<EC_POINT *> a(TEST_TIMES);
// 	vector<EC_POINT *> r1(TEST_TIMES);
// 	vector<EC_POINT *> r2(TEST_TIMES);

// 	for (int i = 0; i < TEST_TIMES; i++)
// 	{
// 		a[i] = base;
// 		r1[i] = EC_POINT_new(group);
// 		r2[i] = EC_POINT_new(group);
// 	}

// 	auto start = chrono::high_resolution_clock::now();
// 	for (int i = 0; i < TEST_TIMES; i++)
// 	{
// 		myBigInt<INTS> u(hexwords[i]);
// 		getOptimalDBC(u);
// 		DBC_POINT_mul(r1[i], a[i]);
// 		w_min.print(1);
// 		cout << w_min.length << endl;
// 		print_DBC(0);

// 		// print_point(a);
// 		// print_point(r);
// 	}
// 	auto end = chrono::high_resolution_clock::now();

// 	cout << "最优DBC用时：" << duration_cast<milliseconds>(end - start).count() << " milliseconds" << endl;

// 	// 直接计算
// 	BIGNUM *n = BN_new();
// 	auto start2 = chrono::high_resolution_clock::now();
// 	for (int i = 0; i < TEST_TIMES; i++)
// 	{
// 		BN_hex2bn(&n, hexwords[i]);
// 		EC_POINT_mul(group, r2[i], NULL, a[i], n, ctx);
// 		// print_point(r);
// 	}
// 	auto end2 = chrono::high_resolution_clock::now();
// 	cout << "直接计算用时：" << duration_cast<milliseconds>(end2 - start2).count() << " milliseconds" << endl;

// 	// 比较两个点
// 	int error = 0;
// 	for (int i = 0; i < TEST_TIMES; i++)
// 	{
// 		int result = EC_POINT_cmp(group, r1[i], r2[i], NULL);
// 		if (result == 1)
// 		{
// 			// cout<<"计算出错！"<<endl;
// 			// print_point(r1[i]);
// 			// print_point(r2[i]);
// 			// break;
// 			error++;
// 		}
// 	}
// 	cout << error << endl;

// 	return 0;
// }