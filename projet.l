%{
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"

	char* library = NULL;
	int precision = 0;
	char* rounding = NULL;
%}

PRAGMA			^#pragma
LIBRARY			MPFR|MPC
PRECISION		precision
ROUNDING		rounding
FUNCTION		sqrt|pow
CST					[A-Z_]*
SPACE				[ \t]
NEWLINE			[\n]
IDENTIFIER	[a-zA-Z_][a-zA-Z_0-9]*
INTEGER			[0-9]+
FLOAT				[0-9]*\.[0-9]+
OPERATORS 	[(){}+*-/=,;><!]
%%

{PRAGMA}			{ return PRAGMA;}
{LIBRARY}			{
								yylval.text=yytext;
								return LIBRARY;
							}
{PRECISION}		{ return PRECISION;}
{ROUNDING}		{ return ROUNDING;}
{FUNCTION}		{
								yylval.text=yytext;
								return FUNC;
							}
{CST}					{
								yylval.text=yytext;
								return CST;
							}
{IDENTIFIER} 	{
								yylval.text=yytext;
								return ID;
							}
{INTEGER}    	{
								yylval.entier_lex=atoi(yytext);
								return ENTIER;
							}
{FLOAT}				{
								yylval.flottant=atof(yytext);
								return FLOTTANT;
							}
{OPERATORS}   { return yytext[0];}

{SPACE}				{ printf("%s", yytext); }
{NEWLINE}			{ return yytext[0]; }
.							{ printf("%s", yytext); }
%%
