#ifndef __SYMBOL_H__
#define __SYMBOL_H__

#include <stdbool.h>

typedef struct symbolS
{
    char *id;
    bool isConstant;
    int value;
    struct symbolS *next;
} symbol;

symbol* symbolAlloc();
void symbolFree(symbol*);
symbol* symbolNewTemp(symbol**);
symbol* symbolLookup(symbol*, char*);
symbol* symbolAdd(symbol**, char*);
void symbolTablePrint(symbol **TS);
void symbolPrint(symbol*);

#endif
