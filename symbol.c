#include "symbol.h"

/**
  * symbolAlloc : allocate the memory for a symbol
  * Params : none
  */
symbol* symbolAlloc() {

	// memory allocation
	symbol* new = (symbol* )malloc(sizeof(symbol));
	return new;
}

/**
  * symbolFree : free a symbol
  * Params :
		* sym : symbol to free
  */
void symbolFree(symbol* sym) {
	if(sym != NULL) {

		// memory deallocation
		free(sym);
	}
}

/**
  * symbolNewTemp : create a new temporary variable
	* 								and add it to the symbole table
  * Params :
		* TS : adress of the symbol table
  */
symbol* symbolNewTemp(symbol** TS) {
	char buffer[1024];
	static int cptTemp = 0;
	snprintf(buffer, 1024, "T%d", cptTemp);
	cptTemp++;

	return symbolAdd(TS, buffer);
}

/**
  * symbolLookup : look if a symbol already exists or not
  * Params :
		* TS : symbol used to run through the symbol table
		* name : name of the symbol
  */
symbol* symbolLookup(symbol* TS, char* name) {

	// run through the symbol table
	while(TS) {
		if(strcmp(name, TS->id) == 0) {
			return TS;
		}
		TS = TS->next;
	}
	return NULL;
}

/**
  * symbolAdd : add a symbol to the symbol table
  * Params :
		* TS : adress of a symbol table
		* name : name of the symbol
  */
symbol* symbolAdd(symbol** TS, char* name) {
	symbol* new = symbolAlloc();
	new->id = strdup(name);

	// test if the symbol table is empty
	if(*TS == NULL) {
		*TS = new;
		return* TS;
	} else {
		symbol* current = *TS;

		// if the symbol table is not empty, run through it
		while(current->next != NULL) {
			current = current->next;
		}
		current->next = new;
	}
	return new;
}

/**
  * symbolTablePrint : print a symbol table
  * Params :
		* TS : adress of the symbol table to print
  */
void symbolTablePrint(symbol** TS) {
	printf("___________\n");
	printf("Symbol Table\n");

	// test if the table is not NULL
	if(*TS != NULL) {
		symbol* current = *TS;

		// run through the table
		while(current->next != NULL) {
			symbolPrint(current);
			current = current->next;
		}
		symbolPrint(current);
	}
	printf("___________\n");
}

/**
  * symbolPrint : print a symbol
  * Params :
		* sym : symbol to print
  */
void symbolPrint(symbol* sym) {
	printf("%s: %d%s\n",
		sym->id, sym->value, sym->isConstant == true ? "(CST)" : ""
	);
}

/**
  * initVariables : print all variables initialisations
  * Params :
		* TS : adress of the symbol table containing the temporary variables
		* out_file : file where to print
		* library : used library (MPC or MPFR)
		* precision : used precision
		* rouding : used rouding mode
  */
void initVariables(symbol** TS, FILE* out_file, char* library, int precision, char* rounding) {

	// default value of prefixe
	char* prefixe = "mpc";

	// test if the library is MPFR instead of MPC
	if(strcmp(library, "MPFR") == 0) {
		prefixe = "mpfr";
	}

	// test if the symbol table and the file are not NULL
	if((*TS != NULL) && (out_file != NULL)) {
		symbol* current = *TS;

		// run through the table
		while(current->next != NULL) {

			// create variable
			fprintf(
				out_file,
				"%s_t %s; %s_init2(%s, %d);\n",
				prefixe,
				current->id,
				prefixe,
				current->id,
				precision
			);

			// if the variable has a value, set it
			if(current->isConstant) {
				fprintf(
					out_file,
					"%s_set_si(%s, %d, %s);\n",
					prefixe,
					current->id,
					current->value,
					rounding
				);
			}

			fprintf(out_file, "\n");
			current = current->next;
		}

		// create variable (last symbol)
		fprintf(
			out_file,
			"%s_t %s; %s_init2(%s, %d);\n",
			prefixe,
			current->id,
			prefixe,
			current->id,
			precision
		);

		// if the variable has a value, set it (last symbol)
		if(current->isConstant) {
			fprintf(
				out_file,
				"%s_set_si(%s, %d, %s);\n",
				prefixe,
				current->id,
				current->value,
				rounding
			);
		}

		fprintf(out_file, "\n");
	}
}

/**
  * desallocVariables : print all variables desallocations
  * Params :
		* TS : adress of the symbol table containing the temporary variables
		* out_file : file where to print
		* library : used library (MPC or MPFR)
  */
void desallocVariables(symbol** TS, FILE* out_file, char* library) {

	// default value of prefixe
	char* prefixe = "mpc";

	// test if the library is MPFR instead of MPC
	if(strcmp(library, "MPFR") == 0) {
		prefixe = "mpfr";
	}

	// test if the symbol table and the file are not NULL
	if((*TS != NULL) && (out_file != NULL)) {
		symbol* current = *TS;

		// run through the table
		while(current->next != NULL) {
			fprintf(
				out_file,
				"%s_clear(%s);\n",
				prefixe,
				current->id
			);

			current = current->next;
		}

		// last symbol
		fprintf(
			out_file,
			"%s_clear(%s);\n",
			prefixe,
			current->id
		);
	}
}
