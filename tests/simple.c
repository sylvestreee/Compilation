int main() {

	#pragma MPC precision(128) rounding(MPC_RNDZZ) {
		   ((4+4)*5)/8;
	}
}
