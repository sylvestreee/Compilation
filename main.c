#include "y.tab.h"

int main(int argc, char* argv[]) {

  if(argc != 2) {
    printf("USAGE: projet [file_to_compile]\n");
    return 1;
  }

  yyin = fopen(argv[1], "r");
  if (yyin == NULL) {
    printf ("File doesn't exist\n");
    return 1;
  }

  // opens a file to write the result in it
  out_file = fopen("result.c", "w");
  yyparse();
  end_file(compt);
  fclose(out_file);

  return 0;
}
