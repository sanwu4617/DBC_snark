#include <fstream>
#include <iostream>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/bn.h>
#include <openssl/ec.h>

#include "timer.h"
using namespace std;
typedef uint32_t uint;
typedef BIGNUM bn;
//typedef EC_GROUP group;
typedef EC_POINT point;
typedef unsigned char uchar;

const int SCALE = 16*2;
const int BATCH = 16;
const int LOOP  = SCALE / BATCH;

BN_CTX* ctx;
EC_GROUP* group;
EC_KEY* key;
EC_POINT* a;
EC_POINT* r;
bn* nums[BATCH];
bn* mod;
bn* res;
//DBCGroup w, w_;
//DBC w_min;
//Chain now_DBC[MAX_2];
char hexwords[10000][72] = {0};

void init()
{
	//初始化全局ctx
	ctx = BN_CTX_new();
	//为DBC代码运行提供基础环境
    for (int i = 0; i < BATCH; i++) {
        nums[i] = BN_new();
    }
    res = BN_new();
    mod = BN_new();
    BN_hex2bn(&mod, "30644E72E131A029B85045B68181585D97816A916871CA8D3C208C16D87CFD47");

}

int main() {
    //decltype<GetSysTimeMicros> s, e;
    auto s = GetSysTimeMicros(), e = GetSysTimeMicros();
    init();
    ifstream fin("1.txt");
	// 生成椭圆曲线上的一个点
	BIGNUM *x = BN_new();
	BIGNUM *y = BN_new();
	int ret;
	key = EC_KEY_new();
	group = EC_GROUP_new_by_curve_name(NID_secp256k1);
	ret = EC_KEY_set_group(key, group);
	ret = EC_KEY_generate_key(key);
	a = (EC_POINT *)EC_KEY_get0_public_key(key);
	r = EC_POINT_new(group);
	if (EC_POINT_get_affine_coordinates_GFp(group, a, x, y, NULL))
	{
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
	if (EC_POINT_get_affine_coordinates_GFp(group, r, x, y, NULL))
	{
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
	EC_POINT_add(group, r, r, a, ctx);
	cout << r << endl;
	if (EC_POINT_get_affine_coordinates_GFp(group, r, x, y, NULL))
	{
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
	cout << endl
		 << endl
		 << endl;
    auto mys = GetSysTimeMicros();
	for (int i = 0; i < 16; i++) {
        EC_POINT_dbl(group, r, a, ctx);
    }
    auto mye = GetSysTimeMicros();
    auto interv1 = mye - mys;
    for (int i = 0; i < 16; i++) {
	    EC_POINT_add(group, r, r, a, ctx);
    }
    mys = GetSysTimeMicros();
    auto interv2 = mys - mye;
    printf("Short Test: %lld %lld\n", interv1, interv2);
    if (EC_POINT_get_affine_coordinates_GFp(group, r, x, y, NULL))
	{
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
	cout << endl
		 << endl
		 << endl;

	for (int i = 0; i < 10000; i++)
	{
		fin >> hexwords[i];
		if(i % 1000 == 0) cout<<hexwords[i]<<endl;
	}

    for (int i = 0; i < LOOP; i++) {
        for (int j = 0; j < BATCH; j++) {
            if (0 == BN_hex2bn(&nums[j], hexwords[j]) ) {
                cout << "alert!!! : " << hexwords[j] << endl;
            }
        }
    }
    s = GetSysTimeMicros();
    for (int l = 0; l < LOOP; l++) {
        for (int i = 0; i < BATCH; i+=2) {
            BN_mod_add_quick(res, nums[i], nums[i+1], mod);
        }
    }
    e = GetSysTimeMicros();
    auto t1 = e - s;
    s = GetSysTimeMicros();
    for (int l = 0; l < LOOP; l++) {
        for (int i = 0; i < BATCH; i+=2) {
            //BN_mod_mul_montgomery(res, nums[i], nums[i+1], nullptr, ctx);
        }
    }
    e = GetSysTimeMicros();
    auto t2 = e - s;
    s = GetSysTimeMicros();
    for (int l = 0; l < LOOP; l++) {
        for (int i = 0; i < BATCH; i+=2) {
            BN_mod_mul(res, nums[i], nums[i+1], mod, ctx);
        }
    }
    e = GetSysTimeMicros();
    auto t3 = e - s;
    s = GetSysTimeMicros();
    for (int l = 0; l < LOOP; l++) {
        for (int i = 0; i < BATCH; i+=2) {
            BN_mod_inverse(res, nums[i], mod, ctx);
        }
    }
    e = GetSysTimeMicros();
    auto t4 = e - s;
    s = GetSysTimeMicros();
    for (int l = 0; l < LOOP; l++) {
        for (int i = 0; i < BATCH; i+=2) {
            //BN_mod_exp_mont(res, nums[i], nums[i+1], mod, ctx, nullptr);
        }
    }
    e = GetSysTimeMicros();
    auto t5 = e - s;
    s = GetSysTimeMicros();
    for (int l = 0; l < LOOP; l++) {
        for (int i = 0; i < BATCH; i+=2) {
            BN_mod_exp(res, nums[i], nums[i+1], mod, ctx);
        }
    }
    e = GetSysTimeMicros();
    auto t6 = e - s;
    printf("OpenSSL size %d*%d:\nadd:%ld\nmul:%ld\nmont_mul:%ld\ninv:%ld\nexp:%ld\nmont_exp:%ld\n", LOOP, BATCH/2, t1, t3, t2, t4, t5, t6);
    return 0;
}
