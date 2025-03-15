#include "DBC.h"
#include "variables.h"
#include "functions.h"
// #include "constant.h"
#include <fstream>
#include <chrono>
#include <unordered_map>
using namespace std;
using namespace std::chrono;

void DBC_POINT_mul(EC_POINT *r, EC_POINT *a, BIGNUM* n)
{
	// 计算椭圆曲线倍点
	EC_POINT *mult_points = EC_POINT_new(group);
	EC_POINT_copy(mult_points, a);

	while (BN_is_zero(n) == 0) {  // 检查 n 是否为 0
        if (BN_is_odd(n)) {  // 检查 n 是否为奇数
            if (!EC_POINT_add(group, r, r, mult_points, ctx)) {
                fprintf(stderr, "EC_POINT_add failed.\n");
                break;
            }
        }
        if (!EC_POINT_dbl(group, mult_points, mult_points, ctx)) {
            fprintf(stderr, "EC_POINT_dbl failed.\n");
            break;
        }
        if (!BN_rshift1(n, n)) {  
            fprintf(stderr, "BN_rshift1 failed.\n");
            break;
        }
    }
}

char hexwords[TEST_TIMES][INTS * 8 + 1] = {0};
int main()
{
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

	BIGNUM *n = BN_new();
	//二进制计算
	auto start = chrono::high_resolution_clock::now();
	for (int i = 0; i < TEST_TIMES; i++)
	{
		BN_hex2bn(&n, hexwords[i]);
		DBC_POINT_mul(r1[i], a[i], n);
	}
	auto end = chrono::high_resolution_clock::now();

	cout << "二进制计算用时：" << duration_cast<milliseconds>(end - start).count() << " milliseconds" << endl;

	// 直接计算
	auto start2 = chrono::high_resolution_clock::now();
	for (int i = 0; i < TEST_TIMES; i++)
	{
		BN_hex2bn(&n, hexwords[i]);
		EC_POINT_mul(group, r2[i], NULL, a[i], n, ctx);
	}
	auto end2 = chrono::high_resolution_clock::now();
	cout << "直接计算用时：" << duration_cast<milliseconds>(end2 - start2).count() << " milliseconds" << endl;

	// 比较两个点
	for (int i = 0; i < TEST_TIMES; i++)
	{
		int result = EC_POINT_cmp(group, r1[i], r2[i], NULL);
		if (result == 1)
		{
			cout << "计算出错！" << endl;
			print_point(r1[i]);
			print_point(r2[i]);
			break;
		}
	}

	//测试基础操作用时
	EC_POINT* ret=EC_POINT_new(group);

	auto start_dbl=high_resolution_clock::now();
	for (int i = 0; i < TEST_TIMES*100; i++)
	{
		EC_POINT_dbl(group, ret, r1[i%TEST_TIMES], ctx);
	}
	auto end_dbl=high_resolution_clock::now();
	cout << "二倍点计算用时：" << duration_cast<milliseconds>(end_dbl - start_dbl).count() << " milliseconds" << endl;

	auto start_tpl=high_resolution_clock::now();
	for (int i = 0; i < TEST_TIMES*100; i++)
	{
		EC_POINT_tpl(group, ret, r1[i%TEST_TIMES], ctx);
	}
	auto end_tpl=high_resolution_clock::now();
	cout << "三倍点计算用时：" << duration_cast<milliseconds>(end_tpl - start_tpl).count() << " milliseconds" << endl;

	auto start_add=high_resolution_clock::now();
	for (int i = 0; i < TEST_TIMES*100; i++)
	{
		EC_POINT_add(group,ret, r2[i%TEST_TIMES], r1[i%TEST_TIMES], ctx);
	}
	auto end_add=high_resolution_clock::now();
	cout << "点加计算用时：" << duration_cast<milliseconds>(end_add - start_add).count() << " milliseconds" << endl;
}
