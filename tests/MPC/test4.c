#include <math.h>
//,
int main () {
	sqrt(2);
	#pragma MPC precision(128) rounding(MPC_RNDZZ) {
		exp(1);
		log(1);
		sin(0);
		tan(1);
		asin(1);
		acos(-1);
		atan(1);
	}
	int hello;
}
