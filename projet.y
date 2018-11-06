%{
  #include <stdio.h>
  int yylex();
  void yyerror(char*);
  int compt = 0;

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
E : E '+' T		 { fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-2),$1);
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-1),$3);
                 fprintf(out_file, "mpc_add(T%d,T%d,T%d, arrondi);\n",(compt-1),(compt-1),(compt-2));
					       $$ = $1+$3;
               }
  | E '-' T    { fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-2),$1);
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-1),$3);
                 fprintf(out_file, "mpc_sub(T%d,T%d,T%d, arrondi);\n",(compt-1),(compt-1),(compt-2));
  					     $$ = $1-$3;
               }
  | T
  ;
T : T '*' F		 { fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-2),$1);
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-1),$3);
                 fprintf(out_file, "mpc_mult(T%d,T%d,T%d, arrondi);\n",(compt-1),(compt-1),(compt-2));
                 $$ = $1*$3;
               }
  | T '/' F    { fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_t T%d; mpc_init2(T%d, prec);\n",compt,compt); compt++;
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-2),$1);
                 fprintf(out_file, "mpc_set_si(T%d,%d, arrondi);\n",(compt-1),$3);
                 fprintf(out_file, "mpc_div(T%d,T%d,T%d, arrondi);\n",(compt-1),(compt-1),(compt-2));
  					     $$ = $1/$3;
               }
  | F
  ;
F : '(' E ')'	 { $$=$2;}
  | ENTIER
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
