%{
  #include <stdio.h>
  int yylex();
  void yyerror(char*);

  FILE* yyin;
  FILE* out_file;

%}

%token ID
%token ENTIER
%token FLOTTANT
%start ligne
%left '+' '-'
%left '*' '/'
%left '(' ')'

%%
ligne : E '\n' { fprintf(out_file, "\n"); $$=$1;}
E : E '+' T		 { 	fprintf(out_file, 	"mpc_t T0; mpc_init2(T0, prec);\nmpc_t T1; mpc_init2(T1, prec);\nmpc_t T2; mpc_init2(T2, prec);\nmpc_set_si(T0,%d, arrondi);\nmpc_set_si(T1,%d, arrondi);\nmpc_add(T0,T1,T2, arrondi)\n",$1,$3); 
					$$ = $1+$3;}
  | E '-' T    { fprintf(out_file, "mpc_sub(%d,%d,res, arrondi)\n",$1,$3); $$ = $1-$3; }
  | T
  ;
T : T '*' F		 { fprintf(out_file, "mpc_mult(%d,%d,res,arrondi)\n",$1,$3); $$= $1*$3;}
  | T '/' F    { fprintf(out_file, "mpc_div(%d,%d,res,arrondi)\n",$1,$3); $$= $1/$3;}
  | F
  ;
F : '(' E ')'	 { $$=$2;}
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
