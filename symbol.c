#include "symbol.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

symbol* symbolAlloc() {
	symbol* new = (symbol* )malloc(sizeof(symbol));
	return new;
}

void symbolFree(symbol* sym) {
	if(sym != NULL) {
		free(sym);
	}
}

symbol* symbolNewTemp(symbol** TS) {
	char buffer[1024];
	static int cptTemp = 0;
	snprintf(buffer, 1024, "T%d", cptTemp);
	cptTemp++;

	return symbolAdd(TS, buffer);
}

symbol* symbolLookup(symbol* TS, char* name) {
	while(TS) {
		if(strcmp(name, TS->id) == 0) {
			return TS;
		}
		TS = TS->next;
	}
	return NULL;
}

symbol* symbolAdd(symbol** TS, char* name) {
	symbol* new = symbolAlloc();
	new->id = strdup(name);

	if(*TS == NULL) {
		*TS = new;
		return* TS;
	} else {
		symbol* current = *TS;
		while(current->next != NULL) {
			current = current->next;
		}
		current->next = new;
	}
	return new;
}

void symbolTablePrint(symbol** TS) {
	printf("___________\n");
	printf("Symbol Table\n");

	if(*TS != NULL) {
		symbol* current = *TS;
		while(current->next != NULL) {
			symbolPrint(current);
			current = current->next;
		}
	}
	printf("___________\n");
}

void symbolPrint(symbol* sym) {
	printf("%s: %d%s\n",
		sym->id, sym->value, sym->isConstant == true ? "(CST)" : ""
	);
}

/**
 * Print all variables initialisations in a file
 * Args:
 * Table of symbols containing the temporary variables
 * File to complete
 */
void initVariables(symbol** TS, FILE* out_file, char* library, int precision, char* rounding) {
	char* prefixe = "mpc";
	if(strcmp(library, "MPFR") == 0) {
		prefixe = "mpfr";
	}

	if((*TS != NULL) && (out_file != NULL)) {
		symbol* current = *TS;

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

			// if it has a value, set it
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
	}
}
/**
 * Print all variables desallocations in a file
 * Args:
 * Table of symbols containing the temporary variables
 * File to complete
 */
void desallocVariables(symbol** TS, FILE* out_file, char* library) {
	char* prefixe = "mpc";
	if(strcmp(library, "MPFR") == 0) {
		prefixe = "mpfr";
	}

	if((*TS != NULL) && (out_file != NULL)) {
		symbol* current = *TS;

		while(current->next != NULL) {
			fprintf(
				out_file,
				"%s_clear(%s);\n",
				prefixe,
				current->id
			);

			current = current->next;
		}
	}
}
