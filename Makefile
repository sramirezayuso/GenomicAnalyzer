LEX=flex
tpe1: lex.yy.c
	gcc -o tpe1 lex.yy.c -lfl
lex.yy.c:
	flex -Cfa tpe1.l
proteins: lex2.yy.c
	gcc -o proteins lex2.yy.c -lfl
lex2.yy.c:
	flex -Cfa proteins.l