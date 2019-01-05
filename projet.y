%{
	#include <stdio.h>
	#include <string.h>
	#include "utils.h"
	#include "quad.h"
	#include "symbol.h"

	int yylex();
	void yyerror(char*);
	int compt = 0;

	FILE* yyin;
	FILE* out_file;
	symbol* symbolTable = NULL;

	char* library = "MPC";
	int num_precision = 128;
	char* rounding = "MPC_RNDZZ";
%}

%union {
	struct {
		struct symbolS* result;
		struct quadS* code;
	} codegen;

	char * string;

	char* text;
	float flottant;
	int entier_lex;
};

%token pragma
%token <text> retour
%token <text> bibli
%token <text> autre
%token <entier_lex> precision
%token <entier_lex> arrondi
%token <text> cst
%token <text> ID
%token <entier_lex> ENTIER
%token <flottant> n_flottant
%token <text> fonction
%token <text> '+' ';' '{' '}' '*' '=' '(' ')' '/' '-' ',' '>' '<' '!'

%type <codegen> E LIGNES L_PRAGMA
%type <text> TEXTE PONCT
%type <entier_lex> ENTIER_LEX
%type <string> OTHER

%start START
%left '+' '-'
%left '*' '/'
%left '<' '>'
%left '='
%left '(' ')' '{' '}'

%%

START : OTHER L_PRAGMA OTHER
	{
		printf("%s\n",$1);
	}
	;

L_PRAGMA :
	pragma bibli ARGUMENT ARGUMENT '{' LIGNES '}' retour
	{
		library = $2;

		symbolTablePrint(&symbolTable);
		initVariables(&symbolTable, out_file, library, num_precision, rounding);
		$$.code = $6.code;
		listQuadPrint($$.code, out_file, rounding, library);
		desallocVariables(&symbolTable, out_file, library);
	}

OTHER:
	PONCT OTHER
	{
		printf("ponct %s\n",$1 );
		printf("ponct 2%s\n", $2);
		$$ = strcat($1,$2);
	}
	| TEXTE OTHER
	{
		printf("texte  1 %s\n", $1);
		printf("texte 2 %s\n", $1);
		$$ = strcat($1,$2);
	}
	| TEXTE
	{
		printf("texte %s\n", $1);
		$$ = $1;
	}
	| ENTIER_LEX OTHER
	{
		char str[250];
		sprintf(str,"%d",$1);
		$$ = strcat(str,$2);
	}
	| n_flottant OTHER
	{
		char str[250];
		sprintf(str,"%f",$1);
		$$ = strcat(str,$2);
	}
	;

PONCT : '+'		| ';'	| '{'	| '}' 	| '*' 	| '='
		| '('	| ')'	| '/'	| '-' 	| ','	| '>'
		| '<'	| '!' ;

TEXTE : autre | retour | bibli | cst | ID | fonction ;

ENTIER_LEX : precision | arrondi | ENTIER ;

ARGUMENT :
	precision '(' ENTIER ')'
	{
		num_precision = $3;
	}

	| arrondi '(' cst ')'
	{
		rounding = $3;
	}
	;

LIGNES :
	retour E ';' retour LIGNES
	{
		$$.code = $2.code;
		quadAdd(&$$.code, $5.code);
	}

	| retour E ';' retour
	{
		$$.code = $2.code;
	}

	| E ';' retour LIGNES
	{
		$$.code = $1.code;
		quadAdd(&$$.code, $4.code);
	}

	| E ';' retour
	{
		$$.code = $1.code;
		$$.result = $1.result;
	}

	| E ';'
	{
		$$.code = $1.code;
		$$.result = $1.result;
	}
	;

E :
	// '-' E
	// {
	// 	// #TODO
	// }

	E '+' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code);
		quadAdd(&$$.code, quadInit('+', $1.result, $3.result, $$.result));
	}

	| E '-' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code);
		quadAdd(&$$.code, quadInit('-', $1.result, $3.result, $$.result));
	}

	| E '*' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code);
		quadAdd(&$$.code, quadInit('*', $1.result, $3.result, $$.result));
	}

	| E '/' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code);
		quadAdd(&$$.code, quadInit('/', $1.result, $3.result, $$.result));
	}

	| E '>' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code);
		quadAdd(&$$.code, quadInit('>', $1.result, $3.result, $$.result));
	}

	| E '<' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code);
		quadAdd(&$$.code, quadInit('<', $1.result, $3.result, $$.result));
	}

	| E '>''=' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $4.code);
		quadAdd(&$$.code, quadInit('s', $1.result, $4.result, $$.result));
	}

	| E '<''=' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $4.code);
		quadAdd(&$$.code, quadInit('i', $1.result, $4.result, $$.result));
	}

	| '(' E ')'
	{
		$$.result = $2.result;
		$$.code = $2.code;
	}
	| ID
	{
		// add ID only if it's not in symbol table
		symbol* newSymbol = symbolLookup(symbolTable, $1);
		if(newSymbol == NULL) {
			newSymbol = symbolAdd(&symbolTable, $1);
		}
		// get the initial name
		$$.result = newSymbol;
		$$.code = NULL;
	}
	| ENTIER
	{
		symbol* newSymbol = symbolNewTemp(&symbolTable);
		newSymbol->isConstant = true;
		newSymbol->value = $1;
		$$.result = newSymbol;
		$$.code = NULL;
	}
	;
%%

int main(int argc, char* argv[]) {

	if(argc == 2) {
		yyin = fopen(argv[1], "r");
		if(yyin == NULL) {
			printf("File doesn't exist\n");
			return 1;
		}

		// opens a file to write the result in it
		out_file = fopen("result.c", "w");
		yyparse();
		end_file(compt, out_file);
		fclose(out_file);

	} else {
		yyparse();
	}

	return 0;
}
