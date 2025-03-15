#include "DBC.h"
#include "variables.h"
#include "functions.h"
// #include "constant.h"
#include <fstream>
#include <chrono>
using namespace std;
using namespace std::chrono;

int getEOSDBC(myBigInt<INTS> n)
{
	// 将n转为双精度类型
	double dbl_n = n.to_double();
	// 计算B1,B2
	double B1 = 0.9091372900969896 * dbl_n; // 9*n/(7*sqrt(2))
	double B2 = 1.0774960475223583 * dbl_n; // 16*sqrt(2)*n/21
	// 计算LBound,RBound
	int LBound[MAX_3];
	int RBound[MAX_3];
	int DBC_index = 0;
	DBC_len[1] = 1 << 20; // 初始化为足够大的数，保证在只计算出1个DBC时该DBC被识别为为最短的那个，减少条件判断
	for (int z = 0; z < MAX_3; z++)
	{
		int b = z; // b_try[z];
		LBound[b] = log(B1 / d_pow23_all[0][b]) / log(2) + 1;
		RBound[b] = log(B2 / d_pow23_all[0][b]) / log(2);

		if (LBound[b] < 0 || RBound[b] < 0)
			break;
		if (LBound[b] == RBound[b])
		{
			int a = RBound[b];
			int i = 0;
			int b_temp = b;
			myBigInt<INTS> t = n;
			int s = 1;
			while (!t.iszero())
			{
				// 计算alpha,beta
				double dbl_t = t.to_double();
				int alpha = a, beta = b_temp;
				double logt = log(dbl_t) / log(2);
				double log3 = log(3) / log(2);
				for (int j = b_temp; j >= max(0,b_temp-4); j--)
				{
					int alpha_j;
					if (d_pow23_all[0][j] >= dbl_t)
						alpha_j = 0;
					else
					{
						int k_j = int(logt - j * log3);
						if (k_j >= a)
							alpha_j = a;

						else
						{
							if (fabs(dbl_t - d_pow23_all[k_j][j]) <= fabs(d_pow23_all[k_j + 1][j] - dbl_t))
								alpha_j = k_j;
							else
								alpha_j = k_j + 1;
						}
					}

					if (fabs(dbl_t - d_pow23_all[alpha_j][j]) <= fabs(d_pow23_all[alpha][beta] - dbl_t))
					{
						alpha = alpha_j;
						beta = j;
					}
				}

				int stmp = s;
				if (!(t >= pow23_all[alpha][beta]))
					s = -s;

				DBC_store[DBC_index][i][0] = stmp;
				DBC_store[DBC_index][i][1] = alpha;
				DBC_store[DBC_index][i][2] = beta;
				i++;

				if (t >= pow23_all[alpha][beta])
					t = t - pow23_all[alpha][beta];
				else
					t = pow23_all[alpha][beta] - t;

				a = alpha;
				b_temp = beta;
			}
			DBC_len[DBC_index] = i;
			int temp0 = DBC_len[0] * ADD_COST + DBC_store[0][0][1] * DBL_COST + DBC_store[0][0][2] * TPL_COST;
			int temp1 = DBC_len[1] * ADD_COST + DBC_store[1][0][1] * DBL_COST + DBC_store[1][0][2] * TPL_COST;
			if (temp0 < temp1)
				DBC_index = 1;
			else
				DBC_index = 0;
		}
	}
	int min_index = 1 - DBC_index;
	return min_index;
}
// inline int EC_POINT_tpl(const EC_GROUP *group, EC_POINT *r, const EC_POINT *a, BN_CTX *ctx)
// {
// 	// EC_POINT_dbl(group, r, a, (BN_CTX*)(uint64(ctx)+1));
// 	EC_POINT *temp = EC_POINT_new(group);
// 	EC_POINT_dbl(group, temp, a, ctx);
// 	EC_POINT_add(group, r, temp, a, ctx);
// 	return 0;
// }

// char hexwords[TEST_TIMES][INTS * 8 + 1] = {0};
// int main()
// {
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
// 		int min_index = getEOSDBC(u);
// 		DBC_POINT_mul(r1[i], a[i], min_index);
// 		// w_min.print(1);
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
// 	}
// 	auto end2 = chrono::high_resolution_clock::now();
// 	cout << "直接计算用时：" << duration_cast<milliseconds>(end2 - start2).count() << " milliseconds" << endl;

// 	// 比较两个点
// 	for (int i = 0; i < TEST_TIMES; i++)
// 	{
// 		int result = EC_POINT_cmp(group, r1[i], r2[i], NULL);
// 		if (result == 1)
// 		{
// 			cout<<"计算出错！"<<endl;
// 			print_point(r1[i]);
// 			print_point(r2[i]);
// 			break;
// 		}
// 	}
// }
