#include "quad.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

quad* quadInit(char* op, symbol* arg1, symbol* arg2, symbol* res) {
	quad* new 	= (quad* )malloc(sizeof(quad));
	new->arg1 	= arg1;
	new->arg2 	= arg2;
	new->op 	= op;
	new->res 	= res;

	return new;
}

void quadFree(quad* q) {
	free(q);
}

/**
 * Add a quad to a list of quad
 * Params:
 * Adress of a list of quads
 * Quad to add
 */
void quadAdd(quad** quadList, quad* newQuad) {
	if((newQuad != NULL) && (quadList != NULL)) {
		// the list is empty
		if(quadList[0] == NULL) {
			quadList[0] = newQuad;

		} else {
			// add the new quad at the end of the lis
			quad* current = quadList[0];
			while(current->next != NULL) {
				current = current->next;
			}

			current->next = newQuad;
			newQuad->next = NULL;
		}

		// DEBUG
		// printf("New quad:\n");
		// quadPrint(newQuad, NULL);
	}
}

/**
 * Print a quad : if out_file is NULL, print in terminal, else, in file
 * Args:
 * q the quad to print
 * out_file the optional file to use
 */
void quadPrint(quad* q, FILE* out_file, char* rounding, char* library) {
	char* prefixe = "mpc";
	if(strcmp(library, "MPFR") == 0) {
		prefixe = "mpfr";
	}

	if(q->arg2 != NULL) { // if 2 args
		// ADDITION
		if(strcmp(q->op, "+") == 0) {
			if(out_file == NULL) {
				printf("%s_add(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			} else {
				fprintf(out_file,
					"%s_add(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			}

		// SUBSTRACTION
		} else if(strcmp(q->op, "-") == 0) {
			if(out_file == NULL) {
				printf("%s_sub(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			} else {
				fprintf(out_file,
					"%s_sub(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			}

		// MULTIPLICATION
		} else if(strcmp(q->op, "*") == 0) {
			if(out_file == NULL) {
				printf("%s_mult(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			} else {
				fprintf(out_file,
					"%s_mult(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			}

		// DIVISION
		} else if(strcmp(q->op, "/") == 0) {
			if(out_file == NULL) {
				printf("%s_div(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			} else {
				fprintf(out_file,
					"%s_div(%s, %s, %s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id,
					q->res->id,
					rounding
				);
			}

		// BOOLEANS
		} else if((strcmp(q->op, "<") == 0) || (strcmp(q->op, ">") == 0)
		 	|| (strcmp(q->op, "s") == 0) || (strcmp(q->op, "i") == 0)) {

			if(out_file == NULL) {
				printf("%s_cmp(%s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id
				);
			} else {
				fprintf(out_file,
					"%s_cmp(%s, %s)\n",
					prefixe,
					q->arg1->id,
					q->arg2->id
				);
			}

		// DEFAULT
		} else {
			if(out_file == NULL) {
				printf("%s = %s(%d) %s %s(%d)\n",
					q->res->id,
					q->arg1->id,q->arg1->value,
					q->op,
					q->arg2->id,q->arg2->value
				);
			} else {
				fprintf(out_file,
					"%s = %s(%d) %s %s(%d)\n",
					q->res->id,
					q->arg1->id,q->arg1->value,
					q->op,
					q->arg2->id,q->arg2->value
				);
			}
		}

	// FUNCTIONS
	} else {
		if(out_file == NULL) {
			printf("%s_%s(%s)\n",
				prefixe,
				q->op,
				q->arg1->id
			);
		} else {
			fprintf(out_file,
				"%s_%s(%s)\n",
				prefixe,
				q->op,
				q->arg1->id
			);
		}
	}
}

void listQuadPrint(quad *q, FILE* out_file, char* rounding, char* library) {
	if(q != NULL) {
		quad* quad_temp = (quad* )malloc(sizeof(quad));
		quad_temp = q;
		while(quad_temp != NULL) {
			quadPrint(quad_temp, out_file, rounding, library);
			quad_temp = quad_temp->next;
		}
	}
	fprintf(out_file, "\n");
}
