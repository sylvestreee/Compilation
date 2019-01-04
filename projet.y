%{
  #include <stdio.h>
  #include "utils.h"
  #include "quad.h"
  #include "symbol.h"

  int yylex();
  void yyerror(char*);
  int compt = 0;

  FILE* yyin;
  FILE* out_file;
  symbol* symbolTable = NULL;

%}

%union {
  struct {
    struct symbolS* result;
    struct quadS* code;
  } codegen;

  char* text;
  float flottant;
  int entier_lex;
};

%token PRAGMA
%token <text> LIBRARY
%token <entier_lex> PRECISION
%token <entier_lex> ROUNDING
%token <text> CST
%token <text> ID
%token <entier_lex> ENTIER
%token <flottant> FLOTTANT
%token <text> FUNC

%type <codegen> E ligne

%start ligne
%left '+' '-'
%left '*' '/'
%left '(' ')' '{' '}'

%%

ligne : E '\n'
              {
                // $$=$1;
              }

E :
  '-' E
            {
              // #TODO
            }

  | E '+' E
            {
              $$.result = symbolNewTemp(&symbolTable);
              $$.code = $1.code;
              quadAdd(&$$.code, $3.code);
              quadAdd(&$$.code, quadInit('+', $1.result, $3.result, $$.result));
            }

  | E '*' E
            {
              $$.result = symbolNewTemp(&symbolTable);
              $$.code = $1.code;
              quadAdd(&$$.code, $3.code);
              quadAdd(&$$.code, quadInit('*', $1.result, $3.result, $$.result));
            }

  | '(' E ')'
            {
              $$.result = $2.result;
              $$.code = $2.code;
            }
  // | ID
  //   {
  //     struct symbol* newSymbol = symbolLookup(TdS, $1);
  //     if(newSymbol == NULL)
  //       newSymbol = symbolAdd(&TdS);
  //     $$.result = newSymbol;
  //     $$.code = NULL;
  //   }
  | ENTIER
            {
              symbol* newSymbol = symbolNewTemp(&symbolTable);
              // printf("Cet entier a comme id : %s\n", newSymbol->id);
              newSymbol->isConstant = true;
              newSymbol->value = $1;
              $$.result = newSymbol;
              $$.code = NULL;
            }
  ;

// ligne : E '\n' { fprintf(out_file, "\n"); $$=$1;}
// E : E '+' T		 { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_add(T,T,T, arrondi);\n");
// 					       //$$ = $1+$3;
//                }
//   | E '-' T    { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_sub(T,T,T, arrondi);\n");
//   					     //$$ = $1-$3;
//                }
//   | T
//   ;
// T : T '*' F		 { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_mult(T,T,T, arrondi);\n");
//                  //$$ = $1*$3;
//                }
//   | T '/' F    { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
//                  fprintf(out_file, "mpc_div(T,T,T, arrondi);\n");
//   					     //$$ = $1/$3;
//                }
//   | F
//   ;
// F : '(' E ')'	 { fprintf(out_file," ");}
//   | ENTIER     { fprintf(out_file, "entier\n"); }
//   ;

%%
