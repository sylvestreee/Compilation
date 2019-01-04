#include "quad.h"

#include <stdlib.h>
#include <stdio.h>

quad *quadInit(char op, symbol *arg1, symbol *arg2, symbol *res) {
    quad *new = (quad *)malloc(sizeof(quad));
    new->arg1 = arg1;
    new->arg2 = arg2;
    new->op = op;
    new->res = res;

    return new;
}

void quadFree(quad *quad) {
    free(quad);
}

/**
 * Add a quad to a list of quad
 * Params:
 * Adress of a list of quads
 * Quad to add
 */
void quadAdd(quad **quadList, quad *newQuad) {
    if(newQuad != NULL && quadList != NULL)
    {
        // the list is empty
        if(quadList[0] == NULL) {
            quadList[0] = newQuad;

        } else {
            // add the new quad at the end of the lis
            quad *current = quadList[0];
            while (current->next != NULL) {
                current = current->next;
            }
            current->next = newQuad;
            newQuad->next = NULL;
        }

        // DEBUG
        printf("New quad:\n");
        quadPrint(newQuad);
    }
}

void quadPrint(quad *quad) {
    if(quad->arg2 != NULL) { // if 2 args
        printf("%s = %s(%d) %c %s(%d)\n",
            quad->res->id,
            quad->arg1->id,quad->arg1->value,
            quad->op,
            quad->arg2->id,quad->arg2->value
        );
    } else {
        printf("%s = %c %s(%d)\n",
            quad->res->id,
            quad->op,
            quad->arg1->id,quad->arg1->value
        );
    }
}
