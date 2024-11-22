#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <random>
#include "gmp.h"
#include "gpuec256.h"
#include "openssl/sha.h"
#include "cuda_common.h"
#include "sha256.cuh"
#include <sys/time.h>

#define N_DATA (1024)
#define dh_mybig_copy(a,b) {(a)[0]=(b)[0];(a)[1]=(b)[1];(a)[2]=(b)[2];(a)[3]=(b)[3];}
#define TIME_TEST

mpz_t n;
const UINT64 h_Gx[4]={0x59F2815B16F81798L,0x029BFCDB2DCE28D9L,0x55A06295CE870B07L,0x79BE667EF9DCBBACL};
const UINT64 h_Gy[4]={0x9C47D08FFB10D4B8L,0xFD17B448A6855419L,0x5DA4FBFC0E1108A8L,0x483ADA7726A3C465L};
const UINT64 h_Gz[4]={0x1L,0x0L,0x0L,0x0L};

const UINT64 h_R2[4]={0x000007a2000e90a1L,0x1L,0x0L,0x0L};
// const UINT64 h_R2modN[4]={0x896cf21467d7d140L,0x741496c20e7cf878L,0xe697f5e45bcd07c6L,0x9d671cd581c69bc5L};




char Vx[] =     "4e37ee0ff806bc2a90adb4a9fbc2bcac4853e688f96074c27d4f8504067bb821" ;
char Vy[] =     "35d0be4c081d5886d3b537be233a0523a03e065281f0f6fb7824d7d3407428cb" ;

char Ax[] =     "ccd393ca0432f633be28af8f9418e1b7a6c04a561470ad31eedae90014213b2c" ;
char Ay[] =     "777eb3cc1e68c7810c299273e98f0843975fe13d3666666f2d82c3195ccb282d" ;

char Sx[] =     "b978a8f312d3dc589ea2ec1a13b6297ce143977d0580abd4fdf3e3f0ac757bd6" ;
char Sy[] =     "fccf48f6190ff1ace5627770148e0ef4775f55995bd2beb9e34e4f3e06462953" ;

char T1x[] =    "77afdb45531e1f777e7d82c82697085f025f54d96469a23981689cb9bc69d30c" ;
char T1y[] =    "e34b9d20e2ae413f112816452def92605bee2ddeee5be074f054665eda44dba1" ;

char T2x[] =    "c7dc07138ebdc0192a14d8aacc2f8463aa1fcf7bcbe65c526e71ed7ebca46d88" ;
char T2y[] =    "261cca6c0a4fd2158b65ab8974959ae64332f3cb2a049c1df3388ca8a066e963" ;

char Taux[] =   "efe10e0a6a89d6e46ec64f85734cee91acd094295b9dabb6424ad826e37d65ce" ;
char Tprime[] = "2c05837d7bcdfcd3e82ff90e444512966ba22009ce6a2f119e45c739035af098" ;
char Mu[] =     "e8e4a791ba0a5edeca104fae41b6273a3edee5a0a07f868506f3c8c4fa7c5588" ;


char ipCommitx[] = "1bd12210b9eb1f0ad612157f5fb7f72ca52ec1267c66f39b252926434aff6b8f";
char ipCommity[] = "b550cb1997688b1db545b80b12489b9618872ba47797b0e5e9f849b0a50762fc";

char ipA[] = "24593a5ee28c5581536637414bfebec9d25df0423047b38cc019382b142b8f21";
char ipB[] = "6ac01e46063d4e5b4577e85127fa7bdec2b308eea7df253403561129ab9c477c";

char ipUx[] = "d77df5c1a44024ad4388a28096ec6a2ef7c9dc00d29aeba38d6f1865307b6013";
char ipUy[] = "abf3f071be36929429d48dd92bd7d885c9506ceb01fb8779f37e5a3a51bc2d9e";

char ippramPx[] = "ed0f725abe71e10cab9ed861cfa40529e3a97e4da3a4b05325376d8433fe6788";
char ippramPy[] = "62db7f7a5b12c8f1dcdf7a124c92eb7b7b1228420aaf407ce3da33608c68f313";

char ipProvex[] = "ba56003e29bc5aa060964ab93388a2d4c377d18dd4fbe2efba5979c789fdcfab";
char ipProvey[] = "f0e405322e2a5286ef619a89913ce1ea395551585c815eb4785716adb7892d94";

char ipLsRs[][65] ={
    "71d1601a4bb8cee3e75b64b75029c10994ac3c8a7f6905c4c1b6c8265fb62d72",
    "a261c85c27389f72a6f6000d799d04b700a807df4d43e5878c1d27a449fbe8ad",
    "ba8ce28517d3e5ca7343b9405c511595eec77f9792ae3524a586310cd8b38a1b",
    "d94658ecb9b19636ad2d2e84a60c2a5700d95af483ec55314c805f893c23af03",
    "f0ac8b23fa9e54e638a1ee92ab610a1d35a34c6dc7fa5bae3283c46fb9601e79",
    "25c5adacdcfab9c10804e035b4e045103a75587329f7e64fc7bc7cdcb72e720b",
    "657669461f195d18030e5fa6407c0d9721d54624ff6a68eb5dd70c786161d3e9",
    "5b3c0d719647b7a04fd77daa98bba1bc69b26c3e3b2f7f548ed1d3d3aaa8fa07",
    "2064cbc107bc3e6814dfb0564b560c543140c90abf120d5925d747013fa774d2",
    "8e8f096b264b70105ed867c5fbe0751e8550a78a1e768342eefa750226ed9c60",
    "6550c8ffeb8dc7d47bf2dac0f1e7abd77338d0f6648c85bd0e349425eb5f7b26",
    "9298c66f731f550af9cd296ae541f4aab3d3ef378f82a4dc971a3130c947ae02",
    "7384ce47988daa2e14b603fddd404ef78a41fe0be027f52d02d9053c86636a23",
    "24e9c96f60757dd9dfe9cf64b7a414674afda445025e60c64ffee66799270250",
    "b2bbbe121ae465507e87081c5bf023e00d008ba8b9935a8b6247db115aff03dd",
    "f6b16da6046bf26a297ff754822344388ecd006321c49a00aaa6d78aab38029c",
    "4dd04e33fe49bca8076deb7d814da16494f100e6e00261a905e976ffa3e5a75b",
    "6c4fd632f33eaf4a7cba515897f75e61f2f8fa2adf414bda9085c9cc2cb8d37b",
    "182609eefde301e907150754ce5dd326f967e822e610798303d65223eb02cd2b",
    "f42de008ab86d51c052c8d88a8be2327d132a786220357ae111c7c8317ebb286"
};

char BL[32][65] ={
    "f1ff061b2e1945b6a9336170508f4012119f19c48a38ced70cd8d54b3290ad3f",
    "b5b5f5a7a71b6d809d8712c2ff56da24df49975cf0c1d5e0646d243715e38695",
    "a6c74ece1bf58c5f3aed7e51474271c5f380e36c0b6a3eeab57878aa39fc8b6",
    "a71a69da2b930ae1b1c16b72faa3fb4e415f1631d18523753dd9627f1eb10ee3",
    "c0ec984ab4c2b3b6b4d9e50b51dff2de225f7f19122403b4e63b958da931c739",
    "96d0c6fdc9eadc373fa1cfa0ea8a6311a3897615a99713fd990a78f419263701",
    "6b2e7b1fd39e0a58ee996da1c9d2287ff1ad86551e2726ad477c965c550247c",
    "f610efd48903cb4f30f3b217cda1045da05046fadcdae5c7d7b65e210d5323d9",
    "296db58f81293713628653a59ea3a74dafce9edde965739eace2db7456380afa",
    "6f987eb53e1c24da036e9358c40910f73845be58a97efa2298fc5102cf7f9b45",
    "25f64c6d215f61eae535a2f5e23c6f59c671ecc87f8be39215252cdb6dd4ef5",
    "daf86b0c7c39ccbb3b145647a07071cde86ed6fa75256ef35db636ddcf52936e",
    "dac3892a935c75c1a42b8e336c60588f12324a754745360069a63dd848efa92",
    "31c1561f5299c144350de78d9b7198d36ab597d719001a60b9208796cc11824e",
    "7f4a97adebf4ad2399279ee525a07f0d7be16644a464e8e6aabe06b1b1c7e970",
    "27ff06127072cd41d205c1e08da564b3380670f7ef2c4376d3f8441d1e8c4b35",
    "24efb2cbee5a5d6c21132923adaa90bafa73cc70c6d04b962197e5a8f13dcda6",
    "a2fa5e1a7a62f0a96a63af4960b3258ad199c9c5da2a376f9be18a32690ad5fc",
    "cab9a2edaf106ccd731eb1dbc682fdf5fb729bf1bbdc4370f5573a002866eb00",
    "8ea2ddc69638b969fb1cf2172970155aa51b7237f6cc24e7c4530294ce350ad4",
    "2566ce58589c97c4635ea6c6824b37a654e9d8e3da61b32b4e3e8691198b9f9b",
    "f7cf09f81683d71eb1d027f1667f887e8fe03f50f6474cbcb401f3edeacfa1d9",
    "3601e02bb005dfa3c1c80e501229554264c9db97af18904fc1e93abf29f6f1e9",
    "6b60ef35c86887e6a5d5be3f863728bd794594445d72c6c9d1905d3315d8d592",
    "337e0df7c9567c18ff873e0ebeb3b442ed521e81ea38727c05fde6fe794d881b",
    "c5578548b7b3afdd7fbe480e4e427b948cb6547fc07c685dec18bdb0ade4a76e",
    "ec02c55789de1dfd9939e94e51552f089d02ade587835fb58ad53c941f2964ba",
    "f2a5a507ad656499515fe4bc45360dcf0f4b7e1d6f00683b6cf7b32a739e4061",
    "86d247a0f5e847bae9baa4d0f173dd5a25a0d25cb5c91772513d30d1722fa5da",
    "8678f9f06068bf2dfd8ee8015f62aa0d30bfb5cb311e6b0245d93e94b4382dbb",
    "adfe0f06f3bb4d420e2501577f829eab8b6cf342af526fce37ee6d28d39e2002",
    "bc7716e40d651b4764125bbfeb8975f4386a836dc49d95e66b9576db217f22b5"
};
char BR[32][65] ={
    "b76f4d3278cfa4da06b5ca64b80b3762981e7ab1f60bf6540f8f7da23382213a",
    "d9074b02449df795bd83414726abce8a00ef74a01c34244749580074d7b19937",
    "247cc73bd5d1c1045864192af37d4b1c06d05bb9449bc883033ac97459bdaab9",
    "d188fcc2ad8c36da679302cf74363a4d1bfc5d6d0e5b8da2bdc69971d30998f9",
    "57aece4bf7b0f50ac7158a5287415bf1f78ab8735585a9cbf0a7d87284173454",
    "cb8ed282a12f8eaad5ab10e855f2eac75bae80cc130bea00d2b7680ec1966f51",
    "3272267027ef2f0872932db583b1a1510d8c24044ead47265fc9576b131b8dfd",
    "6ae31da34585809dc6b57181a28df38af88a44f51fddea01745555899c03c564",
    "12ceceba85721f3866e448ed3eacc4a474cd00296716cb9cf89b3f06f98daf32",
    "7a4404c0b601dafa95ff5b66cd41cbc19e6f09af6fe5fa18712f9822a2a6efc4",
    "5351ed1521e3946df2a1817ffab799e506f64431d641931e88478a74f6b55e06",
    "101d26aefbc67129895aa17dc59f2b1480f1b2e19938f84c6778b61b0399c1d1",
    "129c3d2b4018f228536c5b01249345037ab8910342572f26311b3caa309a42d1",
    "809af26522029703353ba23ab10628ff5c08e767eb37b1e0941d6fde1e31756c",
    "ceaa2788d83564b163999e5ca2fe33472eafc80abc8578ca093f23b0e9bedf47",
    "eeb680e0e918e3a321c96c25e4b185a02c6bc4ac50db154740a22a54d7496897",
    "a41fc0b5659acbeb24997ab639a1e94d68af0689ff017a97631196b7151ec067",
    "69447842f5c4a5b96b49c5442aae203068cea7be0fb0b99d25825e53d4c05ec4",
    "fba6dd9a1121d3157ca8d32ac3b0df75904097dd88533b87157f6ccb8311479f",
    "ce2f65936c3bc67d5df1b26f3a38400364cef25192f0faebdb6e9acc4e29fd9",
    "2482bac6150922d09afb80cf3d4fbb2bde4b6ccee667f1342c90823aa1df6e0e",
    "7d176056e407c91ab0bab80c00b03adde5f110dcae19e702d9cd0e4bfa523386",
    "955ad43f5eb343eb7ffe76f82d3f070cc1a0a105862e0f13e9c0a4b4e990032e",
    "c478af54c2e119010e6d0b9755e8411425a4de705043ec06ab1b89ee43680be8",
    "f90906f6bac11998c6b9030eccd831d44fa53f6a6c96971573b7d3ca582ab3dc",
    "ac1b87cef65f876fa15e2a0d8ba340c5fb250484fdd09ee5c08114c4bfcfa354",
    "27f6a98d7336fbbe4b769a48ceeeb7462385fb2fa4e492ebb3cd29b317d299cb",
    "e60b1b47e548a2748b05d18e7b0d27c5cef22e93808985e52a2d0c6e5d668c0b",
    "e63807eaddb3349fcabc42856f6e4255efe931ec26b5c7b143ca003e26db150e",
    "1437a65cd01f407bfc151e8af2f4528922555bffbc751d731a3b073478fd0ff",
    "8567b7b886a20092677cdc72bb4d63bd21a13eba903b8d2c814e5f19a10e6ad9",
    "34a9707e2e22f7330363b7957668ed722d48779fdab481477d2e7f7bde5fcd53"
};



BPSetupParams h_params[N_DATA];
initParamRandom h_ranParams[N_DATA];
std::string SEED="gyy hello world";
std::string SEEDU="gyy innerproduct";
BPProve h_prove[N_DATA];
UINT64 h_bLR[256*N_DATA];

Jpoint h_ipcommit[N_DATA];

Jpoint h_lsrs[10*N_DATA*2];
Jpoint *d_lsrs;

BPSetupParams *d_params;
initParamRandom *d_ranParams;

BPProve *d_prove;
UINT64 *d_bLR;

Jpoint *d_hprime;
Jpoint *d_ipcommit;
Jpoint* d_tmpJ;
Jpoint *d_tmpgphp;

UINT64 h_xyz[4*4*N_DATA],*d_xyz; //x,y,z,(y-1)^-1


void str2uint64(char *s,UINT64* x){
    std::string tmps(s);
    int len = tmps.size();
    // std::cout<<"len="<<len<<std::endl;
    // std::cout<<"size="<<tmps.size()<<std::endl;
    // std::cout<<"tmps="<<tmps<<std::endl;
    // std::cout<<"s="<<s<<std::endl;
    // std::cout<<tmps<<std::endl;
    // std::cout<<"0="<<tmps.substr(tmps.size()-16,16).c_str()<<std::endl;
    // std::cout<<"1="<<tmps.substr(tmps.size()-32,16).c_str()<<std::endl;
    // std::cout<<"2="<<tmps.substr(tmps.size()-48,16).c_str()<<std::endl;
    // std::cout<<"3="<<tmps.substr(0,16-(64-tmps.size())).c_str()<<std::endl;
    if(len<16){
        x[0]=strtoull(tmps.c_str(),NULL,16);
        x[1]=0;
        x[2]=0;
        x[3]=0;
        return ;
    }
    if(len<32){
        x[0]=strtoull(tmps.substr(tmps.size()-16,16).c_str(),NULL,16);
        x[1]=strtoull(tmps.substr(0,16-(32-tmps.size())).c_str(),NULL,16);
        printf("%s\n",tmps.substr(0,16-(32-tmps.size())).c_str());
        x[2]=0;
        x[3]=0;
        return ;
    }
    if(len<48){
        x[0]=strtoull(tmps.substr(tmps.size()-16,16).c_str(),NULL,16);
        x[1]=strtoull(tmps.substr(tmps.size()-32,16).c_str(),NULL,16);
        x[2]=strtoull(tmps.substr(0,16-(48-tmps.size())).c_str(),NULL,16);
        x[3]=0;
        return ;
    }
    x[0]=strtoull(tmps.substr(tmps.size()-16,16).c_str(),NULL,16);
    x[1]=strtoull(tmps.substr(tmps.size()-32,16).c_str(),NULL,16);
    x[2]=strtoull(tmps.substr(tmps.size()-48,16).c_str(),NULL,16);
    x[3]=strtoull(tmps.substr(0,16-(64-tmps.size())).c_str(),NULL,16);
    return ;
    

    // h_mybig_print(x);
    // std::cout<<std::endl;
}
void setJpoint(char* x,char* y,Jpoint* jp){
    str2uint64(x,jp->x);
    str2uint64(y,jp->y);
    str2uint64("1",jp->z);
}

void sha256(char *string, char *outputBuffer)
{
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, string, strlen(string));
    SHA256_Final(hash, &sha256);
    int i = 0;
    for(i = 0; i < SHA256_DIGEST_LENGTH; i++)
    {
        sprintf(outputBuffer + (i * 2), "%02x", hash[i]);
    }
    outputBuffer[64] = 0;
}
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
void uint642byte(UINT64 *x,char *h){
    for(int i=0;i<4;i++){
        for(int j=0;j<8;j++){
            h[i*8+j]=(x[3-i]>>((7-j)*8))&0xff;
        }
    }
}
__device__  void d_uint642byte(UINT64 *x, unsigned char *h){
    for(int i=0;i<4;i++){
        for(int j=0;j<8;j++){
            h[i*8+j]=(x[3-i]>>((7-j)*8))&0xff;
        }
    }
}
void uint642bin(UINT64* x,unsigned char *s){
    for(int i=3;i>=0;i--){
        for(int j=0;j<8;j++){
            s[(3-i)*8+j] = (x[i]>>((7-j)*8))&0xff;
            // printf("%02x\n",(x[i]>>((7-j)*8))&0xff);
        }
        
    }
    s[64]=0;
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

    char tmp[65];
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

void cudaInit(){
    cudaMalloc(&d_params,sizeof(BPSetupParams)*N_DATA);
    cudaMalloc(&d_prove,sizeof(BPProve)*N_DATA);
    cudaMalloc(&d_tmpJ,sizeof(Jpoint)*5*N_DATA);
    cudaMalloc(&d_xyz,sizeof(UINT64)*16*N_DATA);
    cudaMalloc(&d_hprime,sizeof(Jpoint)*h_params[0].N*N_DATA);
    cudaMalloc(&d_ipcommit,sizeof(Jpoint)*N_DATA);
    cudaMalloc(&d_bLR,sizeof(UINT64)*256*N_DATA);
    cudaMalloc(&d_lsrs,sizeof(Jpoint)*10*N_DATA*2);
    cudaMalloc(&d_tmpgphp,sizeof(Jpoint)*2*N_DATA);
}

void init(){
    for(int j=0;j<N_DATA;j++){
        setJpoint(Vx,Vy,&h_prove[j].V);
        setJpoint(Ax,Ay,&h_prove[j].A); 
        setJpoint(Sx,Sy,&h_prove[j].S);
        setJpoint(T1x,T1y,&h_prove[j].T1);
        setJpoint(T2x,T2y,&h_prove[j].T2);
        setJpoint(ipCommitx,ipCommity,&h_ipcommit[j]);

        for(int i=0;i<5;i++){
            setJpoint(ipLsRs[i*2],ipLsRs[i*2+1],&h_lsrs[j*5+i]);
            
        }
        for(int i=0;i<5;i++){
            setJpoint(ipLsRs[10+i*2],ipLsRs[10+i*2+1],&h_lsrs[N_DATA*5+j*5+i]);
            
        }

        setJpoint(ipUx,ipUy,&h_params[j].ipU);
        setJpoint(ippramPx,ippramPy,&h_params[j].ipP);

        str2uint64(Taux,h_prove[j].Taux);
        str2uint64(Mu,h_prove[j].Mu);
        str2uint64(Tprime,h_prove[j].Tprime);

        for(int i=0;i<32;i++){
            str2uint64(BL[i],&h_bLR[256*j+4*i]); 
            str2uint64(BR[i],&h_bLR[256*j+(32+i)*4]); 
        }

        str2uint64(ipA,h_params[j].ipA);
        str2uint64(ipB,h_params[j].ipB);
    }
    
}
    

void calInvy(UINT64 *yinv,char *stry){
    mpz_init(n);
    mpz_set_str(n,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",16);
    mpz_t bny,bnyinv;
    mpz_init(bny);
    mpz_set_str(bny,stry,16);
    mpz_invert(bnyinv,bny,n);
    mpz_mod(bnyinv,bnyinv,n);
    char tmp[65]={0};
    mpz_get_str(tmp,16,bnyinv);
    str2uint64(tmp,yinv);
}

void inline JpointCpyFromXYZ(Jpoint *jp,const UINT64 *x,const UINT64 *y,const UINT64 *z){
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

void inline JpointCpy(Jpoint *des,Jpoint *src){
    des->x[0]=src->x[0];
    des->x[1]=src->x[1];
    des->x[2]=src->x[2];
    des->x[3]=src->x[3];

    des->y[0]=src->y[0];
    des->y[1]=src->y[1];
    des->y[2]=src->y[2];
    des->y[3]=src->y[3];

    des->z[0]=src->z[0];
    des->z[1]=src->z[1];
    des->z[2]=src->z[2];
    des->z[3]=src->z[3];
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
    for(int j=0;j<N_DATA;j++){
        std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine(19970504);
        // std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine;
        gen_random_uint64(engine,h_ranParams[j].gamma);
        gen_random_uint64(engine,h_ranParams[j].alpha);
        gen_random_uint64(engine,h_ranParams[j].rho);
        gen_random_uint64(engine,h_ranParams[j].tau1);
        gen_random_uint64(engine,h_ranParams[j].tau2);
        
        

        for(int i=0;i<32;i++){

            gen_random_uint64(engine,&(h_ranParams[j].SL[i*4]));
            gen_random_uint64(engine,&(h_ranParams[j].SR[i*4]));         
        }
    }
    
    // h_mybig_print(ranParams.gamma);
    // h_mybig_print(ranParams.alpha);
}
void initPoint(){
    for(int i=0;i<N_DATA;i++){
        JpointCpyFromXYZ(&h_params[i].G,h_Gx,h_Gy,h_Gz);
        mapToGroup(SEED,&h_params[i].H);
        // printf("param[%d].H=\n",i);
        // h_print_pointJ(&h_params[i].H);
        h_params[i].N=32;

        for(int j=0;j<h_params[i].N;j++){
        
            char tmp[3];
            sprintf(tmp,"%u",j);
            mapToGroup(SEED+"h"+tmp,&h_params[i].Hh[j]);
            mapToGroup(SEED+"g"+tmp,&h_params[i].Gg[j]);
        }
        // mapToGroup(SEEDU,&h_params[i].ipU);
    }

    // JpointCpyFromXYZ(&h_params.G,h_Gx,h_Gy,h_Gz);
    // mapToGroup(SEED,&h_params.H);
    // printf("param.H=\n");
    // h_print_pointJ(&h_params.H);
    // h_params.N=32;
}

 void Jpoint2Apoint(Jpoint *A,Jpoint *ret){
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

void compute_al_ar(int v,int *al,UINT64 *ar,int n){
    for(int i=0;i<n;i++){
        al[i] = (v>>i) &0x1;
        if(al[i]){
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

void updateGen(Jpoint *hprime,Jpoint *Hh,UINT64 *y,int N){
    UINT64 yinv[4],expy[4],mony[4];
    JpointCpy(&hprime[0],&Hh[0]);
    dh_mybig_monmult_64_modN(y,h_R2modN,mony);
    // h_mybig_print(mony);
    dh_mybig_copy(expy,mony);
    // h_mybig_print(expy);
    dh_mybig_moninv_modN(expy,yinv);
    
    dh_mybig_monmult_64(hprime[0].x,h_R2,hprime[0].x);
    dh_mybig_monmult_64(hprime[0].y,h_R2,hprime[0].y);
    dh_mybig_monmult_64(hprime[0].z,h_R2,hprime[0].z);

    // printf("yinv=\n");
    // h_mybig_print(yinv);
    // dh_mybig_monmult_64(expy,h_R2,expy);
    for(int i=1;i<N;i++){
        dh_mybig_moninv_modN(expy,yinv);
        dh_mybig_monmult_64(Hh[i].x,h_R2,hprime[i].x);
        dh_mybig_monmult_64(Hh[i].y,h_R2,hprime[i].y);
        dh_mybig_monmult_64(Hh[i].z,h_R2,hprime[i].z);
        dh_point_mult_finalversion(&hprime[i],yinv,&hprime[i]);
        // dh_mybig_monmult_64(hprime[i].x,h_ONE,hprime[i].x);
        // dh_mybig_monmult_64(hprime[i].y,h_ONE,hprime[i].y);
        // dh_mybig_monmult_64(hprime[i].z,h_ONE,hprime[i].z);
        dh_mybig_monmult_64_modN(expy,mony,expy);
    }
}

void Jpoint_to_mon(Jpoint *jp){
    dh_mybig_monmult_64(jp->x,h_R2,jp->x);
    dh_mybig_monmult_64(jp->y,h_R2,jp->y);
    dh_mybig_monmult_64(jp->z,h_R2,jp->z);
}
void Jpoint_from_mon(Jpoint *jp){
    dh_mybig_monmult_64(jp->x,h_ONE,jp->x);
    dh_mybig_monmult_64(jp->y,h_ONE,jp->y);
    dh_mybig_monmult_64(jp->z,h_ONE,jp->z);
}

void BPProve_to_mon(){
    for(int i=0;i<N_DATA;i++){
        Jpoint_to_mon(&h_prove[i].V);
        Jpoint_to_mon(&h_prove[i].A);
        Jpoint_to_mon(&h_prove[i].S);
        Jpoint_to_mon(&h_prove[i].T1);
        Jpoint_to_mon(&h_prove[i].T2);
    }
    
   
}
void xyz_to_monN(){
    for(int i=0;i<N_DATA;i++){
        UINT64 *curhxyz = h_xyz+i*16;
        dh_mybig_monmult_64_modN(curhxyz  ,h_R2modN,curhxyz  );
        dh_mybig_monmult_64_modN(curhxyz+4,h_R2modN,curhxyz+4);
        dh_mybig_monmult_64_modN(curhxyz+8,h_R2modN,curhxyz+8);
    }
    
}
void param_to_mon(){
    for(int j=0;j<N_DATA;j++){
        for(int i=0;i<h_params[j].N;i++){
            Jpoint_to_mon(&h_params[j].Gg[i]);
        }
        Jpoint_to_mon(&h_ipcommit[j]);
        Jpoint_to_mon(&h_params[j].ipU);
        Jpoint_to_mon(&h_params[j].ipP);
        dh_mybig_monmult_64_modN(h_params[j].ipA,h_R2modN,h_params[j].ipA);
        dh_mybig_monmult_64_modN(h_params[j].ipB,h_R2modN,h_params[j].ipB);
        
    }
    
    
    
}
void blr_to_mon(){
    for(int j=0;j<N_DATA;j++){
        UINT64 *curbLR = h_bLR+4*64*j;
        for(int i=0;i<h_params[j].N*2;i++){
            dh_mybig_monmult_64_modN(curbLR+4*i,h_R2modN,curbLR+4*i);
        }
    }
    // for(int i=0;i<64;i++){
    //     dh_mybig_monmult_64_modN(h_bLR+4*i,h_R2modN,h_bLR+4*i);
    // }
    
}
void lsrs_to_mon(){
    for(int i=0;i<N_DATA;i++){
        for(int j=0;j<10;j++){
            dh_mybig_monmult_64(h_lsrs[i*10+j].x,h_R2,h_lsrs[N_DATA*10+i*10+j].x);
            dh_mybig_monmult_64(h_lsrs[i*10+j].y,h_R2,h_lsrs[N_DATA*10+i*10+j].y);
            dh_mybig_monmult_64(h_lsrs[i*10+j].z,h_R2,h_lsrs[N_DATA*10+i*10+j].z);           
        }
        
    }
    
}
void var2mon(){
    BPProve_to_mon();
    xyz_to_monN();
    param_to_mon();
    blr_to_mon();
    lsrs_to_mon();
    
}
__global__ void kernel_commitG1(Jpoint* res,BPSetupParams *param,BPProve *prove,int N){
    int tx = threadIdx.x;
    int idx = tx+blockIdx.x*blockDim.x;
    
    if(idx<N){
        Jpoint *curres = res+idx;
        UINT64 *curx = prove[idx].Tprime;
        UINT64 *curr = prove[idx].Taux ;
        Jpoint *curh = &param[idx].H;

        Jpoint tmp;
        Jpoint tmp2;
        dh_point_mult_finalversion(curh,curr,&tmp);
        d_base_point_mul(&tmp2,curx);
        // printf("tmp2=\n");
        // d_mybig_print(tmp2.x);
        // d_mybig_print(tmp2.y);
        // d_mybig_print(tmp2.z);
        // dh_mybig_copy(res->x,tmp2.x);
        // dh_mybig_copy(res->y,tmp2.y);
        // dh_mybig_copy(res->z,tmp2.z);
        dh_ellipticAdd_JJ(&tmp,&tmp2,curres);
        // printf("g^t'*htaux=\n");
        // d_mybig_print(tmp2.x);
        // d_mybig_print(tmp2.y);
        // d_mybig_print(tmp2.z);


    }
}

__global__ void kernel_rhs65(Jpoint* res,UINT64* d_xyz,BPProve *prove,BPSetupParams *param){
    int tx = threadIdx.x;
    int idx = tx + blockDim.x*blockIdx.x;
    int bx = blockIdx.x;

    int n = param[bx].N;
    if(tx>=4) return;
    __shared__ Jpoint sh_tmp[6];
    Jpoint *VT1T2 = &prove[bx].V;
    Jpoint* cur = (Jpoint*)VT1T2+tx;
    UINT64* curk = ((UINT64*)sh_tmp) + tx*4;
    UINT64 *xyz = d_xyz+bx*16;
    Jpoint *curres = res+bx;

    UINT64 x[4],y[4],z[4];
    dh_mybig_copy(z,xyz+8);
    dh_mybig_copy(y,xyz+4);
    dh_mybig_copy(x,xyz);
    if(tx==0){
        UINT64 t1[4],z3[4],yn[4];
        dh_mybig_monmult_64_modN(z,z,curk);   //z^2
        dh_mybig_monmult_64_modN(z,curk,z3);  //z^3
        dh_mybig_modsub_64_modN(z,curk,z);    //z-z^2
        // dh_mybig_monmult_64_modN(z3,dc_ONE,z3);
        // printf("z3=\n");
        // d_mybig_print(z3);
        // dh_mybig_monmult_64_modN(z,dc_ONE,z);
        // printf("z-z2=\n");
        // d_mybig_print(z);
        t1[3] = t1[2] = t1[1] = 0;
        t1[0] = 0xffffffff; 
        dh_mybig_monmult_64_modN(t1,dc_R2modN,t1);
        // dh_mybig_monmult_64_modN(t1,dc_ONE,t1);
        // printf("t1=\n");
        // d_mybig_print(t1);
        // dh_mybig_monmult_64_modN(y,dc_ONE,y);
        // printf("y=\n");
        // d_mybig_print(y);
        dh_mybig_modexp_ui32_modN(y,n,yn);
        
        dh_mybig_modsub_64_modN(yn,dc_mon_ONE_modN,yn);
        // dh_mybig_monmult_64_modN(yn,dc_ONE,yn);
        // printf("y32-1=\n");
        // d_mybig_print(yn);

        dh_mybig_copy(y,xyz+12); //y = (y-1)^-1
        // dh_mybig_monmult_64_modN(y,dc_ONE,y);
        // printf("y-1^-1=\n");
        // d_mybig_print(y);

        dh_mybig_monmult_64_modN(yn,y,yn);
        // dh_mybig_monmult_64_modN(yn,dc_ONE,yn);
        // printf("yn/y=\n");
        // d_mybig_print(yn);

        dh_mybig_monmult_64_modN(yn,z,yn);
        dh_mybig_monmult_64_modN(z3,t1,z3);
        dh_mybig_modsub_64_modN(yn,z3,yn);
        dh_mybig_monmult_64_modN(yn,dc_ONE,sh_tmp[1].x);
        // printf("delta=\n");
        // d_mybig_print(sh_tmp[1].x);

        dh_mybig_copy(sh_tmp[0].y,x);
        dh_mybig_monmult_64_modN(x,x,x);
        dh_mybig_copy(sh_tmp[0].z,x);
    }
    
    
    if(tx==3){
        d_base_point_mul(&sh_tmp[5],sh_tmp[1].x);
    }else{
        dh_mybig_monmult_64_modN(curk,dc_ONE,curk);
        dh_point_mult_finalversion(cur,curk,&sh_tmp[tx+2]);
    }
    // for(int i=1;i<4;i<<2){
    
    // }
    for(int i=1;i<4;i<<=1){
        if(tx%(i*2)==0)
            dh_ellipticAdd_JJ(&sh_tmp[tx+2],&sh_tmp[tx+2+i],&sh_tmp[tx+2]);
    }
    if(tx==0){
        dh_mybig_copy(curres->x,sh_tmp[2].x);
        dh_mybig_copy(curres->y,sh_tmp[2].y);
        dh_mybig_copy(curres->z,sh_tmp[2].z);
        // printf("rhs65\n");
        // dh_mybig_monmult_64(sh_tmp[2].x,dc_ONE,sh_tmp[2].x);
        // dh_mybig_monmult_64(sh_tmp[2].y,dc_ONE,sh_tmp[2].y);
        // dh_mybig_monmult_64(sh_tmp[2].z,dc_ONE,sh_tmp[2].z);
        // d_mybig_print(sh_tmp[2].x);
        // d_mybig_print(sh_tmp[2].y);
        // d_mybig_print(sh_tmp[2].z);
    }




}
// __global__ void kernel_calP(Jpoint* res,Jpoint *Gg,UINT64* xyz,Jpoint *hprime,Jpoint *A,Jpoint *S,int n)
__global__ void kernel_calP(Jpoint* res,BPSetupParams *params,UINT64* xyz,Jpoint *hprime,BPProve *prove,int n){
    int tx = threadIdx.x;
    int idx = tx + blockDim.x*blockIdx.x;
    int bx = blockIdx.x;
    __shared__ Jpoint sh_jp[64];//x,z,-z,z2

    UINT64 x[4],z[4],mz[4],z2[4];

    Jpoint *Gg = params[bx].Gg;
    UINT64 *curxyz = xyz+bx*16;
    Jpoint *curhprime = hprime+bx*32;
    Jpoint *A = &(prove[bx].A);
    Jpoint *S = &(prove[bx].S);
    Jpoint *curres = res+bx;

    dh_mybig_copy(x,curxyz);
    dh_mybig_copy(z,curxyz+8);
    dh_mybig_neg_modN(z,mz);
    dh_mybig_monmult_64_modN(mz,dc_ONE,mz);
    dh_mybig_monmult_64_modN(z,z,z2);

    dh_point_mult_finalversion(&Gg[tx],mz,&sh_jp[tx]);

    UINT64 t1[4],t2[4];
    dh_mybig_copy(t1,curxyz+4);
    dh_mybig_copy(t2,dc_mon_TWO_modN);
    dh_mybig_modexp_ui32_modN(t1,tx,t1);
    dh_mybig_modexp_ui32_modN(t2,tx,t2);
    dh_mybig_monmult_64_modN(t1,z,t1);
    dh_mybig_monmult_64_modN(t2,z2,t2);

    
    dh_mybig_modadd_64_modN(t1,t2,t1);
    dh_mybig_monmult_64_modN(t1,dc_ONE,t1);

    dh_point_mult_finalversion(&curhprime[tx],t1,&sh_jp[tx+32]);

    for(int i=1;i<=32;i<<=1){
        if(tx%(i)==0)
            dh_ellipticAdd_JJ(&sh_jp[tx*2],&sh_jp[tx*2+i],&sh_jp[tx*2]);
        __syncthreads();
    }
        // __syncthreads();


    if(tx==0){
        dh_ellipticAdd_JJ(&sh_jp[0],A,&sh_jp[0]);
        dh_mybig_monmult_64_modN(x,dc_ONE,x);
        dh_point_mult_finalversion(S,x,&sh_jp[1]);
        dh_ellipticAdd_JJ(&sh_jp[0],&sh_jp[1],&sh_jp[0]);

        dh_mybig_monmult_64(sh_jp[0].x,dc_ONE,curres->x);
        dh_mybig_monmult_64(sh_jp[0].y,dc_ONE,curres->y);
        dh_mybig_monmult_64(sh_jp[0].z,dc_ONE,curres->z);
        // printf("66P\n");
        // d_mybig_print(res->x);
        // d_mybig_print(res->y);
        // d_mybig_print(res->z);

    }
    


    
}
// __global__ void kernel_calP67(Jpoint *res,Jpoint *commit,Jpoint *h,UINT64 *mu)
__global__ void kernel_calP67(Jpoint *res,Jpoint *commit,BPSetupParams *params,BPProve *prove){
    int tx = threadIdx.x;
    int idx = tx + blockDim.x*blockIdx.x;
    int bx = blockIdx.x;

    Jpoint *curres = res+bx;
    Jpoint *h = &params[bx].H;
    UINT64 *mu = prove[bx].Mu;
    Jpoint *curcommit = commit + bx;

    if(tx==0){
        dh_point_mult_finalversion(h,mu,curres);
        dh_ellipticAdd_JJ(curres,curcommit,curres);

        // printf("67Ph^ucommit\n");
        dh_mybig_monmult_64(curres->x,dc_ONE,curres->x);
        dh_mybig_monmult_64(curres->y,dc_ONE,curres->y);
        dh_mybig_monmult_64(curres->z,dc_ONE,curres->z); 
        // d_mybig_print(res->x);
        // d_mybig_print(res->y);
        // d_mybig_print(res->z);
    }
}
__global__ void kernel_calip68(UINT64 *blr,int n){
    int tx = threadIdx.x;
    int idx = tx + blockDim.x*blockIdx.x;
    int bx = blockIdx.x;

    UINT64 *curblr = blr+bx*64*4;;

    dh_mybig_monmult_64_modN(&curblr[tx*4],&curblr[4*(tx+n)],&curblr[4*tx]);
    for(int i=n/2;i>0;i>>=1){
        if(tx<i)
            dh_mybig_modadd_64_modN(&curblr[tx*4],&curblr[(tx+i)*4],&curblr[tx*4]);
        __syncthreads();
    }
    // if(tx==0){
    //     dh_mybig_monmult_64_modN(&blr[4*(tx)],dc_ONE,&blr[4*(tx)]);
    //     printf("blr[%d] t'\n",tx);
    //     d_mybig_print(&blr[4*(tx)]);
    // }
    
}
void updateGen2(Jpoint *hprime,Jpoint *Hh,UINT64 *y,int N){
    UINT64 yinv[4],expy[4],mony[4];
    JpointCpy(&hprime[0],&Hh[0]);
    dh_mybig_monmult_64_modN(y,h_R2modN,mony);
    // h_mybig_print(mony);
    dh_mybig_copy(expy,mony);
    // h_mybig_print(expy);
    dh_mybig_moninv_modN(expy,yinv);
    
    dh_mybig_monmult_64(hprime[0].x,h_R2,hprime[0].x);
    dh_mybig_monmult_64(hprime[0].y,h_R2,hprime[0].y);
    dh_mybig_monmult_64(hprime[0].z,h_R2,hprime[0].z);

    // printf("yinv=\n");
    // h_mybig_print(yinv);
    // dh_mybig_monmult_64(expy,h_R2,expy);
    for(int i=1;i<N;i++){
        dh_mybig_moninv_modN(expy,yinv);
        dh_mybig_monmult_64(Hh[i].x,h_R2,hprime[i].x);
        dh_mybig_monmult_64(Hh[i].y,h_R2,hprime[i].y);
        dh_mybig_monmult_64(Hh[i].z,h_R2,hprime[i].z);
        dh_point_mult_finalversion(&hprime[i],yinv,&hprime[i]);
        // dh_mybig_monmult_64(hprime[i].x,h_ONE,hprime[i].x);
        // dh_mybig_monmult_64(hprime[i].y,h_ONE,hprime[i].y);
        // dh_mybig_monmult_64(hprime[i].z,h_ONE,hprime[i].z);
        dh_mybig_monmult_64_modN(expy,mony,expy);
    }
}
// __global__ void kernel_updateGen2(Jpoint *hprime,BPSetupParams *params,UINT64 *xyz,int N){
//     int tx = threadIdx.x;
//     int bx = blockIdx.x;
//     int idx = bx*blockDim.x+tx;

//     Jpoint *Hh = params[idx].Hh;
//     UINT64 *y = xyz+idx*16+4;
//     Jpoint *curhprime = hprime+idx*N;

//     UINT64 yinv[4],expy[4],mony[4];
//     // dh_mybig_copy(curhprime[0].x,Hh[0].x);
//     // dh_mybig_copy(curhprime[0].y,Hh[0].y);
//     // dh_mybig_copy(curhprime[0].z,Hh[0].z);
    
//     // dh_mybig_monmult_64_modN(y,dc_R2modN,mony);
//     dh_mybig_copy(mony,y);
//     dh_mybig_copy(expy,mony);
//     dh_mybig_moninv_modN(expy,yinv);
//     dh_mybig_monmult_64(Hh[0].x,dc_R2,curhprime[0].x);
//     dh_mybig_monmult_64(Hh[0].y,dc_R2,curhprime[0].y);
//     dh_mybig_monmult_64(Hh[0].z,dc_R2,curhprime[0].z);

//     for(int i=1;i<N;i++){
//         dh_mybig_moninv_modN(expy,yinv);
//         dh_mybig_monmult_64(Hh[i].x,dc_R2,curhprime[i].x);
//         dh_mybig_monmult_64(Hh[i].y,dc_R2,curhprime[i].y);
//         dh_mybig_monmult_64(Hh[i].z,dc_R2,curhprime[i].z);
//         dh_point_mult_finalversion(&curhprime[i],yinv,&curhprime[i]);
//         // dh_mybig_monmult_64(hprime[i].x,h_ONE,hprime[i].x);
//         // dh_mybig_monmult_64(hprime[i].y,h_ONE,hprime[i].y);
//         // dh_mybig_monmult_64(hprime[i].z,h_ONE,hprime[i].z);
//         dh_mybig_monmult_64_modN(expy,mony,expy);
//     }

// }
__global__ void kernel_updateGen(Jpoint *hprime,BPSetupParams *params,UINT64 *xyz,int N,int totalN){
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int idx = bx*blockDim.x+tx;
    
    int curp = idx/N;
    if (curp>=totalN) return ;

    int laneid = idx%N;
    Jpoint *Hh = params[curp].Hh;
    UINT64 *y = xyz+curp*16+4;
    Jpoint *curhprime = hprime+idx;

    UINT64 yinv[4],expy[4],mony[4];
    // dh_mybig_copy(curhprime[0].x,Hh[0].x);
    // dh_mybig_copy(curhprime[0].y,Hh[0].y);
    // dh_mybig_copy(curhprime[0].z,Hh[0].z);
    
    // dh_mybig_monmult_64_modN(y,dc_R2modN,mony);
    dh_mybig_copy(mony,y);
    dh_mybig_copy(expy,mony);
    // dh_mybig_moninv_modN(expy,yinv);
    dh_mybig_monmult_64(Hh[laneid].x,dc_R2,curhprime->x);
    dh_mybig_monmult_64(Hh[laneid].y,dc_R2,curhprime->y);
    dh_mybig_monmult_64(Hh[laneid].z,dc_R2,curhprime->z);

    dh_mybig_modexp_ui32_modN(mony,(unsigned int)laneid,mony);
    dh_mybig_moninv_modN(mony,yinv);
    dh_point_mult_finalversion(curhprime,yinv,curhprime);

    // for(int i=1;i<N;i++){
    //     dh_mybig_moninv_modN(expy,yinv);
    //     dh_mybig_monmult_64(Hh[i].x,dc_R2,curhprime[i].x);
    //     dh_mybig_monmult_64(Hh[i].y,dc_R2,curhprime[i].y);
    //     dh_mybig_monmult_64(Hh[i].z,dc_R2,curhprime[i].z);
    //     dh_point_mult_finalversion(&curhprime[i],yinv,&curhprime[i]);
    //     // dh_mybig_monmult_64(hprime[i].x,h_ONE,hprime[i].x);
    //     // dh_mybig_monmult_64(hprime[i].y,h_ONE,hprime[i].y);
    //     // dh_mybig_monmult_64(hprime[i].z,h_ONE,hprime[i].z);
    //     dh_mybig_monmult_64_modN(expy,mony,expy);
    // }

}
__device__ void device_hashBP(Jpoint *A,Jpoint *B,UINT64 *x,UINT64 *y){
    
    
    
    unsigned char tmp[32];
    unsigned char hash[32];
    // char tmp2[65];
    // char o1str[65];
    MYSHA256_CTX ctx;
    sha256_init(&ctx);
    d_uint642byte(A->x,tmp);
    sha256_update(&ctx, tmp, 32);
    d_uint642byte(A->y,tmp);
    sha256_update(&ctx, tmp, 32);
    d_uint642byte(B->x,tmp);
    sha256_update(&ctx, tmp, 32);
    d_uint642byte(B->y,tmp);
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
    d_uint642byte(A->x,tmp);
    sha256_update(&ctx2, tmp, 32);
    d_uint642byte(A->y,tmp);
    sha256_update(&ctx2, tmp, 32);
    d_uint642byte(B->x,tmp);
    sha256_update(&ctx2, tmp, 32);
    d_uint642byte(B->y,tmp);
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
__global__ void kernel_ipverify(Jpoint *tmpgphp,Jpoint* LsRs,BPSetupParams *params,Jpoint *hprime,int N,int logN,int totalN){
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int idx = bx*blockDim.x+tx;
    extern __shared__ Jpoint sh[];
    extern __shared__ UINT64 shuint64[];

    int NperGroup = N*2;
    int curp = idx/NperGroup;
    int laneid = idx%NperGroup;
    if(curp>=totalN) return ;
    int groupPerBlock = blockDim.x/NperGroup;
   
    Jpoint *curLs = LsRs+curp*logN;
    Jpoint *curRs = LsRs+(totalN+curp)*logN;
    UINT64 *curx = (UINT64*)(&shuint64[blockDim.x*3*4]);
    UINT64 *curxinv = curx+logN*groupPerBlock*4;
    Jpoint *Gg = params[curp].Gg;
    Jpoint *curhprime = hprime+curp*N;
    UINT64 *ipA = params[curp].ipA;
    UINT64 *ipB = params[curp].ipB;
    Jpoint *ipU = &params[curp].ipU;
    Jpoint *ipP = &params[curp].ipP;
    // Jpoint *cursh = sh+(tx/N)*N;
    Jpoint *curmonLs = LsRs+N_DATA*logN*2+curp*logN;
    Jpoint *curmonRs = LsRs+N_DATA*logN*2+(totalN+curp)*logN;;
    if(tx<logN*groupPerBlock){
        device_hashBP(&curLs[tx],&curRs[tx],curx+tx*4,NULL);
        dh_mybig_monmult_64_modN(curx+tx*4,dc_R2modN,curxinv+tx*4);
        dh_mybig_moninv_modN(curxinv+tx*4,curxinv+tx*4);
        // if(bx==444&&tx==0){
        //     printf("lsrs invx=\n");
        //     d_mybig_print(curxinv);
        //     printf("lsrs invx[1]=\n");
        //     d_mybig_print(curxinv+(1)*4);
        //     printf("lsrs invx[2]=\n");
        //     d_mybig_print(curxinv+(2)*4);
        //     printf("lsrs invx[3]=\n");
        //     d_mybig_print(curxinv+(3)*4);
        //     printf("lsrs invx[4]=\n");
        //     d_mybig_print(curxinv+(4)*4);
        //     printf("lsrs invx[1][0]=\n");
        //     d_mybig_print(curxinv+(5)*4);
        //     printf("lsrs invx[1][1]=\n");
        //     d_mybig_print(curxinv+(6)*4);
        // }
        
    }
    __syncthreads();
    Jpoint *tmpshJ = sh+logN*groupPerBlock;
    if(tx<logN*groupPerBlock*2){
        dh_mybig_monmult_64_modN(curx+tx*4,dc_R2modN,shuint64+tx*4); 
        dh_mybig_monmult_64_modN(shuint64+tx*4,shuint64+tx*4,shuint64+tx*4);
        dh_mybig_monmult_64_modN(shuint64+tx*4,dc_ONE,shuint64+tx*4);
        
        if(tx<logN*groupPerBlock)
            dh_point_mult_finalversion(&curmonLs[tx],shuint64+tx*4,tmpshJ+tx);
        else
            dh_point_mult_finalversion(&curmonRs[tx-logN*groupPerBlock],shuint64+tx*4,tmpshJ+tx);
        
        
    }
    __syncthreads();
    int curid = tx%10;
    for(int i=8;i>=1;i/=2){
        if((tx<logN*groupPerBlock*2)&&(curid+i<10)&&(curid<i)){
            dh_ellipticAdd_JJ(&tmpshJ[tx],&tmpshJ[tx+i],&tmpshJ[tx]);
        }
        __syncthreads();
                
    }
    if(tx<logN*groupPerBlock*2&&curid==0){
        dh_ellipticAdd_JJ(&tmpshJ[tx],ipP,&tmpshJ[tx]);
    }
    
    // if(bx==0&&tx==0){
        
    //     printf("Ls[0]^x0^2=\n");
    //     Jpoint tmp;
    //     // d_mybig_print(curLs[0].x); 
    //     // d_mybig_print(curLs[0].y); 
    //     // d_mybig_print(curLs[0].z); 
        
    //     dh_mybig_monmult_64(tmpshJ[0].x,dc_ONE,tmp.x);
    //     dh_mybig_monmult_64(tmpshJ[0].y,dc_ONE,tmp.y);
    //     dh_mybig_monmult_64(tmpshJ[0].z,dc_ONE,tmp.z);
    //     d_mybig_print(tmp.x); 
    //     d_mybig_print(tmp.y); 
    //     d_mybig_print(tmp.z); 
    // }
    
    
    curx=curx+tx/NperGroup*logN*4;
    curxinv = curxinv+tx/NperGroup*logN*4;
    if(laneid<N){
        dh_mybig_copy(sh[tx].x,Gg[laneid].x);
        dh_mybig_copy(sh[tx].y,Gg[laneid].y);
        dh_mybig_copy(sh[tx].z,Gg[laneid].z);
    }else{
        dh_mybig_copy(sh[tx].x,curhprime[laneid].x);
        dh_mybig_copy(sh[tx].y,curhprime[laneid].y);
        dh_mybig_copy(sh[tx].z,curhprime[laneid].z);
    }
    
    
    // __syncthreads();
    for(int k=logN-1;k>=0;k--){
        if(((laneid>>k)&0x1)==1){
            // if(bx==0&&tx==0){
            //     printf("1111\n");
            // }
            if(laneid<N)
                dh_point_mult_finalversion(&sh[tx],curx+(logN-1-k)*4,&sh[tx]);
            else
                dh_point_mult_finalversion(&sh[tx],curxinv+(logN-1-k)*4,&sh[tx]);
            
        }else{
            // if(bx==0&&tx==32){
            //     d_mybig_print(curxinv+(logN-1-k)*4);
            //     printf("gx0x1x2[0]=\n");
            //     Jpoint tmp;
            //     dh_mybig_monmult_64(sh[32].x,dc_ONE,tmp.x);
            //     dh_mybig_monmult_64(sh[32].y,dc_ONE,tmp.y);
            //     dh_mybig_monmult_64(sh[32].z,dc_ONE,tmp.z);
            //     d_mybig_print(tmp.x); 
            //     d_mybig_print(tmp.y); 
            //     d_mybig_print(tmp.z); 
            // }
            if(laneid<N)
                dh_point_mult_finalversion(&sh[tx],curxinv+(logN-1-k)*4,&sh[tx]);
            else
            dh_point_mult_finalversion(&sh[tx],curx+(logN-1-k)*4,&sh[tx]);
            
            
        }
    }

    
    // __syncthreads();
    
    for(int i=N/2;i>=1;i/=2){
        if((laneid%N)<i){
            dh_ellipticAdd_JJ(&sh[tx],&sh[tx+i],&sh[tx]);
        }
        
    }
    __syncthreads();
    
    // if(bx==0&tx==0){
    //     printf("gx0x1x2[0][0]=\n");
    //     Jpoint tmp;
    //     dh_mybig_monmult_64(sh[0].x,dc_ONE,tmp.x);
    //     dh_mybig_monmult_64(sh[0].y,dc_ONE,tmp.y);
    //     dh_mybig_monmult_64(sh[0].z,dc_ONE,tmp.z);
    //     d_mybig_print(tmp.x); 
    //     d_mybig_print(tmp.y); 
    //     d_mybig_print(tmp.z); 
        
    //     printf("gx0x1x2[1][0]=\n");
    //     dh_mybig_monmult_64(sh[64].x,dc_ONE,tmp.x);
    //     dh_mybig_monmult_64(sh[64].y,dc_ONE,tmp.y);
    //     dh_mybig_monmult_64(sh[64].z,dc_ONE,tmp.z);
    //     d_mybig_print(tmp.x); 
    //     d_mybig_print(tmp.y); 
    //     d_mybig_print(tmp.z); 

    //     printf("hx0x1x2[0][0]=\n");
    //     dh_mybig_monmult_64(sh[32].x,dc_ONE,tmp.x);
    //     dh_mybig_monmult_64(sh[32].y,dc_ONE,tmp.y);
    //     dh_mybig_monmult_64(sh[32].z,dc_ONE,tmp.z);
    //     d_mybig_print(tmp.x); 
    //     d_mybig_print(tmp.y); 
    //     d_mybig_print(tmp.z); 

    //     printf("hx0x1x2[1][0]=\n");
    //     dh_mybig_monmult_64(sh[96].x,dc_ONE,tmp.x);
    //     dh_mybig_monmult_64(sh[96].y,dc_ONE,tmp.y);
    //     dh_mybig_monmult_64(sh[96].z,dc_ONE,tmp.z);
    //     d_mybig_print(tmp.x); 
    //     d_mybig_print(tmp.y); 
    //     d_mybig_print(tmp.z); 
    // }
    if(laneid<2){
        dh_mybig_copy(tmpgphp[curp*2+laneid].x,sh[tx+laneid*N].x);
        dh_mybig_copy(tmpgphp[curp*2+laneid].y,sh[tx+laneid*N].y);
        dh_mybig_copy(tmpgphp[curp*2+laneid].z,sh[tx+laneid*N].z);
        // dh_mybig_copy(tmpgphp[curp*2].x,sh[tx].x);
        // dh_mybig_copy(tmpgphp[curp*2].y,sh[tx].y);
        // dh_mybig_copy(tmpgphp[curp*2].z,sh[tx].z);
        
    }
    
    return ;
    if(laneid==0){
        dh_mybig_monmult_64_modN(ipA,ipB,curx+8);
        dh_mybig_monmult_64_modN(ipA,dc_ONE,curx);
        dh_mybig_monmult_64_modN(ipB,dc_ONE,curx+4);
        dh_mybig_monmult_64_modN(curx+8,dc_ONE,curx+8);
        dh_point_mult_finalversion(&sh[tx],curx,&sh[tx]);
        dh_point_mult_finalversion(&sh[tx+N],curx+4,&sh[tx+1]);
        dh_point_mult_finalversion(ipU,curx+8,&sh[tx+2]);
        dh_ellipticAdd_JJ(&sh[tx],&sh[tx+1],&sh[tx]);
        dh_ellipticAdd_JJ(&sh[tx],&sh[tx+2],&sh[tx]);
    }
    

    // __syncthreads();
    // if(tx==0&&bx==423){
    //     printf("g^a*h^b*U^ab[0]=\n");
    //     Jpoint tmp;
    //     dh_mybig_monmult_64(sh[0].x,dc_ONE,tmp.x);
    //     dh_mybig_monmult_64(sh[0].y,dc_ONE,tmp.y);
    //     dh_mybig_monmult_64(sh[0].z,dc_ONE,tmp.z);
    //     d_mybig_print(tmp.x); 
    //     d_mybig_print(tmp.y); 
    //     d_mybig_print(tmp.z); 

    //     // printf("g^a*h^b*U^ab[1]=\n");
        
    //     // dh_mybig_monmult_64(sh[64].x,dc_ONE,tmp.x);
    //     // dh_mybig_monmult_64(sh[64].y,dc_ONE,tmp.y);
    //     // dh_mybig_monmult_64(sh[64].z,dc_ONE,tmp.z);
    //     // d_mybig_print(tmp.x); 
    //     // d_mybig_print(tmp.y); 
    //     // d_mybig_print(tmp.z); 
    // }

}

void gpu_commitG1(){ 
    int nT = 256;
    int nB = (N_DATA+nT-1)/nT;
    kernel_commitG1<<<nB,nT>>>(d_tmpJ,d_params,d_prove,N_DATA);
}

void gpu_rhs65(){
    int nT = 32;
    int nB = N_DATA;
    kernel_rhs65<<<nB,nT>>>(d_tmpJ+N_DATA,d_xyz,d_prove,d_params);
}

void gpu_calP(){
    int nT = 32;
    int nB = N_DATA;
    int n = h_params[0].N;
    // kernel_calP<<<nB,nT>>>(d_tmpJ+2,d_params->Gg,d_xyz,d_hprime,&d_prove->A,&d_prove->S,n);
    kernel_calP<<<nB,nT>>>(d_tmpJ+2*N_DATA,d_params,d_xyz,d_hprime,d_prove,n);
}

void gpu_calP67(){
    int nT = 32;
    int nB = N_DATA;
    kernel_calP67<<<nB,nT>>>(d_tmpJ+3*N_DATA,d_ipcommit,d_params,d_prove);
    // kernel_calP67<<<1,32>>>(d_tmpJ+3,d_ipcommit,&d_params->H,d_prove->Mu);
}

void gpu_calip68(){
    int nT = 32;
    int nB = N_DATA;
    int n = h_params[0].N;
    // printf("n=%d\n",n);
    kernel_calip68<<<nB,nT>>>(d_bLR,n);
}

void gpu_updateGen(){
    int nT = 256;
    int n = h_params[0].N;
    int nB = ((N_DATA+(nT/n))-1)/(nT/n);
    
    kernel_updateGen<<<nB,nT>>>(d_hprime,d_params,d_xyz,n,N_DATA);
}
// void gpu_updateGen2(){
//     int nT = 32;
//     int nB = (N_DATA+32-1)/nT;
//     int n = h_params[0].N;
//     kernel_updateGen2<<<nB,nT>>>(d_hprime,d_params,d_xyz,n);
// }

void gpu_ipverify(){
    int n = h_params[0].N;
    int nT = 256;
    int nB = (N_DATA+(nT/n/2)-1)/(nT/n/2);
    int logn = log2((double)n);
    // printf("n=%d\n",n);
    // printf("logn=%d\n",logn);
    int sm_size = nT*3*4+(logn*nT/n/2*4*2);
    kernel_ipverify<<<nB,nT,sizeof(UINT64)*sm_size>>>(d_tmpgphp,d_lsrs,d_params,d_hprime,n,logn,N_DATA);
    // printf("sm_size=%d\n",sm_size);
}

size_t SMwithipverify(int bs){
    int logn =5;
    int sm_size=bs*3*4+(logn*bs/32/2*4*2);
    return sizeof(UINT64)*sm_size;
}

int main(){
    cudaSetDevice(0);

    int nB,nT;
    cudaOccupancyMaxPotentialBlockSize(&nB,&nT,kernel_commitG1);
    printf("kernel_commitG1 nB=%d,nT=%d\n",nB,nT);
    cudaOccupancyMaxPotentialBlockSize(&nB,&nT,kernel_updateGen);
    printf("kernel_updateGen nB=%d,nT=%d\n",nB,nT);
    cudaOccupancyMaxPotentialBlockSize(&nB,&nT,kernel_ipverify);
    printf("kernel_ipverify nB=%d,nT=%d\n",nB,nT);
    cudaOccupancyMaxPotentialBlockSizeVariableSMem(&nB,&nT,kernel_ipverify,SMwithipverify);
    printf("kernel_ipverify nB=%d,nT=%d\n",nB,nT);
    printf("byte sm = %d\n",SMwithipverify(256));
    init();

    // CUDA_CHECK_ERROR();
    int al[32]={0};
    UINT64 ar[32*4]={0};
    int value = rand();
    compute_al_ar(value,al,ar,32);

    printf("value=%d\n",value);

    printf("N_DATA = %d\n",N_DATA);
    // for(int i=31;i>=0;i--){
    //     printf("%d",al[i]);
    // }
    // printf("\n");
    // for(int i=31;i>=0;i--){
    //     printf("%d",ar[i]);
    // }
    // printf("\n");
    
    // std::string s = "gyy hello world";
    initPoint();
    // JpointCpyFromXYZ(&h_params.G,h_Gx,h_Gy,h_Gz);
    // mapToGroup(SEED,&h_params.H);
    // printf("param.H=\n");
    // h_print_pointJ(&h_params.H);
    // h_params.N=32;
    // cout<<SEED
    // for(int i=0;i<h_params.N;i++){
        
    //     char tmp[3];
    //     sprintf(tmp,"%u",i);
    //     mapToGroup(SEED+"h"+tmp,&h_params.Hh[i]);
    //     mapToGroup(SEED+"g"+tmp,&h_params.Gg[i]);
    // }
        

 
    init_random_param();
    // printf("ipU=\n");
    // h_print_pointJ(&h_params[0].ipU);
    // printf("Gg[0]=\n");
    // h_print_pointJ(&h_params[0].Gg[0]);
    // printf("Gg[1]=\n");
    // h_print_pointJ(&h_params[0].Gg[1]);
    // printf("Hh[0]=\n");
    // h_print_pointJ(&h_params[0].Hh[0]);

    
    // printf("rho=\n");
    // h_mybig_print(h_ranParams[0].rho);
    // h_mybig_print(h_ranParams[1].rho);
    // printf("gamma=\n");
    // h_mybig_print(h_ranParams[0].gamma);
    // h_mybig_print(h_ranParams[1].gamma);
    // printf("alpha=\n");
    // h_mybig_print(h_ranParams[0].alpha);
    // h_mybig_print(h_ranParams[1].alpha);
    // printf("tau1=\n");
    // h_mybig_print(h_ranParams[0].tau1);
    // h_mybig_print(h_ranParams[1].tau1);
    // printf("tau2=\n");
    // h_mybig_print(h_ranParams[0].tau2);
    // h_mybig_print(h_ranParams[1].tau2);

    
    Jpoint* hprime = (Jpoint*)malloc(sizeof(Jpoint)*h_params[0].N*N_DATA);
    unsigned char sd[32];
    UINT64 myz[4];
    UINT64 myy[4];
    // HashBP_V2(&h_prove.A,&h_prove.S,myy,myz);
    // UINT64 z[4];
    UINT64 ym1[4*N_DATA];


    cudaInit();

    struct timeval s1,e1,s2,e2,s3,e3,s4,e4,s5,e5,s6,e6,s7,e7,s8,e8,s9,e9,s10,e10;
    gettimeofday(&s1,NULL);

    for(int i=0;i<N_DATA;i++){
        UINT64 *curhxyz = h_xyz+i*16;
        HashBP_V2(&h_prove[i].A,&h_prove[i].S,curhxyz+4,curhxyz+8);
        HashBP_V2(&h_prove[i].T1,&h_prove[i].T2,curhxyz,NULL);

        dh_mybig_modsub_64_ui32_modN(curhxyz+4,1,ym1);
        dh_mybig_moninv_modN(ym1,curhxyz+12);
        // printf("xyz for data[%d]\n",i);
        // h_mybig_print(curhxyz);
        // h_mybig_print(curhxyz+4);
        // h_mybig_print(curhxyz+8);
        // h_mybig_print(curhxyz+12);
        
        
    }
    gettimeofday(&e1,NULL);
    // HashBP_V2(&h_prove.A,&h_prove.S,h_xyz+4,h_xyz+8);
    // HashBP_V2(&h_prove.T1,&h_prove.T2,h_xyz,NULL);
    // dh_mybig_modsub_64_ui32_modN(h_xyz+4,1,ym1);
    // dh_mybig_moninv_modN(ym1,h_xyz+12);
    // dh_mybig_monmult_64_modN(h_xyz+12,h_ONE,h_xyz+12);
    // printf("x,y,z,(y-1)^-1=\n");
    // h_mybig_print(h_xyz);
    // h_mybig_print(h_xyz+4);
    // h_mybig_print(h_xyz+8);
    // h_mybig_print(h_xyz+12);
    
    // gettimeofday(&s2,NULL);
    // for(int i=0;i<N_DATA;i++){
    //     UINT64 *curhxyz = h_xyz+i*16;
    //     Jpoint *curhprime = hprime+i*h_params[0].N;
    //     updateGen(curhprime,h_params[i].Hh,curhxyz+4,h_params[i].N);
    // }
    // gettimeofday(&e2,NULL);

    // Jpoint tmpJp;
    // printf("hprime[0]=\n");
    // JpointCpy(&tmpJp,&hprime[0]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1]=\n");
    // JpointCpy(&tmpJp,&hprime[1]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[31]=\n");
    // JpointCpy(&tmpJp,&hprime[31]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1][0]=\n");
    // JpointCpy(&tmpJp,&hprime[32]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1][1]=\n");
    // JpointCpy(&tmpJp,&hprime[33]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1][31]=\n");
    // JpointCpy(&tmpJp,&hprime[63]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    gettimeofday(&s3,NULL);
    var2mon();
    // BPProve_to_mon();
    for(int i=0;i<N_DATA;i++){
        Jpoint_to_mon(&h_params[i].H);
    }
    gettimeofday(&e3,NULL);

    // printf("taux=\n");
    // h_mybig_print(h_prove.Taux);
    // printf("tprime=\n");
    // h_mybig_print(h_prove.Tprime);

    
    gettimeofday(&s4,NULL);
    CUDA_SAFE_CALL(cudaMemcpy(d_prove,&h_prove,sizeof(BPProve)*N_DATA,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_params,&h_params,sizeof(BPSetupParams)*N_DATA,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_xyz,h_xyz,sizeof(UINT64)*16*N_DATA,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_hprime,hprime,sizeof(Jpoint)*h_params[0].N*N_DATA,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_ipcommit,&h_ipcommit,sizeof(Jpoint)*N_DATA,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_bLR,h_bLR,sizeof(UINT64)*256*N_DATA,cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(d_lsrs,h_lsrs,sizeof(Jpoint)*10*N_DATA*2,cudaMemcpyHostToDevice));
    gettimeofday(&e4,NULL);
    


    gettimeofday(&s2,NULL);

    gpu_updateGen();

    cudaDeviceSynchronize();
    gettimeofday(&e2,NULL);


    // CUDA_SAFE_CALL(cudaMemcpy(hprime,d_hprime,sizeof(Jpoint)*h_params[0].N*N_DATA,cudaMemcpyDeviceToHost));
    // Jpoint tmpJp;
    // printf("hprime[0]=\n");
    // JpointCpy(&tmpJp,&hprime[0]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1]=\n");
    // JpointCpy(&tmpJp,&hprime[1]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[31]=\n");
    // JpointCpy(&tmpJp,&hprime[31]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1][0]=\n");
    // JpointCpy(&tmpJp,&hprime[32]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1][1]=\n");
    // JpointCpy(&tmpJp,&hprime[33]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[1][31]=\n");
    // JpointCpy(&tmpJp,&hprime[63]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);
    // printf("hprime[5][0]=\n");
    // JpointCpy(&tmpJp,&hprime[32*4]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[5][1]=\n");
    // JpointCpy(&tmpJp,&hprime[32*4+1]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);

    // printf("hprime[5][31]=\n");
    // JpointCpy(&tmpJp,&hprime[32*4+31]);
    // Jpoint_from_mon(&tmpJp);
    // Jpoint2Apoint(&tmpJp,&tmpJp);
    // h_print_pointJ(&tmpJp);


    gettimeofday(&s5,NULL);

    gpu_commitG1();

    cudaDeviceSynchronize();
    gettimeofday(&e5,NULL);

    // Jpoint hres[N_DATA];
    // CUDA_SAFE_CALL(cudaMemcpy(hres,d_tmpJ,sizeof(Jpoint)*N_DATA,cudaMemcpyDeviceToHost)) ;
    // for(int i=0;i<N_DATA;i++){
    //     printf("G^t' * H^taux [%d]=\n",i);
    //     Jpoint_from_mon(&hres[i]);
    //     Jpoint2Apoint(&hres[i],&hres[i]);
    //     h_print_pointJ(&hres[i]);
    // }

    
    gettimeofday(&s6,NULL);   

    gpu_rhs65();

    cudaDeviceSynchronize();
    gettimeofday(&e6,NULL);

    
    // Jpoint lh65;
    // CUDA_SAFE_CALL(cudaMemcpy(&hres,d_tmpJ+N_DATA,sizeof(Jpoint)*N_DATA,cudaMemcpyDeviceToHost)) ;
    // for(int i=0;i<N_DATA;i++){
    //     printf("lh65 [%d]=\n",i);
    //     Jpoint_from_mon(&hres[i]);
    //     Jpoint2Apoint(&hres[i],&hres[i]);
    //     h_print_pointJ(&hres[i]);
    // }
    // printf("lh65=\n");
    // h_print_pointJ(&lh65);
    // Jpoint_from_mon(&lh65);

    // printf("lh65=\n");
    // h_print_pointJ(&lh65);
    
    gettimeofday(&s7,NULL);

    gpu_calP();

    cudaDeviceSynchronize();
    gettimeofday(&e7,NULL);

    // CUDA_SAFE_CALL(cudaMemcpy(&hres,d_tmpJ+N_DATA*2,sizeof(Jpoint)*N_DATA,cudaMemcpyDeviceToHost)) ;
    // for(int i=0;i<N_DATA;i++){
    //     printf("66P [%d]=\n",i);
    //     // Jpoint_from_mon(&hres[i]);
    //     Jpoint2Apoint(&hres[i],&hres[i]);
    //     h_print_pointJ(&hres[i]);
    // }

    
    gettimeofday(&s8,NULL);

    gpu_calP67();

    cudaDeviceSynchronize();
    gettimeofday(&e8,NULL);

    // Jpoint hres[N_DATA];
    // CUDA_SAFE_CALL(cudaMemcpy(&hres,d_tmpJ+N_DATA*3,sizeof(Jpoint)*N_DATA,cudaMemcpyDeviceToHost)) ;
    // for(int i=0;i<N_DATA;i++){
    //     printf("67P [%d]=\n",i);
    //     // Jpoint_from_mon(&hres[i]);
    //     Jpoint2Apoint(&hres[i],&hres[i]);
    //     h_print_pointJ(&hres[i]);
    // }
    cudaDeviceSynchronize();
    gettimeofday(&s10,NULL);
    gpu_ipverify();
    cudaDeviceSynchronize();
    gettimeofday(&e10,NULL);
    
    gettimeofday(&s9,NULL);

    gpu_calip68();

    cudaDeviceSynchronize();
    gettimeofday(&e9,NULL);

    UINT64 htpres[256*N_DATA];
    CUDA_SAFE_CALL(cudaMemcpy(&htpres,d_bLR,sizeof(UINT64)*N_DATA*256,cudaMemcpyDeviceToHost)) ;
    // for(int i=0;i<N_DATA;i++){
    //     printf("68ip [%d]=\n",i);
    //     // Jpoint_from_mon(&hres[i]);
    //     dh_mybig_monmult_64_modN(&htpres[i*256],h_ONE,&htpres[i*256]);
    //     h_mybig_print(&htpres[i*256]);
    // }

    

    
    
    
    long long time_use;
    time_use=(e1.tv_sec-s1.tv_sec)*1000000+(e1.tv_usec-s1.tv_usec);//微秒
    printf("t1 is %llu\n",time_use);
    time_use=(e2.tv_sec-s2.tv_sec)*1000000+(e2.tv_usec-s2.tv_usec);//微秒
    printf("t2 is %llu\n",time_use);
    time_use=(e3.tv_sec-s3.tv_sec)*1000000+(e3.tv_usec-s3.tv_usec);//微秒
    printf("t3 is %llu\n",time_use);
    time_use=(e4.tv_sec-s4.tv_sec)*1000000+(e4.tv_usec-s4.tv_usec);//微秒
    printf("t4 is %llu\n",time_use);
    time_use=(e5.tv_sec-s5.tv_sec)*1000000+(e5.tv_usec-s5.tv_usec);//微秒
    printf("t5 is %llu\n",time_use);
    time_use=(e6.tv_sec-s6.tv_sec)*1000000+(e6.tv_usec-s6.tv_usec);//微秒
    printf("t6 is %llu\n",time_use);
    time_use=(e7.tv_sec-s7.tv_sec)*1000000+(e7.tv_usec-s7.tv_usec);//微秒
    printf("t7 is %llu\n",time_use);
    time_use=(e8.tv_sec-s8.tv_sec)*1000000+(e8.tv_usec-s8.tv_usec);//微秒
    printf("t8 is %llu\n",time_use);
    time_use=(e9.tv_sec-s9.tv_sec)*1000000+(e9.tv_usec-s9.tv_usec);//微秒
    printf("t9 is %llu\n",time_use);
    time_use=(e10.tv_sec-s10.tv_sec)*1000000+(e10.tv_usec-s10.tv_usec);//微秒
    printf("t10 is %llu\n",time_use);
    
    time_use=(e9.tv_sec-s1.tv_sec)*1000000+(e9.tv_usec-s1.tv_usec);//微秒
    printf("all is %llu\n",time_use);
    return 0;
    

    std::cout<<"Hello world!"<<std::endl;
}