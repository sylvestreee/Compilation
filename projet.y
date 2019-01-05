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

	char* library = "MPC";
	int num_precision = 128;
	char* rounding = "MPC_RNDZZ";
%}

%union {
	struct {
		struct symbolS* result;
		struct quadS* code;
	} codegen;

	int character;
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

%type <codegen> E LIGNES L_PRAGMA
%type <text> TEXTE
// %type <character> PONCT
%type <entier_lex> ENTIER_LEX

%start START
%left '+' '-'
%left '*' '/'
%left '<' '>'
%left '='
%left '(' ')' '{' '}'

%%

START : L_PRAGMA OTHER | L_PRAGMA | OTHER;

L_PRAGMA :
	pragma bibli ARGUMENT ARGUMENT '{' retour LIGNES '}' retour
	{
		symbolTablePrint(&symbolTable);
		initVariables(&symbolTable, out_file, library, num_precision);
	}

OTHER:
	TEXTE OTHER
	| ENTIER_LEX OTHER
	| n_flottant OTHER
	/*| PONCT OTHER*/
	| L_PRAGMA
	| L_PRAGMA OTHER
	| retour
	;

TEXTE : autre | retour | bibli | cst | ID | fonction ;

ENTIER_LEX : precision | arrondi | ENTIER ;

// PONCT : '(';

ARGUMENT :
	precision '(' ENTIER ')'
	{
		//
	}

	| arrondi '(' cst ')'
	{
		//
	}
	;

LIGNES :
	E retour LIGNES
	{
		//
	}

	| E retour
	{
		//
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
		quadAdd(&$$.code, $3.code, out_file);
		quadAdd(&$$.code, quadInit('+', $1.result, $3.result, $$.result), out_file);
	}

	| E '-' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code, out_file);
		quadAdd(&$$.code, quadInit('-', $1.result, $3.result, $$.result), out_file);
	}

	| E '*' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code, out_file);
		quadAdd(&$$.code, quadInit('*', $1.result, $3.result, $$.result), out_file);
	}

	| E '/' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code, out_file);
		quadAdd(&$$.code, quadInit('/', $1.result, $3.result, $$.result), out_file);
	}

	| E '>' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code, out_file);
		quadAdd(&$$.code, quadInit('>', $1.result, $3.result, $$.result), out_file);
	}

	| E '<' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $3.code, out_file);
		quadAdd(&$$.code, quadInit('<', $1.result, $3.result, $$.result), out_file);
	}

	| E '>''=' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $4.code, out_file);
		quadAdd(&$$.code, quadInit('s', $1.result, $4.result, $$.result), out_file);
	}

	| E '<''=' E
	{
		$$.result = NULL;
		$$.code = $1.code;
		quadAdd(&$$.code, $4.code, out_file);
		quadAdd(&$$.code, quadInit('i', $1.result, $4.result, $$.result), out_file);
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
