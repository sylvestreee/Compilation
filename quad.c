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
quad* quadInit(char* op, symbol* arg1, symbol* arg2, symbol* res) {

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
		* outFile : file where to print (optional),
		*						 if outFile is NULL, print is made in terminal
		* rounding : used rounding mode
		* library : used library (MPC or MPFR)
  */
void quadPrint(quad* q, FILE* outFile, char* rounding, char* library) {

	// default value of prefixe
	char* prefixe = "mpc";

	// test if the library is MPFR instead of MPC
	if(strcmp(library, "MPFR") == 0) {
		prefixe = "mpfr";
	}

	// test if the op concerns two arguments
	if(q->arg2 != NULL) {

		// print depends of the op

		// addition
		if(strcmp(q->op, "+") == 0) {
			if(outFile == NULL) {
				// file is NULL (=) print in terminal
				printf("%s_add(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			} else {
				// file is not NULL (=) print in file
				fprintf(outFile,
					"%s_add(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			}
		// substraction
		} else if(strcmp(q->op, "-") == 0) {
			if(outFile == NULL) {
				// file is NULL (=) print in terminal
				printf("%s_sub(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			} else {
				// file is not NULL (=) print in file
				fprintf(outFile,
					"%s_sub(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			}
			// multiplication
		} else if(strcmp(q->op, "*") == 0) {
			if(outFile == NULL) {
				// file is NULL (=) print in terminal
				printf("%s_mul(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			} else {
				// file is not NULL (=) print in file
				fprintf(outFile,
					"%s_mul(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			}
		// division
		} else if(strcmp(q->op, "/") == 0) {
			if(outFile == NULL) {
				// file is NULL (=) print in terminal
				printf("%s_div(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			} else {
				// file is not NULL (=) print in file
				fprintf(outFile,
					"%s_div(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			}
		// inferior / superior / superior or equal / inferior or equal
		} else if((strcmp(q->op, "<") == 0) || (strcmp(q->op, ">") == 0)
		|| (strcmp(q->op, "s") == 0) || (strcmp(q->op, "i") == 0)) {
			if(outFile == NULL) {

				// file is NULL (=) print in terminal
				printf("%s_cmp(%s, %s);\n",
					prefixe,
					q->arg1->id,
					q->arg2->id
				);
			} else {

				// file is not NULL (=) print in file
				fprintf(outFile,
					"%s_cmp(%s, %s);\n",
					prefixe,
					q->arg1->id,
					q->arg2->id
				);
			}
		} else if(strcmp(q->op, "pow") == 0) {
			if(outFile == NULL) {
				// file is NULL (=) print in terminal
				printf("%s_pow(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			} else {
				// file is not NULL (=) print in file
				fprintf(outFile,
					"%s_pow(%s, %s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					q->arg2->id,
					rounding
				);
			}
		// unknown operator
		} else {
			if(outFile == NULL) {

				// file is NULL (=) print in terminal
				printf("%s = %s(%d) %s %s(%d)\n",
					q->res->id,
					q->arg1->id,q->arg1->value,
					q->op,
					q->arg2->id,q->arg2->value
				);
			} else {

				// file is not NULL (=) print in file
				fprintf(outFile,
					"%s = %s(%d) %s %s(%d)\n",
					q->res->id,
					q->arg1->id,q->arg1->value,
					q->op,
					q->arg2->id,q->arg2->value
				);
			}
		}

	// one argument
	} else {

		if(strcmp(q->op, "=") == 0)  {
			if(outFile == NULL) {
				printf("%s_set(%s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					rounding
				);
			} else {
				fprintf(
					outFile,
					"%s_set(%s, %s, %s);\n",
					prefixe,
					q->res->id,
					q->arg1->id,
					rounding
				);
			}
		// FUNCTIONS
		} else {
			if(outFile == NULL) {
				printf("%s_%s(%s, %s, %s);\n",
					prefixe,
					q->op,
					q->res->id,
					q->arg1->id,
					rounding
				);
			} else {
				fprintf(outFile,
					"%s_%s(%s, %s, %s);\n",
					prefixe,
					q->op,
					q->res->id,
					q->arg1->id,
					rounding
				);
			}
		}
	}
}

/**
  * listQuadPrint : print a list of quads
  * Params :
		* q : quad used to run through the list of quads
		* outFile : file where to print (optional),
		*						 if outFile is NULL, print is made in terminal
		* rounding : used rounding mode
		* library : used library (MPC or MPFR)
  */
void listQuadPrint(quad* q, FILE* outFile, char* rounding, char* library) {

	// test if the quad is not NULL
	if(q != NULL) {
		quad* quadTemp = (quad* )malloc(sizeof(quad));
		quadTemp = q;

		// run through the list
		while(quadTemp != NULL) {
			quadPrint(quadTemp, outFile, rounding, library);
			quadTemp = quadTemp->next;
		}
	}
	fprintf(outFile, "\n");
}
