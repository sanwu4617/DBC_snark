//
// Created by occul on 2021/10/15.
//

#include "DBC.h"
#include "constants.h"
#include "variables.h"

#define DBC_COEF 10      //次优DBC参数设置，本参数越小计算DBC越快，但DBC质量越好。不过参数过小可能会引起bug，建议不要小于10
int bBound[MAX_2] = { 0 };
//extern int MAX_T;
// int DBC_store[DBC_COEF][MAX_2][3]={0};   //第1维：不同的DBC，第2维：一个DBC的不同项，第3维：符号，2的次数，3的次数
int DBC_store[1][MAX_2][3]={0}; 
int DBC_len[MAX_2]={0};

// __host__ __device__ Chain::Chain() {
//     dbl = 0;
//     tpl = 0;
//     minus = 0;
// }

// __host__ __device__ void Chain::setdata(byte dbl, byte tpl, bool minus)
// {
// 	this->dbl = dbl;
// 	this->tpl = tpl;
// 	this->minus = minus;
// }
// __host__ __device__ int min_index(int a, int b, int c)
// {
// 	if (a < b)
// 	{
// 		if (a < c)
// 			return 0;
// 		return 2;
// 	}
// 	if (b < c)
// 		return 1;
// 	return 2;
// }
// __host__ __device__ int min_index(int a, int b)
// {
// 	if (a < b)
// 	{
// 		return 0;
// 	}
// 	return 1;
// }



// __host__ DBC::DBC() // runs in host.
// {
//     length = 0;
//     memset(w_min0, 0, sizeof(w_min0));
//     memset(w_rec, 0, sizeof(w_rec));
//     w_rec[1][1][1] = 1024;   //��Ϊ�ܴ������ʾNULL��ʹ����minL����ʱ���ᱻȡ��
//     for (int i = 0; i < MAX_2; i++)
//     {
//         w_rec[i][0][0] = 1024;
//         w_rec[i][0][1] = 1024;
//     }
//     for (int t = 0; t < MAX_3; t++)
//     {
//         w_rec[0][t][0] = 1024;
//         w_rec[0][t][1] = 1024;
//     }
//     for (int b = 0; b < MAX_2 - 1; b++)
//     {
//         for (int t = 0; t < MAX_3 - 1; t++)
//         {
//             if (t > t_right_cpu[b])
//             {
//                 w_rec[b + 1][t + 1][0] = 1024;
//                 w_rec[b + 1][t + 1][1] = 1024;
//             }
//             if (t < t_left_cpu[b])
//             {
//                 w_rec[b + 1][t + 1][0] = 1024;
//                 w_rec[b + 1][t + 1][1] = 1024;
//             }
//         }
//     }
// }

// __host__ __device__ inline int getDBC(uint288 n)
// {
// 	int b_try[130]={
// 	72,71,73,74,70,69,75,68,76,67,
// 	77,66,65,78,64,79,63,80,62,61,
// 	81,60,82,59,58,83,57,84,56,55,
// 	85,54,53,86,52,51,87,50,88,49,
// 	48,89,47,46,90,45,44,91,43,42,
// 	92,41,40,93,39,38,94,37,36,95,
// 	35,34,96,33,32,97,31,30,98,29,
// 	28,27,99,26,25,100,24,23,101,22,
// 	21,102,20,19,103,18,17,104,16,15,
// 	105,14,13,106,12,11,107,10,9,108,
// 	8,7,6,109,5,4,110,3,2,111,
// 	1,112,0,113,114,115,116,117,118,119
// 	};
	
// 	//将n转为双精度类型
// 	double dbl_n=n.to_double();
// 	//计算B1,B2
// 	double B1=0.9091372900969896*dbl_n;    //9*n/(7*sqrt(2))
// 	double B2=1.0774960475223583*dbl_n;    //16*sqrt(2)*n/21
// 	//计算LBound,RBound
// 	int LBound[MAX_3];
// 	int RBound[MAX_3];
// 	int DBC_index=0;

// 	for(int z=0;z<DBC_COEF;z++)
// 	{
// 		int b=b_try[z];
// 		LBound[b]=log(B1/d_pow23[0][b])/log(2)+1;
// 		RBound[b]=log(B2/d_pow23[0][b])/log(2);
// 		if(LBound[b]==RBound[b])
// 		{
// 			int a=RBound[b];
// 			int i=0;
// 			int b_temp=b;
// 			uint288 t=n;
// 			int s=1;
// 			while(!t.iszero())
// 			{
// 				//计算alpha,beta
// 				double dbl_t=t.to_double();
// 				int alpha=a,beta=b_temp;
// 				double logt=log(dbl_t)/log(2);
// 				double log3=log(3)/log(2);
// 				for(int j=b_temp;j>=max(0,b_temp-6);j--)
// 				{
// 					int alpha_j;
// 					if(d_pow23[0][j]>=dbl_t)
// 						alpha_j=0;
// 					else
// 					{
// 						int k_j=int(logt-j*log3);
// 						if(k_j>=a)
// 							alpha_j=a;
// 						else
// 						{
// 							if(abs(dbl_t-d_pow23[k_j][j])<=abs(d_pow23[k_j+1][j]-dbl_t))
// 								alpha_j=k_j;
// 							else
// 								alpha_j=k_j+1;
// 						}
// 					}
// 					if(abs(dbl_t-d_pow23[alpha_j][j])<=abs(d_pow23[alpha][beta]-dbl_t))
// 					{
// 						alpha=alpha_j;
// 						beta=j;
// 					}
// 				}
				
// 				int stmp=s;
// 				if(!(t>=u_pow23[alpha][beta]))
// 					s=-s;
// 				DBC_store[DBC_index][i][0]=stmp;
// 				DBC_store[DBC_index][i][1]=alpha;
// 				DBC_store[DBC_index][i][2]=beta;
// 				i++;
// 				if(t>=u_pow23[alpha][beta])
// 					t=t-u_pow23[alpha][beta];
// 				else
// 					t=u_pow23[alpha][beta]-t;
// 				a=alpha;
// 				b_temp=beta;

// 			}
// 			DBC_len[DBC_index]=i;
// 			DBC_index++;
			
// 		}
		
// 	}
// 	int V=9999999;
// 	int min_index=-1;
// 	for(int i=0;i<DBC_index;i++)
// 	{
// 		int temp=DBC_len[i]*150+DBC_store[i][0][1]*70+DBC_store[i][0][2]*126;
// 		if(temp<V)
// 		{
// 			V=temp;
// 			min_index=i;
// 		}
// 	}

// 	return min_index;
// }

// __host__ __device__ void DBC::get(uint288* np, int monitor) // runs in device.
// {
//     uint288 n = *np; 
//     uint288 B;
//     uint288 six_n;
//     uint288 record_outer;
//     uint288 temp_outer;
//     uint64 n0;
//     int bBound[MAX_2] = { 0 };
//     //w_min = n;
//     w_min0[2] = getV(np);
//     B = n.mul_2();
//     six_n = B.mul_3();
//     record_outer = B;
//     int log2B = 0;
//     int log3B = 0;
//     int t = 0, b = 0;
//     for (int i = 257; i >= 0; i--)
//     {
//         if (B >= pow23_256[i][0])
//         {
//             log2B = i;
//             break;
//         }
//     }
//     for (int i = 162; i >= 0; i--)
//     {
//         if (B >= pow23_256[0][i])
//         {
//             log3B = i;
//             break;
//         }
//     }
//     bBound[0] = log2B;
//     int i = 256;
//     for (t = 1; t <= log3B; t++)
//     {
//         for (; i >= 0; i--)
//         {
//             if (B >= pow23_256[i][t])
//             {
//                 bBound[t] = i;
//                 break;
//             }
//         }
//         i--;
//     }

//     if (monitor) {
//         //printf("DBC::get(): DBC_len is %d\n, wrec 0, 1 is %d, %d", DBC_len);
//         printf("w_rec[]:\n");
//         for (int i = 0; i < 20; i++) {
//             for (int j = 0; j < 16; j++) {
//                 printf("(%d %d %d)\t", w_rec[i][j][0], w_rec[i][j][1], w_rec[i][j][2]);
//             }
//             printf("\n\n");
//         }
//     }

//     //alpha=32,beta=18
//     int count = 0;
//     record_outer = six_n;
//     int j_bound = log3B / 18 + 1;
//     int i_outer = 0, j_outer = 0, i_inner = 0, j_inner = 0;
//     int min_index_0 = -1;
//     for (j_outer = 0; j_outer <= j_bound; j_outer++)
//     {
//         temp_outer = record_outer;
//         int i_bound = (bBound[j_outer * 18] >> 5) + 1;
//         for (i_outer = 0; i_outer <= i_bound; i_outer++)
//         {
//             n0 = temp_outer.mod_2_33_3_19();
//             for (j_inner = 0; j_inner <= 17; j_inner++)
//             {
//                 t = j_outer * 18 + j_inner;
//                 if (t > log3B)    //���������������������б���ѭ����������t>log3B�����ֱ��break
//                     break;
//                 if (t > MAX_T)     //����DBC�������Ž⣺triple���ʹ��t��
//                     break;
//                 for (i_inner = 0; i_inner <= 31; i_inner++)
//                 {
//                     count++;
//                     b = (i_outer << 5) + i_inner;
//                     if (t > t_right[b])
//                     {
//                         continue;
//                     }
//                     if (t < t_left[b])
//                     {
//                         continue;
//                     }
//                     if (b > 256)
//                         break;
//                     if (b + t > 0 && b <= bBound[t])
//                     {
//                         int quot = (n0 / pow23_1[i_inner][j_inner]) % 6;
//                         if (quot < 2)
//                         {
//                             //min_index_0 = min_index(w0[b][t + 1][1], w0[b + 1][t][1], w_0[b + 1][t][1] + 1);
//                             min_index_0 = min_index(w_rec[b][t + 1][0], w_rec[b + 1][t][0], w_rec[b + 1][t][1] + 1);
//                             //min_index_0=2;
//                             if (min_index_0 == 0)     //w(b,t)=w(b-1,t), w_(b,t)=w_(b-1,t)-2^(b-1)*3^t
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0];
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1] + 1;
//                                 //mode:4λ16���������ֱ�Ϊw(b,t)���w(b,t)���w_(b,t)���w_(b,t)����
//                                 w_rec[b + 1][t + 1][2] = 0x0123;
//                             }
//                             else if (min_index_0 == 1)    //w(b,t)=w(b,t-1), w_(b,t)=w_(b-1,t)-2^(b-1)*3^t
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b + 1][t][0];
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x0223;
//                             }
//                             else      //w(b,t)=w_(b,t-1)+2^b*3^(t-1), w_(b,t)=w_(b-1,t)-2^(b-1)*3^t
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b + 1][t][1] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x1423;
//                             }
//                         }
//                         else if (quot == 2)
//                         {
//                             //min_index_0 = min_index(w0[b][t + 1][1], w_0[b][t + 1][1] + 1, w_0[b + 1][t][1] + 1);
//                             min_index_0 = min_index(w_rec[b][t + 1][0], w_rec[b][t + 1][1] + 1, w_rec[b + 1][t][1] + 1);
//                             if (min_index_0 == 0)     //w(b,t)=w(b-1,t), w_(b,t)=w_(b-1,t)-2^(b-1)*3^t
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0];
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x0123;
//                             }
//                             else if (min_index_0 == 1)    //w(b,t)=w_(b-1,t)+2^(b-1)*3^t, w_(b,t)=w_(b-1,t)-2^(b-1)*3^t
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][1] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x2323;
//                             }
//                             else      //w(b,t)=w_(b,t-1)+2^b*3^(t-1), w_(b,t)=w_(b-1,t)-2^(b-1)*3^t
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b + 1][t][1] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x1423;
//                             }
//                         }
//                         else if (quot == 3)
//                         {
//                             //w(b,t)=w(b-1,t)+2^(b-1)*3^t
//                             min_index_0 = min_index(w_rec[b][t + 1][0] + 1, w_rec[b][t + 1][1], w_rec[b + 1][t][1] + 1);
//                             if (min_index_0 == 0)    //w(b-1,t)-2^(b-1)*3^t
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][0] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x2121;
//                             }
//                             else if (min_index_0 == 1)   //w_(b-1,t)
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1];
//                                 w_rec[b + 1][t + 1][2] = 0x2103;
//                             }
//                             else     //w_(b,t-1)-2^b*3^(t-1)
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b + 1][t][1] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x2114;
//                             }
//                         }
//                         else
//                         {
//                             //w(b,t)=w(b-1,t)+2^(b-1)*3^t
//                             min_index_0 = min_index(w_rec[b][t + 1][0] + 1, w_rec[b][t + 1][1], w_rec[b + 1][t][1] + 1);
//                             if (min_index_0 == 0)    //w(b,t-1)-2^b*3^(t-1)
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b + 1][t][0] + 1;
//                                 w_rec[b + 1][t + 1][2] = 0x2112;
//                             }
//                             else if (min_index_0 == 1)   //w_(b-1,t)
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b][t + 1][1];
//                                 w_rec[b + 1][t + 1][2] = 0x2103;
//                             }
//                             else     //w_(b,t-1)
//                             {
//                                 w_rec[b + 1][t + 1][0] = w_rec[b][t + 1][0] + 1;
//                                 w_rec[b + 1][t + 1][1] = w_rec[b + 1][t][1];
//                                 w_rec[b + 1][t + 1][2] = 0x2104;
//                             }
//                         }
//                     }
//                     if (b == bBound[t])
//                     {
//                         if (n >= pow23_256[b][t])
//                         {    //n>=pow23[b][t]  ->  n>nbt
//                             int V1 = w_rec[b + 1][t + 1][0] * 15 + b * 7 + t * 22;
//                             if (V1 < w_min0[2])
//                             {
//                                 w_min0[0] = b;
//                                 w_min0[1] = t;
//                                 w_min0[2] = V1;
//                                 w_min0[3] = 1;
//                             }
//                         }
//                         else {           //n=nbt
//                             int V1 = (w_rec[b + 1][t + 1][0] - 1) * 15 + (b - 1) * 7 + t * 22;
//                             int V2 = w_rec[b + 1][t + 1][1] * 15 + b * 7 + t * 22;
//                             if (V1 < w_min0[2])
//                             {
//                                 if (V2 < V1)
//                                 {
//                                     w_min0[0] = b;
//                                     w_min0[1] = t;
//                                     w_min0[2] = V2;
//                                     w_min0[3] = 3;
//                                 }
//                                 else
//                                 {
//                                     w_min0[0] = b;
//                                     w_min0[1] = t;
//                                     w_min0[2] = V1;
//                                     w_min0[3] = 2;
//                                 }
//                             }
//                             else if (V2 < w_min0[2])
//                             {
//                                 w_min0[0] = b;
//                                 w_min0[1] = t;
//                                 w_min0[2] = V2;
//                                 w_min0[3] = 3;
//                             }
//                         }
//                     }
//                 }
//             }
//             temp_outer.rshift_32(temp_outer);
//         }
//         record_outer.div_3_18();
//     }
//     //д��data
//     int DBC_len = 0;
//     int out_mode = 0;
//     int flag = 0;
//     int bit = 0;
//     b = w_min0[0];
//     t = w_min0[1];
//     switch (w_min0[3])
//     {
//         case 0:
//             for (int i = 8; i >= 0; i--)
//             {
//                 for (uint64 j = 1; j <= ((uint64)1 << 31); j <<= 1)
//                 {
//                     if ((n.data[i] & j) != 0)
//                     {
//                         data[flag].dbl = bit;
//                         data[flag].tpl = 0;
//                         data[flag].minus = false;
//                         flag++;
//                     }
//                     bit++;
//                 }
//             }
//             length = flag;
//             break;
//         case 1:
//             DBC_len = w_rec[b + 1][t + 1][0];
//             data[DBC_len].dbl = b;
//             data[DBC_len].tpl = t;
//             data[DBC_len].minus = 0;
//             length = DBC_len + 1;
//             break;
//         case 2:
//             DBC_len = w_rec[b + 1][t + 1][0];
//             length = DBC_len;
//             break;
//         case 3:
//             DBC_len = w_rec[b + 1][t + 1][1];
//             data[DBC_len].dbl = b;
//             data[DBC_len].tpl = t;
//             data[DBC_len].minus = 0;
//             out_mode = 1;
//             length = DBC_len + 1;
//             break;
//     }
//     /* occulticplus: check for 3^0 bug */
//     if (monitor) {
//         printf("DBC::get(): DBC_len is %d\n", DBC_len);
//         printf("w_rec[]:\n");
//         for (int i = 0; i < 20; i++) {
//             for (int j = 0; j < 16; j++) {
//                 printf("(%d %d %d)\t", w_rec[i][j][0], w_rec[i][j][1], w_rec[i][j][2]);
//             }
//             printf("\n\n");
//         }
//     }
//     int place = DBC_len - 1;
//     while (1)
//     {
//         int mode1 = (w_rec[b + 1][t + 1][2] & (15 << 12)) >> 12;  //w(b,t)����
//         int mode2 = (w_rec[b + 1][t + 1][2] & (15 << 8)) >> 8;    //w(b,t)����
//         int mode3 = (w_rec[b + 1][t + 1][2] & (15 << 4)) >> 4;    //w_(b,t)����
//         int mode4 = w_rec[b + 1][t + 1][2] & 15;    //w_(b,t)����
//         if (out_mode == 0)
//         {
//             if (mode1 == 1)
//             {
//                 data[place].dbl = b;
//                 data[place].tpl = t - 1;
//                 data[place].minus = 0;
//                 place--;
//             }
//             else if (mode1 == 2)
//             {
//                 data[place].dbl = b - 1;
//                 data[place].tpl = t;
//                 data[place].minus = 0;
//                 place--;
//             }
//             switch (mode2)
//             {
//                 case 0:
//                     break;
//                 case 1:
//                     b--;
//                     break;
//                 case 2:
//                     t--;
//                     break;
//                 case 3:
//                     b--;
//                     out_mode = 1;
//                     break;
//                 case 4:
//                     t--;
//                     out_mode = 1;
//                     break;
//             }
//         }
//         else
//         {
//             if (mode3 == 1)
//             {
//                 data[place].dbl = b;
//                 data[place].tpl = t - 1;
//                 data[place].minus = 1;
//                 place--;
//             }
//             else if (mode3 == 2)
//             {
//                 data[place].dbl = b - 1;
//                 data[place].tpl = t;
//                 data[place].minus = 1;
//                 place--;
//             }
//             switch (mode4)
//             {
//                 case 0:
//                     break;
//                 case 1:
//                     b--;
//                     out_mode = 0;
//                     break;
//                 case 2:
//                     t--;
//                     out_mode = 0;
//                     break;
//                 case 3:
//                     b--;
//                     break;
//                 case 4:
//                     t--;
//                     break;
//             }
//         }
//         if (place < 0)
//             break;
//     }
//     return;
// }


// __host__ __device__  void DBC::setNULL()
// {
// 	isNULL = true;
// 	length = 0;
// }
// __host__ __device__  int DBC::getL() const
// {
// 	if (isNULL)
// 		return 99999999;
// 	return length;
// }
// __host__ __device__  int DBC::getV() const
// {
// 	if (isBasic)
// 		return basic_value;
// 	if (isNULL)
// 		return 99999999;
// 	return dbl_cost * addNode.dbl + tpl_cost * addNode.tpl + add_cost * (length - 1);
// }



// __host__ __device__ DBC DBC::add(int dbl, int tpl, int coef)
// {
// 	if (isNULL)
// 		return *this;
// 	DBC ret;
// 	ret.parent = this;
// 	ret.addNode.dbl = dbl;
// 	ret.addNode.tpl = tpl;
// 	ret.length = this->length + 1;
// 	ret.addNode.minus = (coef != 1);
// 	return ret;
// }


// __host__ __device__ void DBC::simDBC()
// {
// 	if (isBasic)
// 		return;
// 	DBC* present = this;
// 	for (int i = length - 1; i >= 0; i--)
// 	{
// 		now_DBC[i].dbl = present->addNode.dbl;
// 		now_DBC[i].tpl = present->addNode.tpl;
// 		now_DBC[i].minus = present->addNode.minus;
// 		present = present->parent;
// 	}
// }

// __host__ __device__ void DBC::print()
// {
// 	if (isNULL && (!isBasic))
// 	{
// 		cout << isNULL << endl;
// 		cout << isBasic << endl;
// 		cout << "NULL" << endl;
// 		return;
// 	}
// 	//simDBC();
// 	for (int i = 0; i < length; i++)
// 	{
// 		if (now_DBC[i].minus)
// 			cout << "-";
// 		else
// 			cout << "+";
// 		cout << "2^" << int(now_DBC[i].dbl) << "*3^" << int(now_DBC[i].tpl);
// 	}
// 	cout << endl;
// 	return;
// }


// __host__ __device__ DBC& DBC::operator =(int n)
// {
// 	if (n == 0)
// 	{
// 		isNULL = false;
// 		length = 0;
// 	}
// 	else
// 	{
// 		int flag = 0;
// 		for (int i = 0; n > 0; i++)
// 		{
// 			if ((n & 1) == 1)
// 			{
// 				now_DBC[flag++].setdata(i, 0, false);
// 			}
// 		}
// 		length = flag;
// 		basic_value = now_DBC[length - 1].dbl * dbl_cost + add_cost * (length - 1);
// 	}
// 	isBasic = true;
// 	return *this;
// }

// __host__ __device__ DBC& DBC::operator =(uint288 n)
// {
// 	int flag = 0;
// 	int bit = 0;
// 	for (int i = 8; i >= 0; i--)
// 	{
// 		for (uint64 j = 1; j <= ((uint64)1 << 31); j <<= 1)
// 		{
// 			if ((n.data[i] & j) != 0)
// 			{
// 				now_DBC[flag++].setdata(bit, 0, false);
// 			}
// 			bit++;
// 		}
// 	}
// 	length = flag;
// 	basic_value = now_DBC[length - 1].dbl * dbl_cost + add_cost * (length - 1);
// 	isBasic = true;

// 	return *this;
// }


__host__ __device__ int DBCv2::getDBC(uint288 *n) {
	int b_try[130]={
	72,71,73,74,70,69,75,68,76,67,
	77,66,65,78,64,79,63,80,62,61,
	81,60,82,59,58,83,57,84,56,55,
	85,54,53,86,52,51,87,50,88,49,
	48,89,47,46,90,45,44,91,43,42,
	92,41,40,93,39,38,94,37,36,95,
	35,34,96,33,32,97,31,30,98,29,
	28,27,99,26,25,100,24,23,101,22,
	21,102,20,19,103,18,17,104,16,15,
	105,14,13,106,12,11,107,10,9,108,
	8,7,6,109,5,4,110,3,2,111,
	1,112,0,113,114,115,116,117,118,119
	};
	
	//将n转为双精度类型
	double dbl_n=n->to_double();
	//计算B1,B2
	double B1=0.9091372900969896*dbl_n;    //9*n/(7*sqrt(2))
	double B2=1.0774960475223583*dbl_n;    //16*sqrt(2)*n/21
	//计算LBound,RBound
	int LBound[MAX_3];
	int RBound[MAX_3];
	int DBC_index=0;

	for(int z=0;z<DBC_COEF;z++)
	{
		int b=b_try[z];
		LBound[b]=log(B1/d_pow23[0][b])/log(2)+1;
		RBound[b]=log(B2/d_pow23[0][b])/log(2);
		if(LBound[b]==RBound[b])
		{
			int a=RBound[b];
			int i=0;
			int b_temp=b;
			uint288 t;
            for (int i = 0; i < 9; i++) {
                t.data[i] = n->data[i];
            }
			int s=1;
			while(!t.iszero())
			{
				//计算alpha,beta
				double dbl_t=t.to_double();
				int alpha=a,beta=b_temp;
				double logt=log(dbl_t)/log(2);
				double log3=log(3)/log(2);
				for(int j=b_temp;j>=max(0,b_temp-6);j--)
				{
					int alpha_j;
					if(d_pow23[0][j]>=dbl_t)
						alpha_j=0;
					else
					{
						int k_j=int(logt-j*log3);
						if(k_j>=a)
							alpha_j=a;
						else
						{
							if(abs(dbl_t-d_pow23[k_j][j])<=abs(d_pow23[k_j+1][j]-dbl_t))
								alpha_j=k_j;
							else
								alpha_j=k_j+1;
						}
					}
					if(abs(dbl_t-d_pow23[alpha_j][j])<=abs(d_pow23[alpha][beta]-dbl_t))
					{
						alpha=alpha_j;
						beta=j;
					}
				}
				
				int stmp=s;
				if(!(t>=u_pow23[alpha][beta]))
					s=-s;
				DBC_store[DBC_index][i][0]=stmp;
				DBC_store[DBC_index][i][1]=alpha;
				DBC_store[DBC_index][i][2]=beta;
				i++;
				if(t>=u_pow23[alpha][beta])
					t=t-u_pow23[alpha][beta];
				else
					t=u_pow23[alpha][beta]-t;
				a=alpha;
				b_temp=beta;

			}
			DBC_len[DBC_index]=i;
			DBC_index++;
			break;
		}
		
	}
	// int V=9999999;
	// int min_index=-1;
	// for(int i=0;i<DBC_index;i++)
	// {
	// 	int temp=DBC_len[i]*150+DBC_store[i][0][1]*70+DBC_store[i][0][2]*126;
	// 	if(temp<V)
	// 	{
	// 		V=temp;
	// 		min_index=i;
	// 	}
	// }

	return 0;//min_index;
}
