LEX=flex
tpe1: lex.yy.c
	gcc -o tpe1 lex.yy.c -lfl
lex.yy.c:
	flex tpe1.l