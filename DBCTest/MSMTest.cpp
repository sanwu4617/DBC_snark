#include "DBC.h"
#include "variables.h"
#include "functions.h"

#ifndef TEST_TIMES
#define TEST_TIMES 131072
#endif
char hexwords[TEST_TIMES][INTS * 8 + 1] = {0};

int main()
{
    init();
    // cout << "请输入倍点的倍数：";
    for (int i = 0; i < TEST_TIMES; i++)
        cin >> hexwords[i];

    // 生成椭圆曲线上的一个点
    EC_POINT *base = (EC_POINT *)EC_KEY_get0_public_key(key);

    vector<EC_POINT *> a(TEST_TIMES);
    vector<EC_POINT *> r1(TEST_TIMES);
    vector<EC_POINT *> r2(TEST_TIMES);
    vector<EC_POINT *> r3(TEST_TIMES);
    vector<EC_POINT *> r4(TEST_TIMES);
    vector<EC_POINT *> r5(TEST_TIMES);
    vector<EC_POINT *> r6(TEST_TIMES);

    for (int i = 0; i < TEST_TIMES; i++)
    {
        a[i] = base;
        r1[i] = EC_POINT_new(group);
        r2[i] = EC_POINT_new(group);
        r3[i] = EC_POINT_new(group);
        r4[i] = EC_POINT_new(group);
        r5[i] = EC_POINT_new(group);
        r6[i] = EC_POINT_new(group);
    }

    cout << "               2^10\t2^11\t2^12\t2^13\t2^14\t2^15\t2^16\t2^17\n";
    cout << "最优DBC        ";
    int t=1024;
    auto start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        if(i==t){
            auto end = chrono::high_resolution_clock::now();
            cout << duration_cast<milliseconds>(end - start).count()<<'\t';
            t<<=1;
        }
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getOptimalDBC(u);
        DBC_POINT_mul(r1[i], a[i], min_index);
    }
    auto end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count()<<endl;

    cout << "EOS_DBC        ";
    t=1024;
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        if(i==t){
            auto end = chrono::high_resolution_clock::now();
            cout << duration_cast<milliseconds>(end - start).count()<<'\t';
            t<<=1;
        }
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getEOSDBC(u);
        DBC_POINT_mul(r2[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count()<<endl;

    cout << "1-次优DBC      ";
    t=1024;
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        if(i==t){
            auto end = chrono::high_resolution_clock::now();
            cout << duration_cast<milliseconds>(end - start).count()<<'\t';
            t<<=1;
        }
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 1);
        DBC_POINT_mul(r3[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count()<<endl;

    // 二进制计算
    cout << "二进制计算     ";
    t=1024;
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        if(i==t){
            auto end = chrono::high_resolution_clock::now();
            cout << duration_cast<milliseconds>(end - start).count()<<'\t';
            t<<=1;
        }
        binary_POINT_mul(r4[i], a[i], hexwords[i]);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count()<<endl;

    // NAF计算
    cout << "NAF计算        ";
    t=1024;
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        if(i==t){
            auto end = chrono::high_resolution_clock::now();
            cout << duration_cast<milliseconds>(end - start).count()<<'\t';
            t<<=1;
        }
        NAF_POINT_mul(r5[i], a[i], hexwords[i]);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count()<< endl;

    // 直接计算
    BIGNUM *n = BN_new();
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        BN_hex2bn(&n, hexwords[i]);
        EC_POINT_mul(group, r6[i], NULL, a[i], n, ctx);
    }
    end = chrono::high_resolution_clock::now();
    // cout << "直接计算用时：" << duration_cast<milliseconds>(end - start).count() TTV << endl;

    // 比较两个点
    int error = 0;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        int result = EC_POINT_cmp(group, r1[i], r6[i], NULL);
        if (result == 1)
        {
            error++;
        }
        result = EC_POINT_cmp(group, r2[i], r6[i], NULL);
        if (result == 1)
        {
            error++;
        }
        result = EC_POINT_cmp(group, r3[i], r6[i], NULL);
        if (result == 1)
        {
            error++;
        }
        result = EC_POINT_cmp(group, r4[i], r6[i], NULL);
        if (result == 1)
        {
            error++;
        }
        result = EC_POINT_cmp(group, r5[i], r6[i], NULL);
        if (result == 1)
        {
            error++;
        }
    }
    cout << "计算错误数量：" << error << endl;

    return 0;
}