#include "symbol.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

symbol* symbolAlloc() {
    symbol *new = (symbol*)malloc(sizeof(symbol));
    return new;
}

void symbolFree(symbol *sym) {
    if(sym != NULL) {
        free(sym);
    }
}

symbol* symbolNewTemp(symbol **TS) {
    char buffer[1024];
    static int cptTemp = 0;
    snprintf(buffer, 1024, "temp_%d", cptTemp);
    cptTemp++;

    return symbolAdd(TS, buffer);
}

symbol* symbolLookup(symbol *TS, char *name) {
    while(TS) {
        if(strcmp(name,TS->id) == 0) {
            return TS;
        }
        TS = TS->next;
    }
    return NULL;
}

symbol *symbolAdd(symbol **TS, char *name) {
    symbol *new = symbolAlloc();
    new->id = strdup(name);

    if(*TS == NULL) {
        *TS = new;
        return *TS;
    } else {
        symbol *current = *TS;
        while(current->next != NULL) {
            current = current->next;
        }
        current->next = new;
    }
    return new;
}

void symbolTablePrint(symbol **TS) {
    printf("___________\n");
    printf("Symbol Table\n");
    
    if(*TS != NULL) {
        symbol *current = *TS;
        while(current->next != NULL) {
            symbolPrint(current);
            current = current->next;
        }
    }
    printf("___________\n");
}

void symbolPrint(symbol *sym) {
    printf("%s: %d%s\n",
        sym->id, sym->value, sym->isConstant == true ? "(CST)" : ""
    );
}
