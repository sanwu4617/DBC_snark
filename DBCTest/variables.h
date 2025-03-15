#ifndef VARIABLES_H
#define VARIABLES_H
#include "DBC.h"
extern BN_CTX* ctx;

extern int DBC_store[2][MAX_2][3]; // 第1维：不同的DBC，第2维：一个DBC的不同项，第3维：符号，2的次数，3的次数
extern int DBC_len[2];

extern myBigInt<INTS> n;
extern myBigInt<INTS> B;
extern myBigInt<INTS> six_n;
extern myBigInt<INTS> record_outer;
extern myBigInt<INTS> temp_outer;
extern uint64 n0;
extern int bBound[MAX_2];

#endif
