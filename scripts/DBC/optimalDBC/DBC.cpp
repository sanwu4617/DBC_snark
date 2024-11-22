#include "DBC.h"
#include "variables.h"
Chain::Chain() {
	dbl = 0;
	tpl = 0;
	minus = 0;
}
void Chain::setdata(unsigned char dbl, unsigned char tpl, bool minus)
{
	this->dbl = dbl;
	this->tpl = tpl;
	this->minus = minus;
}
DBC::DBC()
{
	isNULL = false;
	length = 0;
	parent = NULL;
	isBasic = false;
	basic_value = 0;
}
void DBC::setNULL()
{
	isNULL = true;
	length = 0;
}
int DBC::getL()
{
	if (isNULL)
		return 99999999;
	return length;
}
int DBC::getV()
{
	if (isBasic)
		return basic_value;
	if (isNULL)
		return 99999999;
	return dbl_cost * addNode.dbl + tpl_cost * addNode.tpl + add_cost * (length - 1);
}
DBC DBC::add(int dbl, int tpl, int coef)
{
	if (isNULL)
		return *this;
	DBC ret;
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
void DBC::print()
{
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
		printf("2^{%d}3^{%d}", int(now_DBC[i].dbl), int(now_DBC[i].tpl));
		//cout << "2^" << int(now_DBC[i].dbl) << "*3^" << int(now_DBC[i].tpl);
	}
	cout << endl;
	return;
}
void DBC::simDBC()
{
	if (isBasic)
		return;
	DBC* present = this;
	for (int i = length - 1; i >= 0; i--)
	{
		now_DBC[i].dbl = present->addNode.dbl;
		now_DBC[i].tpl = present->addNode.tpl;
		now_DBC[i].minus = present->addNode.minus;
		present = present->parent;
	}
}
DBC& DBC::operator =(int n)
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
		basic_value = now_DBC[length - 1].dbl * dbl_cost + add_cost * (length - 1);
	}
	isBasic = true;
	return *this;
}
DBC& DBC::operator =(BIGNUM* n)
{
	if (BN_is_zero(n))
	{
		return *this;
	}
	else
	{
		int bytes = BN_num_bytes(n);
		unsigned char temp[256] = { 0 };
		BN_bn2bin(n, temp);
		int flag = 0;
		int bit = 0;
		for (int i = bytes - 1; i >= 0; i--)
		{
			for (int j = 1; j < 256; j <<= 1)
			{
				if ((temp[i] & j) != 0)
				{
					now_DBC[flag++].setdata(bit, 0, false);
					//cout << bit << '\t';
				}
				bit++;
			}
		}
		length = flag;
		basic_value = now_DBC[length - 1].dbl * dbl_cost + (length - 1) * add_cost;
	}
	isBasic = true;
	return *this;
}
DBC& DBC::operator =(uint288 n)
{
	int flag = 0;
	int bit=0;
	for(int i=8;i>=0;i--)
	{
		for(uint64 j=1;j<=((uint64)1<<31);j<<=1)
		{
			if((n.data[i]&j)!=0)
			{
				now_DBC[flag++].setdata(bit,0,false);
			}
			bit++;
		}
	}
	length=flag;
	basic_value = now_DBC[length - 1].dbl * dbl_cost + add_cost * (length - 1);
	isBasic=true;
	return *this;
}
DBC& DBCGroup::operator()(int dbl, int tri)
{
	return dbc[dbl + 1][tri + 1];
}
