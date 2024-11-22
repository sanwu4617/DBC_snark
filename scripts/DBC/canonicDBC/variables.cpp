#include "variables.h"
#include "functions.h"
DBC w_min;
Chain now_DBC[MAX_2];
int t_right[MAX_2];
int t_left[MAX_2];
//variables.cpp中加入下面3个变量，替换掉init函数
unsigned int w_min0[4];    //b,t,v,mode，其中mode=0：二进制，mode=1：w(b,t)+2^b3^t，mode=2：w(b,t)，mode=3：w_(b,t)+2^b3^t
unsigned short w_rec[MAX_2][MAX_3][3];
int MAX_T;
double d_pow23[MAX_2][MAX_3];
uint288 u_pow23[MAX_2][MAX_3];
void init(int down_mode)
{
	//为DBC代码运行提供基础环境
	pow2[0] = 1;
	pow3[0] = 1;
	for (int i = 1; i < 64; i++)
	{
		pow2[i] = pow2[i - 1] * 2;
	}
	for (int i = 1; i < 40; i++)
	{
		pow3[i] = pow3[i - 1] * 3;
	}
	for (int i = 0; i < 33; i++)
	{
		for (int j = 0; j < 19; j++)
		{
			pow23_1[i][j] = pow2[i] * pow3[j];
		}
	}
	pow23_256[0][0].data[8] = 1;
	for (int i = 0; i < 260; i++)
	{
		if (i > 0)
			pow23_256[i][0] = pow23_256[i - 1][0].mul_2();
		for (int j = 1; j < 165; j++)
		{
			if (i + j * log2(3) > 260)
				break;
			pow23_256[i][j] = pow23_256[i][j - 1].mul_3();
		}
	}
	w_rec[1][1][1] = 1024;   //置为很大的数表示NULL，使其在minL计算时不会被取到
	for (int i = 0; i < MAX_2; i++)
	{
		w_rec[i][0][0] = 1024;
		w_rec[i][0][1] = 1024;
	}
	for (int t = 0; t < MAX_3; t++)
	{
		w_rec[0][t][0] = 1024;
		w_rec[0][t][1] = 1024;
	}
	//设置t_left, t_right
	for(int i=0;i<256;i++)
	{
		t_left[i]=0;
		t_right[i]=0;
	}
	if (down_mode == 0)   //0.001
	{
		for (int i = 0; i < MAX_2; i++)
			t_right[i] = 255;
		MAX_T = 255;
	}
	if (down_mode == 1)   //0.001
	{
		t_right[0] = 3;
		t_right[1] = 4;
		for (int i = 2; i <= 4; i++)
			t_right[i] = 6;
		for (int i = 5; i <= 8; i++)
			t_right[i] = 7;
		for (int i = 9; i <= 13; i++)
			t_right[i] = 8;
		for (int i = 14; i <= 18; i++)
			t_right[i] = 9;
		for (int i = 18; i <= 24; i++)
			t_right[i] = 10;
		for (int i = 25; i <= 30; i++)
			t_right[i] = 11;
		for (int i = 31; i <= 37; i++)
			t_right[i] = 12;
		for (int i = 38; i <= 44; i++)
			t_right[i] = 13;
		for (int i = 45; i <= 51; i++)
			t_right[i] = 14;
		for (int i = 52; i <= 59; i++)
			t_right[i] = 15;
		for (int i = 60; i <= 68; i++)
			t_right[i] = 16;
		for (int i = 69; i <= 78; i++)
			t_right[i] = 17;
		for (int i = 79; i <= 89; i++)
			t_right[i] = 18;
		for (int i = 90; i <= 100; i++)
			t_right[i] = 19;
		for (int i = 101; i <= 112; i++)
			t_right[i] = 20;
		for (int i = 112; i <= 125; i++)
			t_right[i] = 21;
		for (int i = 126; i <= 139; i++)
			t_right[i] = 22;
		for (int i = 140; i <= 153; i++)
			t_right[i] = 23;
		for (int i = 154; i <= 167; i++)
			t_right[i] = 24;
		for (int i = 168; i <= 182; i++)
			t_right[i] = 25;
		for (int i = 183; i <= 197; i++)
			t_right[i] = 26;
		for (int i = 198; i < MAX_2; i++)
			t_right[i] = 27;
		MAX_T = 27;
	}
	if (down_mode == 2)   //0.005
	{
		t_right[0] = 2;
		t_right[1] = 3;
		t_right[2] = 3;
		for (int i = 3; i <= 6; i++)
			t_right[i] = 5;
		for (int i = 7; i <= 13; i++)
			t_right[i] = 6;
		for (int i = 14; i <= 19; i++)
			t_right[i] = 7;
		for (int i = 20; i <= 28; i++)
			t_right[i] = 8;
		for (int i = 29; i <= 37; i++)
			t_right[i] = 9;
		for (int i = 38; i <= 46; i++)
			t_right[i] = 10;
		for (int i = 47; i <= 58; i++)
			t_right[i] = 11;
		for (int i = 59; i <= 69; i++)
			t_right[i] = 12;
		for (int i = 70; i <= 81; i++)
			t_right[i] = 13;
		for (int i = 82; i <= 94; i++)
			t_right[i] = 14;
		for (int i = 95; i <= 108; i++)
			t_right[i] = 15;
		for (int i = 109; i <= 118; i++)
			t_right[i] = 16;
		for (int i = 119; i <= 134; i++)
			t_right[i] = 17;
		for (int i = 135; i <= 153; i++)
			t_right[i] = 18;
		for (int i = 154; i <= 165; i++)
			t_right[i] = 19;
		for (int i = 166; i <= 186; i++)
			t_right[i] = 20;
		for (int i = 187; i <= 204; i++)
			t_right[i] = 21;
		for (int i = 205; i < MAX_2; i++)
			t_right[i] = 22;
		for (int i = 128; i <= 159; i++)
			t_left[i] = 1;
		for (int i = 160; i <= 191; i++)
			t_left[i] = 2;
		for (int i = 192; i <= 223; i++)
			t_left[i] = 3;
		for (int i = 224; i < MAX_2; i++)
			t_left[i] = 4;
		MAX_T = 22;
	}
	if (down_mode == 3)   //0.01
	{
		t_right[0] = 2;
		t_right[1] = 2;
		for (int i = 2; i <= 7; i++)
			t_right[i] = 3;
		for (int i = 8; i <= 16; i++)
			t_right[i] = 4;
		for (int i = 17; i <= 24; i++)
			t_right[i] = 5;
		for (int i = 25; i <= 36; i++)
			t_right[i] = 6;
		for (int i = 37; i <= 48; i++)
			t_right[i] = 7;
		for (int i = 49; i <= 64; i++)
			t_right[i] = 8;
		for (int i = 65; i <= 76; i++)
			t_right[i] = 9;
		for (int i = 77; i <= 94; i++)
			t_right[i] = 10;
		for (int i = 95; i <= 107; i++)
			t_right[i] = 11;
		for (int i = 108; i <= 124; i++)
			t_right[i] = 12;
		for (int i = 125; i <= 147; i++)
			t_right[i] = 13;
		for (int i = 148; i <= 162; i++)
			t_right[i] = 14;
		for (int i = 163; i <= 183; i++)
			t_right[i] = 15;
		for (int i = 184; i <= 204; i++)
			t_right[i] = 16;
		for (int i = 205; i < MAX_2; i++)
			t_right[i] = 17;
		for (int i = 96; i <= 127; i++)
			t_left[i] = 1;
		for (int i = 128; i <= 155; i++)
			t_left[i] = 2;
		for (int i = 156; i <= 175; i++)
			t_left[i] = 3;
		for (int i = 176; i <= 199; i++)
			t_left[i] = 4;
		for (int i = 200; i <= 220; i++)
			t_left[i] = 5;
		for (int i = 221; i < MAX_2; i++)
			t_left[i] = 6;
		MAX_T = 17;
	}
	if (down_mode == 4)   //0.015
	{
		t_right[0] = 1;
		for (int i = 1; i <= 5; i++)
			t_right[i] = 2;
		for (int i = 6; i <= 14; i++)
			t_right[i] = 3;
		for (int i = 15; i <= 26; i++)
			t_right[i] = 4;
		for (int i = 27; i <= 40; i++)
			t_right[i] = 5;
		for (int i = 41; i <= 57; i++)
			t_right[i] = 6;
		for (int i = 58; i <= 76; i++)
			t_right[i] = 7;
		for (int i = 77; i <= 97; i++)
			t_right[i] = 8;
		for (int i = 98; i <= 123; i++)
			t_right[i] = 9;
		for (int i = 124; i <= 142; i++)
			t_right[i] = 10;
		for (int i = 143; i <= 168; i++)
			t_right[i] = 11;
		for (int i = 169; i <= 195; i++)
			t_right[i] = 12;
		for (int i = 196; i < MAX_2; i++)
			t_right[i] = 13;
		for (int i = 80; i <= 109; i++)
			t_left[i] = 1;
		for (int i = 110; i <= 130; i++)
			t_left[i] = 2;
		for (int i = 131; i <= 150; i++)
			t_left[i] = 3;
		for (int i = 151; i <= 165; i++)
			t_left[i] = 4;
		for (int i = 166; i <= 180; i++)
			t_left[i] = 5;
		for (int i = 181; i <= 190; i++)
			t_left[i] = 6;
		for (int i = 191; i <= 210; i++)
			t_left[i] = 7;
		for (int i = 211; i < MAX_2; i++)
			t_left[i] = 8;
		MAX_T = 13;
	}
	if (down_mode == 8)   //0.011
	{
		t_right[0] = 2;
		t_right[1] = 2;
		for (int i = 2; i <= 9; i++)
			t_right[i] = 3;
		for (int i = 10; i <= 17; i++)
			t_right[i] = 4;
		for (int i = 18; i <= 29; i++)
			t_right[i] = 5;
		for (int i = 30; i <= 42; i++)
			t_right[i] = 6;
		for (int i = 43; i <= 56; i++)
			t_right[i] = 7;
		for (int i = 57; i <= 68; i++)
			t_right[i] = 8;
		for (int i = 69; i <= 84; i++)
			t_right[i] = 9;
		for (int i = 85; i <= 100; i++)
			t_right[i] = 10;
		for (int i = 101; i <= 115; i++)
			t_right[i] = 11;
		for (int i = 116; i <= 135; i++)
			t_right[i] = 12;
		for (int i = 136; i <= 153; i++)
			t_right[i] = 13;
		for (int i = 154; i <= 173; i++)
			t_right[i] = 14;
		for (int i = 174; i <= 196; i++)
			t_right[i] = 15;
		for (int i = 197; i < MAX_2; i++)
			t_right[i] = 16;
		for (int i = 96; i <= 127; i++)
			t_left[i] = 1;
		for (int i = 128; i <= 155; i++)
			t_left[i] = 2;
		for (int i = 156; i <= 175; i++)
			t_left[i] = 3;
		for (int i = 176; i <= 199; i++)
			t_left[i] = 4;
		for (int i = 200; i <= 220; i++)
			t_left[i] = 5;
		for (int i = 221; i < MAX_2; i++)
			t_left[i] = 6;
		MAX_T = 16;
	}
	for (int b = 0; b < MAX_2 - 1; b++)
	{
		for (int t = 0; t < MAX_3 - 1; t++)
		{
			if (t > t_right[b])
			{
				w_rec[b + 1][t + 1][0] = 1024;
				w_rec[b + 1][t + 1][1] = 1024;
			}
			if (t < t_left[b])
			{
				w_rec[b + 1][t + 1][0] = 1024;
				w_rec[b + 1][t + 1][1] = 1024;
			}
		}
	}
	d_pow23[0][0]=1;
	memset(u_pow23,0,sizeof(u_pow23));
	u_pow23[0][0].data[8]=1;
	for (int i = 0; i < MAX_2; i++)
	{
		for (int j = 1; j < MAX_3; j++)
		{
			d_pow23[i][j] = d_pow23[i][j - 1] * 3;
			u_pow23[i][j] = u_pow23[i][j - 1].mul_3();
		}
		if (i < MAX_2 - 1)
		{
			d_pow23[i + 1][0] = d_pow23[i][0] * 2;
			u_pow23[i + 1][0] = u_pow23[i][0].mul_2();
		}
	}
	

}
