#ifndef DBC_H
#define DBC_H
#pragma warning(disable:4996)
#include "uint288.h"
#define MAX_2 270
#define MAX_3 180
#define dbl_cost 70
#define add_cost 150
#define tpl_cost 126
struct Chain {
	unsigned char dbl;
	unsigned char tpl;
	bool minus;
	Chain();
	void setdata(unsigned char dbl, unsigned char tpl, bool minus);
};
struct DBC {
	bool isNULL;
	bool isBasic;
	int length;
	Chain addNode;
	int basic_value;
	DBC* parent;
	DBC& operator =(BIGNUM* n);
	DBC& operator =(int n);
	DBC& operator =(uint288 n);
	DBC();
	void setNULL();
	int getL();
	int getV();
	DBC add(int dbl, int tpl, int coef);
	void print();
	void simDBC();
};
struct DBCGroup {
	DBC& operator()(int dbl, int tri);
	DBC dbc[MAX_2][MAX_3];
};
#endif
