%{
  #include <stdio.h>
  
  int yylex();
  void yyerror(char*);

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
ligne : E '\n'     { fprintf(out_file, "\n");}
E : E '+' T		 { fprintf(out_file, "mpc_add(%d,%d,res, arrondi)\n",$1,$3);}
  | E '-' T    { fprintf(out_file, "mpc_sub(%d,%d,res, arrondi)\n",$1,$3); }
  | T
  ;
T : T '*' F		 { fprintf(out_file, "mpc_mult(%d,%d,res,arrondi)\n",$1,$3);}
  | T '/' F    { fprintf(out_file, "mpc_div(%d,%d,res,arrondi)\n",$1,$3);}
  | F
  ;
F : '(' E ')'	 { fprintf(out_file," ");}
  | ENTIER
  ;

%%

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
  fclose(out_file);

  return 0;
}
