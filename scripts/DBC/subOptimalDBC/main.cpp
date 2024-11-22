#include "uint288.h"
#include "constant.h"
#include <fstream>
using namespace std;

#define DBL_COST 70
#define ADD_COST 150
#define TPL_COST 126

uint288 n;
uint288 B;
uint288 six_n;
uint288 record_outer;
uint288 temp_outer;
uint64 n0;
#define DBC_COEF 10 //次优DBC参数设置，本参数越小计算DBC越快，但DBC质量越好。不过参数过小可能会引起bug，建议不要小于10
int bBound[MAX_2] = {0};

int DBC_store[2][MAX_2][3] = {0}; //第1维：不同的DBC，第2维：一个DBC的不同项，第3维：符号，2的次数，3的次数
int DBC_len[2] = {0};

inline int getDBC(uint288 n)
{
	int b_try[130] = {
		72,71,73,74,70,69,75,68,76,67,
		77,66,65,78,64,79,63,80,62,61,
		81,60,82,59,58,83,57,84,56,55,
		85,54,53,86,52,51,87,50,88,49,
		48,89,47,46,90,45,44,91,43,42,
		92,41,40,93,39,38,94,37,36,95,
		35,34,96,33,32,97,31,30,98,29,
		28,27,99,26,25,100,24,23,101,22,
		21,102,20,19,103,18,17,104,16,15,
		105,14,13,106,12,11,107,10,9,108};

	//将n转为双精度类型
	double dbl_n = n.to_double();
	//计算B1,B2
	double B1 = 0.9091372900969896 * dbl_n; // 9*n/(7*sqrt(2))
	double B2 = 1.0774960475223583 * dbl_n; // 16*sqrt(2)*n/21
	//计算LBound,RBound
	int LBound[MAX_3];
	int RBound[MAX_3];
	int DBC_index = 0;
	DBC_len[1] = 1 << 20; //初始化为足够大的数，保证在只计算出1个DBC时该DBC被识别为为最短的那个，减少条件判断
	for (int z = 0; z < DBC_COEF; z++)
	{
		int b = b_try[z];
		LBound[b] = log(B1 / d_pow23[0][b]) / log(2) + 1;
		RBound[b] = log(B2 / d_pow23[0][b]) / log(2);
		if (LBound[b] == RBound[b])
		{
			int a = RBound[b];
			int i = 0;
			int b_temp = b;
			uint288 t = n;
			int s = 1;
			while (!t.iszero())
			{
				//计算alpha,beta
				double dbl_t = t.to_double();
				int alpha = a, beta = b_temp;
				double logt = log(dbl_t) / log(2);
				double log3 = log(3) / log(2);
				for (int j = b_temp; j >= max(0, b_temp - 6); j--)
				{
					int alpha_j;
					if (d_pow23[0][j] >= dbl_t)
						alpha_j = 0;
					else
					{
						int k_j = int(logt - j * log3);
						if (k_j >= a)
							alpha_j = a;
						else
						{
							if (fabs(dbl_t - d_pow23[k_j][j]) <= fabs(d_pow23[k_j + 1][j] - dbl_t))
								alpha_j = k_j;
							else
								alpha_j = k_j + 1;
						}
					}
					if (fabs(dbl_t - d_pow23[alpha_j][j]) <= fabs(d_pow23[alpha][beta] - dbl_t))
					{
						alpha = alpha_j;
						beta = j;
					}
				}

				int stmp = s;
				if (!(t >= u_pow23[alpha][beta]))
					s = -s;
				DBC_store[DBC_index][i][0] = stmp;
				DBC_store[DBC_index][i][1] = alpha;
				DBC_store[DBC_index][i][2] = beta;
				i++;
				if (t >= u_pow23[alpha][beta])
					t = t - u_pow23[alpha][beta];
				else
					t = u_pow23[alpha][beta] - t;
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
inline int EC_POINT_tpl2(const EC_GROUP *group, EC_POINT *r, const EC_POINT *a, BN_CTX *ctx)
{
	//EC_POINT_dbl(group, r, a, (BN_CTX*)(uint64(ctx)+1));
	EC_POINT *temp = EC_POINT_new(group);
	EC_POINT_dbl(group, temp, a, ctx);
	EC_POINT_add(group, r, temp, a, ctx);
	return 0;
}

char hexwords[10000][72] = {0};


void mytest() {
	uint288 test_num = {0, 0xe16a49aU, 0x1b30302bU, 0xa6208771U, 0x62842d8aU, 0x27ae4f28U, 0x893d6f26U, 0xa46870a3U, 0xa1ffc686U};

	cout << "请输入倍点的倍数：";
	cin >> hexwords[0];
	uint288 u;
	u.setData(hexwords[0]);
	BN_CTX* ctx = BN_CTX_new();
	int ret;
	auto idx = getDBC(u);
	for (int j = DBC_len[idx]; j >= 0; j--) {
		printf("%c2^{%d}3^{%d}", DBC_store[idx][j][0]==1?'+':'-', DBC_store[idx][j][1], DBC_store[idx][j][2]);
	}
	cout << endl;
	auto last = DBC_len[idx];
	cout << last << ' ' << 7.0*DBC_store[idx][0][1] + 12.6*DBC_store[idx][0][2] + 15*(last - 1);
}
//#define CORRECT_TEST
int main()
{
#ifdef CORRECT_TEST
	mytest();
	return 0;
#endif
	ifstream fin("1.txt");
	//生成椭圆曲线上的一个点
	EC_GROUP *group;
	EC_KEY *key;
	EC_POINT *a;
	EC_POINT *r;
	BN_CTX *ctx = BN_CTX_new();
	BIGNUM *x = BN_new();
	BIGNUM *y = BN_new();
	int ret;
	key = EC_KEY_new();
	group = EC_GROUP_new_by_curve_name(NID_secp256k1);
	ret = EC_KEY_set_group(key, group);
	ret = EC_KEY_generate_key(key);
	a = (EC_POINT *)EC_KEY_get0_public_key(key);
	r = EC_POINT_new(group);

	for (int i = 0; i < 10000; i++)
	{
		fin >> hexwords[i];
	}

	clock_t start = clock();
	for (int i = 0; i < 10000; i++)
	{
		uint288 u;
		u.setData(hexwords[i]);
		int min_index = getDBC(u);
		//计算椭圆曲线倍点
		EC_POINT *mult_points = EC_POINT_new(group);
		EC_POINT_copy(mult_points, a);
		int now_dbl = 0, now_tpl = 0;
		bool first = true;
		for (int i = DBC_len[min_index] - 1; i >= 0; i--)
		{
			while (1)
			{
				if (now_dbl < DBC_store[min_index][i][1])
				{
					EC_POINT_dbl(group, mult_points, mult_points, ctx);
					now_dbl++;
				}
				else if (now_tpl < DBC_store[min_index][i][2])
				{
					EC_POINT_tpl(group, mult_points, mult_points, ctx);
					now_tpl++;
				}
				else
					break;
			}
			if (DBC_store[min_index][i][0] == -1)
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
			if (DBC_store[min_index][i][0] == -1)
			{
				EC_POINT_invert(group, mult_points, ctx);
			}
		}
	}
	clock_t end = clock();
	cout << "DBC计算时间：" << end - start << endl;
	cout << "DBC计算结果：" << endl;
	if (EC_POINT_get_affine_coordinates_GFp(group, r, x, y, NULL))
	{
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
	//直接计算
	BIGNUM *n = BN_new();
	clock_t flag_3 = clock();
	for (int i = 0; i < 10000; i++)
	{
		BN_hex2bn(&n, hexwords[i]);
		EC_POINT_mul(group, r, NULL, a, n, ctx);
	}
	clock_t flag_4 = clock();
	cout << "直接计算时间：" << flag_4 - flag_3 << endl;
	cout << "直接计算结果：" << endl;
	if (EC_POINT_get_affine_coordinates_GFp(group, r, x, y, NULL))
	{
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}

	return 0;
}
