#ifndef GPUEC_256_H
#define GPUEC_256_H
#include <stdio.h>
#include <assert.h>
#include "constants.cuh"

typedef unsigned long long UINT64; //定义64位字类型
typedef long long INT64;

#define NCOMMIT 2

// 仿射点构造
// typedef struct Affine_point{
// 	UINT64 x[4];
// 	UINT64 y[4];
// }Apoint;

// 射影点构造

typedef struct Jacobi_point{
	UINT64 x[4];
	UINT64 y[4];
	UINT64 z[4];
}Jpoint;


typedef struct BulletProofSetupParams{
	Jpoint G;
	Jpoint H;
	int N;//这里默认n是32，为了CPU和CPU之间数据传输的方便
	Jpoint Gg[32];
	Jpoint Hh[32];


	UINT64 ipA[4];
	UINT64 ipB[4];
	Jpoint ipU;
	
	Jpoint ipP;


}BPSetupParams;

typedef struct BulletProofProve{
	
	Jpoint A;
	Jpoint S;
	Jpoint V;
	Jpoint T1;
	Jpoint T2;
	UINT64 Taux[4];
	UINT64 Mu[4];
	UINT64 Tprime[4];
	Jpoint Commit[4];

}BPProve;


typedef struct initParamRandom{
	UINT64 gamma[4];
	UINT64 alpha[4];
	UINT64 rho[4];
	UINT64 tau1[4];
	UINT64 tau2[4];
	UINT64 SL[32*4];
	UINT64 SR[32*4];

}InitParamR;

#define DBC_COEF 10 //次优DBC参数设置，本参数越小计算DBC越快，但DBC质量越好。不过参数过小可能会引起bug，建议不要小于10

#define DBC_MAXLENGTH 100

__constant__ static int b_try[130] = {
		72, 71, 73, 74, 70, 69, 75, 68, 76, 67,
		77, 66, 65, 78, 64, 79, 63, 80, 62, 61,
		81, 60, 82, 59, 58, 83, 57, 84, 56, 55,
		85, 54, 53, 86, 52, 51, 87, 50, 88, 49,
		48, 89, 47, 46, 90, 45, 44, 91, 43, 42,
		92, 41, 40, 93, 39, 38, 94, 37, 36, 95,
		35, 34, 96, 33, 32, 97, 31, 30, 98, 29,
		28, 27, 99, 26, 25, 100, 24, 23, 101, 22,
		21, 102, 20, 19, 103, 18, 17, 104, 16, 15,
		105, 14, 13, 106, 12, 11, 107, 10, 9, 108,
		8, 7, 6, 109, 5, 4, 110, 3, 2, 111,
		1, 112, 0, 113, 114, 115, 116, 117, 118, 119
};

const static UINT64 h_ONE[4]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
const static UINT64 h_mon_ONE[4]={0x1000003d1L,0x0L,0x0L,0x0L};
const static UINT64 h_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};
const static UINT64 h_N[4]={0xBFD25E8CD0364141L,0xBAAEDCE6AF48A03BL,0xFFFFFFFFFFFFFFFEL,0xFFFFFFFFFFFFFFFFL};
const static UINT64 h_R2modN[4]={0x896cf21467d7d140L,0x741496c20e7cf878L,0xe697f5e45bcd07c6L,0x9d671cd581c69bc5L};

__constant__ static UINT64 dc_ONE[4]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
__constant__ static UINT64 dc_mon_ONE[4]={0x1000003d1L,0x0L,0x0L,0x0L};
__constant__ static UINT64 dc_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};
__constant__ static UINT64 dc_N[4]={0xBFD25E8CD0364141L,0xBAAEDCE6AF48A03BL,0xFFFFFFFFFFFFFFFEL,0xFFFFFFFFFFFFFFFFL};
__constant__ static UINT64 dc_R2modN[4]={0x896cf21467d7d140L,0x741496c20e7cf878L,0xe697f5e45bcd07c6L,0x9d671cd581c69bc5L};
__constant__ static UINT64 dc_mon_ONE_modN[4]={0x402da1732fc9bebf,0x4551231950b75fc4,0x1,0x0};
__constant__ static UINT64 dc_mon_TWO_modN[4]={0x805b42e65f937d7e,0x8aa24632a16ebf88,0x2,0x0};
__constant__ static UINT64 dc_R2[4]={0x000007a2000e90a1L,0x1L,0x0L,0x0L};

// occulticplus: we use a.
__constant__ static UINT64 dc_mon_inv_two[4]={0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x8000000000000000L};
const static UINT64 h_mon_inv_two[4]={0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x8000000000000000L};
//
__constant__ static UINT64 dc_mon_a[4]={0xfffffffffffffffcL,0xfffffffc00000003L,0xffffffffffffffffL,0xfffffffbffffffffL};
const static UINT64 h_mon_a[4]={0xfffffffffffffffcL,0xfffffffc00000003L,0xffffffffffffffffL,0xfffffffbffffffffL};


void h_print_para();
void h_mybig_print(const UINT64 *a);
__device__ void d_mybig_print(const UINT64 *a);
__host__ void h_print_pointJ(const Jpoint *pt);
__device__ void d_print_pointJ(const Jpoint *pt);
// void h_print_pointA(const Apoint *pt);
// __device__ __host__ void dh_ellipticSumEqual_AJ(Jpoint *pt1, Apoint* pt2);//pt1,pt2必须保证非无穷远点，在函数中无判断
__device__ __host__ void dh_ellipticAdd_JJ(Jpoint *pt1, Jpoint* pt2,Jpoint* pt3);
__device__ __host__ void dh_mybig_modadd_64(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__ void dh_mybig_modadd_64_modN(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__ void dh_mybig_modsub_64(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__ void dh_mybig_modsub_64_modN(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__ void dh_mybig_modsub_64_ui32_modN(const UINT64 *x, unsigned int y, UINT64 *z);
__device__ __host__ void dh_mybig_neg(UINT64 *y,UINT64 *res);
__device__ __host__ void dh_mybig_neg_modN(UINT64 *y,UINT64 *res);
__device__ __host__ void dh_mybig_monmult_64(const UINT64 *Aa, const UINT64 *Ba, UINT64 *Ca);//pass, c=a*b
__device__ __host__ void dh_mybig_monmult_64_modN(const UINT64 *Aa, const UINT64 *Ba ,UINT64 *Ca);

__device__ __host__ void dh_mybig_half_64(const UINT64 *A, UINT64 *C);
__device__ __host__ void dh_mybig_moddouble_64(const UINT64 *A, const UINT64 *P, UINT64 *C);
__device__ __host__ void ppoint_double(Jpoint *pt1,Jpoint* pt2);
__device__ __host__ void dh_point_mult_inplace(Jpoint* pt1,UINT64 *k);
__device__ __host__ void dh_point_mult_outofplace(Jpoint* pt1,UINT64 *k,Jpoint* pt2);
__device__ __host__ void dh_point_mult_finalversion(Jpoint* pt1,UINT64 *k,Jpoint* pt2);
__device__ void d_base_point_mul(Jpoint *res,UINT64 *k);
// __device__ __host__ void dh_apoint_mult(Jpoint* pt1,Apoint* pt2,UINT64 *k);
__device__ __host__ void dh_mybig_modexp(UINT64* a,UINT64 *k,UINT64* c);
__device__ __host__ void dh_mybig_modexp_modN(UINT64* a,UINT64 *k,UINT64* c);
__device__  void dh_mybig_modexp_ui32_modN(UINT64* a,unsigned int k,UINT64* c);
__device__ __host__ void dh_point_mult_uint32(Jpoint* pt1, int k,Jpoint* pt2);
__device__ __host__ void dh_mybig_moninv(const UINT64 *A,UINT64 *C);
__device__ __host__ void dh_mybig_moninv_modN(const UINT64 *A,UINT64 *C);

__device__ __host__ void ppoint_triple(Jpoint *pt1,Jpoint* pt2);
__device__ __host__ void ppoint_triple_fast(Jpoint *pt1,Jpoint* pt2);
__device__ int run_DBC_v2(Jpoint* pt1, Jpoint* res, int*DBC, int len);
__device__ int get_DBC(uint288 *n, int*DBC_store, int* DBC_len);
int h_get_gpu_info();
#endif /*  GPUEC_256_H */