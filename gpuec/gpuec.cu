#include <stdio.h>
typedef unsigned long long UINT64; //����64λ������
typedef long long INT64;

// ����㹹��
typedef struct Affine_point{
	UINT64 x[8];
	UINT64 y[8];
}Apoint;

// ��Ӱ�㹹��
typedef struct Jacobi_point{
	UINT64 x[8];
	UINT64 y[8];
	UINT64 z[8];
}Jpoint;


// ��tesla C2050��Ŀǰ����������Ч����ߣ������޸ġ�
#define PARAL 64
#define BLOCKNUM (14*8)
#define BLOCKSIZE 32
#define THREADNUM (BLOCKNUM*BLOCKSIZE)


// ����__global__���͵ı��������16���ر���
#define d_BIN_WINDOW_16 16 //16���ر�
#define d_ROWS_16 32
#define d_COLS_16 (1L<<d_BIN_WINDOW_16)


#define HANDLE_ERROR( err ) { if (err != cudaSuccess) { \
		printf( "%s in %s at line %d\n", cudaGetErrorString( err ), __FILE__, __LINE__ );\
	  exit( EXIT_FAILURE ); }  \
}

//�汾Ϊ512�������߹�ģ���������޸�Ϊ256���ذ汾
//�ð汾����������������Ϊ��������
//h_ONE��host�õ���Ԫ��1
//dc_ONE��gpu���õ���Ԫ��1
//h_mon_ONE��dc_mon_ONE��ȣ��ֱ���host��gpu�����õ��ɸ��������ϵ�1
//h_p��dc_p��512��������
//Pa0��Pa7�ǽ������ֿ�����Ϊ�궨��

const UINT64 h_ONE[8]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
const UINT64 h_mon_ONE[8]={0x0000000000000001L,0x0000000100000000L,0x0000000000000000L,0x0000000100000000L,0x0000000000000000L,0x0000000000000001L,0x0000000100000000L,0x0000000000000000L};
const UINT64 h_p[8]={0xffffffffffffffffL,0xfffffffeffffffffL,0xffffffffffffffffL,0xfffffffeffffffffL,0xffffffffffffffffL,0xfffffffffffffffeL,0xfffffffeffffffffL,0xffffffffffffffffL};

__constant__ UINT64 dc_ONE[8]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
__constant__ UINT64 dc_mon_ONE[8]={0x0000000000000001L,0x0000000100000000L,0x0000000000000000L,0x0000000100000000L,0x0000000000000000L,0x0000000000000001L,0x0000000100000000L,0x0000000000000000L};
__constant__ UINT64 dc_p[8]={0xffffffffffffffffL,0xfffffffeffffffffL,0xffffffffffffffffL,0xfffffffeffffffffL,0xffffffffffffffffL,0xfffffffffffffffeL,0xfffffffeffffffffL,0xffffffffffffffffL};

#define Pa0 0xffffffffffffffffLL //-1
#define Pa1 0xfffffffeffffffffLL 
#define Pa2 0xffffffffffffffffLL //-1
#define Pa3 0xfffffffeffffffffLL 
#define Pa4 0xffffffffffffffffLL //-1
#define Pa5 0xfffffffffffffffeLL //-2
#define Pa6 0xfffffffeffffffffLL 
#define Pa7 0xffffffffffffffffLL //-1


/////////////////GPU���������㺯����ʼ////////////////////////////////////////////////////

#define dh_mybig_copy(a,b) {(a)[0]=(b)[0];(a)[1]=(b)[1];(a)[2]=(b)[2];(a)[3]=(b)[3];(a)[4]=(b)[4];(a)[5]=(b)[5];(a)[6]=(b)[6];(a)[7]=(b)[7];}

//ʵ����������ģ�Ӻ���
__device__ __host__ void dh_mybig_modadd_64(const UINT64 *x, const UINT64 *y, UINT64 *z)//����z=x+y, x=x+y, ����ʵ��y=x+y��
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
	
	z[4] = x[4] + g; f = z[4] < g; z[4] += y[4]; f += z[4] < y[4];
	z[5] = x[5] + f; g = z[5] < f; z[5] += y[5]; g += z[5] < y[5];
	z[6] = x[6] + g; f = z[6] < g; z[6] += y[6]; f += z[6] < y[6];
	z[7] = x[7] + f; g = z[7] < f; z[7] += y[7]; g += z[7] < y[7];
		
	if(g==0)
	{
		for(i=7;i>=0;i--)
		{
			if(z[i]!=Pa[i])
			{
				g=(z[i]>Pa[i]);
				break;
			}
			else if(i==0)//ȫ���,��t=P, ��ʵ��ʱ��ֵΪ0����
			{
				g=1;
			}
		}
	}
	
	if(g)//x+y���ܵ���ģ��
	{
		f = z[0] < Pa0; z[0] -= Pa0;
		g = z[1] < f; z[1] -= f; g += z[1] < Pa1; z[1] -= Pa1;
		f = z[2] < g; z[2] -= g; f += z[2] < Pa2; z[2] -= Pa2;		                                                  
		g = z[3] < f; z[3] -= f; g += z[3] < Pa3; z[3] -= Pa3;		
		f = z[4] < g; z[4] -= g; f += z[4] < Pa4; z[4] -= Pa4;		                                                  
		g = z[5] < f; z[5] -= f; g += z[5] < Pa5; z[5] -= Pa5;
		f = z[6] < g; z[6] -= g; f += z[6] < Pa6; z[6] -= Pa6;				
		z[7] -= f; z[7] -= Pa7;
	}
}

//ʵ����������ģ������
__device__ __host__ void dh_mybig_modsub_64(const UINT64 *x, const UINT64 *y, UINT64 *z)//����z=x-y, x=x-y, ����ʵ��y=x-y��
{
	UINT64 f,g;
	//UINT64 z0,z1,z2,z3,z4,z5,z6,z7;
	f=(x[0]<y[0]); z[0]=x[0]-y[0];
	g=(x[1]<f); z[1]=x[1]-f; g+=(z[1]<y[1]); z[1]-=y[1];
	f=(x[2]<g); z[2]=x[2]-g; f+=(z[2]<y[2]); z[2]-=y[2];
	g=(x[3]<f); z[3]=x[3]-f; g+=(z[3]<y[3]); z[3]-=y[3];
	
	f=(x[4]<g); z[4]=x[4]-g; f+=(z[4]<y[4]); z[4]-=y[4];
	g=(x[5]<f); z[5]=x[5]-f; g+=(z[5]<y[5]); z[5]-=y[5];
	f=(x[6]<g); z[6]=x[6]-g; f+=(z[6]<y[6]); z[6]-=y[6];
	g=(x[7]<f); z[7]=x[7]-f; g+=(z[7]<y[7]); z[7]-=y[7];
	//��λΪg;

	if(g)//ֻ�жϽ�λ���ٶ�Ӧ�ÿ�һ��
	{
		z[0]+=Pa0; f=(z[0]<Pa0);
		z[1]+=f; f=(z[1]<f); z[1]+=Pa1; f+=(z[1]<Pa1);
		z[2]+=f; f=(z[2]<f); z[2]+=Pa2; f+=(z[2]<Pa2);
		z[3]+=f; f=(z[3]<f); z[3]+=Pa3; f+=(z[3]<Pa3);
		z[4]+=f; f=(z[4]<f); z[4]+=Pa4; f+=(z[4]<Pa4);
		z[5]+=f; f=(z[5]<f); z[5]+=Pa5; f+=(z[5]<Pa5);
		z[6]+=f; f=(z[6]<f); z[6]+=Pa6; f+=(z[6]<Pa6);
		z[7]+=f; z[7]+=Pa7;		
	}	
}

//����������Գ˷���ȡ64λ�˷���λ
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

//ʵ���ɸ������˷�C=a*b
/////////////////////////////////////////
//Montgomeryģ��
//C=A*B*2^-512 mod P
//����CIOS�㷨
//////////////////////////////////////////
__device__ __host__  void dh_mybig_monmult_64(const UINT64 *Aa, const UINT64 *Ba, UINT64 *Ca)//pass, c=a*b
{
	UINT64 t[8+2]={0};//8��64��������,�޶�512
	
	//minv*P[0] mod 2^wordlen = -1. ��Ϊ�ó����ֳ���64���أ�P[0]=0xffffffffffffffff=-1������minv=1, minv*P[0]=-1 mod 2^64=-1
	
	//���������P������Ҫ���¼������á����ֵ����Ǵ��룬���߶���Ϊȫ�ֱ���
	UINT64 minv=1;//minvֵ��Ҫ��������P�����λP[0]�˻�ģ2^64=-1(��ΪP[0]��64�����֣������32�����֣����ҵ�ģ2^32=-1�Ǹ����� ���õ�����������������ֵ�ģ2^wordlen����ĸ�ֵ��

	UINT64 m;	
	UINT64 c,s,cin;
	int i,j;
	
	#ifdef __CUDA_ARCH__	
		UINT64 *Pa=dc_p;	
		#define h_Hi64 __umul64hi
	#else
		const UINT64 *Pa=h_p;
	#endif	
	
	for(i=0;i<8;i++)
	{
		c=0;
		m=Ba[i];
		
		s=m*Aa[0]; c+=t[0];	cin=(c<t[0]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[0])+cin; 	t[0]=s;
		s=m*Aa[1]; c+=t[1];	cin=(c<t[1]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[1])+cin; 	t[1]=s;
		s=m*Aa[2]; c+=t[2];	cin=(c<t[2]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[2])+cin; 	t[2]=s;
		s=m*Aa[3]; c+=t[3];	cin=(c<t[3]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[3])+cin; 	t[3]=s;
		s=m*Aa[4]; c+=t[4];	cin=(c<t[4]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[4])+cin; 	t[4]=s;
		s=m*Aa[5]; c+=t[5];	cin=(c<t[5]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[5])+cin; 	t[5]=s;
		s=m*Aa[6]; c+=t[6];	cin=(c<t[6]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[6])+cin; 	t[6]=s;
		s=m*Aa[7]; c+=t[7];	cin=(c<t[7]);		s+=c;		cin+=(s<c);	c=h_Hi64(m,Aa[7])+cin; 	t[7]=s;		
								
		s=t[8]+c;
		c=(s<c);
		t[8]=s;
		t[8+1]=c;
				
		m=minv*t[0];//����p��minv=1���ȼ���m=t[0]
		c=h_Hi64(m,Pa0);
		s=m*Pa0+t[0];   //��Ϊ���������������Pa0=-1, minv=1������s=0;		
		c+=(s<t[0]);
		
		s=m*Pa1; c+=t[1]; cin=(c<t[1]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa1)+cin; t[0]=s;		
		s=m*Pa2; c+=t[2]; cin=(c<t[2]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa2)+cin; t[1]=s;
		s=m*Pa3; c+=t[3]; cin=(c<t[3]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa3)+cin; t[2]=s;		
	    s=m*Pa4; c+=t[4]; cin=(c<t[4]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa4)+cin; t[3]=s;		
		s=m*Pa5; c+=t[5]; cin=(c<t[5]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa5)+cin; t[4]=s;
		s=m*Pa6; c+=t[6]; cin=(c<t[6]); s+=c;	cin+=(s<c); c=h_Hi64(m,Pa6)+cin; t[5]=s;		
		s=m*Pa7; c+=t[7]; cin=(c<t[7]); s+=c;   cin+=(s<c); c=h_Hi64(m,Pa7)+cin; t[6]=s;
		
		s=t[8]+c;
		c=(s<c);
		t[8-1]=s;
		t[8]=t[8+1]+c;
	}
	
	j=(t[8]!=0);
	if(j==0)
	{
		for(i=8-1;i>=0;i--)
		{
			if(t[i]!=Pa[i])
			{				
				j=(t[i]>Pa[i]);
				break;
			}
			else if(i==0)//ȫ���,��t=P, ��ʵ��ʱ��ֵΪ0����
			{
				j=1;
			}
		}
	}
	
	//����	
	if(j)
	{
		cin=1;	
		for(i=0;i<8;i++)
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
		for(i=0;i<8;i++)
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
	for(i=0;i<8;i++)
	{
		if(A[i]!=0)	return 0;
	}
	return 1;	
}

//�Ƚϴ�С
//return 1	A>B
//return 0	A=B
//return -1 A<B
__device__ __host__ int dh_mybig_compare_64(const UINT64 *A, const UINT64 *B)
{
	int i;
	int flag=0;

	for(i=7;i>=0;i--)
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
	for(i=8-1;i>=0;i--)
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
	for(i=0;i<8;i++)
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
	for(i=0;i<8;i++)
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
	for(i=0;i<8;i++)
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
//��2ģ
//����:		A P
//���:		C
//C=2*A mod P
//////////////////////////////////////////
__device__ __host__ void dh_mybig_moddouble_64(const UINT64 *A, const UINT64 *P, UINT64 *C)
{
	int i,sub_en=0;
	UINT64 cin,c,temp64;

	//��λ
	cin=(A[0]>>63)&0x1;//ȫ������һλ,�൱�ڳ�2
	C[0]=A[0]<<1;
	for(i=1;i<8;i++)
	{
		c=(A[i]>>63)&0x1;
		C[i]=(A[i]<<1)|cin;
		cin=c;
	}

	//�Ƚϴ�С
	if(cin==1)//�����һ����λΪ1,������ô���ֽ��Ѿ��治��2*A�����2*A�϶���p��
	{
		sub_en=1;
	}
	else
	{
		for(i=7;i>=0;i--)
		{
			if(C[i]!=P[i])
			{
				if(C[i]>P[i]) sub_en=1;
				break;
			}
			else if(i==0) sub_en=1;//����ȫ���
		}
	}
	
	//����
	if(sub_en)//����Ӧ��дΪif(sub_en!=0)���ɱ�������
	{
		cin=1;
		for(i=0;i<8;i++)
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
	if( A[0]|A[1]|A[2]|A[3]|A[4]|A[5]|A[6]|A[7])
		return 0;
	else return 1;
}

void h_mybig_print(const UINT64 *a)
{
	int i;
	unsigned char *t=(unsigned char*) a;
	for(i=64-1;i>=0;i--) if(*(t+i)) break;//��0������ȥ
	if(i<0) printf("0");
	else
	{
		printf("%x",*(t+i)&0xff);//��һ��0����ӡ
		for(i=i-1;i>=0;i--)printf("%02x",*(t+i)&0xff);
	}	
}
__device__ void d_mybig_print(const UINT64 *a)
{
	int i;
	unsigned char *t=(unsigned char*) a;
	for(i=32-1;i>=0;i--) if(*(t+i)) break;//��0������ȥ
	if(i<0) printf("0");
	else
	{
		printf("%x",*(t+i)&0xff);//��һ��0����ӡ
		for(i=i-1;i>=0;i--)printf("%02x",*(t+i)&0xff);
	}
	printf("\n");	
}
/////////////////////////////////////////
//������: ����ģ��C=A^-512 * 2^512 mod P
//����:		A C l(lΪ���ı��س���512)
//���:		C (C=A^-1 * 2^512 mod P)
//˵��: A<P
//////////////////////////////////////////
__device__ __host__ void dh_mybig_moninv(const UINT64 *A,UINT64 *C)//test
{
	int i,k;
	UINT64 U[8],V[8],R[8],S[8];
	int z,cp,cs,cr,sh;
	/*
	#ifdef __CUDA_ARCH__	
		UINT64 *P=dc_p;	
	#else
		const UINT64 *P=h_p;
	#endif	
	//*/

	/************************�㷨********************************
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
	U[0]=0xffffffffffffffffL; //U=P��P��ֵ������Ҫȥ����
	U[1]=0xfffffffeffffffffL;
	U[2]=0xffffffffffffffffL;
	U[3]=0xfffffffeffffffffL;
	U[4]=0xffffffffffffffffL;
	U[5]=0xfffffffffffffffeL;
	U[6]=0xfffffffeffffffffL;
	U[7]=0xffffffffffffffffL;


	for(i=0;i<8;i++) V[i]=A[i];
	for(i=0;i<8;i++) R[i]=0;
	for(i=1;i<8;i++) S[i]=0;
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
	
	U[0]=0xffffffffffffffffL;
	U[1]=0xfffffffeffffffffL;
	U[2]=0xffffffffffffffffL;
	U[3]=0xfffffffeffffffffL;
	U[4]=0xffffffffffffffffL;
	U[5]=0xfffffffffffffffeL;
	U[6]=0xfffffffeffffffffL;
	U[7]=0xffffffffffffffffL;

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
 	 if(k>512)
	 {	
	    for(i=0;i<8;i++) V[i]=0;
	    V[(int)((1024-k)/64)]=(((UINT64)1)<<((int)((1024-k)%64)));
	    dh_mybig_monmult_64(R,V,C);
	 }	
	 else if(k==512) 
	 {
			V[0]=0x0000000000000001L;
			V[1]=0x0000000100000000L;
			V[2]=0x0000000000000000L;
			V[3]=0x0000000100000000L;
			V[4]=0x0000000000000000L;
			V[5]=0x0000000000000001L;
			V[6]=0x0000000100000000L;
			V[7]=0x0000000000000000L;
			dh_mybig_monmult_64(R,V,C);		
		}
		else if(k<512) 
		{
		  //printf("2\n");
		  for(i=1;i<=(512-k);i++)
			{		
				dh_mybig_moddouble_64(R,U,R);			
			}
		  for(i=0;i<8;i++) C[i]=R[i];
		}

}

//////////////////////////////////////test inv end//////////////////////////////////////

/////////////////GPU���������㺯������////////////////////////////////////////////////////


/////////////////GPU��Ӻͱ��㺯����ʼ��û��дȫ�ĵ�Ӻ������������������������㣬�Լ����ݵ�ӹ�ʽ����///////////////////////////////////////
__device__ __host__  void dh_setzero_J(Jpoint *pt)
{
	int i;
	for(i=0;i<8;i++) pt->z[i]=0UL;
}

__device__ __host__  void dh_setzero_A(Apoint *pt)
{
	int i;
	for(i=0;i<8;i++) pt->x[i]=0UL;	
}

__device__ __host__  int dh_iszero_J(const Jpoint *pt)
{
	if((pt->z[0]|pt->z[1]|pt->z[2]|pt->z[3]|pt->z[4]|pt->z[5]|pt->z[6]|pt->z[7]) == 0UL)	return 1;
	return 0;	
}


__device__ __host__  int dh_iszero_A(const Apoint *pt)
{	
	if((pt->x[0]|pt->x[1]|pt->x[2]|pt->x[3]|pt->x[4]|pt->x[5]|pt->x[6]|pt->x[7]) == 0UL)	return 1;
	return 0;
}


//����Ӱ������ת��Ϊ��������
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

__device__ void d_mon2normal_J(Jpoint *pt)
{
	dh_mybig_monmult_64(pt->x, dc_ONE, pt->x);
	dh_mybig_monmult_64(pt->y, dc_ONE, pt->y);
	dh_mybig_monmult_64(pt->z, dc_ONE, pt->z);	
}
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
	h_mybig_print(pt->x);printf("\n");
	h_mybig_print(pt->y);printf("\n");
	
}

void h_print_pointJ(const Jpoint *pt)
{
	/*
	if(dh_iszero_J(pt))
	{ 
		printf("(Infinity)\n");
		return;
	}*/
	h_mybig_print(pt->x);printf("\n");
	h_mybig_print(pt->y);printf("\n");
	h_mybig_print(pt->z);printf("\n");
}


//��Ӱ��pt1�ӵȷ����pt2, pt1+=pt2
__device__ __host__ void dh_ellipticSumEqual_AJ(Jpoint *pt1, Apoint* pt2)//pt1,pt2���뱣֤������Զ�㣬�ں��������ж�
{
	UINT64 u1[8],u2[8];
	if(dh_iszero_A(pt2))	return;	
	if(dh_iszero_J(pt1))
	{
		dh_mybig_copy(pt1->x, pt2->x);
		dh_mybig_copy(pt1->y, pt2->y);
		//Z��ֵΪmon_ONE�����ֵ��Ҫ����p��������
		pt1->z[0]=0x0000000000000001L;		pt1->z[1]=0x0000000100000000L;		pt1->z[2]=0x0000000000000000L;		pt1->z[3]=0x0000000100000000L;
		pt1->z[4]=0x0000000000000000L;		pt1->z[5]=0x0000000000000001L;		pt1->z[6]=0x0000000100000000L;		pt1->z[7]=0x0000000000000000L;				
		return;
	}	
	//���ڳ������жϣ���ֹ�ӷ������������Զ��
	
	
	//3.����u1=(pt1->z)^2.
	dh_mybig_monmult_64(pt1->z, pt1->z, u1);
	
	//4.����u2=(pt1->z)*u1.
	dh_mybig_monmult_64(pt1->z, u1, u2);
	
	//5.����u1=(pt2->x)*u1.
	dh_mybig_monmult_64(pt2->x, u1, u1);
	
	//6.����u2=(pt2->y)*u2.
	dh_mybig_monmult_64(pt2->y, u2, u2);
	
	//7.����u1=u1-pt1->x.		
	dh_mybig_modsub_64(u1, pt1->x,u1);
	
	//8.����u2=u2-pt1->y.	
	dh_mybig_modsub_64(u2,pt1->y,u2);
	
	///*	
	//9.�жϵȵ�,��Ҫ���ö��������.
	if(dh_mybig_iszero(u1))
	{
		if(dh_mybig_iszero(u2))
		{
			//ppoint_double(pt1,pt3);//y����Ҳ��ͬ�����ض�����
			printf("here! use ppoint double!\n");
			return;
		}
		else//��������ӣ���������Զ��
		{
			dh_setzero_J(pt1);
			return ;
		}
	}
	//*/
	//10.pt1->z=pt1->z*u1.
	dh_mybig_monmult_64(pt1->z, u1, pt1->z);
	
	//11.����pt2->x=u1^2.
	dh_mybig_monmult_64(u1, u1, pt2->x);
	
	//12.����pt2->y=pt2->x*u1.
	dh_mybig_monmult_64(u1, pt2->x, pt2->y);
	
	//13.����pt2->x=pt1->x*pt2->x.
	dh_mybig_monmult_64(pt1->x, pt2->x, pt2->x);
	
	//14.����u1=2*pt2->x.
	dh_mybig_modadd_64(pt2->x,pt2->x,u1);
	
	//15.x1=u2^2.
	dh_mybig_monmult_64(u2, u2, pt1->x);
	
	//16.x1=pt2->x
	dh_mybig_modsub_64(pt1->x,u1,pt1->x);
	
	//17.x1=x1-pt2->y
	dh_mybig_modsub_64(pt1->x,pt2->y,pt1->x);
	
	//18.����pt2->x=pt2->x-x1.
	dh_mybig_modsub_64(pt2->x,pt1->x,pt2->x);
	
	//19.pt2->x=pt2->x*u2
	dh_mybig_monmult_64(pt2->x, u2, pt2->x);
	
	//20.pt2->y=pt2->y*y1
	dh_mybig_monmult_64(pt2->y, pt1->y, pt2->y);
	
	//21.y1=pt2->x-pt2->y
	dh_mybig_modsub_64(pt2->x,pt2->y,pt1->y);
}

//��������
__device__ void d_multi_inverse(UINT64 *x)
{
	int i,j;
	UINT64 invlj[PARAL*8];//�Ĵ���ÿ��С�˿��Է�4KB�ֽڣ�4096=64*256,������256��512������
	UINT64 lmd[8];
	
	dh_mybig_copy(invlj,x);//	for(i=0;i<8;i++) invlj[0][i]=x[0][i];
		
	for(i=1;i<PARAL;i++)
	{			    					
		dh_mybig_monmult_64(invlj+(i-1)*8,x+i*8,invlj+i*8);
	}
		
	dh_mybig_monmult_64(invlj+(PARAL-1)*8,dc_ONE,lmd);//z=Z mod P //��ȥ���ɸ�����
	dh_mybig_moninv(lmd,lmd); //�����ʱ���ִ���2^n��
		
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

//�������滯��Ӱ��
__global__ void d_multi_normlize_J(Jpoint *A, int n)
{	
	//����n����ΪPARAL��������
	
	int i,j,k;
	UINT64 tmp[8];
	int mytid=threadIdx.x+blockDim.x*blockIdx.x;
	int threadnum=blockDim.x*gridDim.x;
	UINT64 z[8*PARAL];//�˴�z����α��������
			
	for(i=mytid*PARAL;i<n;i+=threadnum*PARAL) //n����PARAL��������һ�Σ�ÿ��С����һ�Σ�ѭ������ȥ
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

			//z��ʼ��Ϊmon_ONE�����mon_ONE���ֳ��й�
			A[i+j].z[0]=0x0000000000000001L;	A[i+j].z[1]=0x0000000100000000L;	A[i+j].z[2]=0x0000000000000000L;	A[i+j].z[3]=0x0000000100000000L;
			A[i+j].z[4]=0x0000000000000000L;	A[i+j].z[5]=0x0000000000000001L;	A[i+j].z[6]=0x0000000100000000L;	A[i+j].z[7]=0x0000000000000000L;	
			
			d_mon2normal_J(A+i+j);
		}
	}
	
}

/////////////////GPU��Ӻͱ��㺯������////////////////////////////////////////////////////

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
