#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <random>
#include "gmp.h"
#include "ag_gpuec256.h"
#include "openssl/sha.h"
#include "cuda_common.h"

#define dh_mybig_copy(a,b) {(a)[0]=(b)[0];(a)[1]=(b)[1];(a)[2]=(b)[2];(a)[3]=(b)[3];}
// #define NCOMMIT 2


mpz_t n;
const UINT64 h_Gx[4]={0x59F2815B16F81798L,0x029BFCDB2DCE28D9L,0x55A06295CE870B07L,0x79BE667EF9DCBBACL};
const UINT64 h_Gy[4]={0x9C47D08FFB10D4B8L,0xFD17B448A6855419L,0x5DA4FBFC0E1108A8L,0x483ADA7726A3C465L};
const UINT64 h_Gz[4]={0x1L,0x0L,0x0L,0x0L};

const UINT64 h_R2[4]={0x000007a2000e90a1L,0x1L,0x0L,0x0L};
const UINT64 h_R2modN[4]={0x896cf21467d7d140L,0x741496c20e7cf878L,0xe697f5e45bcd07c6L,0x9d671cd581c69bc5L};




char Vx[] =     "4e37ee0ff806bc2a90adb4a9fbc2bcac4853e688f96074c27d4f8504067bb821" ;
char Vy[] =     "35d0be4c081d5886d3b537be233a0523a03e065281f0f6fb7824d7d3407428cb" ;

char Ax[] =     "ccd393ca0432f633be28af8f9418e1b7a6c04a561470ad31eedae90014213b2c" ;
char Ay[] =     "777eb3cc1e68c7810c299273e98f0843975fe13d3666666f2d82c3195ccb282d" ;

char Sx[] =     "b978a8f312d3dc589ea2ec1a13b6297ce143977d0580abd4fdf3e3f0ac757bd6" ;
char Sy[] =     "fccf48f6190ff1ace5627770148e0ef4775f55995bd2beb9e34e4f3e06462953" ;

char T1x[] =    "8e5a60f5c2783a9c12afa44e4409e9e2e9009695f534763075bb9494c67e9089" ;
char T1y[] =    "96d689b27346008aa41ba218d8edc64054dece65c70041034d14e4012fcac3d3" ;

char T2x[] =    "e0aa38bed979fe0f86b7b60ba0f93f821258bf80cf2384106ed0cb89ca9febcb" ;
char T2y[] =    "1050d4fe521403a511914adc58c7541dfd77d8c4a5e18ef02337e4de536fb0c8" ;

char Taux[] =   "ebdff4501a8f6d887c15093e03386b286e86d447471ede1b54c9afee39f844db" ;
char Tprime[] = "d19a68ebf69769536b13014e30bcd92f8279713159e336ca0400ecb309498868" ;
char Mu[] =     "fdf10871a351b0caca73a33fff99f3ca0959a3d29898cbc89eba716e178b675b" ;

char BL[32][65] ={
    "a63f67f8c305d78d5d63a0dc22cf7a46f72e580d5b48c0a8a564d514b049a489",
    "75aa7e628479e74e1921e316a80306f417f08204b8647092a31ca30c9a07ba80",
    "ab7c4b468d630427e70a842e3450c2e8954c6210692203164dd9a118b4eff097",
    "9e003ab6ebfe627b0500885c65546f8a92ec638bf08ad8d4a9c060c31ba22b19",
    "a489b858f486035383cb2a4dd4397404f4ae960e2c80f6023b896ee8f40be392",
    "f13dd205d75902942e9f2503d3b278fb0ce4b23bb3a1d8e82f51e772ba2c2707",
    "802ae424198adc330d7893ef93a5912b0ca10686ba82b61eddf22c19b4920249",
    "2918c4f35508dd5921886086347b573a6bbfbd1582c65407e99a6978a61ddca5",
    "baeb30102adbf71149654cd29e245f21ba5668508abc84e187014b4ee1975ffd",
    "dd1bbd8a79403d4ddae4040623e693f780f3a33b62bae25e12a150a727083180",
    "3fa3a1b24e13cf04eb9b7b0b1b1a629de1c7955132b1f5ed208db54cb0696ab8",
    "99ad9f71d29d78b28923d52e9a0bc3f300e6d0ee9bc0a211da1e3e4fb0e90f2c",
    "a5ca12879aa8fbb11ea7dfcfb8d810e1e553425855fa730529dd747cc4e1f0e5",
    "b8e5e3cdb7c4ecdd9a2e5cd1c537c3b3db5245a39496a1235c2f5d6da3bfd787",
    "334711005ac9f6e4e8fdd4ccfe5c5389a359a7013e68cb64cfde5ef9f4b4fd71",
    "68a9c0de5b56bb519fc6b3c2a93147e9cd0d5c954adcca9a4d803cf830975968",
    "75855d128957fb656264623899be1f91605e9e6a607b0ffad5db560d05228ed2",
    "61f665e4ebdc33bf6a4394d6dc0d48408ab7db1cba7952db74cd721c0022d219",
    "54b1bbe429e4edc28fe53c955f995b7618735e99645e273b30ecef9b48b199f4",
    "92da1cb50b015f025296771f93cf62d8138ccd53d8340a216c1cbeef3ededf0f",
    "3e5bfad7c9312e45a2df4674b39a1c105d6adab51f0c809ddc2c700f655660c8",
    "7d2a6b6be39bedc1112229d9f087c6456c0f53ed38454e0c11e5e4c5d66d6b93",
    "a0c52f47311d9e1b9c7c131f1879bee3730276699f138fd6148b78ce7d647c3e",
    "4792e9c21deb13eaa8d9d5e0326512ee25ba4b731fc60a0ee191758be1bc1937",
    "e3d3a4799d187242a84f1e61b18a422f0a0a58469833e4dc34d6519d61b48b59",
    "1d91fbb378f8e048034d617e9fb8c5817b7ba020b5e76793ab6cd89237638fce",
    "27acf8951a83690b973e505695cec74fc13c80b2b731b361765d130046c78f58",
    "2368d16270296445b1110d894b34939c3d74597797c3f823f83312a72d39f8bb",
    "80044e678d25cd67da108b7a6fcc3d85087d5fddb464f55e64d22ae367a8e2fc",
    "cce1f9fe480a684174530d14db3845efd1126895c8198f7ab42751b44e772103",
    "429dd79ee498b3a0bf61c7706abb7a3ec67400ccd897b538d6398caad423fb95",
    "a299d46ab118a13a92c81662b03068fdb5e1a702525eedbdf242ea7774ca6420"
};
char BR[32][65] ={
    "ba70ff7c351ea26397ad0c3bcf094db05dfdd77f4236fa4c54ec61782047a375",
    "db7be64a9783e9dfccaf553c193fdb8b0c82a0f388df52b983358d47aa3d4a8d",
    "889e7236abebd33b0c5602890977cdb7371a575833119962e57a507f36913ba0",
    "b22443d202834ccaac65a621759ac51eb70f44488345a81368222f53bf8dfc40",
    "7a743ac6ade7756a22ed646375ab2747542d490855eb7c373c6c8a99f383b412",
    "235136ac18f4a5839c8259614e80fa8c7a415fd5329c844f4f63256df688f81d",
    "331ec69f64499b469f5510407fff0674d9802c9e536415a854391353ad3375a4",
    "3aa30e5f6abd82a7d9f8dc8d810f1608d059e3e075d687058ae2394e6f899e06",
    "f22ce0f73c75e10a27e9132ec8ce57cbb66456fbc85d5016df29b48d720bab7e",
    "56270145a12fcb44aa2e7376c7beb2ae7a5053e2231d2501f03d098d677f0b6c",
    "360b24e9be4cc4535c8118958ecc6de833ffb3c1387ee06875edead1a10c5533",
    "4b9f11fc705eb1e5e8eb7e69b6f610c95804511fc660ffcefafef354c08c66b3",
    "e71a62131167e21bc47a9ca02277647d35dc1a0d3fbb693d8cfbc4e91a0fc57",
    "19dd683b98e85ef1cffd6ed48d66e731e931614e60c527ad8e436308670ae588",
    "453c4bf9a850f93848f48e816683ecfc7da730106ffeb8da8f88585bbe26774e",
    "3c0c9e3cfa57639890b0266295d9d63ab54e80a9289a5cc62ff758582f848755",
    "db0acf3dd412f5f97cfaee7bb7e6bf104beb844f284d4e965fe5470460c5c526",
    "29ed05fe749ca34f9e27904988788a844f355c55b959cf031287c6a9eae99ee6",
    "968382aeb9271aba91de083bc664b1de7418b504c980bb115637b40bfc8217ff",
    "f4059c9d3cd7a26c728fe976852eafd5f9ae22900653f14e84f8bece990dab1c",
    "160a3d1ac5455223f01add67962fcf0cbf71c5c753fcddec55b3a51f33365f40",
    "b58b41193b25c80e1a044c2d14f32ed35bd728e5e0033b72a88287cc00630029",
    "e876e725b1066b42732c81689787714e89b3ee02ba46fbc69fbf9594e7a4758d",
    "e840a0bacff2daf8ebe9790443252247423ba0a007d171f8ae9d1de6459ada1a",
    "23cc706144607e87d91162f6929119fbd1c03f198c8d74b66aa940671b494af8",
    "b769031887f39a5236dc4228064a1eb15e3a9183d9e140356dde404c8e4cd4be",
    "47173fbecb64e907f178e763bbba94e3960ed161e9c4bfd01f9ffbf03f99c95",
    "34e41609df5e815bdbcad7572393d58bd29408340d50d7e14ad6a7f16d54c51c",
    "c02381ffaee0de970e798fadeef5854288f695ae0acf9dd4112dd1573d504c30",
    "7c268c9b3a57e017979ed640b44ede50354b7e07588e31cc69945d8b4722bb1c",
    "a8dcf4ab9445368c2f1c7de581d8606435d24d992d8b2d16aa04d85656494079",
    "14c706871dce0dcc8a2080e9a6d98ceec8586ae89f85d2cefa62e34332f84472"
    
};



BPSetupParams h_params;
initParamRandom h_ranParams;
std::string SEED="gyy hello world";
BPProve h_prove;
UINT64 h_bLR[256];

BPSetupParams *d_params;
initParamRandom *d_ranParams;

BPProve *d_prove;
UINT64 *d_bLR;
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
// void init(){
//     setJpoint(Vx,Vy,&h_prove.V);
//     setJpoint(Ax,Ay,&h_prove.A); 
//     setJpoint(Sx,Sy,&h_prove.S);
//     setJpoint(T1x,T1y,&h_prove.T1);
//     setJpoint(T2x,T2y,&h_prove.T2);

//     str2uint64(Taux,h_prove.Taux);
//     str2uint64(Mu,h_prove.Mu);
//     str2uint64(Tprime,h_prove.Tprime);

//     for(int i=0;i<32;i++){
//         str2uint64(BL[i],&h_bLR[4*i]); 
//         str2uint64(BR[i],&h_bLR[(32+i)*4]); 
//     }
// }
    

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
    std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine(19970504);
    // std::independent_bits_engine<std::default_random_engine,64,unsigned long long int> engine;
    // gen_random_uint64(engine,h_ranParams.gamma);
    gen_random_uint64(engine,h_ranParams.alpha);
    gen_random_uint64(engine,h_ranParams.rho);
    gen_random_uint64(engine,h_ranParams.tau1);
    gen_random_uint64(engine,h_ranParams.tau2);
    
    for(int i=0;i<NCOMMIT;i++){
        gen_random_uint64(engine,h_ranParams.gamma+i*4);
    }

    for(int i=0;i<32*NCOMMIT;i++){

        gen_random_uint64(engine,&(h_ranParams.SL[i*4]));
        gen_random_uint64(engine,&(h_ranParams.SR[i*4]));         
        
        
    }
    // h_mybig_print(ranParams.gamma);
    // h_mybig_print(ranParams.alpha);
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
    h_mybig_print(expy);
    dh_mybig_moninv_modN(expy,yinv);
    
    printf("yinv=\n");
    h_mybig_print(yinv);
    // dh_mybig_monmult_64(expy,h_R2,expy);
    for(int i=1;i<N;i++){
        dh_mybig_moninv_modN(expy,yinv);
        dh_mybig_monmult_64(Hh[i].x,h_R2,hprime[i].x);
        dh_mybig_monmult_64(Hh[i].y,h_R2,hprime[i].y);
        dh_mybig_monmult_64(Hh[i].z,h_R2,hprime[i].z);
        dh_point_mult_finalversion(&hprime[i],yinv,&hprime[i]);
        dh_mybig_monmult_64(hprime[i].x,h_ONE,hprime[i].x);
        dh_mybig_monmult_64(hprime[i].y,h_ONE,hprime[i].y);
        dh_mybig_monmult_64(hprime[i].z,h_ONE,hprime[i].z);
        dh_mybig_monmult_64_modN(expy,mony,expy);
    }
}

__device__ d_value[NCOMMIT];

int main(){
    // init();


    int al[32]={0};
    UINT64 ar[32*4]={0};
    int value[NCOMMIT];
    for(int i=0;i<NCOMMIT;i++){
        value[i]= rand();
        printf("value[%d]=%d\n",i,value);
    }
    
    compute_al_ar(value,al,ar,32);
    printf("value=%d\n",value);
    // for(int i=31;i>=0;i--){
    //     printf("%d",al[i]);
    // }
    // printf("\n");
    // for(int i=31;i>=0;i--){
    //     printf("%d",ar[i]);
    // }
    // printf("\n");
    
    // std::string s = "gyy hello world";
    JpointCpyFromXYZ(&h_params.G,h_Gx,h_Gy,h_Gz);
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

    unsigned char sd[32];
    UINT64 x[4];
    UINT64 y[4];
    UINT64 z[4];
    UINT64 yinv[4];
    HashBP(&h_prove.A,&h_prove.S,y,z);
    // h_mybig_print(y);
    // h_mybig_print(z);
    Jpoint* hprime = (Jpoint*)malloc(sizeof(Jpoint)*h_params.N);
    updateGen(hprime,h_params.Hh,y,h_params.N);

    // h_print_pointJ(&hprime[0]);
    // h_print_pointJ(&hprime[1]);
    h_print_pointJ(&hprime[31]);
    // std::cout<<o1<<std::endl;
    // calInvy(yinv,o1);

    // std::cout<<o2<<std::endl;
    // HashBP(&h_prove.T1,&h_prove.T2,o1,NULL);
    // std::cout<<o1<<std::endl;
    // h_mybig_print(b);
    // h_mybig_print(c);
    // h_mybig_print(d);

    

    // printf("V=\n");
    // h_print_pointJ(&h_prove.V);
    // printf("A=\n");
    // h_print_pointJ(&h_prove.A);
    // printf("S=\n");
    // h_print_pointJ(&h_prove.S);
    // printf("T1=\n");
    // h_print_pointJ(&h_prove.T1);
    // printf("T2=\n");
    // h_print_pointJ(&h_prove.T2);
    // printf("Taux=\n");
    // h_mybig_print(h_prove.Taux);
    // printf("Tprime=\n");
    // h_mybig_print(h_prove.Tprime);
    // printf("Mu=\n");
    // h_mybig_print(h_prove.Mu);
    // printf("BL=\n");
    // for(int i=0;i<32;i++){
    //     h_mybig_print(h_bLR+4*i);
    // }
    // printf("BR=\n");
    // for(int i=0;i<32;i++){
    //     h_mybig_print(h_bLR+4*(i+32));
    // }

    std::cout<<"Hello world!"<<std::endl;
}