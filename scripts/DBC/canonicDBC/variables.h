#ifndef VARIABLES_H
#define VARIABLES_H
#include "DBC.h"
extern DBC w_min;
extern Chain now_DBC[MAX_2];
extern int t_right[MAX_2];
extern int t_left[MAX_2];
//variables.h中加入下面3个变量的声明
extern unsigned int w_min0[4];
extern unsigned short w_rec[MAX_2][MAX_3][3];   //最后一维三个值分别为w[i][j]长度，w_[i][j]长度，mode
extern int MAX_T;
extern double d_pow23[MAX_2][MAX_3];
extern uint288 u_pow23[MAX_2][MAX_3];
#endif
