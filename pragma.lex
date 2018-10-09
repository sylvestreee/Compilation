%{
	char* const MPFR = "MPFR";	
	char* const MPC = "MPC";
	
	char* library = NULL;
	int precision = 0;
	char * rounding = NULL;

%}

PRAGMA			^#pragma
LIBRARY			MPFR|MPC
ARG_NAME		precision|rounding
ARG_VALUE		\([0-9A-Z_]*\)
BEGIN_SRC		\{
END_SRC			\}
SPACE			[ \t]
NEWLINE			[ \n]

%%

{PRAGMA}		printf("PRAGMA ");
{LIBRARY}		{
					printf("LIBRARY ");
				}
{ARG_NAME}		printf("ARG_NAME ");
{ARG_VALUE}		printf("ARG_VALUE ");

{BEGIN_SRC}		printf("{");
{END_SRC}		printf("}");

{NEWLINE}		printf("\n");

{BEGIN_SRC}.*{END_SRC} printf("SOURCE : %s : FIN SOURCE", yytext);

.				printf("%s", yytext);

%%

int main() {
	yylex();
	return 0;
}
