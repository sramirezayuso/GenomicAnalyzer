#! /bin/bash
	
	flex -Cfa tpe1.l
	gcc -o tpe1 lex.yy.c -lfl
	flex -Cfa proteins.l
	gcc -o proteins lex.yy.c -lfl
	
