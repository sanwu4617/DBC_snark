//
// Created by occul on 2021/10/15.
//

#ifndef GPUEC_DBC_H
#define GPUEC_DBC_H

#include "uint288.h"
#include "constants.h"
#include <cstdio>

// 更新DBC代码 jiangze 2022/09/09
#define MAX_2 270
#define MAX_3 180
#define dbl_cost 7
#define add_cost 15
#define tpl_cost 22

#define DBC_COEF 10 //次优DBC参数设置，本参数越小计算DBC越快，但DBC质量越好。不过参数过小可能会引起bug，建议不要小于10

struct DBC
{
	/* data */
	int value[MAX_2][3];
	int length;
};


struct DBCv2 {
	int DBC_store[DBC_COEF][MAX_2][3] = {0};
	int DBC_len[MAX_2] = {0};
	__host__ __device__ int getDBC(uint288* n);
};

#endif //GPUEC_DBC_H
