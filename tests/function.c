int main () {
	sqrt(2);
	#pragma MPC precision(128) rounding(MPC_RNDZZ) {
		int a = 3+4-2/2;
		a = sqrt(9);
		4+4;
		cos(42);
		pow(4);
	}
	int hello;
}
