#ifndef FUNCTIONS_H

#define FUNCTIONS_H

#include "DBC.h"

void init();

DBC minL(DBC a, DBC b);

DBC minL(DBC a, DBC b, DBC c);

DBC minV(DBC a, DBC b);

DBC minV(DBC a, DBC b, DBC c);

void bn_dec_printf(BIGNUM* a);

istream& operator >>(istream& in, BIGNUM*& b);

ostream& operator << (ostream& out, BIGNUM*& b);

void BN_pow23(BIGNUM*& a, int pow_2, int pow_3);

#endif



