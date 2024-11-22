#ifndef GPUEC_H
#define GPUEC_H

typedef unsigned long long UINT64; //定义64位字类型
typedef long long INT64;

void h_print_para();
void h_mybig_print(const UINT64 *a);
__device__ __host__ void dh_mybig_modadd_64(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__ void dh_mybig_modsub_64(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__  void dh_mybig_monmult_64(const UINT64 *Aa, const UINT64 *Ba, UINT64 *Ca);//pass, c=a*b
#endif /*  GPUEC_H */