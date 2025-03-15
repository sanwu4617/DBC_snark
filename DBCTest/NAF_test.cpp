#include <iostream>
#include <vector>
#include <algorithm>
#include <openssl/bn.h>
using namespace std;
vector<int> int_to_naf(BIGNUM *n)
{
    if (BN_is_zero(n))
    {
        return {0};
    }

    vector<int> naf;
    BIGNUM *two = BN_new(), *four = BN_new(), *mod_result = BN_new(), *ni_bn = BN_new();
    BN_CTX *ctx = BN_CTX_new();

    BN_set_word(two, 2);
    BN_set_word(four, 4);

    while (!BN_is_zero(n))
    {
        BN_mod(mod_result, n, two, ctx);
        // Check if n is even
        if (BN_is_zero(mod_result))
        {
            naf.push_back(0);
        }
        else
        {
            // Find the closest odd value and decide between +1 or -1
            BN_mod(mod_result, n, four, ctx);
            int ni = 2 - BN_get_word(mod_result);
            naf.push_back(ni);
            ni > 0 ? BN_sub(n, n, BN_value_one()) : BN_add(n, n, BN_value_one());
        }
        BN_div(n, NULL, n, two, ctx); // This only keeps the quotient part, discarding remainder.
        BN_print_fp(stdout,n);
        cout<<endl;
    }

    BN_free(two);
    BN_free(four);
    BN_free(mod_result);
    BN_free(ni_bn);
    BN_CTX_free(ctx);
    reverse(naf.begin(), naf.end());
    return naf;
}

int main()
{
    // 示例：计算整数的NAF表示
    // OpenSSL_add_all_algorithms(); // 初始化算法

    BIGNUM *n = BN_new();
    BN_dec2bn(&n, "123"); // 将字符串"123"转换为BIGNUM类型的值，你可以替换为你想计算的任意整数值

    vector<int> naf_representation = int_to_naf(n);

    cout << "整数 ";
    BN_print_fp(stdout, n); // 打印BIGNUM类型的值
    cout << " 的NAF表示形式为: ";
    for (int bit : naf_representation)
    {
        cout << bit<<',';
    }
    cout << endl;

    BN_free(n);
    // EVP_cleanup(); // 清理资源

    return 0;
}