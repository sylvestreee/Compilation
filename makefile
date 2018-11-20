prefixe=main
prefixe_yacc=projet

all: y.tab.o lex.yy.o utils.o
	gcc utils.o y.tab.o lex.yy.o -ly -lfl -o $(prefixe)

y.tab.o: $(prefixe_yacc).y
	yacc -v -d $(prefixe_yacc).y
	gcc -c y.tab.c

lex.yy.o: $(prefixe_yacc).l y.tab.h
	lex $(prefixe_yacc).l
	gcc -c lex.yy.c

utils.o:
	gcc -c utils.c -o utils.o

clean:
	rm -f *.o y.tab.c y.tab.h lex.yy.c a.out $(prefixe) $(prefixe_yacc)
