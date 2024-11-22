#ifndef DBC_H
#define DBC_H
#pragma warning(disable:4996)
#include "uint288.h"
#define MAX_2 270
#define MAX_3 180
#define dbl_cost 7
#define add_cost 15
#define tpl_cost 22
struct Chain {
	byte dbl;
	byte tpl;
	bool minus;
	Chain();
	void setdata(byte dbl, byte tpl, bool minus);
};
struct DBC {
	bool isNULL;
	bool isBasic;
	int length;
	Chain addNode;
	int basic_value;
	DBC* parent;
	DBC& operator =(int n);
	DBC& operator =(uint288 n);
	DBC();
	void setNULL();
	int getL() const;
	int getV() const;
	DBC add(int dbl, int tpl, int coef);
	void print();
	void simDBC();
};
#endif