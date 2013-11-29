LEX=flex
tpe1: lex.yy.c
	gcc -o tpe1 lex.yy.c -lfl
lex.yy.c:
	flex -Cfa tpe1.l