#ifndef __SYMBOL_H__
#define __SYMBOL_H__

#include <stdbool.h>
#include <stdio.h>

typedef struct symbolS {
	char *id;
	bool isConstant;
	int value;
	struct symbolS *next;
} symbol;

symbol* symbolAlloc();
void symbolFree(symbol* sym);
symbol* symbolNewTemp(symbol** TS);
symbol* symbolLookup(symbol* TS, char* name);
symbol* symbolAdd(symbol** TS, char* name);
void symbolTablePrint(symbol **TS);
void symbolPrint(symbol* sym);
void initVariables(symbol** TS, FILE* out_file, char* library, int precision);

#endif
