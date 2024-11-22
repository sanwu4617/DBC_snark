#ifndef GPUEC_256_H
#define GPUEC_256_H

typedef unsigned long long UINT64; //定义64位字类型
typedef long long INT64;

#define NCOMMIT 2

// 仿射点构造
typedef struct Affine_point{
	UINT64 x[4];
	UINT64 y[4];
}Apoint;

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

	UINT64 ipN;
	UINT64 ipCc[4];
	Jpoint ipUu;
	Jpoint ipH;
	Jpoint ipP;
	Jpoint ipGg[32];
	Jpoint ipHh[32];

}BPSetupParams;

typedef struct BulletProofProve{
	Jpoint V[NCOMMIT];
	Jpoint A;
	Jpoint S;
	Jpoint T1;
	Jpoint T2;
	UINT64 Taux[4];
	UINT64 Mu[4];
	UINT64 Tprime[4];
	Jpoint Commit[4];

}BPProve;


typedef struct initParamRandom{
	UINT64 gamma[4*NCOMMIT];
	UINT64 alpha[4];
	UINT64 rho[4];
	UINT64 tau1[4];
	UINT64 tau2[4];
	UINT64 SL[32*4*NCOMMIT];
	UINT64 SR[32*4*NCOMMIT];

}InitParamR;


const static UINT64 h_ONE[4]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
const static UINT64 h_mon_ONE[4]={0x1000003d1L,0x0L,0x0L,0x0L};
const static UINT64 h_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};
const static UINT64 h_N[4]={0xBFD25E8CD0364141L,0xBAAEDCE6AF48A03BL,0xFFFFFFFFFFFFFFFEL,0xFFFFFFFFFFFFFFFFL};

__constant__ static UINT64 dc_ONE[4]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
__constant__ static UINT64 dc_mon_ONE[4]={0x1000003d1L,0x0L,0x0L,0x0L};
__constant__ static UINT64 dc_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};
__constant__ static UINT64 dc_N[4]={0xBFD25E8CD0364141L,0xBAAEDCE6AF48A03BL,0xFFFFFFFFFFFFFFFEL,0xFFFFFFFFFFFFFFFFL};

void h_print_para();
void h_mybig_print(const UINT64 *a);
void h_print_pointJ(const Jpoint *pt);
void h_print_pointA(const Apoint *pt);
__device__ __host__ void dh_ellipticSumEqual_AJ(Jpoint *pt1, Apoint* pt2);//pt1,pt2必须保证非无穷远点，在函数中无判断
__device__ __host__ void dh_ellipticAdd_JJ(Jpoint *pt1, Jpoint* pt2,Jpoint* pt3);
__device__ __host__ void dh_mybig_modadd_64(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__ void dh_mybig_modsub_64(const UINT64 *x, const UINT64 *y, UINT64 *z);
__device__ __host__ void dh_mybig_monmult_64(const UINT64 *Aa, const UINT64 *Ba, UINT64 *Ca);//pass, c=a*b
__device__ __host__ void dh_mybig_monmult_64_modN(const UINT64 *Aa, const UINT64 *Ba ,UINT64 *Ca);
__device__ __host__ void dh_mybig_half_64(const UINT64 *A, UINT64 *C);
__device__ __host__ void dh_mybig_moddouble_64(const UINT64 *A, const UINT64 *P, UINT64 *C);
__device__ __host__ void ppoint_double(Jpoint *pt1,Jpoint* pt2);
__device__ __host__ void dh_point_mult_inplace(Jpoint* pt1,UINT64 *k);
__device__ __host__ void dh_point_mult_outofplace(Jpoint* pt1,UINT64 *k,Jpoint* pt2);
__device__ __host__ void dh_point_mult_finalversion(Jpoint* pt1,UINT64 *k,Jpoint* pt2);
__device__ __host__ void dh_apoint_mult(Jpoint* pt1,Apoint* pt2,UINT64 *k);
__device__ __host__ void dh_mybig_modexp(UINT64* a,UINT64 *k,UINT64* c);
__device__ __host__ void dh_point_mult_uint32(Jpoint* pt1, int k,Jpoint* pt2);
__device__ __host__ void dh_mybig_moninv(const UINT64 *A,UINT64 *C);
__device__ __host__ void dh_mybig_moninv_modN(const UINT64 *A,UINT64 *C);

#endif /*  GPUEC_256_H */