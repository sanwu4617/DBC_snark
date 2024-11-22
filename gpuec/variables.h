//
// Created by occul on 2021/11/15.
//

#ifndef GPUEC_VARIABLES_H
#define GPUEC_VARIABLES_H

#include "DBC.h"
extern DBC w_min;
extern Chain now_DBC[MAX_2];
//extern int t_right[MAX_2];
//extern int t_left[MAX_2];
//variables.h�м�������3������������
extern unsigned int w_min0[4];
extern unsigned short w_rec[MAX_2][MAX_3][3];   //���һά����ֵ�ֱ�Ϊw[i][j]���ȣ�w_[i][j]���ȣ�mode
//extern int MAX_T;
extern double d_pow23[MAX_2][MAX_3];
extern uint288 u_pow23[MAX_2][MAX_3];
#endif //GPUEC_VARIABLES_H
