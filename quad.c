#include "quad.h"

/**
  * quadInit : initialize a quad
  * Params :
		* op : operator
		* arg1 : argument 1
		* arg2 : argument 2 (optional)
		* res : result of the op between arg1 and arg2 (
		* 		  if arg2 is NULL, res is the result of the op on arg1
  */
quad* quadInit(char op, symbol* arg1, symbol* arg2, symbol* res) {

	// memory allocation
	quad* new 	= (quad* )malloc(sizeof(quad));

	// affectation of the attributes
	new->arg1 	= arg1;
	new->arg2 	= arg2;
	new->op 	= op;
	new->res 	= res;
	new->next = NULL;

	return new;
}

/**
  * quadFree : free a quad
  * Params :
		* q : quad to free
  */
void quadFree(quad* q) {

	// memory deallocation
	free(q);
}

/**
  * quadAdd : add a quad to a list of quads
  * Params :
		* quadList : adress of a list of quads
		* newQuad : quad to add
  */
void quadAdd(quad** quadList, quad* newQuad) {

	// test if the parameters are not NULL
	if((newQuad != NULL) && (quadList != NULL)) {

		// if the list is empty
		if(quadList[0] == NULL) {
			quadList[0] = newQuad;
		} else {

			// add the new quad at the end of the list if not empty
			quad* current = quadList[0];

			// run through the list
			while(current->next != NULL) {
				current = current->next;
			}

			// add the new quad to the list
			current->next = newQuad;
			newQuad->next = NULL;
		}

		// DEBUG
		// printf("New quad: %d\n", i);
		// quadPrint(newQuad, NULL, "MPC_RNDZZ", "mpc");
		// fflush(stdout);
		// i++;
	}
}

/**
  * quadPrint : print a quad
  * Params :
		* q : quad to print
		* out_file : file where to print (optional),
		*						 if out_file is NULL, print is made in terminal
		* rounding : used rounding mode
		* library : used library (MPC or MPFR)
  */
void quadPrint(quad* q, FILE* out_file, char* rounding, char* library) {

	// default value of prefixe
	char* prefixe = "mpc";

	// test if the library is MPFR instead of MPC
	if(strcmp(library, "MPFR") == 0) {
		prefixe = "mpfr";
	}

	// test if the op concerns two arguments
	if(q->arg2 != NULL) {

		// print depends of the op
		switch(q->op) {

			// addition
			case '+' :
				if(out_file == NULL) {

					// file is NULL (=) print in terminal
					printf("%s_add(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				} else {

					// file is not NULL (=) print in file
					fprintf(out_file,
						"%s_add(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				}
				break;

			// substraction
			case '-' :
				if(out_file == NULL) {

					// file is NULL (=) print in terminal
					printf("%s_sub(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				} else {

					// file is not NULL (=) print in file
					fprintf(out_file,
						"%s_sub(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				}
				break;

			// multiplication
			case '*' :
				if(out_file == NULL) {

					// file is NULL (=) print in terminal
					printf("%s_mult(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				} else {

					// file is not NULL (=) print in file
					fprintf(out_file,
						"%s_mult(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				}
				break;

			// division
			case '/' :
				if(out_file == NULL) {

					// file is NULL (=) print in terminal
					printf("%s_div(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				} else {

					// file is not NULL (=) print in file
					fprintf(out_file,
						"%s_div(%s, %s, %s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id,
						q->res->id,
						rounding
					);
				}
				break;

			// inferior / superior / superior or equal / inferior or equal
			case '<' :
			case '>' :
			case 's' :
			case 'i' :
				if(out_file == NULL) {

					// file is NULL (=) print in terminal
					printf("%s_cmp(%s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id
					);
				} else {

					// file is not NULL (=) print in file
					fprintf(out_file,
						"%s_cmp(%s, %s)\n",
						prefixe,
						q->arg1->id,
						q->arg2->id
					);
				}
				break;

			// unknown operator
			default :
				if(out_file == NULL) {

					// file is NULL (=) print in terminal
					printf("%s = %s(%d) %c %s(%d)\n",
						q->res->id,
						q->arg1->id,q->arg1->value,
						q->op,
						q->arg2->id,q->arg2->value
					);
				} else {

					// file is not NULL (=) print in file
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

		// if the op concerns only one argument (=) print in terminal
		printf("%s = %c %s(%d)\n",
			q->res->id,
			q->op,
			q->arg1->id,q->arg1->value
		);
	}
}

/**
  * listQuadPrint : print a list of quads
  * Params :
		* q : quad used to run through the list of quads
		* out_file : file where to print (optional),
		*						 if out_file is NULL, print is made in terminal
		* rounding : used rounding mode
		* library : used library (MPC or MPFR)
  */
void listQuadPrint(quad *q, FILE* out_file, char* rounding, char* library) {

	// test if the quad is not NULL
	if(q != NULL) {
		quad* quad_temp = (quad* )malloc(sizeof(quad));
		quad_temp = q;

		// run through the list
		while(quad_temp != NULL) {
			quadPrint(quad_temp, out_file, rounding, library);
			quad_temp = quad_temp->next;
		}
	}
	fprintf(out_file, "\n");
}
