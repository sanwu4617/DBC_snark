#ifndef DBC_H
#define DBC_H
#pragma warning(disable : 4996)
#include "myBigInt.h"

struct Chain
{
	ushort dbl;
	ushort tpl;
	bool minus;
	Chain()
	{
		dbl = 0;
		tpl = 0;
		minus = 0;
	}

	void setdata(ushort dbl, ushort tpl, bool minus)
	{
		this->dbl = dbl;
		this->tpl = tpl;
		this->minus = minus;
	}
};

extern Chain now_DBC[MAX_2];

template <int N>
struct optimal_DBC
{
	bool isNULL;
	bool isBasic;
	int length;
	Chain addNode;
	int basic_value;
	optimal_DBC *parent;
	// optimal_DBC& operator =(BIGNUM* n);
	optimal_DBC &operator=(int n)
	{
		if (n == 0)
		{
			isNULL = false;
			length = 0;
		}
		else
		{
			int flag = 0;
			for (int i = 0; n > 0; i++)
			{
				if ((n & 1) == 1)
				{
					now_DBC[flag++].setdata(i, 0, false);
				}
			}
			length = flag;
			basic_value = now_DBC[length - 1].dbl * DBL_COST + ADD_COST * (length - 1);
		}
		isBasic = true;
		return *this;
	}

	optimal_DBC &operator=(myBigInt<N> n)
	{
		int flag = 0;
		int bit = 0;
		for (int i = INTS-1; i >= 0; i--)
		{
			for (uint64 j = 1; j <= ((uint64)1 << 31); j <<= 1)
			{
				if ((n.data[i] & j) != 0)
				{
					now_DBC[flag++].setdata(bit, 0, false);
				}
				bit++;
			}
		}
		length = flag;
		basic_value = now_DBC[length - 1].dbl * DBL_COST + ADD_COST * (length - 1);
		isBasic = true;
		return *this;
	}

	optimal_DBC()
	{
		isNULL = false;
		length = 0;
		parent = NULL;
		isBasic = false;
		basic_value = 0;
	}

	void setNULL()
	{
		isNULL = true;
		length = 0;
	}

	int getL()
	{
		if (isNULL)
			return 99999999;
		return length;
	}

	int getV()
	{
		if (isBasic)
			return basic_value;
		if (isNULL)
			return 99999999;
		return DBL_COST * addNode.dbl + TPL_COST * addNode.tpl + ADD_COST * (length - 1);
	}

	optimal_DBC add(int dbl, int tpl, int coef)
	{
		if (isNULL)
			return *this;
		optimal_DBC<N> ret;
		ret.parent = this;
		ret.addNode.dbl = dbl;
		ret.addNode.tpl = tpl;
		ret.length = this->length + 1;
		if (coef == 1)
			ret.addNode.minus = false;
		else
			ret.addNode.minus = true;
		return ret;
	}

	void print(int type)
	{
		// type=0：latex格式
		// type=1：python格式
		if (isNULL && (!isBasic))
		{
			cout << isNULL << endl;
			cout << isBasic << endl;
			cout << "NULL" << endl;
			return;
		}
		simDBC();
		for (int i = 0; i < length; i++)
		{
			if (now_DBC[i].minus)
				cout << "-";
			else
				cout << "+";
			if(type==0)
				printf("2^{%d}3^{%d}", int(now_DBC[i].dbl), int(now_DBC[i].tpl));
			else if(type==1)
				printf("2**%d * 3**%d", int(now_DBC[i].dbl), int(now_DBC[i].tpl));
			// cout << "2^" << int(now_DBC[i].dbl) << "*3^" << int(now_DBC[i].tpl);
		}
		cout << endl;
		return;
	}

	void simDBC()
	{
		if (isBasic)
			return;
		optimal_DBC<N> *present = this;
		for (int i = length - 1; i >= 0; i--)
		{
			now_DBC[i].dbl = present->addNode.dbl;
			now_DBC[i].tpl = present->addNode.tpl;
			now_DBC[i].minus = present->addNode.minus;
			present = present->parent;
		}
	}
};

template <int N>
struct DBCGroup
{
	optimal_DBC<N> &operator()(int dbl, int tri)
	{
		return dbc[dbl + 1][tri + 1];
	}

	optimal_DBC<N> dbc[MAX_2+1][MAX_3+1];
};

extern DBCGroup<INTS> w, w_;
extern optimal_DBC<INTS> w_min;

int getOptimalDBC(myBigInt<INTS> n);
int getSubOptimalDBC(myBigInt<INTS> n, int dbc_coef);
int getEOSDBC(myBigInt<INTS> n);
#endif
