%{
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"

	char* library = NULL;
	int num_precision = 0;
	char* rounding = NULL;
	// debug
	int displayTokens = 0;
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

{PRAGMA}		{
					if(displayTokens) printf("T:pragma\n");
					return pragma;
				}
{LIBRARY}		{
					if(displayTokens) printf("T:bibli\n");
					yylval.text=yytext;
					return bibli;
				}
{PRECISION}		{
					if(displayTokens) printf("T:precision\n");
					return precision;
				}
{ROUNDING}		{
					if(displayTokens) printf("T:arrondi\n");
					return arrondi;
				}
{FUNCTION}		{
					if(displayTokens) printf("T:fonction\n");
					yylval.text=yytext;
					return fonction;
				}
{CST}			{
					if(displayTokens) printf("T:cst\n");
					yylval.text=yytext;
					return cst;
				}
{IDENTIFIER} 	{
					if(displayTokens) printf("T:ID\n");
					yylval.text=yytext;
					return ID;
				}
{INTEGER}    	{
					if(displayTokens) printf("T:ENTIER\n");
					yylval.entier_lex=atoi(yytext);
					return ENTIER;
				}
{FLOAT}			{
					if(displayTokens) printf("T:n_flottant\n");
					yylval.flottant=atof(yytext);
					return n_flottant;
				}
{OPERATORS}   	{
					if(displayTokens) printf("T:%c\n", yytext[0]);
					return yytext[0];
				}

{SPACE}			{ }
{NEWLINE}		{
					if(displayTokens) printf("T:retour\n");
					return retour;
				}
.				{
					if(displayTokens) printf("T:autre\n");
					return autre;
				}
%%
