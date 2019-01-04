%{
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"

	char* library = NULL;
	int num_precision = 0;
	char* rounding = NULL;
%}

PRAGMA		^#pragma
LIBRARY		MPFR|MPC
PRECISION	precision
ROUNDING	rounding
FUNCTION	sqrt|pow
CST			[A-Z_]*
SPACE		[ \t]+
NEWLINE		[\n]+
IDENTIFIER	[a-zA-Z_][a-zA-Z0-9_]*
INTEGER		[0-9]+
FLOAT		[0-9]*\.[0-9]+
OPERATORS 	[(){}+*-/=,;><!]
%%

{PRAGMA}		{ return pragma;}
{LIBRARY}		{
					yylval.text=yytext;
					return bibli;
				}
{PRECISION}		{ return precision;}
{ROUNDING}		{ return arrondi;}
{FUNCTION}		{
					yylval.text=yytext;
					return fonction;
				}
{CST}			{
					yylval.text=yytext;
					return cst;
				}
{IDENTIFIER} 	{
					yylval.text=yytext;
					return ID;
				}
{INTEGER}    	{
					yylval.entier_lex=atoi(yytext);
					return ENTIER;
				}
{FLOAT}			{
					yylval.flottant=atof(yytext);
					return n_flottant;
				}
{OPERATORS}   	{ return yytext[0];}

{SPACE}			{ }
{NEWLINE}		{ return retour; }
.				{ printf("%s", yytext); }
%%
