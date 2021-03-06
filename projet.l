%{
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"

	// debug
	int displayTokens = 0;
%}

PRAGMA		^[ \t]*#pragma
LIBRARY		MPFR|MPC
PRECISION	precision
ROUNDING	rounding
FUNCTION	sqrt|div|exp|log|sin|cos|tan|asin|acos|atan
POW			pow
CST			[A-Z_]*
SPACE		[ \t]+
NEWLINE		[\n]+
IDENTIFIER	[a-zA-Z_][a-zA-Z0-9_]*
INTEGER		[0-9]+
FLOAT		[0-9]*\.[0-9]+
OPERATORS 	[(){}+*-/=,;><!\.#]
TYPE 		int|float|char|double
HEADER 		^[ \t]*#include[ ]+<[A-Za-z_]+\.h>|^[ \t]*#include[ ]+"[A-Za-z_]+\.h"
%%

{PRAGMA}		{
					if(displayTokens) printf("T:pragma\n");
					return pragma;
				}
{LIBRARY}		{
					if(displayTokens) printf("T:bibli\n");
					yylval.text=strdup(yytext);
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
{POW}			{
					if(displayTokens) printf("T:pow\n");
					yylval.text=strdup(yytext);
					return pow;
				}
{FUNCTION}		{
					if(displayTokens) printf("T:fonction\n");
					yylval.text=strdup(yytext);
					return fonction;
				}
{TYPE}\**		{
					if(displayTokens) printf("T:type\n");
					yylval.text=strdup(yytext);
					return type;
				}
{CST}			{
					if(displayTokens) printf("T:cst\n");
					yylval.text=strdup(yytext);
					return cst;
				}
{IDENTIFIER} 	{
					if(displayTokens) printf("T:id\n");
					yylval.text=strdup(yytext);
					return id;
				}
{INTEGER}    	{
					if(displayTokens) printf("T:entier\n");
					yylval.entierLex=atoi(yytext);
					return entier;
				}
{FLOAT}			{
					if(displayTokens) printf("T:nFlottant\n");
					yylval.flottant=atof(yytext);
					return nFlottant;
				}
{OPERATORS}   	{
					if(displayTokens) printf("T:%c\n", yytext[0]);
					yylval.text=strdup(yytext);
					return yytext[0];
				}

{HEADER}		{
					if(displayTokens) printf("T:HEADER\n");
					yylval.text=strdup(yytext);
					return header;
				}

{SPACE}			{
					if(displayTokens) printf("T:space\n");
				}
{NEWLINE}		{
					if(displayTokens) printf("T:retour\n");
					return retour;
				}
.				{
					if(displayTokens) printf("T:autre\n");
					return autre;
				}
%%
