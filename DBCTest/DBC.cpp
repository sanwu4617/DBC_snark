#include "DBC.h"
#include "variables.h"
#include "functions.h"

#ifndef TEST_TIMES
#define TEST_TIMES 10000
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

    cout << "               计算点乘用时(ms)\t计算DBC用时(ms)\t汉明重量\n";
    cout << "最优DBC        ";
    auto start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getOptimalDBC(u);
        DBC_POINT_mul(r1[i], a[i], min_index);
    }
    auto end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count();

    start = chrono::high_resolution_clock::now();
    double TTV = 0; // 理论时值
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getOptimalDBC(u);
        TTV += compute_TTV(min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << "\t\t" << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    cout << "EOS_DBC        ";
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getEOSDBC(u);
        DBC_POINT_mul(r2[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count();

    start = chrono::high_resolution_clock::now();
    TTV = 0; // 理论时值
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getEOSDBC(u);
        TTV += compute_TTV(min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << "\t\t" << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    cout << "1-次优DBC      ";
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 1);
        DBC_POINT_mul(r3[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count();

    start = chrono::high_resolution_clock::now();
    TTV = 0; // 理论时值
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 1);
        TTV += compute_TTV(min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << "\t\t" << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    cout << "2-次优DBC      ";
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 2);
        DBC_POINT_mul(r3[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count();

    start = chrono::high_resolution_clock::now();
    TTV = 0; // 理论时值
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 2);
        TTV += compute_TTV(min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << "\t\t" << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    cout << "3-次优DBC      ";
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 3);
        DBC_POINT_mul(r3[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count();

    start = chrono::high_resolution_clock::now();
    TTV = 0; // 理论时值
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 3);
        TTV += compute_TTV(min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << "\t\t" << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    cout << "10-次优DBC     ";
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 10);
        DBC_POINT_mul(r3[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count();

    start = chrono::high_resolution_clock::now();
    TTV = 0; // 理论时值
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 10);
        TTV += compute_TTV(min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << "\t\t" << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    cout << "20-次优DBC     ";
    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 20);
        DBC_POINT_mul(r3[i], a[i], min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << duration_cast<milliseconds>(end - start).count();

    start = chrono::high_resolution_clock::now();
    TTV = 0; // 理论时值
    for (int i = 0; i < TEST_TIMES; i++)
    {
        myBigInt<INTS> u(hexwords[i]);
        int min_index = getSubOptimalDBC(u, 20);
        TTV += compute_TTV(min_index);
    }
    end = chrono::high_resolution_clock::now();
    cout << "\t\t" << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    // 二进制计算
    start = chrono::high_resolution_clock::now();
    TTV = 0;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        TTV += binary_POINT_mul(r4[i], a[i], hexwords[i]);
    }
    end = chrono::high_resolution_clock::now();
    cout << "二进制计算     " << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << "/";
    cout << "\t\t" << TTV / TEST_TIMES << endl;

    // NAF计算
    start = chrono::high_resolution_clock::now();
    TTV = 0;
    for (int i = 0; i < TEST_TIMES; i++)
    {
        TTV += NAF_POINT_mul(r5[i], a[i], hexwords[i]);
    }
    end = chrono::high_resolution_clock::now();
    cout << "NAF计算        " << duration_cast<milliseconds>(end - start).count();
    cout << "\t\t" << "/";
    cout << "\t\t" << TTV / TEST_TIMES << endl;

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