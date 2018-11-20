prefixe=main
prefixe_yacc=projet

all: y.tab.o lex.yy.o utils.o symbol.o quad.o
	gcc -g utils.o symbol.o quad.o y.tab.o lex.yy.o -ly -lfl -o $(prefixe)

y.tab.o: $(prefixe_yacc).y
	yacc -v -d $(prefixe_yacc).y
	gcc -c -g y.tab.c

lex.yy.o: $(prefixe_yacc).l y.tab.h
	lex $(prefixe_yacc).l
	gcc -c -g lex.yy.c

utils.o:
	gcc -c -g utils.c -o utils.o

symbol.o:
	gcc -c -g symbol.c -o symbol.o

quad.o:
	gcc -c -g quad.c -o quad.o

clean:
	rm -f *.o y.tab.c y.tab.h lex.yy.c a.out $(prefixe) $(prefixe_yacc)
