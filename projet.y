%{
	#include "quad.h"
	#include "symbol.h"

	int yylex();
	void yyerror(char*);
	int compt = 0;

	int firstQuad = 0;

	//list of quads
	quad* tableQuad = NULL;
	//first element of the list
	//save in order to print quads in the right order
	quad* first = NULL;

	FILE* yyin;
	FILE* outFile;
	symbol* symbolTable = NULL;

	char* library = "MPC";
	int numPrecision = 128;
	char* rounding = "MPC_RNDZZ";
%}

%union {
	struct {
		struct symbolS* result;
		struct quadS* code;
	} codegen;

	char* string;

	char* text;
	float flottant;
	int entierLex;
};

%token pragma
%token <string> retour
%token <text> bibli
%token <text> autre
%token <entierLex> precision
%token <entierLex> arrondi
%token <text> cst
%token <text> ID
%token <entierLex> ENTIER
%token <flottant> nFlottant
%token <text> fonction
%token <text> pow
%token <text> type
%token <text> header
%token <text> '+' ';' '{' '}' '*' '=' '(' ')' '/' '-' ',' '>' '<' '!' '.' '#'

%type <codegen> E LIGNES L_PRAGMA
%type <text> TEXTE PONCT
%type <entierLex> entierLex
%type <string> OTHER L

%start START
%left '='
%left '+' '-'
%left '*' '/'
%left '<' '>'
%left '(' ')' '{' '}'

%%

START : OTHER L_PRAGMA OTHER
	{
		if(outFile == NULL) {
			printf("%s\n", $1);
			printf("%s\n", $3);
		} else {
			// before the pragma
			if(strcmp(library, "MPC") == 0) {
				fprintf(outFile, "#include \"mpc.h\"\n");
			} else {
				fprintf(outFile, "#include <mpfr.h>\n");
			}
			fprintf(outFile, "%s\n\n", $1);

			// pragma content
			initVariables(&symbolTable, outFile, library, numPrecision, rounding);
			listQuadPrint(first, outFile, rounding, library);
			desallocVariables(&symbolTable, outFile, library);

			// after the pragma
			fprintf(outFile, "\n%s\n", $3);
		}
	}
	;

L_PRAGMA :
	pragma bibli ARGUMENT ARGUMENT '{' LIGNES '}' retour
	{
		// get the library to use
		library = $2;

		// debug : print the symbol table when it is fully built
		symbolTablePrint(&symbolTable);

		$$.code = $6.code;
	}

OTHER: L retour OTHER
	{
		$$ = strcat(strcat($1, "\n"), $3);
	}
	| L retour;

L:
	PONCT
	{
		$$ = $1;
	}
	| PONCT L
	{
		if((strncmp($1,"/",1) == 0) && (strncmp($2, "/",1) == 0)) {
			$$ = strcat($1, $2);
		} else if((strncmp($1,"/",1) == 0) && (strncmp($2, "*",1) == 0)) {
			$$ = strcat($1, $2);
		} else if((strncmp($1,"*",1) == 0) && (strncmp($2, "/",1) == 0)) {
			$$ = strcat($1, $2);
		} else if((strncmp($1,"#",1) == 0)) {
			$$ = strcat($1, $2);
		} else {
			$$ = strcat(strcat($1," "),$2);
		}
	}
	| TEXTE L
	{
		$$ = strcat(strcat($1," "),$2);
	}
	| TEXTE
	{
		$$ = strcat($1," ");
	}
	| entierLex L
	{
		char str[250];
		sprintf(str,"%d",$1);
		$$ = strcat(strcat(str," "),$2);
	}
	| nFlottant L
	{
		char str[250];
		sprintf(str,"%f",$1);
		$$ = strcat(strcat(str," "),$2);
	}
	;

PONCT :   '+'	| ';'	| '{'	| '}' 	| '*' 	| '='
		| '('	| ')'	| '/'	| '-' 	| ','	| '>'
		| '<'	| '!'	| '.'	| '#';

TEXTE : autre | bibli | cst | ID | fonction | type | header;

entierLex : precision | arrondi | ENTIER ;

ARGUMENT :
	precision '(' ENTIER ')'
	{
		numPrecision = $3;
	}

	| arrondi '(' cst ')'
	{
		rounding = $3;
	}
	;

LIGNES :
	retour E ';' retour LIGNES
	{}
	| retour E ';' retour
	{}
	| E ';' retour LIGNES
	{}
	| E ';' retour
	{}
	| E ';'
	{}
	;

E :
	'-' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("neg", $2.result, NULL, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("neg", $2.result, NULL, $$.result);
			first = tableQuad;
			firstQuad =1;
		}
		else {
			tableQuad->next = quadInit("neg", $2.result, NULL, $$.result);
			tableQuad = tableQuad->next;
		}
	}
	| E '+' '+'
	{
		symbol* newSymbol = symbolNewTemp(&symbolTable);
		newSymbol->isConstant = true;
		newSymbol->value = 1;
		quadAdd(&$$.code, quadInit("+", $1.result, newSymbol, $1.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("+", $1.result, newSymbol, $1.result);
			first = tableQuad;
			firstQuad =1;
		} else {
			tableQuad->next = quadInit("+", $1.result, newSymbol, $1.result);
			tableQuad = tableQuad->next;
		}

	}
	| E '-' '-'
	{
		symbol* newSymbol = symbolNewTemp(&symbolTable);
		newSymbol->isConstant = true;
		newSymbol->value = 1;
		quadAdd(&$$.code, quadInit("-", $1.result, newSymbol, $1.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("-", $1.result, newSymbol, $1.result);
			first = tableQuad;
			firstQuad =1;
		} else {
			tableQuad->next = quadInit("-", $1.result, newSymbol, $1.result);
			tableQuad = tableQuad->next;
		}

	}
	| E '+' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("+", $1.result, $3.result, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("+", $1.result, $3.result, $$.result);
			first = tableQuad;
			firstQuad =1;
		} else {
			tableQuad->next = quadInit("+", $1.result, $3.result, $$.result);
			tableQuad = tableQuad->next;
		}

	}

	| E '-' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("-", $1.result, $3.result, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("-", $1.result, $3.result, $$.result);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit("-", $1.result, $3.result, $$.result);
			tableQuad = tableQuad->next;
		}
	}

	| E '*' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("*", $1.result, $3.result, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("*", $1.result, $3.result, $$.result);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit("*", $1.result, $3.result, $$.result);
			tableQuad = tableQuad->next;
		}
	}

	| E '/' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("/", $1.result, $3.result, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("/", $1.result, $3.result, $$.result);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit("/", $1.result, $3.result, $$.result);
			tableQuad = tableQuad->next;
		}
	}

	| E '>' E
	{
		$$.result = NULL;
		quadAdd(&$$.code, quadInit(">", $1.result, $3.result, $$.result));
	}

	| E '<' E
	{
		$$.result = NULL;
		quadAdd(&$$.code, quadInit("<", $1.result, $3.result, $$.result));
	}

	| E '>''=' E
	{
		$$.result = NULL;
		quadAdd(&$$.code, quadInit("s", $1.result, $4.result, $$.result));
	}

	| E '<''=' E
	{
		$$.result = NULL;
		quadAdd(&$$.code, quadInit("i", $1.result, $4.result, $$.result));
	}

	| '(' E ')'
	{
		$$.result = $2.result;
		$$.code = $2.code;
	}

	| pow '(' E ',' E ')'
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit($1, $3.result, $5.result, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit($1, $3.result, $5.result, $$.result);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit($1, $3.result, $5.result, $$.result);
			tableQuad = tableQuad->next;
		}
	}

	| fonction '(' E ')'
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit($1, $3.result, NULL, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit($1, $3.result, NULL, $$.result);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit($1, $3.result, NULL, $$.result);
			tableQuad = tableQuad->next;
		}
	}

	| type ID '=' E
	{
		symbol* newSymbol = symbolLookup(symbolTable, $2);
		if(newSymbol == NULL) {
			newSymbol = symbolAdd(&symbolTable, $2);
		}
		$$.result = newSymbol;
		quadAdd(&$$.code, quadInit("=", $4.result, NULL, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("=", $4.result, NULL, $$.result);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit("=", $4.result, NULL, $$.result);
			tableQuad = tableQuad->next;
		}
	}

	| ID '=' E
	{
		symbol* newSymbol = symbolLookup(symbolTable, $1);
		if(newSymbol == NULL) {
			newSymbol = symbolAdd(&symbolTable, $1);
		}
		$$.result = newSymbol;
		quadAdd(&$$.code, quadInit("=", $3.result, NULL, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("=", $3.result, NULL, $$.result);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit("=", $3.result, NULL, $$.result);
			tableQuad = tableQuad->next;
		}
	}

	| ID
	{
		// add ID only if it's not in symbol table
		symbol* newSymbol = symbolLookup(symbolTable, $1);
		if(newSymbol == NULL) {
			newSymbol = symbolAdd(&symbolTable, $1);
		}
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
		outFile = fopen("result.c", "w");
		yyparse();
		fclose(outFile);

	} else {
		yyparse();
	}

	return 0;
}
