#include "functions.h"
DBC minL(DBC a, DBC b)
{
	int temp1 = a.getL();
	int temp2 = b.getL();
	if (temp1 < temp2)
		return a;
	else
		return b;
}
DBC minL(DBC a, DBC b, DBC c)
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
DBC minV(DBC a, DBC b)
{
	int temp1 = a.getV();
	int temp2 = b.getV();
	if (temp1 < temp2)
		return a;
	else
		return b;
}
DBC minV(DBC a, DBC b, DBC c)
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
void bn_dec_printf(BIGNUM* a)
{
	char* p = BN_bn2dec(a);
	printf("%s\n", p);
	OPENSSL_free(p);
}
istream& operator >>(istream& in, BIGNUM*& b)
{
	char temp[1024] = { 0 };
	in >> temp;
	BN_dec2bn(&b, temp);
	return in;
}
ostream& operator << (ostream& out, BIGNUM*& b)
{
	char* p = BN_bn2dec(b);
	out << p;
	return out;
}
void BN_pow23(BIGNUM*& a, int pow_2, int pow_3)
{
	int power_3[19] = { 1,3,9,27,81,243,729,2187,6561,19683,59049,177147,531441,
					 1594323,4782969,14348907 ,43046721 ,129140163 ,387420489 };
	BN_set_word(a, 1);
	int pow_2_a = pow_2 / 31;
	int pow_2_r = pow_2 % 31;
	int pow_3_a = pow_3 / 19;
	int pow_3_r = pow_3 % 19;
	for (int i = 0; i < pow_2_a; i++)
		BN_mul_word(a, (unsigned long)1 << 31);
	for (int i = 0; i < pow_3_a; i++)
		BN_mul_word(a, 1162261467);
	BN_mul_word(a, 1 << pow_2_r);
	BN_mul_word(a, power_3[pow_3_r]);
}