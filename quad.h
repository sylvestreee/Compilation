#ifndef __QUAD_H__
#define __QUAD_H__

#include "symbol.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// quad type
typedef struct quadS {
	char* op;
	symbol* arg1;
	symbol* arg2;
	symbol* res;
	struct quadS* next;
} quad;

// functions
quad* quadInit(char* op, symbol* arg1, symbol* arg2, symbol* res);
void quadFree(quad* q);
void quadAdd(quad** dest, quad* src);
void quadPrint(quad* q, FILE* outFile, char* rounding, char* library);
void listQuadPrint(quad* q, FILE* outFile, char* rounding, char* library);

#endif
