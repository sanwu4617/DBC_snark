#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <random>
#include "gmp.h"
#include "gpuec256.h"
#include "openssl/sha.h"
#include "cuda_common.h"
#include "sha256.cuh"
#include<sys/time.h>

#define dh_mybig_copy(a,b) {(a)[0]=(b)[0];(a)[1]=(b)[1];(a)[2]=(b)[2];(a)[3]=(b)[3];}

typedef struct IntermediateVar{		
	UINT64 t1[4];
    UINT64 t2[4];
}InterVar;


const UINT64 h_Gx[4]={0x59F2815B16F81798L,0x029BFCDB2DCE28D9L,0x55A06295CE870B07L,0x79BE667EF9DCBBACL};
const UINT64 h_Gy[4]={0x9C47D08FFB10D4B8L,0xFD17B448A6855419L,0x5DA4FBFC0E1108A8L,0x483ADA7726A3C465L};
const UINT64 h_Gz[4]={0x1L,0x0L,0x0L,0x0L};

const UINT64 h_Gx_mon[4]={0xd7362e5a487e2097L,0x231e295329bc66dbL,0x979f48c033fd129cL,0x9981e643e9089f48L};
const UINT64 h_Gy_mon[4]={0xb15ea6d2d3dbabe2L,0x8dfc5d5d1f1dc64dL,0x70b6b59aac19c136L,0xcf3f851fd4a582d6L};
const UINT64 h_Gz_mon[4]={0x1000003d1L,0x0L,0x0L,0x0L};
const UINT64 h_R2[4]={0x000007a2000e90a1L,0x1L,0x0L,0x0L};
Jpoint pG_mon={{0xd7362e5a487e2097L,0x231e295329bc66dbL,0x979f48c033fd129cL,0x9981e643e9089f48L},
                {0xb15ea6d2d3dbabe2L,0x8dfc5d5d1f1dc64dL,0x70b6b59aac19c136L,0xcf3f851fd4a582d6L},
                {0x1000003d1L,0x0L,0x0L,0x0L}};

BPSetupParams h_params;
initParamRandom h_ranParams;
std::string SEED="gyy hello world";

BPSetupParams *d_params;
initParamRandom *d_ranParams;

BPProve *d_prove;

UINT64 *d_xyz;
UINT64 h_xyz[12];

InterVar *d_iv;

UINT64 *d_aLR;
UINT64 h_aLR[4*64];
UINT64 *d_VLR;
UINT64 *d_z22nyn;

// void h_mybig_print(const UINT64 *a)
// {
// 	int i;
// 	unsigned char *t=(unsigned char*) a;
// 	for(i=32-1;i>=0;i--) if(*(t+i)) break;//把0都跳过去
// 	if(i<0) printf("0");
// 	else
// 	{
// 		printf("%x",*(t+i)&0xff);//第一个0不打印
// 		for(i=i-1;i>=0;i--)printf("%02x",*(t+i)&0xff);
//     }
//     printf("\n");	
// }
// void h_print_pointJ(const Jpoint *pt)
// {
// 	/*
// 	if(dh_iszero_J(pt))
// 	{ 
// 		printf("(Infinity)\n");
// 		return;
// 	}*/
// 	printf("x: ");h_mybig_print(pt->x);printf("\n");
// 	printf("y: ");h_mybig_print(pt->y);printf("\n");
// 	printf("z: ");h_mybig_print(pt->z);printf("\n");
// }

 void uint642str(UINT64* x,char *s){
    int cur=0;
    for(int i=3;i>=0;i--){
        for(int j=0;j<16;j++){
            // std::cout<<((x[i]>>((15-j)*4))&0xf==0)<<std::endl;
            // printf("%d\n",(x[i]>>((15-j)*4))&0xf);
            // printf("%d\n",(int)(x[i]>>((15-j)*4))&0xf == (int)0);
            if(cur==0 && (((x[i]>>((15-j)*4))&0xf) ==0)){
                continue;
            }
            sprintf(s + cur, "%x", (x[i]>>((15-j)*4))&0xf);
            cur++;
            // sprintf(s + (3-i)*16+j*2, "%02x", (x[i]>>((7-j)*8))&0xff);
            // printf("%x\n",(x[i]>>((7-j)*8))&0xff);
        }
        
    }
    s[cur]=0;
}
// __host__  void uint642byte(UINT64 *x,char *h){
//     for(int i=0;i<4;i++){
//         for(int j=0;j<8;j++){
//             h[i*8+j]=(x[3-i]>>((7-j)*8))&0xff;
//         }
//     }
// }
__device__ __host__ void uint642byte(UINT64 *x, unsigned char *h){
    for(int i=0;i<4;i++){
        for(int j=0;j<8;j++){
            h[i*8+j]=(x[3-i]>>((7-j)*8))&0xff;
        }
    }
}

void inline JpointCpy(Jpoint *jp,const UINT64 *x,const UINT64 *y,const UINT64 *z){
    jp->x[0] = x[0];
    jp->x[1] = x[1];
    jp->x[2] = x[2];
    jp->x[3] = x[3];

    jp->y[0] = y[0];
    jp->y[1] = y[1];
    jp->y[2] = y[2];
    jp->y[3] = y[3];

    jp->z[0] = z[0];
    jp->z[1] = z[1];
    jp->z[2] = z[2];
    jp->z[3] = z[3];
}

void str2uint64(char *s,UINT64* x){
    std::string tmps(s);
    // std::cout<<"size="<<tmps.size()<<std::endl;
    // std::cout<<"tmps="<<tmps<<std::endl;
    // std::cout<<"s="<<s<<std::endl;
    // std::cout<<tmps<<std::endl;
    // std::cout<<"0="<<tmps.substr(tmps.size()-16,16).c_str()<<std::endl;
    // std::cout<<"1="<<tmps.substr(tmps.size()-32,16).c_str()<<std::endl;
    // std::cout<<"2="<<tmps.substr(tmps.size()-48,16).c_str()<<std::endl;
    // std::cout<<"3="<<tmps.substr(0,16-(64-tmps.size())).c_str()<<std::endl;
    x[0]=strtoull(tmps.substr(tmps.size()-16,16).c_str(),NULL,16);
    x[1]=strtoull(tmps.substr(tmps.size()-32,16).c_str(),NULL,16);
    x[2]=strtoull(tmps.substr(tmps.size()-48,16).c_str(),NULL,16);
    x[3]=strtoull(tmps.substr(0,16-(64-tmps.size())).c_str(),NULL,16);
    // h_mybig_print(x);
    // std::cout<<std::endl;
}

void sha256(const std::string &srcStr, std::string &encodedHexStr)  
{  
    // 调用sha256哈希    
    unsigned char mdStr[33] = {0};  
    SHA256((const unsigned char *)srcStr.c_str(), srcStr.length(), mdStr);  
  
    // 哈希后的字符串    
    // 哈希后的十六进制串 32字节    
    char buf[65] = {0};  
    char tmp[3] = {0};  
    for (int i = 0; i < 32; i++)  
    {  
        sprintf(tmp, "%02x", mdStr[i]);  
        strcat(buf, tmp);  
    }  
    buf[64] = '\0';   
    encodedHexStr = std::string(buf);  
} 
int check_quadratic_residue(mpz_t num){
    mpz_t t1,t2,d;
    mpz_init(t1);
    mpz_init(t2);
    mpz_init(d);
    mpz_set_str(d,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F",16);

    mpz_sub_ui(t1,d,1);
    mpz_tdiv_q_ui(t2,t1,2);
    // gmp_printf("%#Zx\n",t1);
    mpz_powm(t2,num,t2,d);
    // gmp_printf("%#Zx\n",t2);
    if(mpz_cmp_ui(t2,1)==0){
        // gmp_printf("right\n");
        return 1;
    }
    if(mpz_cmp(t2,t1)==0){
        // gmp_printf("not\n");
        return -1;
    }
    return 0;
}

void mapToGroup(const std::string &s,Jpoint* jp){
    std::string tmphex;
    sha256(s,tmphex);
    // std::cout<<tmphex<<std::endl;
    mpz_t hexr,d;
    mpz_t t1,t2;
    mpz_t rx,ry;
    mpz_init(hexr);
    mpz_init(d);
    mpz_set_str(d,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F",16);
    mpz_init(t1);
    mpz_init(t2);
    mpz_init(rx);
    mpz_init(ry);
    mpz_set_str(hexr,tmphex.c_str(),16);


    for(int i=0;i<2048;i+=1){
        mpz_add_ui(rx,hexr,i);
        mpz_powm_ui(hexr,rx,3,d);
        mpz_add_ui(hexr,hexr,7);
        mpz_mod(hexr,hexr,d);


        // mpz_sub_ui(t1,d,1);
        // mpz_tdiv_q_ui(t2,t1,2);
        // gmp_printf("%#Zx\n",t1);
        // mpz_powm(t2,hexr,t2,d);
        if(check_quadratic_residue(hexr)==1){
            // gmp_printf("right\n");
            break;
        }
        if(check_quadratic_residue(hexr)==-1){
            // gmp_printf("not\n");
        }
        // gmp_printf("%#Zx\n",t2);
    }
    //这里hexr就是满足条件的二次剩余，现在要解二次剩余,rx里存的是x值
    //由于secp256k1曲线素数的特殊性，所以直接采用Tonelli-Shanks算法
    mpz_add_ui(t1,d,1);

    mpz_tdiv_qr_ui(t1,t2,t1,4);
    mpz_powm(ry,hexr,t1,d);

    // gmp_printf("%#Zx\n",rx);
    // gmp_printf("%#Zx\n",ry);
    char jx[65]={0};
    char jy[65]={0};
    mpz_get_str(jx,16,rx);
    mpz_get_str(jy,16,ry);
    str2uint64(jx,jp->x);
    str2uint64(jy,jp->y);
    jp->z[0]=0x1L;
    // h_print_pointJ(jp);
    //验证

    // mpz_powm_ui(t1,rx,3,d);
    // mpz_add_ui(t1,t1,7);
    // mpz_mod(t1,t1,d);
    // mpz_powm_ui(t2,ry,2,d);
    // mpz_mod(t2,t2,d);
    // if(mpz_cmp(t1,t2)==0){
    //     gmp_printf("x and y right\n");
    // }else{
    //     gmp_printf("WRONG!!!\n");
    // }
    
    //下面是Cipolla算法第一步找a^2-n为非二次剩余（由于最终采用了别的方法，所以注释掉）
    /*
    while(1){
        mpz_add_ui(t2,hexr,i);
        mpz_powm_ui(t1,t2,2,d);
        mpz_sub(t1,t1,hexr);
        mpz_mod(t1,t1,d);
        if(check_quadratic_residue(t1)==-1){
            break;
        }
        i++;
    }
    gmp_printf("i=%d\n",i);
    gmp_printf("%#Zx\n",t2);
    gmp_printf("%#Zx\n",hexr);
    */


}
void gen_random_uint64(std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> &engine,UINT64 s[4]){
    // std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine(clock());
    for(int i=0;i<4;i++){
        s[i] = engine();
    }
    if(s[0]==0xFFFFFFFFFFFFFFFF&&s[1]==0xFFFFFFFFFFFFFFFF&&
        s[2]==0xFFFFFFFFFFFFFFFF&&s[3]>0xFFFFFFFEFFFFFC2F){
            s[3]-=0xFFFFFFFEFFFFFC2F;
    }
}

void init_random_param(){
    std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine(19970504);
    // std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine;
    gen_random_uint64(engine,h_ranParams.gamma);
    gen_random_uint64(engine,h_ranParams.alpha);
    gen_random_uint64(engine,h_ranParams.rho);
    gen_random_uint64(engine,h_ranParams.tau1);
    gen_random_uint64(engine,h_ranParams.tau2);
    
    

    for(int i=0;i<32;i++){

        gen_random_uint64(engine,&(h_ranParams.SL[i*4]));
        gen_random_uint64(engine,&(h_ranParams.SR[i*4]));         
        
        
    }
    // h_mybig_print(ranParams.gamma);
    // h_mybig_print(ranParams.alpha);
}

__host__ __device__ void Jpoint2Apoint(Jpoint *A,Jpoint *ret){
    #ifdef __CUDA_ARCH__
		const UINT64 *R2=dc_R2;
        const UINT64 *ONE=dc_ONE;
	#else
		const UINT64 *R2=h_R2;
        const UINT64 *ONE=h_ONE;
	#endif
    UINT64 t1[4],t2[4];
    dh_mybig_moninv(A->z,t1);
    dh_mybig_monmult_64(t1,t1,t2);
    dh_mybig_monmult_64(t1,t2,t1);
    dh_mybig_monmult_64(A->x,R2,ret->x);
    dh_mybig_monmult_64(A->y,R2,ret->y);
    dh_mybig_monmult_64(ret->x,t2,ret->x);
    dh_mybig_monmult_64(ret->y,t1,ret->y);

    dh_mybig_monmult_64(ret->x,ONE,ret->x);
    dh_mybig_monmult_64(ret->y,ONE,ret->y);
    ret->z[0]=1;
    ret->z[1]=0;
    ret->z[2]=0;
    ret->z[3]=0;
}

void HashBP(Jpoint* A,Jpoint* S,UINT64 *o1,UINT64 *o2){
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    // unsigned char tmp[32];

    char tmp[65];
    char o1str[65];
    uint642str(A->x,tmp);
    SHA256_Update(&sha256, tmp, strlen(tmp));
    uint642str(A->y,tmp);
    SHA256_Update(&sha256, tmp, strlen(tmp));
    uint642str(S->x,tmp);
    SHA256_Update(&sha256, tmp, strlen(tmp));
    uint642str(S->y,tmp);
    SHA256_Update(&sha256, tmp, strlen(tmp));
    SHA256_Final(hash, &sha256);
    for(int i = 0; i < SHA256_DIGEST_LENGTH; i++)
    {
        sprintf(o1str + (i * 2), "%02x", hash[i]);
    }
    o1str[64] = 0;
    str2uint64(o1str,o1);
    // printf("tmp=%s\n",o1str);
    // h_mybig_print(o1);
    if(o2==NULL) return;
    SHA256_CTX sha2562;
    SHA256_Init(&sha2562);
    // unsigned char tmp[32];

    uint642str(A->x,tmp);
    SHA256_Update(&sha2562, tmp, strlen(tmp));
    uint642str(A->y,tmp);
    SHA256_Update(&sha2562, tmp, strlen(tmp));
    uint642str(S->x,tmp);
    SHA256_Update(&sha2562, tmp, strlen(tmp));
    uint642str(S->y,tmp);
    SHA256_Update(&sha2562, tmp, strlen(tmp));
    SHA256_Update(&sha2562, o1str, strlen(o1str));
    SHA256_Final(hash, &sha2562);
    for(int i = 0; i < SHA256_DIGEST_LENGTH; i++)
    {
        sprintf(tmp + (i * 2), "%02x", hash[i]);
    }
    str2uint64(tmp,o2);
    // printf("tmp=%s\n",tmp);
    // h_mybig_print(o2);
    // o2[64] = 0;
}

//不转成str
void HashBP_V2(Jpoint* A,Jpoint* S,UINT64 *o1,UINT64 *o2){
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    // unsigned char tmp[32];

    unsigned char tmp[65];
    char o1str[65];
    uint642byte(A->x,tmp);
    SHA256_Update(&sha256, tmp, 32);
    uint642byte(A->y,tmp);
    SHA256_Update(&sha256, tmp, 32);
    uint642byte(S->x,tmp);
    SHA256_Update(&sha256, tmp, 32);
    uint642byte(S->y,tmp);
    SHA256_Update(&sha256, tmp, 32);
    SHA256_Final(hash, &sha256);
    // for(int i = 0; i < SHA256_DIGEST_LENGTH; i++)
    // {
    //     sprintf(o1str + (i * 2), "%02x", hash[i]);
    // }
    // for(int i=0;i<32;i++){
    //     printf("%x ",hash[i]);
    // }
    // printf("\n");
    // o1str[64] = 0;
    // str2uint64(o1str,o1);
    o1[3]=(UINT64)hash[7]|((UINT64)hash[6])<<8|((UINT64)hash[5])<<16|((UINT64)hash[4])<<24
            |((UINT64)hash[3])<<32|((UINT64)hash[2])<<40|((UINT64)hash[1])<<48 |((UINT64)hash[0])<<56;
    o1[2]=(UINT64)hash[15]|((UINT64)hash[14])<<8|((UINT64)hash[13])<<16|((UINT64)hash[12])<<24
            |((UINT64)hash[11])<<32|((UINT64)hash[10])<<40|((UINT64)hash[9])<<48 |((UINT64)hash[8])<<56;
    o1[1]=(UINT64)hash[23]|((UINT64)hash[22])<<8|((UINT64)hash[21])<<16|((UINT64)hash[20])<<24
            |((UINT64)hash[19])<<32|((UINT64)hash[18])<<40|((UINT64)hash[17])<<48 |((UINT64)hash[16])<<56;
    o1[0]=(UINT64)hash[31]|((UINT64)hash[30])<<8|((UINT64)hash[29])<<16|((UINT64)hash[28])<<24
            |((UINT64)hash[27])<<32|((UINT64)hash[26])<<40|((UINT64)hash[25])<<48 |((UINT64)hash[24])<<56;
    // printf("tmp=%s\n",o1str);
    // printf("myO1=\n");
    // h_mybig_print(o1);
    if(o2==NULL) return;
    SHA256_CTX sha2562;
    SHA256_Init(&sha2562);
    // unsigned char tmp[32];

    uint642byte(A->x,tmp);
    SHA256_Update(&sha2562, tmp, 32);
    uint642byte(A->y,tmp);
    SHA256_Update(&sha2562, tmp, 32);
    uint642byte(S->x,tmp);
    SHA256_Update(&sha2562, tmp, 32);
    uint642byte(S->y,tmp);
    SHA256_Update(&sha2562, tmp, 32);
    uint642byte(o1,tmp);
    SHA256_Update(&sha2562, tmp, 32);
    SHA256_Final(hash, &sha2562);
    // for(int i = 0; i < SHA256_DIGEST_LENGTH; i++)
    // {
    //     sprintf(tmp + (i * 2), "%02x", hash[i]);
    // }
    // str2uint64(tmp,o2);
    o2[3]=(UINT64)hash[7]|((UINT64)hash[6])<<8|((UINT64)hash[5])<<16|((UINT64)hash[4])<<24
            |((UINT64)hash[3])<<32|((UINT64)hash[2])<<40|((UINT64)hash[1])<<48 |((UINT64)hash[0])<<56;
    o2[2]=(UINT64)hash[15]|((UINT64)hash[14])<<8|((UINT64)hash[13])<<16|((UINT64)hash[12])<<24
            |((UINT64)hash[11])<<32|((UINT64)hash[10])<<40|((UINT64)hash[9])<<48 |((UINT64)hash[8])<<56;
    o2[1]=(UINT64)hash[23]|((UINT64)hash[22])<<8|((UINT64)hash[21])<<16|((UINT64)hash[20])<<24
            |((UINT64)hash[19])<<32|((UINT64)hash[18])<<40|((UINT64)hash[17])<<48 |((UINT64)hash[16])<<56;
    o2[0]=(UINT64)hash[31]|((UINT64)hash[30])<<8|((UINT64)hash[29])<<16|((UINT64)hash[28])<<24
            |((UINT64)hash[27])<<32|((UINT64)hash[26])<<40|((UINT64)hash[25])<<48 |((UINT64)hash[24])<<56;
    
    // printf("myO2=\n");
    // h_mybig_print(o2);
    // printf("tmp=%s\n",tmp);
    // h_mybig_print(o2);
    // o2[64] = 0;
}


void compute_al_ar(int v,UINT64 *al,UINT64 *ar,int n){
    for(int i=0;i<n;i++){
        al[i*4]=(v>>i) &0x1;
        al[i*4+1]=0;
        al[i*4+2]=0;
        al[i*4+3]=0;
        if(al[i*4]){
            ar[i*4]=0;
            ar[i*4+1]=0;
            ar[i*4+2]=0;
            ar[i*4+3]=0;
        }else{
            ar[i*4  ]=0xBFD25E8CD0364141-1;
            ar[i*4+1]=0xBAAEDCE6AF48A03B;
            ar[i*4+2]=0xFFFFFFFFFFFFFFFE;
            ar[i*4+3]=0xFFFFFFFFFFFFFFFF;
            //  
        }
        
    }
}

__host__ void commitG1(Jpoint *ret,int v,UINT64 *r,Jpoint* h){
    UINT64 value[4]={(UINT64)v,0,0,0};
    Jpoint tp;
    // h_mybig_print(value);
    // printf("h=\n");
    // h_print_pointJ(h);
    dh_point_mult_finalversion(&pG_mon,value,ret);
    // dh_mybig_monmult_64(h->x,h_R2,h->x);
    // dh_mybig_monmult_64(h->y,h_R2,h->y);
    // dh_mybig_monmult_64(h->z,h_R2,h->z);
    dh_point_mult_finalversion(h,r,&tp);
    
    dh_ellipticAdd_JJ(ret,&tp,ret);

    
    // printf("r=\n");
    // h_mybig_print(r);
    dh_mybig_monmult_64(ret->x,h_ONE,ret->x);
    dh_mybig_monmult_64(ret->y,h_ONE,ret->y);
    dh_mybig_monmult_64(ret->z,h_ONE,ret->z);
    // h_print_pointJ(ret);
}

void jpoint_to_mon(Jpoint *p){
    dh_mybig_monmult_64(p->x,h_R2,p->x);
    dh_mybig_monmult_64(p->y,h_R2,p->y);
    dh_mybig_monmult_64(p->z,h_R2,p->z);
}
void jpoint_from_mon(Jpoint *p){
    dh_mybig_monmult_64(p->x,h_ONE,p->x);
    dh_mybig_monmult_64(p->y,h_ONE,p->y);
    dh_mybig_monmult_64(p->z,h_ONE,p->z);
}
void trans_to_mon(){
    jpoint_to_mon(&(h_params.G));
    jpoint_to_mon(&(h_params.H));
    for(int i=0;i<32;i++){
        jpoint_to_mon(&(h_params.Gg[i]));
        jpoint_to_mon(&(h_params.Hh[i]));
    }
}
void trans_to_mon_N(){
    //SL SR AL AR y z
    // dh_mybig_monmult_64_modN(h_xyz+4,h_R2modN,h_xyz+4);
    // dh_mybig_monmult_64_modN(h_xyz+8,h_R2modN,h_xyz+8);

    // for(int i=0;i<32;i++){
    //     dh_mybig_monmult_64_modN(h_ranParams->SL+i*4,h_R2modN,h_ranParams->SL+i*4);
    //     dh_mybig_monmult_64_modN(h_ranParams->SR+i*4,h_R2modN,h_ranParams->SR+i*4);

        
    // }
    for(int i=0;i<32*2;i++){
        dh_mybig_monmult_64_modN(h_aLR+i*4,h_R2modN,h_aLR+i*4);
        
    }

}

void trans_from_mon(){

}

void cal_minus_Jpoint(Jpoint *ret,Jpoint *src){
    ret->x[0] = src->x[0];
    ret->x[1] = src->x[1];
    ret->x[2] = src->x[2];
    ret->x[3] = src->x[3];

    ret->z[0] = src->z[0];
    ret->z[1] = src->z[1];
    ret->z[2] = src->z[2];
    ret->z[3] = src->z[3];

    // ret->y[0] = src->y[0];
    // ret->y[1] = src->y[1];
    // ret->y[2] = src->y[2];
    // ret->y[3] = src->y[3];

    dh_mybig_modsub_64(h_p,src->y,ret->y);

}

void cal_A(UINT64* al,UINT64* ar, Jpoint* ret){
    dh_point_mult_finalversion(&(h_params.H),h_ranParams.alpha,ret);
    Jpoint tp;
    for(int i=0;i<32;i++){
        if(al[i*4]==1){
            dh_ellipticAdd_JJ(ret,&(h_params.Gg[i]),ret);
        }
        if(ar[i*4]!=0){
            // dh_point_mult_finalversion(&(h_params.Hh[i]),&ar[i*4],&tp);
            // dh_ellipticAdd_JJ(ret,&tp,ret);
            cal_minus_Jpoint(&tp,&(h_params.Hh[i]));
            dh_ellipticAdd_JJ(ret,&tp,ret);
        }
    }
    jpoint_from_mon(ret);
}



__global__ void kernel_hashBP(Jpoint *A,Jpoint *B,UINT64 *x,UINT64 *y,int N){
    int tx = threadIdx.x;
    int data_len = 64;
    
    if(tx==0){
        unsigned char tmp[32];
        unsigned char hash[32];
        // char tmp2[65];
        // char o1str[65];
        MYSHA256_CTX ctx;
		sha256_init(&ctx);
        uint642byte(A->x,tmp);
		sha256_update(&ctx, tmp, 32);
        uint642byte(A->y,tmp);
		sha256_update(&ctx, tmp, 32);
        uint642byte(B->x,tmp);
		sha256_update(&ctx, tmp, 32);
        uint642byte(B->y,tmp);
		sha256_update(&ctx, tmp, 32);
		sha256_final(&ctx, hash);
        // tmp2[64] = '\0';
        // printf("str = %s\n",tmp2);
        // d_mybig_print(x);

        x[3]=(UINT64)hash[7]|((UINT64)hash[6])<<8|((UINT64)hash[5])<<16|((UINT64)hash[4])<<24
            |((UINT64)hash[3])<<32|((UINT64)hash[2])<<40|((UINT64)hash[1])<<48 |((UINT64)hash[0])<<56;
        x[2]=(UINT64)hash[15]|((UINT64)hash[14])<<8|((UINT64)hash[13])<<16|((UINT64)hash[12])<<24
                |((UINT64)hash[11])<<32|((UINT64)hash[10])<<40|((UINT64)hash[9])<<48 |((UINT64)hash[8])<<56;
        x[1]=(UINT64)hash[23]|((UINT64)hash[22])<<8|((UINT64)hash[21])<<16|((UINT64)hash[20])<<24
                |((UINT64)hash[19])<<32|((UINT64)hash[18])<<40|((UINT64)hash[17])<<48 |((UINT64)hash[16])<<56;
        x[0]=(UINT64)hash[31]|((UINT64)hash[30])<<8|((UINT64)hash[29])<<16|((UINT64)hash[28])<<24
                |((UINT64)hash[27])<<32|((UINT64)hash[26])<<40|((UINT64)hash[25])<<48 |((UINT64)hash[24])<<56;

        // d_mybig_print(x);

        if(y==NULL) return ;
        MYSHA256_CTX ctx2;
		sha256_init(&ctx2);
        uint642byte(A->x,tmp);
		sha256_update(&ctx2, tmp, 32);
        uint642byte(A->y,tmp);
		sha256_update(&ctx2, tmp, 32);
        uint642byte(B->x,tmp);
		sha256_update(&ctx2, tmp, 32);
        uint642byte(B->y,tmp);
		sha256_update(&ctx2, tmp, 32);
        sha256_update(&ctx2, hash, 32);
		sha256_final(&ctx2, hash);
        y[3]=(UINT64)hash[7]|((UINT64)hash[6])<<8|((UINT64)hash[5])<<16|((UINT64)hash[4])<<24
            |((UINT64)hash[3])<<32|((UINT64)hash[2])<<40|((UINT64)hash[1])<<48 |((UINT64)hash[0])<<56;
        y[2]=(UINT64)hash[15]|((UINT64)hash[14])<<8|((UINT64)hash[13])<<16|((UINT64)hash[12])<<24
                |((UINT64)hash[11])<<32|((UINT64)hash[10])<<40|((UINT64)hash[9])<<48 |((UINT64)hash[8])<<56;
        y[1]=(UINT64)hash[23]|((UINT64)hash[22])<<8|((UINT64)hash[21])<<16|((UINT64)hash[20])<<24
                |((UINT64)hash[19])<<32|((UINT64)hash[18])<<40|((UINT64)hash[17])<<48 |((UINT64)hash[16])<<56;
        y[0]=(UINT64)hash[31]|((UINT64)hash[30])<<8|((UINT64)hash[29])<<16|((UINT64)hash[28])<<24
                |((UINT64)hash[27])<<32|((UINT64)hash[26])<<40|((UINT64)hash[25])<<48 |((UINT64)hash[24])<<56;
        // d_mybig_print(y);
    }
}

__device__ void device_hashBP(Jpoint *A,Jpoint *B,UINT64 *x,UINT64 *y){
    
    
    
        unsigned char tmp[32];
        unsigned char hash[32];
        // char tmp2[65];
        // char o1str[65];
        MYSHA256_CTX ctx;
		sha256_init(&ctx);
        uint642byte(A->x,tmp);
		sha256_update(&ctx, tmp, 32);
        uint642byte(A->y,tmp);
		sha256_update(&ctx, tmp, 32);
        uint642byte(B->x,tmp);
		sha256_update(&ctx, tmp, 32);
        uint642byte(B->y,tmp);
		sha256_update(&ctx, tmp, 32);
		sha256_final(&ctx, hash);
        // tmp2[64] = '\0';
        // printf("str = %s\n",tmp2);
        // d_mybig_print(x);
        // for(int i=0;i<32;i++){
        //     printf("%x ",hash[i]);
        // }
        // printf("\n");

        x[3]=(UINT64)hash[7]|((UINT64)hash[6])<<8|((UINT64)hash[5])<<16|((UINT64)hash[4])<<24
            |((UINT64)hash[3])<<32|((UINT64)hash[2])<<40|((UINT64)hash[1])<<48 |((UINT64)hash[0])<<56;
        x[2]=(UINT64)hash[15]|((UINT64)hash[14])<<8|((UINT64)hash[13])<<16|((UINT64)hash[12])<<24
                |((UINT64)hash[11])<<32|((UINT64)hash[10])<<40|((UINT64)hash[9])<<48 |((UINT64)hash[8])<<56;
        x[1]=(UINT64)hash[23]|((UINT64)hash[22])<<8|((UINT64)hash[21])<<16|((UINT64)hash[20])<<24
                |((UINT64)hash[19])<<32|((UINT64)hash[18])<<40|((UINT64)hash[17])<<48 |((UINT64)hash[16])<<56;
        x[0]=(UINT64)hash[31]|((UINT64)hash[30])<<8|((UINT64)hash[29])<<16|((UINT64)hash[28])<<24
                |((UINT64)hash[27])<<32|((UINT64)hash[26])<<40|((UINT64)hash[25])<<48 |((UINT64)hash[24])<<56;

        // d_mybig_print(x);

        if(y==NULL) return ;
        MYSHA256_CTX ctx2;
		sha256_init(&ctx2);
        uint642byte(A->x,tmp);
		sha256_update(&ctx2, tmp, 32);
        uint642byte(A->y,tmp);
		sha256_update(&ctx2, tmp, 32);
        uint642byte(B->x,tmp);
		sha256_update(&ctx2, tmp, 32);
        uint642byte(B->y,tmp);
		sha256_update(&ctx2, tmp, 32);
        sha256_update(&ctx2, hash, 32);
		sha256_final(&ctx2, hash);
        y[3]=(UINT64)hash[7]|((UINT64)hash[6])<<8|((UINT64)hash[5])<<16|((UINT64)hash[4])<<24
            |((UINT64)hash[3])<<32|((UINT64)hash[2])<<40|((UINT64)hash[1])<<48 |((UINT64)hash[0])<<56;
        y[2]=(UINT64)hash[15]|((UINT64)hash[14])<<8|((UINT64)hash[13])<<16|((UINT64)hash[12])<<24
                |((UINT64)hash[11])<<32|((UINT64)hash[10])<<40|((UINT64)hash[9])<<48 |((UINT64)hash[8])<<56;
        y[1]=(UINT64)hash[23]|((UINT64)hash[22])<<8|((UINT64)hash[21])<<16|((UINT64)hash[20])<<24
                |((UINT64)hash[19])<<32|((UINT64)hash[18])<<40|((UINT64)hash[17])<<48 |((UINT64)hash[16])<<56;
        y[0]=(UINT64)hash[31]|((UINT64)hash[30])<<8|((UINT64)hash[29])<<16|((UINT64)hash[28])<<24
                |((UINT64)hash[27])<<32|((UINT64)hash[26])<<40|((UINT64)hash[25])<<48 |((UINT64)hash[24])<<56;
        // d_mybig_print(y);
    
}

__global__ void kernel_cal_S(Jpoint *ret,UINT64* rho,UINT64* sl,UINT64* sr,Jpoint *H,Jpoint *Gg,Jpoint *Hh,UINT64 *xyz,Jpoint *A){
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    
    __shared__ Jpoint tp[64];
    if(bx==0){
        
        if(tx<32){
            dh_point_mult_finalversion(Gg+tx,sl+(tx*4),tp+tx);
            // if(tx==0)
            // d_mybig_print(sl+(tx*4));
            // printf("\n");
        }else if(tx<64){
            dh_point_mult_finalversion(Hh+tx,sr+((tx-32)*4),tp+tx);
            // if(tx==0)
            // d_mybig_print(sr+(tx*4));
            // printf("\n");
        }
        
        __syncthreads();
        for(int i=1;i<=32;i*=2){
            if(tx%(i*2)==0)
            dh_ellipticAdd_JJ(tp+tx,tp+tx+i,tp+tx);
            
        }
        
        // if(tx==0){
        //     dh_ellipticAdd_JJ(tp,tp+16,ret);
        // }if(tx==32){
        //     dh_ellipticAdd_JJ(tp+32,tp+48,ret);
        // }
        if(tx==0){
            dh_point_mult_finalversion(H,rho,&tp[1]);
            dh_ellipticAdd_JJ(&tp[0],&tp[1],&tp[0]);
        }
        
        
        if(tx==0){
            dh_mybig_monmult_64(tp[0].x,dc_ONE,tp[0].x);
            dh_mybig_monmult_64(tp[0].y,dc_ONE,tp[0].y);
            dh_mybig_monmult_64(tp[0].z,dc_ONE,tp[0].z);
            // printf("S='\n");
            // d_mybig_print(tp[0].x);
            // d_mybig_print(tp[0].y);
            // d_mybig_print(tp[0].z);

            dh_mybig_copy(ret->x,tp[0].x);
            dh_mybig_copy(ret->y,tp[0].y);
            dh_mybig_copy(ret->z,tp[0].z);

            Jpoint2Apoint(&tp[0],&tp[0]);
            Jpoint2Apoint(A,&tp[1]);
            UINT64 y[4],z[4];
            device_hashBP(&tp[1],&tp[0],y,z);
            // printf("device HashBP y=\n");
            // d_mybig_print(y);
            // printf("device HashBP z=\n");
            // d_mybig_print(z);
            dh_mybig_monmult_64_modN(y,dc_R2modN,xyz+4);
            dh_mybig_monmult_64_modN(z,dc_R2modN,xyz+8);
        }
        // dh_mybig_copy(ret->x,tp[0].x);
        // dh_mybig_copy(ret->y,tp[0].y);
        // dh_mybig_copy(ret->z,tp[0].z);
    }
    
}

__global__ void kernel_cal_t12(Jpoint *T12,Jpoint *H,UINT64 *xyz,UINT64 *al,UINT64 *ar,UINT64 *sl,UINT64 *sr,UINT64 *tau12,UINT64 *z22nyn){
    int tx = threadIdx.x;
    int idx = threadIdx.x + blockIdx.x*blockDim.x;
    if(tx>=32) return;
    __shared__ UINT64 sh_ip[4*96];
    UINT64 lh[4],rh[4];
    dh_mybig_monmult_64_modN(sl+tx*4,dc_R2modN,sl+tx*4);
    dh_mybig_monmult_64_modN(sr+tx*4,dc_R2modN,sr+tx*4);



    dh_mybig_modsub_64_modN(al+tx*4,xyz+8,sh_ip+tx*4);
    dh_mybig_modexp_ui32_modN(xyz+4,tx,sh_ip+(tx+64)*4);
    dh_mybig_monmult_64_modN(sh_ip+(tx+64)*4,sr+tx*4,sh_ip+(tx+32)*4);

    dh_mybig_monmult_64_modN(sh_ip+(tx)*4,sh_ip+(tx+32)*4,sh_ip+(tx)*4);
    __syncthreads();
    for(int i=16;i>0;i>>=1){
        if(tx<i){
            dh_mybig_modadd_64_modN(sh_ip+(tx)*4,sh_ip+(tx+i)*4,sh_ip+(tx)*4);
        }
        __syncthreads();
    }
    
    if(tx==0){
        dh_mybig_copy(lh,sh_ip);
        // printf("<al-z,ynsr>[0]=\n");
        // dh_mybig_monmult_64_modN(sh_ip,dc_ONE,sh_ip);
        // d_mybig_print(sh_ip);
        // printf("ynsr[0]=\n");
        // dh_mybig_monmult_64_modN(sh_ip+32*4,dc_ONE,sh_ip+32*4);
        // d_mybig_print(sh_ip+32*4);
    }


    dh_mybig_modadd_64_modN(ar+tx*4,xyz+8,sh_ip+tx*4);
    dh_mybig_monmult_64_modN(sh_ip+tx*4,sh_ip+(tx+64)*4,sh_ip+tx*4);
    //先把2_modN放在rh里
    dh_mybig_copy(rh,dc_mon_TWO_modN);    
       

    dh_mybig_modexp_ui32_modN(rh,tx,sh_ip+(tx+32)*4);
    //再把z2放在rh里
    dh_mybig_monmult_64_modN(xyz+8,xyz+8,rh);
    dh_mybig_monmult_64_modN(sh_ip+(tx+32)*4,rh,sh_ip+(tx+32)*4);
    dh_mybig_copy(z22nyn+tx*4,sh_ip+(tx+32)*4);
    dh_mybig_copy(z22nyn+(tx+32)*4,sh_ip+(tx+64)*4);

    dh_mybig_modadd_64_modN(sh_ip+tx*4,sh_ip+(tx+32)*4,sh_ip+tx*4);

    dh_mybig_monmult_64_modN(sh_ip+tx*4,sl+tx*4,sh_ip+tx*4);

    for(int i=16;i>0;i>>=1){
        if(tx<i){
            dh_mybig_modadd_64_modN(sh_ip+(tx)*4,sh_ip+(tx+i)*4,sh_ip+(tx)*4);
        }
        __syncthreads();
    }
    if(tx==0){
        dh_mybig_copy(rh,sh_ip);
        dh_mybig_modadd_64_modN(lh,rh,sh_ip+32*4);
        // printf("t1=\n");
        dh_mybig_monmult_64_modN(sh_ip+32*4,dc_ONE,sh_ip+32*4);
        // d_mybig_print(sh_ip+32*4);
        // dh_mybig_monmult_64_modN(sl,dc_ONE,sl);
        // d_mybig_print(sl);
        // printf("ynsr[0]=\n");
        // dh_mybig_monmult_64_modN(sh_ip+32*4,dc_ONE,sh_ip+32*4);
        // d_mybig_print(sh_ip+32*4);
    }

    //t2
    dh_mybig_monmult_64_modN(sh_ip+(tx+64)*4,sr+tx*4,sh_ip+(tx)*4);
    dh_mybig_monmult_64_modN(sh_ip+(tx)*4,sl+tx*4,sh_ip+(tx)*4);

    for(int i=16;i>0;i>>=1){
        if(tx<i){
            dh_mybig_modadd_64_modN(sh_ip+(tx)*4,sh_ip+(tx+i)*4,sh_ip+(tx)*4);
        }
        __syncthreads();
    }

    if(tx==0){
        dh_mybig_copy(sh_ip+33*4,sh_ip);
        // printf("t2=\n");
        dh_mybig_monmult_64_modN(sh_ip+33*4,dc_ONE,sh_ip+33*4);
        // d_mybig_print(sh_ip+33*4);
    }

    if(tx<2){
        Jpoint tmpx,tmpy;
        d_base_point_mul(&tmpx,sh_ip+(32+tx)*4);
        dh_point_mult_finalversion(H,tau12+tx*4,&tmpy);
        dh_ellipticAdd_JJ(&tmpx,&tmpy,&tmpx);
        dh_mybig_monmult_64(tmpx.x,dc_ONE,tmpx.x);
        dh_mybig_monmult_64(tmpx.y,dc_ONE,tmpx.y);
        dh_mybig_monmult_64(tmpx.z,dc_ONE,tmpx.z);
        dh_mybig_copy((T12+tx)->x,tmpx.x);
        dh_mybig_copy((T12+tx)->y,tmpx.y);
        dh_mybig_copy((T12+tx)->z,tmpx.z);
    }
    if(tx==0){
        Jpoint t1,t2;
        Jpoint2Apoint(T12,&t1);
        Jpoint2Apoint(T12+1,&t2);
        // printf("device T1=\n");
        // d_mybig_print(t1.x);
        // d_mybig_print(t1.y);
        // d_mybig_print(t1.z);
        // printf("device T2=\n");
        // d_mybig_print(t2.x);
        // d_mybig_print(t2.y);
        // d_mybig_print(t2.z);
        // printf("\n");
        // printf("\n");
        device_hashBP(&t1,&t2,lh,NULL);
        // printf("device HashBP x=\n");
        // d_mybig_print(lh);
        dh_mybig_monmult_64_modN(lh,dc_R2modN,xyz);
    }

}

__global__ void kernel_cal_vlr(UINT64 *tprime,UINT64 *VLR,UINT64 *taux,UINT64 *mu,UINT64 *xyz,UINT64 *al,UINT64 *ar,UINT64 *sl,UINT64 *sr,
                                UINT64 *z22nyn,UINT64 *gamma,UINT64 *alpha,UINT64 *rho,UINT64 *tau1,UINT64 *tau2,int N){
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int idx = bx*blockDim.x+tx;
    if(tx>=N) return ;
    __shared__ UINT64 sh_ip[4*64];
    dh_mybig_modsub_64_modN(al+tx*4,xyz+8,sh_ip+tx*4);
    dh_mybig_monmult_64_modN(sl+tx*4,xyz,sh_ip+(tx+32)*4);
    dh_mybig_modadd_64_modN(sh_ip+tx*4,sh_ip+(tx+32)*4,sh_ip+tx*4);

    dh_mybig_monmult_64_modN(sr+tx*4,xyz,sh_ip+(tx+32)*4);
    dh_mybig_modadd_64_modN(sh_ip+(tx+32)*4,xyz+8,sh_ip+(tx+32)*4);
    dh_mybig_modadd_64_modN(sh_ip+(tx+32)*4,ar+tx*4,sh_ip+(tx+32)*4);

    dh_mybig_monmult_64_modN(sh_ip+(tx+32)*4,z22nyn+(tx+32)*4,sh_ip+(tx+32)*4);
    dh_mybig_modadd_64_modN(sh_ip+(tx+32)*4,z22nyn+tx*4,sh_ip+(tx+32)*4);

    dh_mybig_copy(VLR+tx*4,sh_ip+(tx)*4);
    dh_mybig_copy(VLR+(tx+32)*4,sh_ip+(tx+32)*4);

    dh_mybig_monmult_64_modN(sh_ip+(tx)*4,sh_ip+(tx+32)*4,sh_ip+(tx)*4);
    for(int i=16;i>0;i>>=1){
        if(tx<i){
            dh_mybig_modadd_64_modN(sh_ip+(tx)*4,sh_ip+(tx+i)*4,sh_ip+(tx)*4);
        }
        __syncthreads();
    }

    if(tx==0){
        
        dh_mybig_monmult_64_modN(sh_ip,dc_ONE,tprime);
        // printf("Tprime=\n");
        // d_mybig_print(tprime);

        dh_mybig_monmult_64_modN(xyz,xyz,sh_ip);
        dh_mybig_monmult_64_modN(tau2,dc_R2modN,sh_ip+4);
        dh_mybig_monmult_64_modN(sh_ip,sh_ip+4,sh_ip);

        dh_mybig_monmult_64_modN(xyz+8,xyz+8,sh_ip+8);


        dh_mybig_monmult_64_modN(tau1,dc_R2modN,sh_ip+4);
        dh_mybig_monmult_64_modN(sh_ip+4,xyz,sh_ip+4);

        dh_mybig_monmult_64_modN(gamma,dc_R2modN,sh_ip+12);
        dh_mybig_monmult_64_modN(sh_ip+8,sh_ip+12,sh_ip+8);

        dh_mybig_modadd_64_modN(sh_ip+4,sh_ip+8,sh_ip+4);
        dh_mybig_modadd_64_modN(sh_ip,sh_ip+4,sh_ip);
        dh_mybig_monmult_64_modN(sh_ip,dc_ONE,taux);

        // printf("Taux=\n");
        // d_mybig_print(taux);

        dh_mybig_monmult_64_modN(rho,dc_R2modN,sh_ip);
        dh_mybig_monmult_64_modN(alpha,dc_R2modN,sh_ip+4);
        dh_mybig_monmult_64_modN(sh_ip,xyz,sh_ip);
        dh_mybig_modadd_64_modN(sh_ip,sh_ip+4,sh_ip);
        dh_mybig_monmult_64_modN(sh_ip,dc_ONE,mu);

        // printf("Mu=\n");
        // d_mybig_print(mu);

        



    }



}

void gpu_cal_S(){
    int nB = 1;
    int nT = 64;
    kernel_cal_S<<<nB,nT>>>(&(d_prove->S),d_ranParams->rho,d_ranParams->SL,d_ranParams->SR,&(d_params->H),d_params->Gg,d_params->Gg,d_xyz,&(d_prove->A));
}
//寻找cuda sprintf，待定
void gpu_hashBP(Jpoint *A,Jpoint *B,UINT64 *x,UINT64 *y){
    int nB = 1;
    int nT = 32;
    kernel_hashBP<<<nB,nT>>>(A,B,x,y,1);
}

void gpu_cal_t12(){
    int nB = 1;
    int nT = 32;
    kernel_cal_t12<<<nB,nT>>>(&(d_prove->T1),&(d_params->H),d_xyz,d_aLR,d_aLR+4*32,d_ranParams->SL,d_ranParams->SR,d_ranParams->tau1,d_z22nyn);
}
void gpu_calvlvr(){
    int nB = 1;
    int nT = 32;
    kernel_cal_vlr<<<nB,nT>>>(d_prove->Tprime,d_VLR,d_prove->Taux,d_prove->Mu,d_xyz,d_aLR,d_aLR+32*4,d_ranParams->SL,d_ranParams->SR,d_z22nyn,
                                d_ranParams->gamma,d_ranParams->alpha,d_ranParams->rho,d_ranParams->tau1,d_ranParams->tau2 ,32);
}

int main(){
    cudaSetDevice(0);
    UINT64 *al = h_aLR;
    UINT64 *ar = h_aLR+32*4;
    // UINT64 al[32*4]={0};
    // UINT64 ar[32*4]={0};
    int value = rand();
    compute_al_ar(value,al,ar,32);
    printf("value=%d\n",value);
    // printf("AL=\n");
    // for(int i=0;i<32;i++){
    //     h_mybig_print(al+4*i);
    // }
    // printf("AR=\n");
    // for(int i=0;i<32;i++){
    //     h_mybig_print(ar+4*i);
    // }
    printf("\n");
    
    // std::string s = "gyy hello world";
    JpointCpy(&h_params.G,h_Gx,h_Gy,h_Gz);
    mapToGroup(SEED,&h_params.H);
    printf("param.H=\n");
    h_print_pointJ(&h_params.H);
    h_params.N=32;
    // cout<<SEED
    for(int i=0;i<h_params.N;i++){
        
        char tmp[3];
        sprintf(tmp,"%u",i);
        mapToGroup(SEED+"h"+tmp,&h_params.Hh[i]);
        mapToGroup(SEED+"g"+tmp,&h_params.Gg[i]);
    }
  

 
    init_random_param();
    // printf("SL=\n");
    // for(int i=0;i<32;i++){
    //     h_mybig_print(&(h_ranParams.SL[i*4]));
    // }
    // printf("SR=\n");
    // for(int i=0;i<32;i++){
    //     h_mybig_print(&(h_ranParams.SR[i*4]));
    // }
    // printf("Gg=\n");
    // for(int i=0;i<32;i++){
    //     h_print_pointJ(&h_params.Gg[i]);
    // }
    // printf("Hh=\n");
    // for(int i=0;i<32;i++){
    //     h_print_pointJ(&(h_params.Hh[i]));
    // }
    
    printf("rho=\n");
    h_mybig_print(h_ranParams.rho);
    printf("gamma=\n");
    h_mybig_print(h_ranParams.gamma);
    printf("alpha=\n");
    h_mybig_print(h_ranParams.alpha);
    printf("tau1=\n");
    h_mybig_print(h_ranParams.tau1);
    printf("tau2=\n");
    h_mybig_print(h_ranParams.tau2);
    // return 0;
    // h_mybig_print(h_ranParams.alpha);
    // h_mybig_print(h_ranParams.rho);
    // h_mybig_print(h_ranParams.tau1);
    // h_mybig_print(h_ranParams.tau2);

    CUDA_SAFE_CALL(cudaMalloc((void**)&d_params,sizeof(BPSetupParams)));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_ranParams,sizeof(initParamRandom)));
    // CUDA_SAFE_CALL(cudaMalloc((void**)d_V,sizeof(Jpoint)));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_prove,sizeof(BPProve)));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_xyz,sizeof(UINT64)*4*3));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_iv,sizeof(InterVar)));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_aLR,sizeof(UINT64)*4*64));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_VLR,sizeof(UINT64)*4*h_params.N*2));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_z22nyn,sizeof(UINT64)*4*h_params.N*2));

    Jpoint V,A,S;
    trans_to_mon();

    struct timeval s1,e1;
    gettimeofday(&s1,NULL);
    commitG1(&V,value,h_ranParams.gamma,&h_params.H);
    // printf("V=\n");
    // h_print_pointJ(&V);
    cal_A(al,ar,&A);
    // printf("A=\n");
    // h_print_pointJ(&A);
  
    

    CUDA_SAFE_CALL(cudaMemcpy(d_params,&h_params,sizeof(BPSetupParams),cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_ranParams,&h_ranParams,sizeof(initParamRandom),cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(&(d_prove->V),&V,sizeof(Jpoint),cudaMemcpyHostToDevice));
    
    CUDA_SAFE_CALL(cudaMemcpy(&(d_prove->A),&A,sizeof(Jpoint),cudaMemcpyHostToDevice));

    gpu_cal_S();
    // cal_S_dev<<<1,64>>>(&(d_prove->S),d_ranParams->rho,d_ranParams->SL,d_ranParams->SR,&(d_params->H),d_params->Gg,d_params->Gg);
    // gpu_hashBP(&(d_prove->A),&(d_prove->S),d_xyz+4,d_xyz+8);
    CUDA_SAFE_CALL(cudaMemcpy(&S,&(d_prove->S),sizeof(Jpoint),cudaMemcpyDeviceToHost));
    
    // h_print_pointJ(&A);
    // Jpoint2Apoint(&A,&A);
    // printf("A=\n");
    // h_print_pointJ(&A);
    // Jpoint2Apoint(&S,&S);
    // printf("S=\n");
    // h_print_pointJ(&S);

    // HashBP_V2(&A,&S,h_xyz+4,h_xyz+8);
    // printf("y==\n");
    // h_mybig_print(h_xyz+4);
    // printf("z==\n");
    // h_mybig_print(h_xyz+8);
    
    trans_to_mon_N();
    CUDA_SAFE_CALL(cudaMemcpy(d_aLR,h_aLR,sizeof(UINT64)*4*64,cudaMemcpyHostToDevice));
    // CUDA_SAFE_CALL(cudaMemcpy(d_xyz,h_xyz,sizeof(UINT64)*12,cudaMemcpyHostToDevice));

    gpu_cal_t12();

    Jpoint h_T12[2];
    CUDA_SAFE_CALL(cudaMemcpy(h_T12,&(d_prove->T1),sizeof(Jpoint)*2,cudaMemcpyDeviceToHost));
    
    // printf("T1\n");
    // Jpoint2Apoint(h_T12,h_T12);
    // h_print_pointJ(h_T12);
    // printf("T2\n");
    // Jpoint2Apoint(h_T12+1,h_T12+1);
    // h_print_pointJ(h_T12+1);
    
    // HashBP_V2(h_T12,h_T12+1,h_xyz,NULL);
    // printf("x==\n");
    // h_mybig_print(h_xyz);


    // dh_mybig_monmult_64_modN(h_xyz,h_R2modN,h_xyz);
    // CUDA_SAFE_CALL(cudaMemcpy(d_xyz,h_xyz,sizeof(UINT64)*12,cudaMemcpyHostToDevice));
    gpu_calvlvr();
    gettimeofday(&e1,NULL);

    long long time_use;
    time_use=(e1.tv_sec-s1.tv_sec)*1000000+(e1.tv_usec-s1.tv_usec);//微秒
    printf("time_use is %llu\n",time_use);

    CUDA_SAFE_CALL(cudaMemcpy(d_xyz,h_xyz,sizeof(UINT64)*12,cudaMemcpyHostToDevice));
    // h_print_pointJ(&S);
    printf("hello world\n");
    return 0;
    // h_mybig_print(ranParams.alpha);
    
}