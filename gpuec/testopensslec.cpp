#include <openssl/ec.h>
#include <openssl/bn.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/des.h>
#include <openssl/aes.h>
#include <openssl/sha.h>
#include <openssl/rand.h>

#include <stdio.h>
#include <sys/time.h>
typedef BIGNUM bn;
typedef EC_GROUP group;
typedef EC_POINT point;

const unsigned char EC_Gx_bin[] = {
    0x79, 0xBE ,0x66, 0x7E, 0xF9, 0xDC, 0xBB, 0xAC, 0x55, 0xA0, 0x62, 0x95, 0xCE, 0x87, 0x0B,
    0x07, 0x02, 0x9B, 0xFC, 0xDB, 0x2D, 0xCE, 0x28, 0xD9, 0x59, 0xF2, 0x81, 0x5B, 0x16, 0xF8, 
    0x17, 0x98,
};

const unsigned char EC_Gy_bin[] = {
    0x48, 0x3A, 0xDA, 0x77, 0x26, 0xA3, 0xC4, 0x65, 0x5D, 0xA4, 0xFB, 0xFC, 0x0E, 0x11, 0x08, 
    0xA8, 0xFD, 0x17, 0xB4, 0x48, 0xA6, 0x85, 0x54, 0x19, 0x9C, 0x47, 0xD0, 0x8F, 0xFB, 0x10, 
    0xD4, 0xB8
};
const unsigned char EC_Gz_bin[] = {
    0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
    0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
    0x0, 0x1
};
    

point* EC_gen;
point* EC_r;

bn* myk;
bn* EC_Gx;
bn* EC_Gy;
bn* EC_Gz;
BN_CTX* ctx;
int main(){
    ctx = BN_CTX_new();
    long long time_use=0;
    struct timeval s1;  
    struct timeval e1;


    myk = BN_new();
    EC_Gx = BN_new();
    EC_Gy = BN_new();
    EC_Gz = BN_new();

    BN_hex2bn(&myk, "77");
    // BN_bin2bn((unsigned char*)EC_Gx_bin, 32, EC_Gx);
    // BN_bin2bn((unsigned char*)EC_Gy_bin, 32, EC_Gy);
    // BN_bin2bn((unsigned char*)EC_Gz_bin, 32, EC_Gz);
    group* SECP256K1;
    SECP256K1 = EC_GROUP_new_by_curve_name(NID_secp256k1);
    // EC_gen = EC_POINT_new(SECP256K1);
    EC_r = EC_POINT_new(SECP256K1);
    // EC_POINT_set_Jprojective_coordinates_GFp(SECP256K1,EC_gen,EC_Gx,EC_Gy,EC_Gz,NULL);
    // gettimeofday(&s1,NULL);
    // for(int i=0;i<1024;i++){
        EC_POINT_mul(SECP256K1,EC_r,myk,NULL,NULL,ctx);
    // }
    // gettimeofday(&e1,NULL);

    time_use=(e1.tv_sec-s1.tv_sec)*1000000+(e1.tv_usec-s1.tv_usec);
    printf("time_use is %ld\n",time_use);
        
 }