int main() {
	//
	#pragma MPFR precision(128) rounding(MPFR_RNDN) {
		(3+(4*5))*(67/5);
		6*(9/7);
		45-3;
		7*(4/7+12-(56*5));
	}
	//
	//45-3;
}
