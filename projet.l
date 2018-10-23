%{
	char* const MPFR = "MPFR";	
	char* const MPC = "MPC";
	
	char* library = NULL;
	int precision = 0;
	char * rounding = NULL;

	#include <stdlib.h>
  	#include <string.h>
  	#include "y.tab.h"
%}

PRAGMA			^#pragma
LIBRARY			MPFR|MPC
ARG_NAME		precision|rounding
ARG_VALUE		\([0-9A-Z_]*\)
BEGIN_SRC		\{
END_SRC			\}
SPACE			[ \t]
NEWLINE			[\n] 
IDENTIFIER		[a-zA-Z_][a-zA-Z_0-9]*
INTEGER			[0-9]+
FLOAT			[0-9]*\.[0-9]+
OPERATORS 		[()+*-/]
%%

{PRAGMA}		printf("PRAGMA ");
{LIBRARY}		{
					printf("LIBRARY ");
				}
{ARG_NAME}		printf("ARG_NAME ");
{ARG_VALUE}		printf("ARG_VALUE ");

{BEGIN_SRC}		printf("{");
{END_SRC}		printf("}");

{NEWLINE}		{return yytext[0];}

{BEGIN_SRC}.*{END_SRC} printf("SOURCE : %s : FIN SOURCE", yytext);

{IDENTIFIER} 	{return ID;}

{INTEGER}    	{ yylval=atoi(yytext); return ENTIER;}
{FLOAT}			{ yylval=atof(yytext); return FLOTTANT;}
{OPERATORS}    	{ return yytext[0]; }

.				printf("%s", yytext);
%%