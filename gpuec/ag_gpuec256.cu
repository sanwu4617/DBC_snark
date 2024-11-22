#include <stdio.h>
#include "ag_gpuec256.h"
// typedef unsigned long long UINT64; //定义64位字类型
// typedef long long INT64;
// typedef unsigned int UINT32;
// // 仿射点构造
// typedef struct Affine_point{
// 	UINT64 x[8];
// 	UINT64 y[8];
// }Apoint;

// // 射影点构造
// typedef struct Jacobi_point{
// 	UINT64 x[8];
// 	UINT64 y[8];
// 	UINT64 z[8];
// }Jpoint;


// 在tesla C2050上目前这组参数测得效率最高，不可修改。
#define PARAL 64
#define BLOCKNUM (14*8)
#define BLOCKSIZE 32
#define THREADNUM (BLOCKNUM*BLOCKSIZE)


// 定义__global__类型的变量，存放16比特表。
#define d_BIN_WINDOW_16 16 //16比特表
#define d_ROWS_16 32
#define d_COLS_16 (1L<<d_BIN_WINDOW_16)


#define HANDLE_ERROR( err ) { if (err != cudaSuccess) { \
		printf( "%s in %s at line %d\n", cudaGetErrorString( err ), __FILE__, __LINE__ );\
	  exit( EXIT_FAILURE ); }  \
}

//版本为512比特曲线规模，可自行修改为256比特版本
//该版本曲线所在素域整数为特殊素数
//h_ONE是host用的域元素1
//dc_ONE是gpu卡用的域元素1
//h_mon_ONE和dc_mon_ONE相等，分别定义host和gpu卡所用的蒙哥马利域上的1
//h_p和dc_p是512比特素数
//Pa0到Pa7是将素数分开定义为宏定义

// const UINT64 h_ONE[8]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
// const UINT64 h_mon_ONE[8]={0x0000000000000001L,0x0000000100000000L,0x0000000000000000L,0x0000000100000000L,0x0000000000000000L,0x0000000000000001L,0x0000000100000000L,0x0000000000000000L};
// const UINT64 h_p[8]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0x0L,0x0L,0x0L,0x0L};

// __constant__ UINT64 dc_ONE[8]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
// __constant__ UINT64 dc_mon_ONE[8]={0x0000000000000001L,0x0000000100000000L,0x0000000000000000L,0x0000000100000000L,0x0000000000000000L,0x0000000000000001L,0x0000000100000000L,0x0000000000000000L};
// __constant__ UINT64 dc_p[8]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0x0L,0x0L,0x0L,0x0L};


// const UINT64 h_ONE[4]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
// const UINT64 h_mon_ONE[4]={0x1000003d1L,0x0L,0x0L,0x0L};
// const UINT64 h_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};

// __constant__ UINT64 dc_ONE[4]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
// __constant__ UINT64 dc_mon_ONE[4]={0x1000003d1L,0x0L,0x0L,0x0L};
// __constant__ UINT64 dc_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};

__constant__ UINT64 dc_mon_inv_two[4]={0x0L,0x0L,0x0L,0x8000000000000000L};
const UINT64 h_mon_inv_two[4]={0x0L,0x0L,0x0L,0x8000000000000000L};

#define Pa0 0xFFFFFFFEFFFFFC2FLL //-1
#define Pa1 0xFFFFFFFFFFFFFFFFLL 
#define Pa2 0xFFFFFFFFFFFFFFFFLL //-1
#define Pa3 0xFFFFFFFFFFFFFFFFLL 
// #define Pa4 0x0 //-1
// #define Pa5 0x0 //-2
// #define Pa6 0x0 
// #define Pa7 0x0 //-1


/////////////////GPU大整数运算函数开始////////////////////////////////////////////////////

// #define dh_mybig_copy(a,b) {(a)[0]=(b)[0];(a)[1]=(b)[1];(a)[2]=(b)[2];(a)[3]=(b)[3];(a)[4]=(b)[4];(a)[5]=(b)[5];(a)[6]=(b)[6];(a)[7]=(b)[7];}
#define dh_mybig_copy(a,b) {(a)[0]=(b)[0];(a)[1]=(b)[1];(a)[2]=(b)[2];(a)[3]=(b)[3];}

//实现整大整数模加函数
__device__ __host__ void dh_mybig_modadd_64(const UINT64 *x, const UINT64 *y, UINT64 *z)//可以z=x+y, x=x+y, 不能实现y=x+y！
{
	int i;
	UINT64 f,g;
		
	#ifdef __CUDA_ARCH__
		const UINT64 *Pa=dc_p;
	#else
		const UINT64 *Pa=h_p;
	#endif	
	
	z[0] = x[0] + y[0]; f = z[0] < y[0];
	z[1] = x[1] + f; g = z[1] < f; z[1] += y[1]; g += z[1] < y[1];
	z[2] = x[2] + g; f = z[2] < g; z[2] += y[2]; f += z[2] < y[2];
	z[3] = x[3] + f; g = z[3] < f; z[3] += y[3]; g += z[3] < y[3];
	
	// z[4] = x[4] + g; f = z[4] < g; z[4] += y[4]; f += z[4] < y[4];
	// z[5] = x[5] + f; g = z[5] < f; z[5] += y[5]; g += z[5] < y[5];
	// z[6] = x[6] + g; f = z[6] < g; z[6] += y[6]; f += z[6] < y[6];
	// z[7] = x[7] + f; g = z[7] < f; z[7] += y[7]; g += z[7] < y[7];
		
	if(g==0)
	{
		for(i=3;i>=0;i--)
		{
			if(z[i]!=Pa[i])
			{
				g=(z[i]>Pa[i]);
				break;
			}
			else if(i==0)//全相等,即t=P, 其实此时赋值为0即可
			{
				g=1;
			}
		}
	}
	
	if(g)//x+y可能等于模数
	{
		f = z[0] < Pa0; z[0] -= Pa0;
		g = z[1] < f; z[1] -= f; g += z[1] < Pa1; z[1] -= Pa1;
		f = z[2] < g; z[2] -= g; f += z[2] < Pa2; z[2] -= Pa2;
		z[3] -= f; z[3] -= Pa3;		                                                  
		// g = z[3] < f; z[3] -= f; g += z[3] < Pa3; z[3] -= Pa3;		
		// f = z[4] < g; z[4] -= g; f += z[4] < Pa4; z[4] -= Pa4;		                                                  
		// g = z[5] < f; z[5] -= f; g += z[5] < Pa5; z[5] -= Pa5;
		// f = z[6] < g; z[6] -= g; f += z[6] < Pa6; z[6] -= Pa6;				
		// z[7] -= f; z[7] -= Pa7;
	}
}

//实现整大整数模减函数
__device__ __host__ void dh_mybig_modsub_64(const UINT64 *x, const UINT64 *y, UINT64 *z)//可以z=x-y, x=x-y, 不能实现y=x-y！
{
	UINT64 f,g;
	//UINT64 z0,z1,z2,z3,z4,z5,z6,z7;
	f=(x[0]<y[0]); z[0]=x[0]-y[0];
	g=(x[1]<f); z[1]=x[1]-f; g+=(z[1]<y[1]); z[1]-=y[1];
	f=(x[2]<g); z[2]=x[2]-g; f+=(z[2]<y[2]); z[2]-=y[2];
	g=(x[3]<f); z[3]=x[3]-f; g+=(z[3]<y[3]); z[3]-=y[3];
	
	// f=(x[4]<g); z[4]=x[4]-g; f+=(z[4]<y[4]); z[4]-=y[4];
	// g=(x[5]<f); z[5]=x[5]-f; g+=(z[5]<y[5]); z[5]-=y[5];
	// f=(x[6]<g); z[6]=x[6]-g; f+=(z[6]<y[6]); z[6]-=y[6];
	// g=(x[7]<f); z[7]=x[7]-f; g+=(z[7]<y[7]); z[7]-=y[7];
	//进位为g;

	if(g)//只判断进位，速度应该快一点
	{
		z[0]+=Pa0; f=(z[0]<Pa0);
		z[1]+=f; f=(z[1]<f); z[1]+=Pa1; f+=(z[1]<Pa1);
		z[2]+=f; f=(z[2]<f); z[2]+=Pa2; f+=(z[2]<Pa2);
		z[3]+=f; z[3]+=Pa3;		
		// z[3]+=f; f=(z[3]<f); z[3]+=Pa3; f+=(z[3]<Pa3);
		// z[4]+=f; f=(z[4]<f); z[4]+=Pa4; f+=(z[4]<Pa4);
		// z[5]+=f; f=(z[5]<f); z[5]+=Pa5; f+=(z[5]<Pa5);
		// z[6]+=f; f=(z[6]<f); z[6]+=Pa6; f+=(z[6]<Pa6);
		// z[7]+=f; z[7]+=Pa7;		
	}	
}

//主机汇编语言乘法，取64位乘法高位
static inline UINT64 h_Hi64(const UINT64 x, const UINT64 y)
{
   UINT64 z;   
   __asm__ __volatile__ (
	  "movq  %0,%%rax\n"   
	  "mulq %1\n"
	  "movq %%rdx,%2\n"
	  : 
	  : "m"(x),"m"(y),"m"(z)
	  : "rax","rdx","memory"
	  );      	
	return z;
}

//实现蒙哥马利乘法C=a*b
/////////////////////////////////////////
//Montgomery模乘
//C=A*B*2^-512 mod P
//采用CIOS算法
//////////////////////////////////////////
__device__ __host__  void dh_mybig_monmult_64(const UINT64 *Aa, const UINT64 *Ba, UINT64 *Ca)//pass, c=a*b
{
	UINT64 t[4+2]={0};//8个64比特整字,限定512
	
	//minv*P[0] mod 2^wordlen = -1. 因为该程序字长是64比特，P[0]=0xffffffffffffffff=-1，所以minv=1, minv*P[0]=-1 mod 2^64=-1
	
	//如果是其他P，则需要重新计算设置。这个值最好是传入，或者定义为全局变量
	// UINT64 minv=1;//minv值需要跟域特征P的最低位P[0]乘积模2^64=-1(因为P[0]是64比特字，如果是32比特字，就找到模2^32=-1那个数， 即得到域特征素数的最低字的模2^wordlen的逆的负值。
	UINT64 minv = 0xd838091dd2253531;
	UINT64 m;	
	UINT64 c,s,cin;
	int i,j;
	
	#ifdef __CUDA_ARCH__	
		UINT64 *Pa=dc_p;	
		#define h_Hi64 __umul64hi
	#else
		const UINT64 *Pa=h_p;
	#endif	
	
	for(i=0;i<4;i++)
	{
		c=0;
		m=Ba[i];
		
		s=m*Aa[0]; c+=t[0];	cin=(c<t[0]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[0])+cin; 	t[0]=s;
		s=m*Aa[1]; c+=t[1];	cin=(c<t[1]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[1])+cin; 	t[1]=s;
		s=m*Aa[2]; c+=t[2];	cin=(c<t[2]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[2])+cin; 	t[2]=s;
		s=m*Aa[3]; c+=t[3];	cin=(c<t[3]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[3])+cin; 	t[3]=s;
		// s=m*Aa[4]; c+=t[4];	cin=(c<t[4]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[4])+cin; 	t[4]=s;
		// s=m*Aa[5]; c+=t[5];	cin=(c<t[5]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[5])+cin; 	t[5]=s;
		// s=m*Aa[6]; c+=t[6];	cin=(c<t[6]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[6])+cin; 	t[6]=s;
		// s=m*Aa[7]; c+=t[7];	cin=(c<t[7]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[7])+cin; 	t[7]=s;		
								
		s=t[4]+c;
		c=(s<c);
		t[4]=s;
		t[4+1]=c;
				
		m=minv*t[0];//特殊p，minv=1，等价于m=t[0]
		c=h_Hi64(m,Pa0);
		s=m*Pa0+t[0];   //因为对于这个域素数，Pa0=-1, minv=1，所以s=0;		
		c+=(s<t[0]);
		
		s=m*Pa1; c+=t[1]; cin=(c<t[1]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa1)+cin; t[0]=s;		
		s=m*Pa2; c+=t[2]; cin=(c<t[2]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa2)+cin; t[1]=s;
		s=m*Pa3; c+=t[3]; cin=(c<t[3]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa3)+cin; t[2]=s;		
	    // s=m*Pa4; c+=t[4]; cin=(c<t[4]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa4)+cin; t[3]=s;		
		// s=m*Pa5; c+=t[5]; cin=(c<t[5]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa5)+cin; t[4]=s;
		// s=m*Pa6; c+=t[6]; cin=(c<t[6]); s+=c;	cin+=(s<c); c=h_Hi64(m,Pa6)+cin; t[5]=s;		
		// s=m*Pa7; c+=t[7]; cin=(c<t[7]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa7)+cin; t[6]=s;
		
		s=t[4]+c;
		c=(s<c);
		t[4-1]=s;
		t[4]=t[4+1]+c;
	}
	
	j=(t[4]!=0);
	if(j==0)
	{
		for(i=4-1;i>=0;i--)
		{
			if(t[i]!=Pa[i])
			{				
				j=(t[i]>Pa[i]);
				break;
			}
			else if(i==0)//全相等,即t=P, 其实此时赋值为0即可
			{
				j=1;
			}
		}
	}
	
	//减法	
	if(j)
	{
		cin=1;	
		for(i=0;i<4;i++)
		{
			m=cin+(~Pa[i]);
			cin=(m<cin);
			m+=t[i];
			cin+=(m<t[i]);
			Ca[i]=m;
		}
	}
	else
	{
		for(i=0;i<4;i++)
		{
			Ca[i]=t[i];
		}
	}
	
	#ifdef __CUDA_ARCH__	
		#undef h_Hi64 
	#endif	
}

__device__ __host__  void dh_mybig_monmult_64_modN(const UINT64 *Aa, const UINT64 *Ba ,UINT64 *Ca)//pass, c=a*b
{
	UINT64 t[4+2]={0};//8个64比特整字,限定512
	
	//minv*P[0] mod 2^wordlen = -1. 因为该程序字长是64比特，P[0]=0xffffffffffffffff=-1，所以minv=1, minv*P[0]=-1 mod 2^64=-1
	
	//如果是其他P，则需要重新计算设置。这个值最好是传入，或者定义为全局变量
	// UINT64 minv=1;//minv值需要跟域特征P的最低位P[0]乘积模2^64=-1(因为P[0]是64比特字，如果是32比特字，就找到模2^32=-1那个数， 即得到域特征素数的最低字的模2^wordlen的逆的负值。
	UINT64 minv = 0x4b0dff665588b13f;
	UINT64 m;	
	UINT64 c,s,cin;
	int i,j;
	
	#ifdef __CUDA_ARCH__	
		UINT64 *Pa=dc_N;	
		#define h_Hi64 __umul64hi
	#else
		const UINT64 *Pa=h_N;
	#endif	
	// const UINT64 *Pa=P; 
	
	for(i=0;i<4;i++)
	{
		c=0;
		m=Ba[i];
		
		s=m*Aa[0]; c+=t[0];	cin=(c<t[0]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[0])+cin; 	t[0]=s;
		s=m*Aa[1]; c+=t[1];	cin=(c<t[1]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[1])+cin; 	t[1]=s;
		s=m*Aa[2]; c+=t[2];	cin=(c<t[2]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[2])+cin; 	t[2]=s;
		s=m*Aa[3]; c+=t[3];	cin=(c<t[3]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[3])+cin; 	t[3]=s;
		// s=m*Aa[4]; c+=t[4];	cin=(c<t[4]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[4])+cin; 	t[4]=s;
		// s=m*Aa[5]; c+=t[5];	cin=(c<t[5]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[5])+cin; 	t[5]=s;
		// s=m*Aa[6]; c+=t[6];	cin=(c<t[6]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[6])+cin; 	t[6]=s;
		// s=m*Aa[7]; c+=t[7];	cin=(c<t[7]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[7])+cin; 	t[7]=s;		
								
		s=t[4]+c;
		c=(s<c);
		t[4]=s;
		t[4+1]=c;
				
		m=minv*t[0];//特殊p，minv=1，等价于m=t[0]
		c=h_Hi64(m,Pa[0]);
		s=m*Pa[0]+t[0];   //因为对于这个域素数，Pa0=-1, minv=1，所以s=0;		
		c+=(s<t[0]);
		
		s=m*Pa[1]; c+=t[1]; cin=(c<t[1]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa[1])+cin; t[0]=s;		
		s=m*Pa[2]; c+=t[2]; cin=(c<t[2]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa[2])+cin; t[1]=s;
		s=m*Pa[3]; c+=t[3]; cin=(c<t[3]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa[3])+cin; t[2]=s;		
	    // s=m*Pa4; c+=t[4]; cin=(c<t[4]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa4)+cin; t[3]=s;		
		// s=m*Pa5; c+=t[5]; cin=(c<t[5]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa5)+cin; t[4]=s;
		// s=m*Pa6; c+=t[6]; cin=(c<t[6]); s+=c;	cin+=(s<c); c=h_Hi64(m,Pa6)+cin; t[5]=s;		
		// s=m*Pa7; c+=t[7]; cin=(c<t[7]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa7)+cin; t[6]=s;
		
		s=t[4]+c;
		c=(s<c);
		t[4-1]=s;
		t[4]=t[4+1]+c;
	}
	
	j=(t[4]!=0);
	if(j==0)
	{
		for(i=4-1;i>=0;i--)
		{
			if(t[i]!=Pa[i])
			{				
				j=(t[i]>Pa[i]);
				break;
			}
			else if(i==0)//全相等,即t=P, 其实此时赋值为0即可
			{
				j=1;
			}
		}
	}
	
	//减法	
	if(j)
	{
		cin=1;	
		for(i=0;i<4;i++)
		{
			m=cin+(~Pa[i]);
			cin=(m<cin);
			m+=t[i];
			cin+=(m<t[i]);
			Ca[i]=m;
		}
	}
	else
	{
		for(i=0;i<4;i++)
		{
			Ca[i]=t[i];
		}
	}
	
	#ifdef __CUDA_ARCH__	
		#undef h_Hi64 
	#endif	
}



//////////////////////////////////////test inv//////////////////////////////////////
//A!=0 return 0
//A=0 return 1
__device__ __host__ int dh_mybig_iszero_64(const UINT64 *A)
{
	int i;
	for(i=0;i<4;i++)
	{
		if(A[i]!=0)	return 0;
	}
	return 1;	
}


//比较大小
//return 1	A>B
//return 0	A=B
//return -1 A<B
__device__ __host__ int dh_mybig_compare_64(const UINT64 *A, const UINT64 *B)
{
	int i;
	int flag=0;

	for(i=3;i>=0;i--)
	{
		if(A[i]>B[i])
		{
			flag=1;
			break;
		}
		else if(A[i]<B[i])
		{
			flag=-1;
			break;
		}
	}
	return (flag);
}

//C=A/2
__device__ __host__ void dh_mybig_half_64(const UINT64 *A, UINT64 *C)
{
	int i;
	UINT64 c,c1;

	c=0;
	for(i=4-1;i>=0;i--)
	{
		c1=A[i]&0x1;
		C[i]=c<<(63)|A[i]>>1;
		c=c1;
	}
}

//C=2A
__device__ __host__ UINT64 dh_mybig_double_64(const UINT64 *A, UINT64 *C)//pass
{
	int i;
	UINT64 c,c1;

	c=0;
	for(i=0;i<4;i++)
	{
		c1=A[i]>>63;
		C[i]=(C[i]<<1)|c;
		c=c1;
	}
	return c;
}

//C=A-B
__device__ __host__ void dh_mybig_sub_64(const UINT64 *A, const UINT64 *B, UINT64 *C)
{
	int i;
	UINT64 c,l,h;

	c=1;
	for(i=0;i<4;i++)
	{
		l=(~B[i])+c;
		h=(l<c);
		l+=A[i];
		c=h+(l<A[i]);
		C[i]=l;	
	}
}

//C=A+B
__device__ __host__ UINT64 dh_mybig_add_64(const UINT64 *A, const UINT64 *B, UINT64 *C)
{
	int i;
	UINT64 c,l,h;
	
	c=0;
	for(i=0;i<4;i++)
	{
		l=A[i]+c;
		h=(l<c);
		l+=B[i];
		c=h+(l<B[i]);
		C[i]=l;
	}
	return c;
}

/////////////////////////////////////////
//乘2模
//输入:		A P
//输出:		C
//C=2*A mod P
//////////////////////////////////////////
__device__ __host__ void dh_mybig_moddouble_64(const UINT64 *A, const UINT64 *P, UINT64 *C)
{
	int i,sub_en=0;
	UINT64 cin,c,temp64;

	//移位
	cin=(A[0]>>63)&0x1;//全体左移一位,相当于乘2
	C[0]=A[0]<<1;
	for(i=1;i<4;i++)
	{
		c=(A[i]>>63)&0x1;
		C[i]=(A[i]<<1)|cin;
		cin=c;
	}

	//比较大小
	if(cin==1)//最后还有一个进位为1,表明这么多字节已经存不下2*A，因此2*A肯定比p大
	{
		sub_en=1;
	}
	else
	{
		for(i=3;i>=0;i--)
		{
			if(C[i]!=P[i])
			{
				if(C[i]>P[i]) sub_en=1;
				break;
			}
			else if(i==0) sub_en=1;//就是全相等
		}
	}
	
	//减法
	if(sub_en)//这里应该写为if(sub_en!=0)即可避免问题
	{
		cin=1;
		for(i=0;i<4;i++)
		{			
			temp64=(~P[i])+cin;
			c=(temp64<cin);
			temp64+=C[i];
			cin=c+(temp64<C[i]);
			C[i]=temp64;
		}
	}
}


__device__ __host__  int dh_mybig_iszero(const UINT64 * A)
{
	// if( A[0]|A[1]|A[2]|A[3]|A[4]|A[5]|A[6]|A[7])
	// 	return 0;
	// else return 1;
	if( A[0]|A[1]|A[2]|A[3])
		return 0;
	else return 1;
}

void h_mybig_print(const UINT64 *a)
{
	int i;
	unsigned char *t=(unsigned char*) a;
	for(i=32-1;i>=0;i--) if(*(t+i)) break;//把0都跳过去
	if(i<0) printf("0");
	else
	{
		printf("%x",*(t+i)&0xff);//第一个0不打印
		for(i=i-1;i>=0;i--)printf("%02x",*(t+i)&0xff);
	}
	printf("\n");	
}

/////////////////////////////////////////
//程序功能: 计算模逆C=A^-512 * 2^512 mod P
//输入:		A C l(l为数的比特长度512)
//输出:		C (C=A^-1 * 2^512 mod P)
//说明: A<P
//////////////////////////////////////////
__device__ __host__ void dh_mybig_moninv(const UINT64 *A,UINT64 *C)//test
{
	int i,k;
	UINT64 U[4],V[4],R[4],S[4];
	int z,cp,cs,cr,sh;
	/*
	#ifdef __CUDA_ARCH__	
		UINT64 *P=dc_p;	
	#else
		const UINT64 *P=h_p;
	#endif	
	//*/

	/************************算法********************************
	Preferences: E. Savas, C.K.Koc, The Montgomery Modular
	Inverse-Revisited, IEEE TRANSACTIONS ON COMPUTERS,
	VOL. 49, NO.7, JULY 2000

	--Phase I
	U=P V=A R=0 S=1
	k=0
	while(V>0)
		if U is even then U=U/2 S=2S
		else if V is even then V=V/2 R=2R
		else if U>V then U=(U-V)/2 R=R+S S=2S
		else if V>=U then V=(V-U)/2 S=S+R R=2R
		k=k+1
	if R>=P then R=R-P
	R=P-R

	--Phase II
  R=Mont(R*mR)=A^-1 * 2^k *  2^(2l-k) * 2^(-l) mod P 
  = A^-1 * 2^l mod P
	
	return R
	*************************************************************/

	////0. initial
	//U=P V=A R=0 S=1
	// U[0]=0xffffffffffffffffL; //U=P，P的值根据需要去更换
	// U[1]=0xfffffffeffffffffL;
	// U[2]=0xffffffffffffffffL;
	// U[3]=0xfffffffeffffffffL;
	// U[4]=0xffffffffffffffffL;
	// U[5]=0xfffffffffffffffeL;
	// U[6]=0xfffffffeffffffffL;
	// U[7]=0xffffffffffffffffL;
	U[0] = Pa0;
	U[1] = Pa1;
	U[2] = Pa2;
	U[3] = Pa3;


	for(i=0;i<4;i++) V[i]=A[i];
	for(i=0;i<4;i++) R[i]=0;
	for(i=1;i<4;i++) S[i]=0;
	S[0]=0x1UL; 

	////1. phase I
	//get R=A^-1*2^k mod P
	k=0;
	z=dh_mybig_iszero_64(V);
	while(z==0)
	{	
		//printf("here k=%d  ",k);//getchar();
		cp=dh_mybig_compare_64(U,V);
		if((U[0]&0x1)==0)
		{
			dh_mybig_half_64(U,U);
			cs=dh_mybig_double_64(S,S);
		}
		else if((V[0]&0x1)==0)
		{			
			dh_mybig_half_64(V,V);
			cr=dh_mybig_double_64(R,R);
		}
		else if(cp==1)
		{
			dh_mybig_sub_64(U,V,U);
			dh_mybig_half_64(U,U);
			cr=dh_mybig_add_64(R,S,R);
			cs=dh_mybig_double_64(S,S);
		}
		else if(cp<1) //if(cp==0 || cp==-1)
		{
			dh_mybig_sub_64(V,U,V);
			dh_mybig_half_64(V,V);
			cs=dh_mybig_add_64(S,R,S);
			cr=dh_mybig_double_64(R,R);
		}
		k++;
		z=dh_mybig_iszero_64(V);
		//if(cr==1) printf("\nr\n");
		//if(cs==1) printf("\ns\n");		
	}
	
	// U[0]=0xffffffffffffffffL;
	// U[1]=0xfffffffeffffffffL;
	// U[2]=0xffffffffffffffffL;
	// U[3]=0xfffffffeffffffffL;
	// U[4]=0xffffffffffffffffL;
	// U[5]=0xfffffffffffffffeL;
	// U[6]=0xfffffffeffffffffL;
	// U[7]=0xffffffffffffffffL;
	U[0] = Pa0;
	U[1] = Pa1;
	U[2] = Pa2;
	U[3] = Pa3;

	cp=dh_mybig_compare_64(R,U);
	if(cp==1 || cp==0 || cr==1)
	{
		dh_mybig_sub_64(R,U,R);
	}
	dh_mybig_sub_64(U,R,R);
	////////////////////
	//the result of phase I is R
	//R=A^-1 * 2^k mod P

    
	////2. phaseII
	//get R=A^-1 * 2^l mod P
 	// R=Mont(R*mR)=A^-1 * 2^k *  2^(2l-k) * 2^(-l) mod P = A^-1 * 2^l mod P
 	 if(k>256)
	 {	
		// printf("case 1\n");
	    for(i=0;i<4;i++) V[i]=0;
	    V[(int)((512-k)/64)]=(((UINT64)1)<<((int)((512-k)%64)));
	    dh_mybig_monmult_64(R,V,C);
	 }	
	 else if(k==256) 
	 {
			printf("case 2\n");
			// V[0]=0x0000000000000001L;
			// V[1]=0x0000000100000000L;
			// V[2]=0x0000000000000000L;
			// V[3]=0x0000000100000000L;
			// V[4]=0x0000000000000000L;
			// V[5]=0x0000000000000001L;
			// V[6]=0x0000000100000000L;
			// V[7]=0x0000000000000000L;
			// dh_mybig_monmult_64(R,V,C);		
			for(i=0;i<4;i++) C[i]=R[i];	
		}
		else if(k<256) 
		{
		  printf("case 3\n");
		  for(i=1;i<=(256-k);i++)
			{		
				dh_mybig_moddouble_64(R,U,R);			
			}
		  for(i=0;i<4;i++) C[i]=R[i];
		}

}

/////////////////////////////////////////
//程序功能: 计算模逆C=A^-512 * 2^512 mod P 可以指定P
//输入:		A C l(l为数的比特长度512)
//输出:		C (C=A^-1 * 2^512 mod P)
//说明: A<P
//////////////////////////////////////////
__device__ __host__ void dh_mybig_moninv_modN(const UINT64 *A,UINT64 *C)//test
{
	int i,k;
	UINT64 U[4],V[4],R[4],S[4];
	int z,cp,cs,cr,sh;
	/*
	#ifdef __CUDA_ARCH__	
		UINT64 *P=dc_p;	
	#else
		const UINT64 *P=h_p;
	#endif	
	//*/

	/************************算法********************************
	Preferences: E. Savas, C.K.Koc, The Montgomery Modular
	Inverse-Revisited, IEEE TRANSACTIONS ON COMPUTERS,
	VOL. 49, NO.7, JULY 2000

	--Phase I
	U=P V=A R=0 S=1
	k=0
	while(V>0)
		if U is even then U=U/2 S=2S
		else if V is even then V=V/2 R=2R
		else if U>V then U=(U-V)/2 R=R+S S=2S
		else if V>=U then V=(V-U)/2 S=S+R R=2R
		k=k+1
	if R>=P then R=R-P
	R=P-R

	--Phase II
  R=Mont(R*mR)=A^-1 * 2^k *  2^(2l-k) * 2^(-l) mod P 
  = A^-1 * 2^l mod P
	
	return R
	*************************************************************/

	////0. initial
	//U=P V=A R=0 S=1
	// U[0]=0xffffffffffffffffL; //U=P，P的值根据需要去更换
	// U[1]=0xfffffffeffffffffL;
	// U[2]=0xffffffffffffffffL;
	// U[3]=0xfffffffeffffffffL;
	// U[4]=0xffffffffffffffffL;
	// U[5]=0xfffffffffffffffeL;
	// U[6]=0xfffffffeffffffffL;
	// U[7]=0xffffffffffffffffL;
	U[0] = 0xBFD25E8CD0364141L;
	U[1] = 0xBAAEDCE6AF48A03BL;
	U[2] = 0xFFFFFFFFFFFFFFFEL;
	U[3] = 0xFFFFFFFFFFFFFFFFL;


	for(i=0;i<4;i++) V[i]=A[i];
	for(i=0;i<4;i++) R[i]=0;
	for(i=1;i<4;i++) S[i]=0;
	S[0]=0x1UL; 

	////1. phase I
	//get R=A^-1*2^k mod P
	k=0;
	z=dh_mybig_iszero_64(V);
	while(z==0)
	{	
		//printf("here k=%d  ",k);//getchar();
		cp=dh_mybig_compare_64(U,V);
		if((U[0]&0x1)==0)
		{
			dh_mybig_half_64(U,U);
			cs=dh_mybig_double_64(S,S);
		}
		else if((V[0]&0x1)==0)
		{			
			dh_mybig_half_64(V,V);
			cr=dh_mybig_double_64(R,R);
		}
		else if(cp==1)
		{
			dh_mybig_sub_64(U,V,U);
			dh_mybig_half_64(U,U);
			cr=dh_mybig_add_64(R,S,R);
			cs=dh_mybig_double_64(S,S);
		}
		else if(cp<1) //if(cp==0 || cp==-1)
		{
			dh_mybig_sub_64(V,U,V);
			dh_mybig_half_64(V,V);
			cs=dh_mybig_add_64(S,R,S);
			cr=dh_mybig_double_64(R,R);
		}
		k++;
		z=dh_mybig_iszero_64(V);
		//if(cr==1) printf("\nr\n");
		//if(cs==1) printf("\ns\n");		
	}
	
	// U[0]=0xffffffffffffffffL;
	// U[1]=0xfffffffeffffffffL;
	// U[2]=0xffffffffffffffffL;
	// U[3]=0xfffffffeffffffffL;
	// U[4]=0xffffffffffffffffL;
	// U[5]=0xfffffffffffffffeL;
	// U[6]=0xfffffffeffffffffL;
	// U[7]=0xffffffffffffffffL;
	U[0] = 0xBFD25E8CD0364141L;
	U[1] = 0xBAAEDCE6AF48A03BL;
	U[2] = 0xFFFFFFFFFFFFFFFEL;
	U[3] = 0xFFFFFFFFFFFFFFFFL;

	cp=dh_mybig_compare_64(R,U);
	if(cp==1 || cp==0 || cr==1)
	{
		dh_mybig_sub_64(R,U,R);
	}
	dh_mybig_sub_64(U,R,R);
	////////////////////
	//the result of phase I is R
	//R=A^-1 * 2^k mod P

    
	////2. phaseII
	//get R=A^-1 * 2^l mod P
 	// R=Mont(R*mR)=A^-1 * 2^k *  2^(2l-k) * 2^(-l) mod P = A^-1 * 2^l mod P
 	 if(k>256)
	 {	
		// printf("case 1\n");
	    for(i=0;i<4;i++) V[i]=0;
	    V[(int)((512-k)/64)]=(((UINT64)1)<<((int)((512-k)%64)));
	    dh_mybig_monmult_64_modN(R,V,C);
	 }	
	 else if(k==256) 
	 {
			printf("case 2\n");
			// V[0]=0x0000000000000001L;
			// V[1]=0x0000000100000000L;
			// V[2]=0x0000000000000000L;
			// V[3]=0x0000000100000000L;
			// V[4]=0x0000000000000000L;
			// V[5]=0x0000000000000001L;
			// V[6]=0x0000000100000000L;
			// V[7]=0x0000000000000000L;
			// dh_mybig_monmult_64(R,V,C);		
			for(i=0;i<4;i++) C[i]=R[i];	
		}
		else if(k<256) 
		{
		  printf("case 3\n");
		  for(i=1;i<=(256-k);i++)
			{		
				dh_mybig_moddouble_64(R,U,R);			
			}
		  for(i=0;i<4;i++) C[i]=R[i];
		}

}

//GAO: mod exp
//C = A^k mod P
__device__ __host__ void dh_mybig_modexp(UINT64* a,UINT64 *k,UINT64* c){
	//gyy
	int i,j;
	UINT64 tbn[4];
	// Jpoint t2;
	

	// find first 1
	for(i=3;i>=0;i--){
		if(k[i]!=0)	break;
	}
	if(i<0){
		printf("k==0!!!!!!!!!\n");
	}
	for(j=63;j>=0;j--){
		if((k[i]>>j)&0x01!=0) break;
	}
	
	dh_mybig_copy(tbn,a);

	j--;


		
		for(;j>=0;j--){
				// printf("double\n");
			dh_mybig_monmult_64(tbn,tbn,tbn);
			// ppoint_double(pt1,pt1);
			if((k[i]>>j)&0x01==1){
					// printf("add\n");
				dh_mybig_monmult_64(tbn,a,tbn);
				// dh_ellipticAdd_JJ(pt1,&tp,pt1);
			}
		}
		i--;
		for(;i>=0;i--){
			for(j=63;j>=0;j--){
					// printf("double\n");
				// ppoint_double(pt1,pt1);
				dh_mybig_monmult_64(tbn,tbn,tbn);
				if((k[i]>>j)&0x01==1){
						// printf("add\n");
					// dh_ellipticAdd_JJ(pt1,&tp,pt1);
					dh_mybig_monmult_64(tbn,a,tbn);
				}
			}
		}

		dh_mybig_copy(c,tbn);
	
	// printf("j=%d,i=%d\n",j,i);
	
	// printf("copy\n");
	// dh_mybig_copy(pt1->x,tp.x);
	// dh_mybig_copy(pt1->y,tp.y);
	// dh_mybig_copy(pt1->z,tp.z);
}


//////////////////////////////////////test inv end//////////////////////////////////////

/////////////////GPU大整数运算函数结束////////////////////////////////////////////////////


/////////////////GPU点加和倍点函数开始，没有写全的点加函数，可以利用上述大数运算，自己根据点加公式补充///////////////////////////////////////
//GAO:未修改
__device__ __host__  void dh_setzero_J(Jpoint *pt)
{
	int i;
	for(i=0;i<8;i++) pt->z[i]=0UL;
}
//GAO:未修改
__device__ __host__  void dh_setzero_A(Apoint *pt)
{
	int i;
	for(i=0;i<8;i++) pt->x[i]=0UL;	
}

__device__ __host__  int dh_iszero_J(const Jpoint *pt)
{
	// if((pt->z[0]|pt->z[1]|pt->z[2]|pt->z[3]|pt->z[4]|pt->z[5]|pt->z[6]|pt->z[7]) == 0UL)	return 1;
	// return 0;	
	if((pt->z[0]|pt->z[1]|pt->z[2]|pt->z[3]) == 0UL)	return 1;
	return 0;
}


__device__ __host__  int dh_iszero_A(const Apoint *pt)
{	
	// if((pt->x[0]|pt->x[1]|pt->x[2]|pt->x[3]|pt->x[4]|pt->x[5]|pt->x[6]|pt->x[7]) == 0UL)	return 1;
	// return 0;
	if((pt->x[0]|pt->x[1]|pt->x[2]|pt->x[3]) == 0UL)	return 1;
	return 0;
}

//GAO:未修改
//将射影点坐标转换为仿射坐标
__device__ __host__  void dh_normlize_J(Jpoint *pt)
{	
	UINT64 tmp[8],invtmp[8];
	
	if(dh_iszero_J(pt))	return;
	
	tmp[0]=0x1L; tmp[1]=0x0L; tmp[2]=0x0L; tmp[3]=0x0L; tmp[4]=0x0L; tmp[5]=0x0L; tmp[6]=0x0L; tmp[7]=0x0L;
	
	
	dh_mybig_monmult_64(pt->z,tmp, invtmp);
	dh_mybig_moninv(invtmp, invtmp);
	//invMod(invtmp,pt->z,mod);//invtmp=1/z
	
	//squareMod(tmp,invtmp,mod);//tmp=1/zz
	dh_mybig_monmult_64(invtmp,invtmp, tmp);
	
	//productMod(pt->x,pt->x,tmp,mod);//x/zz
	dh_mybig_monmult_64(pt->x,tmp, pt->x);		
	
	//productMod(tmp,tmp,invtmp,mod);//1/zzz
	dh_mybig_monmult_64(tmp,invtmp, tmp);
	
	//productMod(pt->y,pt->y,tmp,mod);//y/zzz
	dh_mybig_monmult_64(pt->y,tmp, pt->y);
	
	//z=mon_one
	pt->z[0]=0x0000000000000001L;
	pt->z[1]=0x0000000100000000L;
	pt->z[2]=0x0000000000000000L;
	pt->z[3]=0x0000000100000000L;
	pt->z[4]=0x0000000000000000L;
	pt->z[5]=0x0000000000000001L;
	pt->z[6]=0x0000000100000000L;
	pt->z[7]=0x0000000000000000L;	
	
}
//GAO:未修改
__device__ void d_mon2normal_J(Jpoint *pt)
{
	dh_mybig_monmult_64(pt->x, dc_ONE, pt->x);
	dh_mybig_monmult_64(pt->y, dc_ONE, pt->y);
	dh_mybig_monmult_64(pt->z, dc_ONE, pt->z);	
}
//GAO:未修改
__device__ __host__  void dh_mon2normal_A(Apoint *pt)
{
	#ifdef __CUDA_ARCH__
	dh_mybig_monmult_64(pt->x, dc_ONE, pt->x);
	dh_mybig_monmult_64(pt->y, dc_ONE, pt->y);
	#else
	dh_mybig_monmult_64(pt->x, h_ONE, pt->x);
	dh_mybig_monmult_64(pt->y, h_ONE, pt->y);
	#endif
}

void h_print_pointA(const Apoint *pt)
{
	if(dh_iszero_A(pt))
	{ 
		printf("(Infinity)\n");
		return;
	}	
	printf("x: ");h_mybig_print(pt->x);
	printf("y: ");h_mybig_print(pt->y);
	
}

void h_print_pointJ(const Jpoint *pt)
{
	/*
	if(dh_iszero_J(pt))
	{ 
		printf("(Infinity)\n");
		return;
	}*/
	printf("x: ");h_mybig_print(pt->x);
	printf("y: ");h_mybig_print(pt->y);
	printf("z: ");h_mybig_print(pt->z);
}

__device__ __host__ void ppoint_double(Jpoint *pt1,Jpoint* pt2){
	UINT64 u1[4],u2[4],u3[4];

	#ifdef __CUDA_ARCH__
		const UINT64 *Pa=dc_p;
	#else
		const UINT64 *Pa=h_p;
	#endif	

	//这里不判断是否为无穷远
	//secp256k1中a为0，如果需要用其他的曲线需要修改
	dh_mybig_moddouble_64(pt1->y,Pa,u1); 	//u1=2y
	dh_mybig_monmult_64(pt1->z,u1,pt2->z);		//z=u1*z=2yz

	dh_mybig_monmult_64(pt1->x,pt1->x,u2);	//u2=x^2
	dh_mybig_moddouble_64(u2,Pa,u3);		//u3=2*u2=2x^2
	dh_mybig_modadd_64(u3,u2,u3);			//u3=u3+u2 = 3x^2 = lambda_1
	dh_mybig_monmult_64(u1,pt1->y,u1);		//u1 = u1*y = 2y^2
	dh_mybig_monmult_64(u1,pt1->x,u2);		//u2 = u1*x = 2xy^2 
	dh_mybig_moddouble_64(u2,Pa,u2);		//u2 = 2*u1 = 4xy^2= lambda_2
	dh_mybig_monmult_64(u3,u3,pt1->x);		//pt1x = lambda_1^2
	dh_mybig_moddouble_64(u2,Pa,pt1->y);		//pt1y = 2*u2 = 2*lambda_2
	dh_mybig_modsub_64(pt1->x,pt1->y,pt2->x);	//x = pt1x-pt1y = lambda_1^2-2*labmda_2

	dh_mybig_monmult_64(u1,u1,u1);			//u1 = u1*u1 = 4y^4;
	dh_mybig_moddouble_64(u1,Pa,u1);		//u1 = 2u1 = 8y^4 = lambda_3

	dh_mybig_modsub_64(u2,pt2->x,u2);		//u2 = u2-pt1x = lambda2-pt1x
	dh_mybig_monmult_64(u3,u2,pt1->y);		//pt1y = u2*u3 = Lambda_1 * (lambda2-pt1x)
	dh_mybig_modsub_64(pt1->y,u1,pt2->y);	//y = pt1y - labmda_3;
}

__device__ __host__ void dh_ellipticAdd_JJ(Jpoint *pt1, Jpoint* pt2,Jpoint* pt3){
	UINT64 u1[4],u2[4],u3[4],u4[4];
	//u1=z2^2

	#ifdef __CUDA_ARCH__
		const UINT64 *Pa=dc_p;
		const UINT64 *mon_inv_two = dc_mon_inv_two;

	#else
		const UINT64 *Pa=h_p;
		const UINT64 *mon_inv_two = h_mon_inv_two;

	#endif	

	dh_mybig_monmult_64(pt2->z,pt2->z,u1);

	//u2=z1^2
	dh_mybig_monmult_64(pt1->z,pt1->z,u2);

	//u3 = u1*x1=x1*z2^2=lam1
	dh_mybig_monmult_64(pt1->x,u1,u3);

	//u4 = u2*x2 = x2*z1^2=lam2
	dh_mybig_monmult_64(pt2->x,u2,u4);

	//u1 = z2^3
	dh_mybig_monmult_64(u1,pt2->z,u1);

	//u2 = z1^3
	dh_mybig_monmult_64(u2,pt1->z,u2);

	//u1 = u1*y1 = lam4
	dh_mybig_monmult_64(u1,pt1->y,u1);

	//u2 = u2*y2 = lam5
	dh_mybig_monmult_64(u2,pt2->y,u2);

	//pt3y = u3-u4 = lam3
	dh_mybig_modsub_64(u3,u4,pt3->y);

	//u3+=u4 = lam1+lam2 = lam7
	dh_mybig_modadd_64(u3,u4,u3);

	//U4=u1-u2=lam4-lam5=lam6
	dh_mybig_modsub_64(u1,u2,u4);

	//u1+=u2 = lam4+lam5=lam8
	dh_mybig_modadd_64(u1,u2,u1);

	//pt3z = z1*z2*lam3
	dh_mybig_monmult_64(pt1->z,pt2->z,pt3->z);
	dh_mybig_monmult_64(pt3->z,pt3->y,pt3->z);

	//pt3x = u4^2 = lam6^2
	dh_mybig_monmult_64(u4,u4,pt3->x);
	//u2 = pt3y^2 = lam3^2
	dh_mybig_monmult_64(pt3->y,pt3->y,u2);

	//pt3y = pt3y*u2 = lam3^3
	dh_mybig_monmult_64(pt3->y,u2,pt3->y);

	//u2 = u2*u3 = lam7*lam3^2
	dh_mybig_monmult_64(u2,u3,u2);

	//pt3x -= u2 = lam6^2-lam7*lam3^2
	dh_mybig_modsub_64(pt3->x,u2,pt3->x);

	//u3 = 2pt3x
	dh_mybig_moddouble_64(pt3->x,Pa,u3);
	//u2-=u3=lam7lam3^2-2pt3x=lam9
	dh_mybig_modsub_64(u2,u3,u2);

	//u1 *= pt3y = lam8*lam3^3
	dh_mybig_monmult_64(u1,pt3->y,u1);

	//pt3y = u2*u4 = lam9*lam6
	dh_mybig_monmult_64(u2,u4,pt3->y);

	//pt3y-=u1
	dh_mybig_modsub_64(pt3->y,u1,pt3->y);

	//pt3y/=2
	dh_mybig_monmult_64(pt3->y,mon_inv_two,pt3->y);
	// dh_mybig_half_64(pt3->y,pt3->y);

}
//射影点pt1加等放射点pt2, pt1+=pt2
__device__ __host__ void dh_ellipticSumEqual_AJ(Jpoint *pt1, Apoint* pt2)//pt1,pt2必须保证非无穷远点，在函数中无判断
{
	UINT64 u1[4],u2[4];
	if(dh_iszero_A(pt2))	return;	
	if(dh_iszero_J(pt1))
	{
		dh_mybig_copy(pt1->x, pt2->x);
		dh_mybig_copy(pt1->y, pt2->y);
		//Z赋值为mon_ONE，这个值需要根据p重新设置
		//0x1000003d1L,0x0L,0x0L,0x0L
		pt1->z[0]=0x1000003d1L;		pt1->z[1]=0x0L;		pt1->z[2]=0x0L;		pt1->z[3]=0x0L;
		// pt1->z[4]=0x0000000000000000L;		pt1->z[5]=0x0000000000000001L;		pt1->z[6]=0x0000000100000000L;		pt1->z[7]=0x0000000000000000L;				
		return;
	}	
	//可在程序中判断，禁止加仿射坐标的无穷远点
	
	
	//3.计算u1=(pt1->z)^2.
	dh_mybig_monmult_64(pt1->z, pt1->z, u1);
	
	//4.计算u2=(pt1->z)*u1.
	dh_mybig_monmult_64(pt1->z, u1, u2);
	
	//5.计算u1=(pt2->x)*u1.
	dh_mybig_monmult_64(pt2->x, u1, u1);
	
	//6.计算u2=(pt2->y)*u2.
	dh_mybig_monmult_64(pt2->y, u2, u2);
	
	//7.计算u1=u1-pt1->x.		
	dh_mybig_modsub_64(u1, pt1->x,u1);
	
	//8.计算u2=u2-pt1->y.	
	dh_mybig_modsub_64(u2,pt1->y,u2);
	
	///*	
	//9.判断等点,需要调用二倍点程序.
	if(dh_mybig_iszero(u1))
	{
		if(dh_mybig_iszero(u2))
		{
			//GAO:这里自己添加了二倍点函数
			ppoint_double(pt1,pt1);//y坐标也相同，返回二倍点
			printf("here! use ppoint double!\n");
			
			return;
		}
		else//正负点相加，返回无穷远点
		{
			dh_setzero_J(pt1);
			return ;
		}
	}
	//*/
	//10.pt1->z=pt1->z*u1.
	dh_mybig_monmult_64(pt1->z, u1, pt1->z);
	
	//11.计算pt2->x=u1^2.
	dh_mybig_monmult_64(u1, u1, pt2->x);
	
	//12.计算pt2->y=pt2->x*u1.
	dh_mybig_monmult_64(u1, pt2->x, pt2->y);
	
	//13.计算pt2->x=pt1->x*pt2->x.
	dh_mybig_monmult_64(pt1->x, pt2->x, pt2->x);
	
	//14.计算u1=2*pt2->x.
	dh_mybig_modadd_64(pt2->x,pt2->x,u1);
	
	//15.x1=u2^2.
	dh_mybig_monmult_64(u2, u2, pt1->x);
	
	//16.x1=pt2->x
	dh_mybig_modsub_64(pt1->x,u1,pt1->x);
	
	//17.x1=x1-pt2->y
	dh_mybig_modsub_64(pt1->x,pt2->y,pt1->x);
	
	//18.计算pt2->x=pt2->x-x1.
	dh_mybig_modsub_64(pt2->x,pt1->x,pt2->x);
	
	//19.pt2->x=pt2->x*u2
	dh_mybig_monmult_64(pt2->x, u2, pt2->x);
	
	//20.pt2->y=pt2->y*y1
	dh_mybig_monmult_64(pt2->y, pt1->y, pt2->y);
	
	//21.y1=pt2->x-pt2->y
	dh_mybig_modsub_64(pt2->x,pt2->y,pt1->y);
}

__device__ __host__ void dh_point_mult_inplace(Jpoint* pt1,UINT64 *k){
	//gyy
	int i,j;
	Jpoint tp;
	Jpoint t2;
	//找到第一个1的位置

	//testcode
	// dh_mybig_copy(tp.x,pt1->x);
	// dh_mybig_copy(tp.y,pt1->y);
	// dh_mybig_copy(tp.z,pt1->z);



	// ppoint_double(pt1,pt1);
	// dh_ellipticAdd_JJ(pt1,&tp,pt1);
	
	// ppoint_double(pt1,pt1);
	// dh_ellipticAdd_JJ(pt1,&tp,pt1);
	
	// dh_mybig_copy(pt1->x,tp.x);
	// dh_mybig_copy(pt1->y,tp.y);
	// dh_mybig_copy(pt1->z,tp.z);

	for(i=3;i>=0;i--){
		if(k[i]!=0)	break;
	}
	if(i<0){
		printf("k==0!!!!!!!!!\n");
	}
	for(j=63;j>=0;j--){
		if((k[i]>>j)&0x01!=0) break;
	}
	
	dh_mybig_copy(tp.x,pt1->x);
	dh_mybig_copy(tp.y,pt1->y);
	dh_mybig_copy(tp.z,pt1->z);
	j--;
	// printf("j=%d,i=%d\n",j,i);
	for(;j>=0;j--){
			// printf("double\n");
		ppoint_double(pt1,pt1);
		if((k[i]>>j)&0x01==1){
				// printf("add\n");
			dh_ellipticAdd_JJ(pt1,&tp,pt1);
		}
	}
	i--;
	for(;i>=0;i--){
		for(j=63;j>=0;j--){
				// printf("double\n");
			ppoint_double(pt1,pt1);
			if((k[i]>>j)&0x01==1){
					// printf("add\n");
				dh_ellipticAdd_JJ(pt1,&tp,pt1);
			}
		}
	}
	// printf("copy\n");
	// dh_mybig_copy(pt1->x,tp.x);
	// dh_mybig_copy(pt1->y,tp.y);
	// dh_mybig_copy(pt1->z,tp.z);
}

__device__ __host__ void dh_point_mult_finalversion(Jpoint* pt1,UINT64 *k,Jpoint* pt2){
	//gyy
	int i,j;
	Jpoint tp;
	// Jpoint t2;
	
	//找到第一个1的位置

	//testcode
	// dh_mybig_copy(tp.x,pt1->x);
	// dh_mybig_copy(tp.y,pt1->y);
	// dh_mybig_copy(tp.z,pt1->z);



	// ppoint_double(pt1,pt1);
	// dh_ellipticAdd_JJ(pt1,&tp,pt1);
	
	// ppoint_double(pt1,pt1);
	// dh_ellipticAdd_JJ(pt1,&tp,pt1);
	
	// dh_mybig_copy(pt1->x,tp.x);
	// dh_mybig_copy(pt1->y,tp.y);
	// dh_mybig_copy(pt1->z,tp.z);

	for(i=3;i>=0;i--){
		if(k[i]!=0)	break;
	}
	if(i<0){
		printf("k==0!!!!!!!!!\n");
	}
	for(j=63;j>=0;j--){
		if((k[i]>>j)&0x01!=0) break;
	}
	
	dh_mybig_copy(tp.x,pt1->x);
	dh_mybig_copy(tp.y,pt1->y);
	dh_mybig_copy(tp.z,pt1->z);
	j--;

	if(pt1==pt2){
		
		for(;j>=0;j--){
				// printf("double\n");
			ppoint_double(pt1,pt1);
			if((k[i]>>j)&0x01==1){
					// printf("add\n");
				dh_ellipticAdd_JJ(pt1,&tp,pt1);
			}
		}
		i--;
		for(;i>=0;i--){
			for(j=63;j>=0;j--){
					// printf("double\n");
				ppoint_double(pt1,pt1);
				if((k[i]>>j)&0x01==1){
						// printf("add\n");
					dh_ellipticAdd_JJ(pt1,&tp,pt1);
				}
			}
		}
	}else{
		
		// h_print_pointJ(pt1);
		// h_print_pointJ(&tp);
		for(;j>=0;j--){
				// printf("double\n");
			ppoint_double(&tp,&tp);
			if((k[i]>>j)&0x01==1){
					// printf("add\n");
				dh_ellipticAdd_JJ(&tp,pt1,&tp);
			}
		}
		i--;
		for(;i>=0;i--){
			for(j=63;j>=0;j--){
					// printf("double\n");
				ppoint_double(&tp,&tp);
				if((k[i]>>j)&0x01==1){
						// printf("add\n");
					dh_ellipticAdd_JJ(&tp,pt1,&tp);
				}
			}
		}
		// h_print_pointJ(&tp);
		dh_mybig_copy(pt2->x,tp.x);
		dh_mybig_copy(pt2->y,tp.y);
		dh_mybig_copy(pt2->z,tp.z);
	}
	// printf("j=%d,i=%d\n",j,i);
	
	// printf("copy\n");
	// dh_mybig_copy(pt1->x,tp.x);
	// dh_mybig_copy(pt1->y,tp.y);
	// dh_mybig_copy(pt1->z,tp.z);
}

__device__ __host__ void dh_point_mult_uint32(Jpoint* pt1, int k,Jpoint* pt2){
	int i;
	Jpoint tp;
	for(i=31;i>=0;i--){
		if((k>>i)&0x01!=0) break;
	}
	dh_mybig_copy(tp.x,pt1->x);
	dh_mybig_copy(tp.y,pt1->y);
	dh_mybig_copy(tp.z,pt1->z);
	i--;

	if(pt1==pt2){
		for(;i>=0;i--){
			// printf("double\n");
			ppoint_double(pt1,pt1);
			if((k>>i)&0x01==1){
				// printf("add\n");
				dh_ellipticAdd_JJ(pt1,&tp,pt1);
			}
		}
	}else{
		for(;i>=0;i--){
			// printf("double\n");
			ppoint_double(&tp,&tp);
			if((k>>i)&0x01==1){
				// printf("add\n");
				dh_ellipticAdd_JJ(&tp,pt1,&tp);
			}
		}
		dh_mybig_copy(pt2->x,tp.x);
		dh_mybig_copy(pt2->y,tp.y);
		dh_mybig_copy(pt2->z,tp.z);
	}

}


__device__ __host__ void dh_point_mult_outofplace(Jpoint* pt1,UINT64 *k,Jpoint* pt2){
	//gyy
	int i,j;

	//找到第一个1的位置

	//testcode
	dh_mybig_copy(pt2->x,pt1->x);
	dh_mybig_copy(pt2->y,pt1->y);
	dh_mybig_copy(pt2->z,pt1->z);



	for(i=3;i>=0;i--){
		if(k[i]!=0)	break;
	}
	if(i<0){
		printf("k==0!!!!!!!!!\n");
	}
	for(j=63;j>=0;j--){
		if((k[i]>>j)&0x01!=0) break;
	}
	

	j--;
	// printf("j=%d,i=%d\n",j,i);
	for(;j>=0;j--){
			// printf("double\n");
		ppoint_double(pt2,pt2);
		if((k[i]>>j)&0x01==1){
				// printf("add\n");
			dh_ellipticAdd_JJ(pt2,pt1,pt2);
		}
	}
	i--;
	for(;i>=0;i--){
		for(j=63;j>=0;j--){
				// printf("double\n");
			ppoint_double(pt2,pt2);
			if((k[i]>>j)&0x01==1){
					// printf("add\n");
				dh_ellipticAdd_JJ(pt2,pt1,pt2);
			}
		}
	}
	// printf("copy\n");
	// dh_mybig_copy(pt1->x,tp.x);
	// dh_mybig_copy(pt1->y,tp.y);
	// dh_mybig_copy(pt1->z,tp.z);
}

//这个函数因为他自己提供的那个点加函数会更改pt2，所以不能用，除非重写之前的函数
__device__ __host__ void dh_apoint_mult(Jpoint* pt1,Apoint* pt2,UINT64 *k){
	
	dh_mybig_copy(pt1->x,pt2->x);
	dh_mybig_copy(pt1->y,pt2->y);
	dh_mybig_copy(pt1->z,dc_mon_ONE);
	
	ppoint_double(pt1,pt1);
	dh_ellipticSumEqual_AJ(pt1,pt2);
	ppoint_double(pt1,pt1);
	// dh_ellipticSumEqual_AJ(pt1,pt2);
	return;
	//gyy
	int i,j;
	// Jpoint tp;

	//找到第一个1的位置

	//testcode

	for(i=3;i>=0;i--){
		if(k[i]!=0)	break;
	}
	if(i<0){
		printf("k==0!!!!!!!!!\n");
	}
	for(j=63;j>=0;j--){
		if((k[i]>>j)&0x01!=0) break;
	}
	
	dh_mybig_copy(pt1->x,pt2->x);
	dh_mybig_copy(pt1->y,pt2->y);
	dh_mybig_copy(pt1->z,dc_mon_ONE);
	j--;
	
	printf("j=%d,i=%d\n",j,i);
	// return;
	for(;j>=0;j--){
			// printf("double\n");
		ppoint_double(pt1,pt1);
		if((k[i]>>j)&0x01==1){
				// printf("add\n");
			dh_ellipticSumEqual_AJ(pt1,pt2);
		}
	}
	i--;
	for(;i>=0;i--){
		for(j=63;j>=0;j--){
				// printf("double\n");
			ppoint_double(pt1,pt1);
			if((k[i]>>j)&0x01==1){
					// printf("add\n");
					dh_ellipticSumEqual_AJ(pt1,pt2);
			}
		}
	}
	printf("copy\n");
	// dh_mybig_copy(pt1->x,tp.x);
	// dh_mybig_copy(pt1->y,tp.y);
	// dh_mybig_copy(pt1->z,tp.z);
}

//GAO:未修改
//批量求逆
__device__ void d_multi_inverse(UINT64 *x)
{
	int i,j;
	UINT64 invlj[PARAL*8];//寄存器每个小核可以分4KB字节，4096=64*256,可以有256个512比特数
	UINT64 lmd[8];
	
	dh_mybig_copy(invlj,x);//	for(i=0;i<8;i++) invlj[0][i]=x[0][i];
		
	for(i=1;i<PARAL;i++)
	{			    					
		dh_mybig_monmult_64(invlj+(i-1)*8,x+i*8,invlj+i*8);
	}
		
	dh_mybig_monmult_64(invlj+(PARAL-1)*8,dc_ONE,lmd);//z=Z mod P //先去掉蒙哥马利
	dh_mybig_moninv(lmd,lmd); //求逆的时候又戴上2^n了
		
	for(i=PARAL-1;i>0;i--)
	{
		dh_mybig_monmult_64(invlj+(i-1)*8,lmd,invlj+i*8);
		dh_mybig_monmult_64(x+i*8,lmd,lmd);
		dh_mybig_copy(x+i*8,invlj+i*8);
		//for(j=0;j<8;j++) x[i*8+j]=invlj[i*8+j];	
	}	
	dh_mybig_copy(x,lmd);
	//for(j=0;j<8;j++) x[j]=lmd[j];	
}
//GAO:未修改
//批量正规化射影点
__global__ void d_multi_normlize_J(Jpoint *A, int n)
{	
	//参数n必须为PARAL的整数倍
	
	int i,j,k;
	UINT64 tmp[8];
	int mytid=threadIdx.x+blockDim.x*blockIdx.x;
	int threadnum=blockDim.x*gridDim.x;
	UINT64 z[8*PARAL];//此处z用作伪并行求逆
			
	for(i=mytid*PARAL;i<n;i+=threadnum*PARAL) //n个按PARAL个连续的一段，每个小核做一段，循环做下去
	{
		for(j=0;j<PARAL;j++)
		{
			for(k=0;k<8;k++)
				z[j*8+k]=A[i+j].z[k];
		}
				
		d_multi_inverse(z);
		
		for(j=0;j<PARAL;j++)
		{
			dh_mybig_monmult_64(z+j*8,z+j*8, tmp);
			dh_mybig_monmult_64(A[i+j].x,tmp, A[i+j].x);		
			dh_mybig_monmult_64(tmp,z+j*8, tmp);
			dh_mybig_monmult_64(A[i+j].y,tmp, A[i+j].y);

			//z初始化为mon_ONE，这个mon_ONE跟字长有关
			A[i+j].z[0]=0x0000000000000001L;	A[i+j].z[1]=0x0000000100000000L;	A[i+j].z[2]=0x0000000000000000L;	A[i+j].z[3]=0x0000000100000000L;
			A[i+j].z[4]=0x0000000000000000L;	A[i+j].z[5]=0x0000000000000001L;	A[i+j].z[6]=0x0000000100000000L;	A[i+j].z[7]=0x0000000000000000L;	
			
			d_mon2normal_J(A+i+j);
		}
	}
	
}

/////////////////GPU点加和倍点函数结束////////////////////////////////////////////////////

__global__ void d_get_para(UINT64 *para)
{
	int i;
	UINT64 *pt64;
	
	if(threadIdx.x==0 && blockIdx.x==blockDim.x-1)
	{
		pt64=para+  0; for(i=0;i<8;i++) pt64[i]=dc_p[i];
		pt64=para+ 56; for(i=0;i<8;i++) pt64[i]=dc_ONE[i];
		pt64=para+ 64; for(i=0;i<8;i++) pt64[i]=dc_mon_ONE[i];						
	}	
}

void h_print_para()
{
	int groups=11;
	UINT64 *testdata=(UINT64 *)malloc(groups*8*8);	
	UINT64 *d_testdata;
	
	HANDLE_ERROR( cudaMalloc((void**)&d_testdata, groups*8*8) );
	
	d_get_para<<<BLOCKNUM,BLOCKSIZE>>>(d_testdata);
	
	HANDLE_ERROR( cudaMemcpy( testdata, d_testdata,	64*groups, cudaMemcpyDeviceToHost));
	printf("\n__const__ UINT64 testdc_p[8]=");h_mybig_print(testdata);
	printf("\n__const__ UINT64 testdc_ONE[8]=");h_mybig_print(testdata+56);
	printf("\n__const__ UINT64 testdc_mon_ONE[8]=");h_mybig_print(testdata+64);
	
	free(testdata);
	HANDLE_ERROR(cudaFree(d_testdata));
}



int h_get_gpu_info()
{
	  cudaDeviceProp  prop;

    int count;
    HANDLE_ERROR( cudaGetDeviceCount( &count ) );
    
    for (int i=0; i< count; i++) {
        HANDLE_ERROR( cudaGetDeviceProperties( &prop, i ) );
        printf( "   --- General Information for device %d ---\n", i );
        printf( "Name:  %s\n", prop.name );
        printf( "Compute capability:  %d.%d\n", prop.major, prop.minor );
        printf( "Clock rate:  %d\n", prop.clockRate );
        printf( "Device copy overlap:  " );
        if (prop.deviceOverlap)
            printf( "Enabled\n" );
        else
            printf( "Disabled\n");
        printf( "Kernel execution timeout :  " );
        if (prop.kernelExecTimeoutEnabled)
            printf( "Enabled\n" );
        else
            printf( "Disabled\n" );

        printf( "   --- Memory Information for device %d ---\n", i );
        printf( "Total global mem:  %ld\n", prop.totalGlobalMem );
        printf( "Total constant Mem:  %ld\n", prop.totalConstMem );
        printf( "Max mem pitch:  %ld\n", prop.memPitch );
        printf( "Texture Alignment:  %ld\n", prop.textureAlignment );

        printf( "   --- MP Information for device %d ---\n", i );
        printf( "Multiprocessor count:  %d\n",
                    prop.multiProcessorCount );
        printf( "Shared mem per mp:  %ld\n", prop.sharedMemPerBlock );
        printf( "Registers per mp:  %d\n", prop.regsPerBlock );
        printf( "Threads in warp:  %d\n", prop.warpSize );
        printf( "Max threads per block:  %d\n",
                    prop.maxThreadsPerBlock );
        printf( "Max thread dimensions:  (%d, %d, %d)\n",
                    prop.maxThreadsDim[0], prop.maxThreadsDim[1],
                    prop.maxThreadsDim[2] );
        printf( "Max grid dimensions:  (%d, %d, %d)\n",
                    prop.maxGridSize[0], prop.maxGridSize[1],
                    prop.maxGridSize[2] );
        printf( "\n" );
    }

	return 1;
}
