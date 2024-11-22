#include<stdio.h>
#include "gpuec.h"
#include "cuda_common.h"
// typedef unsigned long long UINT64; //定义64位字类型
// typedef long long INT64;

#define N_BIGNUM 8
const UINT64 h_p[8]={0xffffffffffffffffL,0xfffffffeffffffffL,0xffffffffffffffffL,0xfffffffeffffffffL,0xffffffffffffffffL,0xfffffffffffffffeL,0xfffffffeffffffffL,0xffffffffffffffffL};
const UINT64 h_r[8]={0x0000000000000001L,0x0000000100000000L,0x0000000000000000L,0x0000000100000000,0x0000000000000000L ,0x0000000000000001L,0x100000000L,0x0L };
__constant__ UINT64 h_R2[8]={0x0000000d00000003L,0x0000000400000000L,0x0000000000000014L,0x0000000e00000001,0x000000000000000dL ,0x000000140000000aL,0x0000000700000000L,0x18L };
__constant__ UINT64 h_ONE[8]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
//18 0000000700000000 000000140000000a 000000000000000d 0000000e00000001 0000000000000014 0000000400000000 0000000d00000003
void __global__ testadd(UINT64* a ,UINT64* b,UINT64 *c){
    int tx = threadIdx.x;
    dh_mybig_modadd_64(a+tx*8,b+tx*8,c+tx*8);
}
void __global__ testsub(UINT64* a ,UINT64* b,UINT64 *c){
    int tx = threadIdx.x;
    dh_mybig_modsub_64(a+tx*8,b+tx*8,c+tx*8);
}
void __global__ testmul(UINT64* a,UINT64 *b,UINT64 *c){
    int tx = threadIdx.x;
    dh_mybig_monmult_64(a+tx*8,h_R2,a+tx*8);
    // dh_mybig_monmult_64(a+tx*8,h_R2,a+tx*8);
    dh_mybig_monmult_64(a+tx*8,a+tx*8,c+tx*8);
    // dh_mybig_monmult_64(c+tx*8,h_ONE,c+tx*8);
}

void print_big_arr(UINT64* nums,int n){
    for(int i=0;i<n;i++){
        h_mybig_print(nums+i*8);
        printf("\n");
    }
}

void init_big(UINT64 *nums){
    for(int i=0;i<N_BIGNUM;i++){
        for(int j=0;j<8;j++){
            nums[i*8+j]=i;
        }
        // nums[i*8] = h_p[0]-1;
    }
    // nums[0]=25;
    // nums[15]=35;
}
void init_big2(UINT64 *nums){
    for(int i=0;i<N_BIGNUM;i++){
        // for(int j=0;j<8;j++)
        nums[i*8] = i;
    }
    // nums[0]=25;
    // nums[15]=35;
}

int main(){
    // const int N = 8;
    // h_print_para();
    UINT64 *h_nums1 = (UINT64*)malloc(sizeof(UINT64)*8*N_BIGNUM);
    UINT64 *h_nums2 = (UINT64*)malloc(sizeof(UINT64)*8*N_BIGNUM);
    UINT64 *h_nums3 = (UINT64*)malloc(sizeof(UINT64)*8*N_BIGNUM);
    init_big2(h_nums1);
    init_big2(h_nums2);

    UINT64 *d_nums1;
    UINT64 *d_nums2;
    UINT64 *d_nums3;

    CUDA_SAFE_CALL(cudaMalloc((void**)&d_nums1,sizeof(UINT64)*8*N_BIGNUM));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_nums2,sizeof(UINT64)*8*N_BIGNUM));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_nums3,sizeof(UINT64)*8*N_BIGNUM));

    CUDA_SAFE_CALL(cudaMemcpy(d_nums1,h_nums1,sizeof(UINT64)*8*N_BIGNUM,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_nums2,h_nums2,sizeof(UINT64)*8*N_BIGNUM,cudaMemcpyHostToDevice));

    testmul<<<1,N_BIGNUM>>>(d_nums1,d_nums2,d_nums3);

    CUDA_SAFE_CALL(cudaMemcpy(h_nums3,d_nums3,sizeof(UINT64)*8*N_BIGNUM,cudaMemcpyDeviceToHost));
    // CUDA_SAFE_CALL(cudaMemcpy(h_nums1,d_nums1,sizeof(UINT64)*8*N_BIGNUM,cudaMemcpyDeviceToHost));
    print_big_arr(h_nums3,N_BIGNUM);
    // print_big_arr(h_nums1,N_BIGNUM);
    // printf("\n");
    // h_mybig_print(h_nums+8);
}