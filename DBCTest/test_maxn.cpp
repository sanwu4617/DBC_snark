#include "DBC.h"
#include "variables.h"
#include "functions.h"
// #include "constant.h"
#include <fstream>
#include <chrono>
using namespace std;
using namespace std::chrono;

myBigInt<INTS> n;
myBigInt<INTS> B;
myBigInt<INTS> six_n;
myBigInt<INTS> record_outer;
myBigInt<INTS> temp_outer;
uint64 n0;
// #define DBC_COEF 130 //次优DBC参数设置，本参数越小计算DBC越快，但DBC质量越好。不过参数过小可能会引起bug，建议不要小于10
int bBound[MAX_2];

int DBC_store[2][MAX_2][3] = {0}; // 第1维：不同的DBC，第2维：一个DBC的不同项，第3维：符号，2的次数，3的次数
int DBC_len[2] = {0};

void print_DBC(int index)
{
	for (int i = DBC_len[index] - 1; i >= 0; i--)
	{
		if (DBC_store[index][i][0] == -1)
		{
			cout << '-';
		}
		else
		{
			cout << "+";
		}
		cout << "2**" << DBC_store[index][i][1] << "*3**" << DBC_store[index][i][2];
	}
	cout << endl;
}

inline int getOptimalDBC(myBigInt<INTS> n)
{
	// int b_try[130] = {
	// 	72, 71, 73, 74, 70, 69, 75, 68, 76, 67,
	// 	77, 66, 65, 78, 64, 79, 63, 80, 62, 61,
	// 	81, 60, 82, 59, 58, 83, 57, 84, 56, 55,
	// 	85, 54, 53, 86, 52, 51, 87, 50, 88, 49,
	// 	48, 89, 47, 46, 90, 45, 44, 91, 43, 42,
	// 	92, 41, 40, 93, 39, 38, 94, 37, 36, 95,
	// 	35, 34, 96, 33, 32, 97, 31, 30, 98, 29,
	// 	28, 27, 99, 26, 25, 100, 24, 23, 101, 22,
	// 	21, 102, 20, 19, 103, 18, 17, 104, 16, 15,
	// 	105, 14, 13, 106, 12, 11, 107, 10, 9, 108,
	// 	8, 7, 6, 109, 5, 4, 110, 3, 2, 111,
	// 	1, 112, 0, 113, 114, 115, 116, 117, 118, 119};

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
				for (int j = b_temp; j >= 0; j--)
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

					if (fabs(dbl_t - d_pow23_all[alpha_j][j]) * pow(1.5, b_temp - j) <= fabs(d_pow23_all[alpha][beta] - dbl_t))
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

			cout << b << '\t' << DBC_len[DBC_index] * ADD_COST + DBC_store[DBC_index][0][1] * DBL_COST + DBC_store[DBC_index][0][2] * TPL_COST << endl;
			
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

char hexwords[TEST_TIMES][INTS * 8 + 1] = {0};
int main()
{
	// char hexwords[72]={0};
	// 预计算2^i3^j
	init();
	// cout << "请输入倍点的倍数：";
	for (int i = 0; i < TEST_TIMES; i++)
		cin >> hexwords[i];

	auto start = chrono::high_resolution_clock::now();
	for (int z = 0; z < TEST_TIMES; z++)
	{
		myBigInt<INTS> u(hexwords[z]);
		int min_index = getOptimalDBC(u);
		//print_DBC(min_index);
	}
	auto end = chrono::high_resolution_clock::now();

	cout << "Elapsed time: " << duration_cast<milliseconds>(end - start).count() << " milliseconds" << endl;
	return 0;
}
