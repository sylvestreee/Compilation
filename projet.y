%{
	#include "utils.h"
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
%token <string> retour
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
%type <string> OTHER L

%start START
%left '+' '-'
%left '*' '/'
%left '<' '>'
%left '='
%left '(' ')' '{' '}'

%%

START : OTHER L_PRAGMA OTHER
	{
		if(out_file == NULL) {
			printf("%s\n", $1);
			printf("%s\n", $3);
		} else {
			// before the pragma
			if(strcmp(library, "MPC") == 0) {
				fprintf(out_file, "#include \"mpc.h\"\n");
			} else {
				fprintf(out_file, "#include <mpfr.h>\n");
			}
			fprintf(out_file, "%s\n\n", $1);

			// pragma content
			initVariables(&symbolTable, out_file, library, num_precision, rounding);
			listQuadPrint(first, out_file, rounding, library);
			desallocVariables(&symbolTable, out_file, library);

			// after the pragma
			fprintf(out_file, "\n%s\n", $3);
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
	| ENTIER_LEX L
	{
		char str[250];
		sprintf(str,"%d",$1);
		$$ = strcat(strcat(str," "),$2);
	}
	| n_flottant L
	{
		char str[250];
		sprintf(str,"%f",$1);
		$$ = strcat(strcat(str," "),$2);
	}
	;

PONCT : '+'		| ';'	| '{'	| '}' 	| '*' 	| '='
		| '('	| ')'	| '/'	| '-' 	| ','	| '>'
		| '<'	| '!' ;

TEXTE : autre| bibli | cst | ID | fonction ;

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
	// '-' E
	// {
	// 	// #TODO
	// }

	E '+' E
	{
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit("+", $1.result, $3.result, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit("+", $1.result, $3.result, $$.result);
			first = tableQuad;
			firstQuad =1;
		}
		else {
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
		}
		else {
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
		}
		else {
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
		}
		else {
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

	| fonction '(' E ')'
	{
		/* A MODIFIER */
		$$.result = symbolNewTemp(&symbolTable);
		quadAdd(&$$.code, quadInit($1, $3.result, NULL, $$.result));

		if(firstQuad == 0) {
			tableQuad = quadInit($1, $3.result, NULL, $$.result);
			first = tableQuad;
			firstQuad = 1;
		}
		else {
			tableQuad->next = quadInit($1, $3.result, NULL, $$.result);
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
		out_file = fopen("result.c", "w");
		yyparse();
		end_file(compt, out_file);
		fclose(out_file);

	} else {
		yyparse();
	}

	return 0;
}
