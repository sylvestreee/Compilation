%{
  #include <stdio.h>
  int yylex();
  void yyerror(char*);
%}

%token ID
%token ENTIER
%token FLOTTANT
%start ligne
%left '+' '-'
%left '*' '/'
%left '(' ')'

%%
ligne : E '\n' { printf ("\n"); $$=$1;}
E : E '+' T		 { printf("mpc_add(%d,%d,res, arrondi)\n",$1,$3); $$ = $1+$3;}
  | E '-' T    { printf("mpc_sub(%d,%d,res, arrondi)\n",$1,$3); $$ = $1-$3; }
  | T         
  ;
T : T '*' F		 { printf("mpc_mult(%d,%d,res,arrondi)\n",$1,$3); $$= $1*$3;}
  | T '/' F    { printf("mpc_div(%d,%d,res,arrondi)\n",$1,$3); $$= $1/$3;}
  | F         
  ;
F : '(' E ')'	 { $$=$2;}
  | ENTIER    
  ;

%%

int main() {
  printf("Entrez une chaine : \n");
  yyparse();
  printf("Au revoir\n");
  return 0;
}
