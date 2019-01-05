#include "quad.h"

#include <stdlib.h>
#include <stdio.h>

quad* quadInit(char op, symbol* arg1, symbol* arg2, symbol* res) {
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
void quadAdd(quad** quadList, quad* newQuad, FILE * out_file) {
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
		printf("New quad:\n");
		quadPrint(newQuad, out_file);
	}
}

/**
 * Print a quad : if out_file is NULL, print in terminal, else, in file
 * Args:
 * q the quad to print
 * out_file the optional file to use
 */
void quadPrint(quad* q, FILE* out_file) {
	if(q->arg2 != NULL) { // if 2 args
		switch(q->op) {
			case '+' :
				if(out_file == NULL) {
					printf("mpc_add(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				} else {
					fprintf(out_file,
						"mpc_add(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				}
				break;

			case '-' :
				if(out_file == NULL) {
					printf("mpc_sub(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				} else {
					fprintf(out_file,
						"mpc_sub(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				}
				break;

			case '*' :
				if(out_file == NULL) {
					printf("mpc_mult(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				} else {
					fprintf(out_file,
						"mpc_mult(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				}
				break;

			case '/' :
				if(out_file == NULL) {
					printf("mpc_div(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				} else {
					fprintf(out_file,
						"mpc_div(%s, %s, %s, arrondi)\n",
						q->arg1->id,
						q->arg2->id,
						q->res->id
					);
				}
				break;

			case '<' :
			case '>' :
			case 's' :
			case 'i' :
				if(out_file == NULL) {
					printf("mpc_cmp(%s, %s)\n",
						q->arg1->id,
						q->arg2->id
					);
				} else {
					fprintf(out_file,
						"mpc_cmp(%s, %s)\n",
						q->arg1->id,
						q->arg2->id
					);
				}
				break;

			default :
				if(out_file == NULL) {
					printf("%s = %s(%d) %c %s(%d)\n",
						q->res->id,
						q->arg1->id,q->arg1->value,
						q->op,
						q->arg2->id,q->arg2->value
					);
				} else {
					fprintf(out_file,
						"%s = %s(%d) %c %s(%d)\n",
						q->res->id,
						q->arg1->id,q->arg1->value,
						q->op,
						q->arg2->id,q->arg2->value
					);
				}
				break;
		}

	} else {
		printf("%s = %c %s(%d)\n",
			q->res->id,
			q->op,
			q->arg1->id,q->arg1->value
		);
	}
}

void listQuadPrint(quad *q, FILE* out_file) {
	if(q != NULL) {
		quad* quad_temp = (quad* )malloc(sizeof(quad));
		quad_temp = q;
		while(quad_temp != NULL) {
			quadPrint(quad_temp, out_file);
			quad_temp = quad_temp->next;
		}
	}
}
