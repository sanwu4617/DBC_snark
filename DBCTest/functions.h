#ifndef FUNCTIONS_H

#define FUNCTIONS_H

#include "DBC.h"

extern EC_GROUP *group;
extern EC_KEY *key;
void init();

template <int N>
optimal_DBC<N> minL(optimal_DBC<N> a, optimal_DBC<N> b)
{
	int temp1 = a.getL();
	int temp2 = b.getL();
	if (temp1 < temp2)
		return a;
	else
		return b;
}

template <int N>
optimal_DBC<N> minL(optimal_DBC<N> a, optimal_DBC<N> b, optimal_DBC<N> c)
{
	int temp1 = a.getL();
	int temp2 = b.getL();
	int temp3 = c.getL();
	if (temp1 < temp2)
	{
		if (temp1 < temp3)
			return a;
		return c;
	}
	else
	{
		if (temp2 < temp3)
			return b;
		return c;
	}
}

template <int N>
optimal_DBC<N> minV(optimal_DBC<N> a, optimal_DBC<N> b)
{
	int temp1 = a.getV();
	int temp2 = b.getV();
	if (temp1 < temp2)
		return a;
	else
		return b;
}

template <int N>
optimal_DBC<N> minV(optimal_DBC<N> a, optimal_DBC<N> b, optimal_DBC<N> c)
{
	int temp1 = a.getV();
	int temp2 = b.getV();
	int temp3 = c.getV();
	if (temp1 < temp2)
	{
		if (temp1 < temp3)
			return a;
		return c;
	}
	else
	{
		if (temp2 < temp3)
			return b;
		return c;
	}
}

inline void print_point(EC_POINT *a)
{
	BIGNUM *x = BN_new();
	BIGNUM *y = BN_new();
	if (EC_POINT_get_affine_coordinates_GFp(group, a, x, y, NULL))
	{
		BN_print_fp(stdout, x);
		putc('\n', stdout);
		BN_print_fp(stdout, y);
		putc('\n', stdout);
	}
}

inline void DBC_POINT_mul(EC_POINT *r, EC_POINT *a, int min_index = 0)
{
	// 计算椭圆曲线倍点
	EC_POINT *invert_a = EC_POINT_new(group);
	EC_POINT_copy(invert_a, a);
	EC_POINT_invert(group, invert_a, ctx);

	EC_POINT_add(group, r, a, a, ctx);
	EC_POINT_add(group, r, r, invert_a, ctx);

	int now_dbl = DBC_store[min_index][0][1], now_tpl = DBC_store[min_index][0][2];
	bool first = true;
	for (int i = 1; i < DBC_len[min_index]; i++)
	{
		// cout << i << '\t' << DBC_store[min_index][i][0] << '\t' << DBC_store[min_index][i][1] << '\t' << DBC_store[min_index][i][2] << '\t' << now_dbl << '\t' << now_tpl << endl;
		while (1)
		{
			if (now_dbl > DBC_store[min_index][i][1])
			{
				EC_POINT_dbl(group, r, r, ctx);
				now_dbl--;
			}
			else if (now_tpl > DBC_store[min_index][i][2])
			{
				EC_POINT_tpl(group, r, r, ctx);
				now_tpl--;
			}
			else
				break;
		}
		if (DBC_store[min_index][i][0] == -1)
		{
			EC_POINT_add(group, r, r, invert_a, ctx);
		}
		else
		{
			EC_POINT_add(group, r, r, a, ctx);
		}
	}
	while (now_dbl > 0)
	{
		EC_POINT_dbl(group, r, r, ctx);
		now_dbl--;
	}
	while (now_tpl > 0)
	{
		EC_POINT_tpl(group, r, r, ctx);
		now_tpl--;
	}
}

inline double binary_POINT_mul(EC_POINT *r, EC_POINT *a, char *hexwords)
{
	double TTV = 0; // 理论时值
	BIGNUM *n = BN_new();
	BN_hex2bn(&n, hexwords);
	// 计算椭圆曲线倍点
	EC_POINT *mult_points = EC_POINT_new(group);
	EC_POINT_copy(mult_points, a);

	BIGNUM *two = BN_new(), *mod_result = BN_new();
	BN_CTX *ctx = BN_CTX_new();

	BN_set_word(two, 2);

	while (BN_is_zero(n) == 0)
	{
		BN_mod(mod_result, n, two, ctx);
		if (!BN_is_zero(mod_result))
		{ // 检查 n 是否为奇数
			if (!EC_POINT_add(group, r, r, mult_points, ctx))
			{
				fprintf(stderr, "EC_POINT_add failed.\n");
				break;
			}
			TTV += 15;
		}
		if (!EC_POINT_dbl(group, mult_points, mult_points, ctx))
		{
			fprintf(stderr, "EC_POINT_dbl failed.\n");
			break;
		}
		TTV += 7;
		if (!BN_rshift1(n, n))
		{
			fprintf(stderr, "BN_rshift1 failed.\n");
			break;
		}
	}
	BN_free(two);
	BN_free(mod_result);
	BN_CTX_free(ctx);
	return TTV;
}

inline vector<int> int_to_naf(BIGNUM *n)
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

	int remainder=0;
	while (!BN_is_zero(n))
	{
		BN_mod(mod_result, n, two, ctx);
		// BN_mod(mod_result, n, two, ctx);
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
	}

	BN_free(two);
	BN_free(four);
	BN_free(mod_result);
	BN_free(ni_bn);
	BN_CTX_free(ctx);
	reverse(naf.begin(), naf.end());
	return naf;
}

inline double NAF_POINT_mul(EC_POINT *R, EC_POINT *G, char *hexwords)
{
	BIGNUM *k = BN_new();
	BN_hex2bn(&k, hexwords);

	EC_POINT *invert_G = EC_POINT_new(group);
	EC_POINT_copy(invert_G, G);
	EC_POINT_invert(group, invert_G, ctx);

	EC_POINT_copy(R, G);

	auto NAF = int_to_naf(k);
	double TTV = 0;

	for (int i = 1; i < NAF.size(); i++)
	{
		EC_POINT_dbl(group, R, R, ctx);
		TTV += 7;
		if (NAF[i] == 1)
		{
			EC_POINT_add(group, R, R, G, ctx);
			TTV += 15;
		}
		if (NAF[i] == -1)
		{
			EC_POINT_add(group, R, R, invert_G, ctx);
			TTV += 15;
		}
	}
	return TTV;
}

inline void print_DBC(int index)
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
		cout << "2**" << DBC_store[index][i][1] << " * 3**" << DBC_store[index][i][2];
	}
	cout << endl;
}

inline double compute_TTV(int min_index)
{
	return (DBC_len[min_index] - 1) * 15 + DBC_store[min_index][0][1] * 7 + DBC_store[min_index][0][2] * 12.6;
}
#endif