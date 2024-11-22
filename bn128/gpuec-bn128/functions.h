//
// Created by occul on 2021/11/15.
//

#ifndef GPUEC_FUNCTIONS_H
#define GPUEC_FUNCTIONS_H

// DBC jiangze 2022/09/09
#include "DBC.h"
void init(int down_mode = 0);
inline const DBC& minL(const DBC& a, const DBC& b) {
	if (a.getL() < b.getL())
		return a;
	else
		return b;
}
inline const DBC& minL(const DBC& a, const DBC& b, const DBC& c) {
	int temp1 = a.getL();
	int temp2 = b.getL();
	int temp3 = c.getL();
	if (temp1 < temp2)
	{
		if (temp1 < temp3)
			return a;
		return c;
	}
	else
	{
		if (temp2 < temp3)
			return b;
		return c;
	}
}
inline const DBC& minV(const DBC& a, const DBC& b) {
	if (a.getV() < b.getV())
		return a;
	else
		return b;
}
inline const DBC& minV(const DBC& a, const DBC& b, const DBC& c) {
	int temp1 = a.getV();
	int temp2 = b.getV();
	int temp3 = c.getV();
	if (temp1 < temp2)
	{
		if (temp1 < temp3)
			return a;
		return c;
	}
	else
	{
		if (temp2 < temp3)
			return b;
		return c;
	}
}

#endif //GPUEC_FUNCTIONS_H
