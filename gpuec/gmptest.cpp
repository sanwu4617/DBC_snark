#include <gmp.h>
#include<stdio.h>
int main(){
    mpz_t a,b,c,d,r,t1,t2,t3,x,y,z,n;
    mpz_init(a);
    mpz_init(b);
    mpz_init(c);
    mpz_init(d);
    mpz_init(r);
    mpz_init(t1);
    mpz_init(t2);
    mpz_init(t3);
    mpz_init(x);
    mpz_init(y);
    mpz_init(z);
    mpz_init(n);
    mpz_set_str(c,"2",16);
    mpz_set_str(b,"ba70ff7c351ea26397ad0c3bcf094db05dfdd77f4236fa4c54ec61782047a375",16);
    mpz_set_str(a,"a63f67f8c305d78d5d63a0dc22cf7a46f72e580d5b48c0a8a564d514b049a489",16);
    mpz_set_str(r,"10000000000000000000000000000000000000000000000000000000000000000",16);
    mpz_set_str(x,"ffffffffffffffff",16);
    mpz_set_str(y,"4b0dff665588b13f",16);
    mpz_set_str(z,"fb2e498e6fe1a16b7510b125c9a527554cdab84a9cb696e729cd32f46631edf9",16);
    // mpz_set_ui(b,7);
    mpz_set_str(d,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F",16);
    mpz_set_str(n,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",16);
    int cnt = 0;
    // mpz_sub(t1,b,c);
    // mpz_neg(t1,a);
    mpz_mul(t1,a,b);
    mpz_mod(t1,t1,d);
    gmp_printf("%#Zx\n",t1);
    // mpz_mul(t2,b,r);
    // mpz_mod(t2,t2,n);
    // gmp_printf("%#Zx\n",t2);

    // mpz_powm_ui(t1,b,32,n);

    // mpz_sub(t1,t1,c);
    // mpz_sub(t2,b,c);

    // mpz_invert(t2,t2,n);

    // mpz_mod(t2,t2,n);
    // gmp_printf("%#Zx\n",t1);
    // gmp_printf("%#Zx\n",t2);
    // mpz_mul(t3,t1,t2);
    // mpz_mod(t3,t3,n);
    // gmp_printf("%#Zx\n",t3);
    // if(mpz_cmp(t3,b)==0) printf("y right\n");
    // mpz_mul(t1,z,z);
    // // mpz_mul(t1,t1,z);
    // mpz_mod(t1,t1,d);
    // mpz_invert(t2,t1,d);
    // mpz_mul(t3,t2,x);
    // mpz_mod(t3,t3,d);
    // gmp_printf("%#Zx\n",t3);
    // if(mpz_cmp(t3,a)==0) printf("x right\n");

    // mpz_mul(t1,c,c);
    // mpz_mod(t1,t1,d);
    // gmp_printf("hello  %#Zx\n",t1);
    // while(1){
    //     mpz_mod_ui(t1,a,100000);
    //     if(mpz_cmp_ui(t1,0)==0){
    //         printf("no. ");
    //         gmp_printf("%#Zx\n",a);
    //     }
    //     mpz_pow_ui(c,a,3);
    //     mpz_add_ui(c,c,7);
    //     // mpz_mod(c,c,d);
    //     if(mpz_perfect_square_p(c)){
    //         gmp_printf("%#Zx\n",a);
    //         cnt++;
    //     }
    //     if(cnt>=2) break;
    //     mpz_add_ui(a,a,1);
    // }
    
    // mpz_set_str(r,"100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",16);
    // mpz_mul(c,a,b);
    // mpz_mod(t1,r,d);
    
    // int isequ = mpz_cmp(a,t1);
    // printf("is equal %d\n",isequ);

    // mpz_mod(c,b,a);
    // mpz_invert(t1,a,b);
    // mpz_mod(t1,c,b);
    // mpz_mul(t1,a,b);
    // mpz_mod(t2,t1,b);
    // gmp_printf("%#Zx\n",a);
    // gmp_printf("%#Zx\n",b);
    // gmp_printf("%#Zx\n",t2);
    // isequ = mpz_cmp(t2,d);
    // printf("is equal %d\n",isequ);
}