#include<stdio.h>
#include "gpuec256.h"
#include "cuda_common.h"
#include<sys/time.h>
#include<random>
// typedef unsigned long long UINT64; //定义64位字类型
// typedef long long INT64;

#define N_BIGNUM 1024*1024
#define N_POINT N_BIGNUM
#define N_THREAD_PER_BLOCK 384
#define N_BLOCK ((N_BIGNUM+N_THREAD_PER_BLOCK-1)/N_THREAD_PER_BLOCK)
// const UINT64 h_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};
// const UINT64 h_mon_ONE[4]={0x1000003d1L,0x0L,0x0L,0x0L};
// const UINT64 h_ONE[4]={0x1L,0x0L,0x0L,0x0L};
const UINT64 h_R2[4]={0x000007a2000e90a1L,0x1L,0x0L,0x0L};

const UINT64 h_6Gx[4]={0x252931db128244c9L,0x80ec2e92027d7e6eL,0x32c5ee6d51cb1e89L,0xb89bd74c7352f570L};
const UINT64 h_6Gy[4]={0xd8cbce4f20d0d9e4L,0x5b636389add7cc6eL,0xccd07463f61e7fbeL,0x13fae72c0d3c849bL};
const UINT64 h_6Gz[4]={0xbc5c645f1b1c297dL,0x0ba1469cd0bdd88aL,0x40bad30e143dcdceL,0x4bba49beb75cce43L};



const UINT64 h_Gx[4]={0x59F2815B16F81798L,0x029BFCDB2DCE28D9L,0x55A06295CE870B07L,0x79BE667EF9DCBBACL};
const UINT64 h_Gy[4]={0x9C47D08FFB10D4B8L,0xFD17B448A6855419L,0x5DA4FBFC0E1108A8L,0x483ADA7726A3C465L};

const UINT64 h_3Gx[4]={0x8601f113bce036f9L,0xb531c845836f99b0L,0x49344f85f89d5229L,0xf9308a019258c310L};
const UINT64 h_3Gy[4]={0x6cb9fd7584b8e672L,0x6500a99934c2231bL,0x0fe337e62a37f356L,0x388f7b0f632de814L};
const UINT64 h_3Gz[4]={0x1L,0x0L,0x0L,0x0L};

// __constant__ UINT64 dc_R2[4]={0x000007a2000e90a1L,0x1L,0x0L,0x0L};
// __constant__ UINT64 dc_ONE[4]={0x0000000000000001L,0x0000000000000000L,0x0000000000000000L,0x0000000000000000L};
// __constant__ UINT64 dc_p[4]={0xFFFFFFFEFFFFFC2FL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL,0xFFFFFFFFFFFFFFFFL};



void __global__ testadd(UINT64* a ,UINT64* b,UINT64 *c){
    int tx = threadIdx.x;
    dh_mybig_modadd_64(a+tx*4,b+tx*4,c+tx*4);
}
void __global__ testsub(UINT64* a ,UINT64* b,UINT64 *c){
    int tx = threadIdx.x;
    dh_mybig_modsub_64(a+tx*4,b+tx*4,c+tx*4);
}
void __global__ testmul(UINT64* a ,UINT64* b,UINT64 *c){
    int tx = threadIdx.x;
    dh_mybig_monmult_64(a+tx*4,dc_R2,a+tx*4);
    // dh_mybig_monmult_64(b+tx*4,dc_R2,b+tx*4);
    dh_mybig_monmult_64(a+tx*4,b+tx*4,c+tx*4);
    dh_mybig_monmult_64(c+tx*4,dc_ONE,c+tx*4);
}



void __global__ testhalf(UINT64 *a,UINT64 *b){
    int tx = threadIdx.x;
    dh_mybig_half_64(a+tx*4,b+tx*4);
}

__global__ void testinv(UINT64 *a,UINT64 *b){
    int tx = threadIdx.x;
    dh_mybig_monmult_64(a+tx*4,dc_R2,a+tx*4);
    dh_mybig_moninv(a+tx*4,b+tx*4);
}

__global__ void testexp(UINT64 *a,UINT64 *b,UINT64 *c){
    int tx = threadIdx.x;
    dh_mybig_monmult_64(a+tx*4,dc_R2,a+tx*4);
    dh_mybig_modexp(a+tx*4,b+tx*4,c+tx*4);
    dh_mybig_monmult_64(c+tx*4,dc_ONE,c+tx*4);
}

void __global__ point_to_monjj(Jpoint* jp1,Jpoint* jp2){
    // int tx = threadIdx.x;
    int idx = threadIdx.x + blockDim.x*blockIdx.x;
    if(idx<N_BIGNUM){
        dh_mybig_monmult_64((jp1+idx)->x,dc_R2,(jp1+idx)->x);
        dh_mybig_monmult_64((jp1+idx)->y,dc_R2,(jp1+idx)->y);
        dh_mybig_monmult_64((jp1+idx)->z,dc_R2,(jp1+idx)->z);

        dh_mybig_monmult_64((jp2+idx)->x,dc_R2,(jp2+idx)->x);
        dh_mybig_monmult_64((jp2+idx)->y,dc_R2,(jp2+idx)->y);
        dh_mybig_monmult_64((jp2+idx)->z,dc_R2,(jp2+idx)->z);
    }
    
}



void __global__ point_from_monjj(Jpoint* jp1,Jpoint* jp2){
    // int tx = threadIdx.x;
    int idx = threadIdx.x + blockDim.x*blockIdx.x;
    if(idx<N_BIGNUM){
        dh_mybig_monmult_64((jp1+idx)->x,dc_ONE,(jp1+idx)->x);
        dh_mybig_monmult_64((jp1+idx)->y,dc_ONE,(jp1+idx)->y);
        dh_mybig_monmult_64((jp1+idx)->z,dc_ONE,(jp1+idx)->z);

        dh_mybig_monmult_64((jp2+idx)->x,dc_ONE,(jp2+idx)->x);
        dh_mybig_monmult_64((jp2+idx)->y,dc_ONE,(jp2+idx)->y);
        dh_mybig_monmult_64((jp2+idx)->z,dc_ONE,(jp2+idx)->z);
    }
    
}


// void __global__ point_to_monaj(Jpoint* jp1,Apoint* jp2){
//     int tx = threadIdx.x;
//     dh_mybig_monmult_64((jp1+tx)->x,dc_R2,(jp1+tx)->x);
//     dh_mybig_monmult_64((jp1+tx)->y,dc_R2,(jp1+tx)->y);
//     dh_mybig_monmult_64((jp1+tx)->z,dc_R2,(jp1+tx)->z);

//     dh_mybig_monmult_64((jp2+tx)->x,dc_R2,(jp2+tx)->x);
//     dh_mybig_monmult_64((jp2+tx)->y,dc_R2,(jp2+tx)->y);
//     // dh_mybig_monmult_64((jp2+tx)->z,dc_R2,(jp2+tx)->z);
// }



// void __global__ point_from_monaj(Jpoint* jp1,Apoint* jp2){
//     int tx = threadIdx.x;
//     dh_mybig_monmult_64((jp1+tx)->x,dc_ONE,(jp1+tx)->x);
//     dh_mybig_monmult_64((jp1+tx)->y,dc_ONE,(jp1+tx)->y);
//     dh_mybig_monmult_64((jp1+tx)->z,dc_ONE,(jp1+tx)->z);

//     dh_mybig_monmult_64((jp2+tx)->x,dc_ONE,(jp2+tx)->x);
//     dh_mybig_monmult_64((jp2+tx)->y,dc_ONE,(jp2+tx)->y);
//     // dh_mybig_monmult_64((jp2+tx)->z,dc_ONE,(jp2+tx)->z);
// }


void __global__ testdouble(UINT64* a ,UINT64* b){
    int tx = threadIdx.x;
    dh_mybig_moddouble_64(a+tx*4,dc_p,b+tx*4);
}

// void __global__ test_point_addaj(Jpoint* jp,Apoint *ap){
//     int tx = threadIdx.x;
//     dh_ellipticSumEqual_AJ(jp+tx,ap+tx);
// }
void __global__ test_point_addjj(Jpoint* p1,Jpoint *p2,Jpoint *p3){
    int tx = threadIdx.x;
    dh_ellipticAdd_JJ(p1+tx,p2+tx,p3+tx);
}

void __global__ test_point_double(Jpoint *p1,Jpoint *p2){
    int tx = threadIdx.x;
    ppoint_double(p1+tx,p2+tx);
}

void __global__ testbasemul(Jpoint *res,UINT64 *k){
    int idx = threadIdx.x + blockDim.x*blockIdx.x;
    if(idx<N_POINT){
        // d_mybig_print(k+idx*4);
        d_base_point_mul(res+idx,k+idx*4);
    }

}

void __global__ test_point_mul_inplace(Jpoint *p1,UINT64 *k){
    // int tx = threadIdx.x;
    int idx = threadIdx.x + blockDim.x*blockIdx.x;
    dh_point_mult_inplace(p1+idx,k+idx*4);
}
void __global__ test_point_mul_outofplace(Jpoint *p1,UINT64 *k,Jpoint *p2){
    int idx = threadIdx.x + blockDim.x*blockIdx.x;
    dh_point_mult_outofplace(p1+idx,k+idx*4,p2+idx);
}
void __global__ test_point_mul_finalversion(Jpoint *p1,UINT64 *k,Jpoint *p2){
    int idx = threadIdx.x + blockDim.x*blockIdx.x;
    dh_point_mult_finalversion(p1+idx,k+idx*4,p2+idx);
}

void __global__ test_point_mul_uint32(Jpoint *p1,int k,Jpoint *p2){
    int idx = threadIdx.x + blockDim.x*blockIdx.x;
    dh_point_mult_uint32(p1+idx,k,p2+idx);
}

// void __global__ test_point_mul_apoint(Jpoint *p1,Apoint *p2,UINT64 *k){
//     int tx = threadIdx.x;
//     dh_apoint_mult(p1+tx,p2+tx,k+tx*4);
// }

// void __global__ testmul(UINT64* a,UINT64 *b,UINT64 *c){
//     int tx = threadIdx.x;
//     dh_mybig_monmult_64(a+tx*8,h_R2,a+tx*8);
//     // dh_mybig_monmult_64(a+tx*8,h_R2,a+tx*8);
//     dh_mybig_monmult_64(a+tx*8,a+tx*8,c+tx*8);
//     // dh_mybig_monmult_64(c+tx*8,h_ONE,c+tx*8);
// }

void print_big_arr(UINT64* nums,int n){
    for(int i=0;i<n;i++){
        h_mybig_print(nums+i*4);
        printf("\n");
    }
}
void print_jpoint_arr(Jpoint* nums,int n){
    for(int i=0;i<n;i++){
        h_print_pointJ(nums+i);
        printf("\n");
    }
}
// void print_apoint_arr(Apoint* nums,int n){
//     for(int i=0;i<n;i++){
//         h_print_pointA(nums+i);
//         printf("\n");
//     }
// }

void init_big(UINT64 *nums){
    for(int i=0;i<N_BIGNUM;i++){
        for(int j=0;j<4;j++){
            nums[i*4+j]=0;
        }
        nums[i*4] = 0x3;
        nums[i*4+1] = 0x103;
    }
    // nums[0]=25;
    // nums[15]=35;
}
void init_big2(UINT64 *nums){
    for(int i=0;i<N_BIGNUM;i++){
        for(int j=0;j<4;j++){
            nums[i*4+j]=0xabcdef0123456789;
            // nums[i*4+j]=0;
        }
        // nums[i*4] = 8;
    }
    // nums[0]=25;
    // nums[15]=35;
}
void init_random_big(UINT64 *nums){
    timeval start;
    gettimeofday(&start,NULL);
    std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine;
    engine.seed(start.tv_usec);//设定随机数种子
    for(int i=0;i<N_BIGNUM;i++){
        for(int j=0;j<4;j++){
            nums[i*4+j]=engine();
        }
    }
}
// void init_Apoint(Apoint* p){
//     for(int i=0;i<N_POINT;i++){
//         for(int j=0;j<4;j++){
//             p[i].x[j] = h_Gx[j];
//             p[i].y[j] = h_Gy[j];
//             // p[i].z[j] = h_ONE[j];
//         }
//     }
// }

void init_Jpoint(Jpoint* p){
    for(int i=0;i<N_POINT;i++){
        for(int j=0;j<4;j++){
            p[i].x[j] = h_Gx[j];
            p[i].y[j] = h_Gy[j];
            p[i].z[j] = h_ONE[j];
        }
    }
}
void init_Jpoint2(Jpoint* p){
    for(int i=0;i<N_POINT;i++){
        for(int j=0;j<4;j++){
            p[i].x[j] = h_6Gx[j];
            p[i].y[j] = h_6Gy[j];
            p[i].z[j] = h_6Gz[j];
        }
    }
}
// void init_Apoint(Apoint* p){
//     for(int i=0;i<N_POINT;i++){
//         for(int j=0;j<4;j++){
//             p[i].x[j] = h_3Gx[j];
//             p[i].y[j] = h_3Gy[j];
//             // p[i].z[j] = h_mon_ONE[j];
//         }
//     }
// }

int main(){
    struct timeval s1,e1;
    long long time_use=1;
    int nB,nT;
    // UINT64 tmpbig[4]={0x6903021ca8bd10e,1,0,0};
    // h_mybig_print(tmpbig);
    // cudaOccupancyMaxPotentialBlockSize(&nB,&nT,testbasemul);
    // printf("NB=%d,NT=%d\n",nB,nT);
    cudaOccupancyMaxPotentialBlockSize(&nB,&nT,test_point_double);
    printf("NB=%d,NT=%d\n",nB,nT);
    // cudaOccupancyMaxPotentialBlockSize(&nB,&nT,testmul);
    // printf("NB=%d,NT=%d\n",nB,nT);
    // cudaOccupancyMaxPotentialBlockSize(&nB,&nT,testinv);
    // printf("NB=%d,NT=%d\n",nB,nT);
    // cudaOccupancyMaxPotentialBlockSize(&nB,&nT,point_to_monjj);
    // printf("NB=%d,NT=%d\n",nB,nT);

    // UINT64 *h_nums1 = (UINT64*)malloc(sizeof(UINT64)*4*N_BIGNUM);
    // UINT64 *h_nums2 = (UINT64*)malloc(sizeof(UINT64)*4*N_BIGNUM);
    // UINT64 *h_nums3 = (UINT64*)malloc(sizeof(UINT64)*4*N_BIGNUM);
    // init_big2(h_nums1);
    // init_big2(h_nums2);

    // UINT64 *d_nums1;
    // UINT64 *d_nums2;
    // UINT64 *d_nums3;



    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_nums1,sizeof(UINT64)*4*N_BIGNUM));
    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_nums2,sizeof(UINT64)*4*N_BIGNUM));
    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_nums3,sizeof(UINT64)*4*N_BIGNUM));

    // CUDA_SAFE_CALL(cudaMemcpy(d_nums1,h_nums1,sizeof(UINT64)*4*N_BIGNUM,cudaMemcpyHostToDevice));
    // CUDA_SAFE_CALL(cudaMemcpy(d_nums2,h_nums2,sizeof(UINT64)*4*N_BIGNUM,cudaMemcpyHostToDevice));

    // testmul<<<1,N_BIGNUM>>>(d_nums1,d_nums2,d_nums3);

    // CUDA_SAFE_CALL(cudaMemcpy(h_nums3,d_nums3,sizeof(UINT64)*4*N_BIGNUM,cudaMemcpyDeviceToHost));
    // // print_big_arr(h_nums1,N_BIGNUM);
    // // print_big_arr(h_nums2,N_BIGNUM);
    // // print_big_arr(h_nums1,N_BIGNUM);
    // // print_big_arr(h_nums2,N_BIGNUM);
    // print_big_arr(h_nums3,N_BIGNUM);
    // printf("\n");

    // free(h_nums1);
    // free(h_nums2);
    // free(h_nums3);
    // CUDA_SAFE_CALL(cudaFree(d_nums1));
    // CUDA_SAFE_CALL(cudaFree(d_nums2));
    // CUDA_SAFE_CALL(cudaFree(d_nums3));


// ========================================


    Jpoint* h_p1;
    Jpoint* h_p2;
    Jpoint* d_p1;
    Jpoint* d_p2;
    // Apoint* h_Ap;
    // Apoint* d_Ap;
    UINT64* h_num;
    UINT64* d_num;
    // Jpoint* d_result;
    
    h_p1 = (Jpoint*)malloc(N_POINT*sizeof(Jpoint));
    h_p2 = (Jpoint*)malloc(N_POINT*sizeof(Jpoint));
    // h_Ap = (Apoint*)malloc(N_POINT*sizeof(Apoint));
    h_num = (UINT64*)malloc(4*N_BIGNUM*sizeof(UINT64));

    init_Jpoint(h_p1);
    init_Jpoint(h_p2);
    // init_Apoint(h_Ap);
    init_random_big(h_num);
    // h_mybig_print(h_num);
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_p1,N_POINT*sizeof(Jpoint)));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_p2,N_POINT*sizeof(Jpoint)));
    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_Ap,N_POINT*sizeof(Apoint)));
    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_result,N_POINT*sizeof(Jpoint)));
    CUDA_SAFE_CALL(cudaMalloc((void**)&d_num,sizeof(UINT64)*4*N_BIGNUM));


//===========warm up
    // init_random_big(h_num);
    // h_mybig_print(h_num);
    // init_Jpoint(h_p1);
    // init_Jpoint(h_p2);
    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_p1,N_POINT*sizeof(Jpoint)));
    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_p2,N_POINT*sizeof(Jpoint)));
    // CUDA_SAFE_CALL(cudaMalloc((void**)&d_num,sizeof(UINT64)*4*N_BIGNUM));

    CUDA_SAFE_CALL(cudaMemcpy(d_num,h_num,sizeof(UINT64)*4*N_BIGNUM,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_p1,h_p1,N_POINT*sizeof(Jpoint),cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_p2,h_p2,N_POINT*sizeof(Jpoint),cudaMemcpyHostToDevice));
    point_to_monjj<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_p2);
    


    // testbasemul<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_num);
    test_point_double<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_p2);

    point_from_monjj<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_p2);

    CUDA_SAFE_CALL(cudaMemcpy(h_p1,d_p1,N_POINT*sizeof(Jpoint),cudaMemcpyDeviceToHost));
    // CUDA_SAFE_CALL(cudaMemcpy(h_p2,d_p2,N_POINT*sizeof(Jpoint),cudaMemcpyDeviceToHost));
    print_jpoint_arr(h_p1,1);

//==================warm end









    CUDA_SAFE_CALL(cudaMemcpy(d_num,h_num,sizeof(UINT64)*4*N_BIGNUM,cudaMemcpyHostToDevice));
    
    CUDA_SAFE_CALL(cudaMemcpy(d_p1,h_p1,N_POINT*sizeof(Jpoint),cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_p2,h_p2,N_POINT*sizeof(Jpoint),cudaMemcpyHostToDevice));
    point_to_monjj<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_p2);
    CUDA_CHECK_ERROR();
    cudaDeviceSynchronize();

    gettimeofday(&s1,NULL);
    // testbasemul<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_num);
    test_point_double<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_p2);
    cudaDeviceSynchronize();
    gettimeofday(&e1,NULL);
    CUDA_CHECK_ERROR();
    point_from_monjj<<<N_BLOCK,N_THREAD_PER_BLOCK>>>(d_p1,d_p2);
    CUDA_CHECK_ERROR();
    CUDA_SAFE_CALL(cudaMemcpy(h_p1,d_p1,N_POINT*sizeof(Jpoint),cudaMemcpyDeviceToHost));
    // CUDA_SAFE_CALL(cudaMemcpy(h_p2,d_p2,N_POINT*sizeof(Jpoint),cudaMemcpyDeviceToHost));
    time_use=(e1.tv_sec-s1.tv_sec)*1000000+(e1.tv_usec-s1.tv_usec);//微秒
    printf("time_use is %ld us\n",time_use);
    print_jpoint_arr(h_p1,1);
    // print_jpoint_arr(h_p2,1);
    // print_jpoint_arr(h_p2,N_POINT);



    




    free(h_p1);
    free(h_p2);
    free(h_num);
    CUDA_SAFE_CALL(cudaFree(d_p1));
    CUDA_SAFE_CALL(cudaFree(d_p2));
    CUDA_SAFE_CALL(cudaFree(d_num));

}