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

	/**
		makeQuadList : construct the list of the quad
		in order to print it in the file
		Params :
			* op : operator
			* arg1 : argument 1
			* arg2 : argument 2 (optional)
			* res : result of the op between arg1 and arg2
				(if arg2 is NULL, res is the result of the op on arg1)
	*/
	void makeQuadList(char* op, symbol* arg1, symbol* arg2, symbol* res) {
		if(firstQuad == 0) {
			tableQuad = quadInit(op, arg1, arg2, res);
			first = tableQuad;
			firstQuad = 1;
		} else {
			tableQuad->next = quadInit(op, arg1, arg2, res);
			tableQuad = tableQuad->next;
		}
	}
%}

%union {
	struct {
		struct symbolS* result;
		struct quadS* code;
	} codegen;

	char* text;
	float flottant;
	int entierLex;
};

%token pragma
%token <text> retour
%token <text> bibli
%token <text> autre
%token <entierLex> precision
%token <entierLex> arrondi
%token <text> cst
%token <text> id
%token <entierLex> entier
%token <flottant> nFlottant
%token <text> fonction
%token <text> pow
%token <text> type
%token <text> header
%token <text> '+' ';' '{' '}' '*' '=' '(' ')' '/' '-' ',' '>' '<' '!' '.' '#'

%type <codegen> E LIGNES L_PRAGMA
%type <text> TEXTE PONCT
%type <entierLex> entierLex
%type <text> OTHER L

%start START
%left '='
%left '+' '-'
%left '*' '/'
%left '<' '>'
%left '(' ')' '{' '}'

%%

//OTHER recognize and rewrite the text that is outside the pragma
//L_PRAGMA recognize the pragma
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
	//#pragma MPC|MPFR precision(entier) rounding(cst)
	//ARGUMENT recognize the precision and the rounding
	//LIGNES recognize the code inside the pragma
	pragma bibli ARGUMENT ARGUMENT '{' LIGNES '}' retour
	{
		// get the library to use
		library = $2;

		// debug : print the symbol table when it is fully built
		symbolTablePrint(&symbolTable);

		$$.code = $6.code;
	}

ARGUMENT :
	precision '(' entier ')'
	{
		numPrecision = $3;
	}

	| arrondi '(' cst ')'
	{
		rounding = $3;
	}
	;
/* ---------------------------------- */
/* Grammar before and after the pragma */
//L for multiples lines
OTHER: L retour OTHER
	{
		$$ = strcat(strcat($1, "\n"), $3);
	}
	| L retour;

L:
	//PONCT recognize all of the operator
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
	//TEXT recognize all type of text
	| TEXTE L
	{
		$$ = strcat(strcat($1," "),$2);
	}
	| TEXTE
	{
		$$ = strcat($1," ");
	}
	//entierLex recognize all int
	| entierLex L
	{
		char str[250];
		sprintf(str,"%d",$1);
		$$ = strcat(strcat(str," "),$2);
	}
	//nFlottant recognize all float
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

TEXTE : autre | bibli | cst | id | fonction | type | header;

entierLex : precision | arrondi | entier ;

/* -------------------------*/

/* Grammar that recognize the code inside the pragma */
/* All lignes must end with à ; */
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
		quadAdd(&$$.code, quadInit("neg", $2.result, NULL, $2.result));
		makeQuadList("neg", $2.result, NULL, $2.result);
	}
	| E '+' '+'
	{
		symbol* newSymbol = symbolNewTemp(&symbolTable);
		newSymbol->isConstant = true;
		newSymbol->value = 1;
		quadAdd(&$$.code, quadInit("+", $1.result, newSymbol, $1.result));
		makeQuadList("+", $1.result, newSymbol, $1.result);
	}
	| E '-' '-'
	{
		symbol* newSymbol = symbolNewTemp(&symbolTable);
		newSymbol->isConstant = true;
		newSymbol->value = 1;
		quadAdd(&$$.code, quadInit("-", $1.result, newSymbol, $1.result));
		makeQuadList("-", $1.result, newSymbol, $1.result);
	}
	| E '+' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("+", $1.result, $3.result, $$.result));
		makeQuadList("+", $1.result, $3.result, $$.result);
	}

	| E '-' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("-", $1.result, $3.result, $$.result));
		makeQuadList("-", $1.result, $3.result, $$.result);
	}

	| E '*' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("*", $1.result, $3.result, $$.result));
		makeQuadList("*", $1.result, $3.result, $$.result);
	}

	| E '/' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("/", $1.result, $3.result, $$.result));
		makeQuadList("/", $1.result, $3.result, $$.result);
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
		makeQuadList($1, $3.result, $5.result, $$.result);
	}

	| fonction '(' E ')'
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit($1, $3.result, NULL, $$.result));
		makeQuadList($1, $3.result, NULL, $$.result);
	}

	| type id '=' E
	{
		symbol* newSymbol = symbolLookup(symbolTable, $2);
		if(newSymbol == NULL) {
			newSymbol = symbolAdd(&symbolTable, $2);
		}
		$$.result = newSymbol;
		quadAdd(&$$.code, quadInit("=", $4.result, NULL, $$.result));
		makeQuadList("=", $4.result, NULL, $$.result);
	}

	| id '=' E
	{
		symbol* newSymbol = symbolLookup(symbolTable, $1);
		if(newSymbol == NULL) {
			newSymbol = symbolAdd(&symbolTable, $1);
		}
		$$.result = newSymbol;
		quadAdd(&$$.code, quadInit("=", $3.result, NULL, $$.result));
		makeQuadList("=", $3.result, NULL, $$.result);
	}

	| id
	{
		// add id only if it's not in symbol table
		symbol* newSymbol = symbolLookup(symbolTable, $1);
		if(newSymbol == NULL) {
			newSymbol = symbolAdd(&symbolTable, $1);
		}
		$$.result = newSymbol;
		$$.code = NULL;
	}
	| entier
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

		//free the quads
		quad* quadTemp = first;
		quad* quadTemp2;
		while(quadTemp != NULL) {
			quadTemp2 = quadTemp->next;
			quadFree(quadTemp);
			quadTemp = quadTemp2;
		}
	} else {
		yyparse();
	}

	return 0;
}
