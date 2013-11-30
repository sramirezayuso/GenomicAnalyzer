#! /bin/bash
	
flex -Cfa aminoacids.l
gcc -o aminoacids lex.yy.c -lfl
flex -Cfa proteins.l
gcc -o proteins lex.yy.c -lfl
flex -Cfa phenotypes.l
gcc -o phenotypes lex.yy.c -lfl
