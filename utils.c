#include <stdio.h>
#include "utils.h"

/**
 * @TODO : description
 */
void end_file(int compt, FILE* out_file) {
	for(int i=0; i<compt; i++) {
		fprintf(out_file, "mpc_clear(T%d)\n", i);
	}
}
