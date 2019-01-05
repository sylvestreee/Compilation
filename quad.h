#ifndef __QUAD_H__
#define __QUAD_H__

#include "symbol.h"
#include <stdio.h>

typedef struct quadS {
	char op;
	symbol* arg1;
	symbol* arg2;
	symbol* res;
	struct quadS *next;
} quad;

quad* quadInit(char op, symbol* arg1, symbol* arg2, symbol* res);
void quadFree(quad* q);
void quadAdd(quad** dest, quad* src);
void quadPrint(quad* q, FILE* out_file);
void listQuadPrint(quad* q, FILE* out_file);

#endif
