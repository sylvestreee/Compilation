%{
  #include <stdio.h>

  int yylex();
  void yyerror(char*);
  int compt = 0;

  FILE* yyin;
  FILE* out_file;

%}

%union
{
  char* text;
  float flottant;
  int entier_lex;
  void * none;
}

%token PRAGMA
%token <text> LIBRARY
%token <entier_lex> PRECISION
%token <entier_lex> ROUNDING
%token <text> CST
%token <text> ID
%token <entier_lex> ENTIER
%token <flottant> FLOTTANT
%token <text> FUNC

%type <none> ligne E F T

%start ligne
%left '+' '-'
%left '*' '/'
%left '(' ')' '{' '}'

%%
ligne : E '\n' { fprintf(out_file, "\n"); $$=$1;}
E : E '+' T		 { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_add(T,T,T, arrondi);\n");
					       //$$ = $1+$3;
               }
  | E '-' T    { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_sub(T,T,T, arrondi);\n");
  					     //$$ = $1-$3;
               }
  | T
  ;
T : T '*' F		 { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_mult(T,T,T, arrondi);\n");
                 //$$ = $1*$3;
               }
  | T '/' F    { fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_t T; mpc_init2(T, prec);\n"); compt++;
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_set_si(T,, arrondi);\n");
                 fprintf(out_file, "mpc_div(T,T,T, arrondi);\n");
  					     //$$ = $1/$3;
               }
  | F
  ;
F : '(' E ')'	 { fprintf(out_file," ");}
  | ENTIER     { fprintf(out_file, "entier\n"); }
  ;

%%

void end_file() {
  int i;
  for(i = 0; i < compt; i++) {
    fprintf(out_file, "mpc_clear(T%d)\n",i);
  }
}

int main(int argc, char* argv[]) {

  if(argc != 2) {
    printf("USAGE: projet [file_to_compile]\n");
    return 1;
  }

  yyin = fopen(argv[1], "r");
  if (yyin == NULL) {
    printf ("File doesn't exist\n");
    return 1;
  }

  // opens a file to write the result in it
  out_file = fopen("result.c", "w");
  yyparse();
  end_file();
  fclose(out_file);

  return 0;
}
