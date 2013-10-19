ISOL ATT|ATC|ATA
LEUC CTT|CTC|CTA|CTG|TTA|TTG
VALI GTT|GTC|GTA|GTG
PHEN TTT|TTC
METH ATG
CYST TGT|TGC
ALAN GCT|GCC|GCA|GCG
GLYC GGT|GGC|GGA|GGG
PROL CCT|CCC|CCA|CCG
THRE ACT|ACC|ACA|ACG
SERI TCT|TCC|TCA|TCG|AGT|AGC
TYRO TAT|TAC
TRYP TGG
GLUT CAA|CAG
ASPA AAT|AAC
HIST CAT|CAC
GLUA GAA|GAG
ASPR GAT|GAC
LYST AAA|AAG
ARGI CGT|CGC|CGA|CGG|AGA|AGG
STOP TAA|TAG|TGA|STOP
ANY  [ATCG]
SELE \{.*\}
REPE {SELE}\*
NUM  [0-9]
POS  \[{NUM}+\]
REPN {REPE}{POS}

%%
.	 	write("JUNK", 4);
{ISOL}	write('I');
{LEUC}	write('L');
{VALI}	write('V');
{PHEN}	write('F');
{METH}	write('M');
{CYST}	write('C');
{ALAN}	write('A');
{GLYC}	write('G');
{PROL}	write('P');
{THRE}	write('T');
{SERI}	write('S');
{TYRO}	write('Y');
{TRYP}	write('W');
{GLUT}	write('Q');
{ASPA}	write('N');
{HIST}	write('H');
{GLUA}	write('E');
{ASPR}	write('D');
{LYST}	write('K');
{ARGI}	write('R');
{POS}{ANY}			{if(!posChecker(yyleng, yytext)) return -1;}
{POS}{SELE}			{}
{REPN}				{}
{STOP} 				{clear(); return 0;}
{SELE}{SELE}{SELE}	{tripleSelector(&yyleng, yytext); yyless(0);};
{ANY}{SELE}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
{SELE}{ANY}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
{SELE}{SELE}{ANY}	{doubleSelector(&yyleng, yytext); yyless(0);};
{SELE}{ANY}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
{ANY}{SELE}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
{ANY}{ANY}{SELE}	{singleSelector(&yyleng, yytext); yyless(0);};

%%
#include <stdio.h>
#include <stdlib.h>

#define TRUE 1
#define FALSE !TRUE
#define WBUFF_SIZE 1024
#define VALID_CHAR(c) ((c)=='A' || (c)=='T' || (c)=='C' || (c)=='G')?(TRUE):(FALSE)

typedef enum {PRE, FIRST_IN, OTHERS_IN, POST} state;

typedef struct {
	char* text;
	int size;
	int curr;
} t_wbuff;

t_wbuff wbuff;

int
posChecker (int len, char* text) {
	return posChecker(atoi(text+1), text[len-1]);
}

int
posChecker (int pos, char c) {
	if (wbuff.curr>=pos && wbuff.text[pos]==c)
		return TRUE;
	return FALSE;
}

void
write (char c) {
	if (!(wbuff.curr%wbuff.size))
		fwrite(wbuff.text, wbuff.curr, 1, yyout);
	wbuff.text[wbuff.curr++] = c;
}

void
write (char* text, int len) {
	int i;
	for (i=0; i<len ;i++)
		write(text[i]);
}

void
trim (char* text, int *len) {
	int i, j, state;

	for (j=i=0, state=PRE; j<*len ;j++) {

		switch (state) {
			case PRE:
				if (text[j]=='{')
					state= FIRST_IN;
				else if (VALID_CHAR(text[j])) {
					text[i]=text[j];
					i++;
				}
				break;
			case FIRST_IN:
				if (text[j]==',')
					state= OTHERS_IN;
				else if (VALID_CHAR(text[j])) {
					text[i]=text[j];
					i++;
				}
				break;
			case OTHERS_IN:
				if (text[j]=='}')
					state= POST;
				break;
			case POST:
				if (VALID_CHAR(text[j])) {
					text[i]=text[j];
					i++;
				} else if (text[j]=='{')
					state= FIRST_IN;
				break;
		}
	}
	*len=i;
	return ;
}

int
singleSelector (int *len, char* text) {
	trim(text, len);
	return 0;
}

int
doubleSelector (int *len, char* text) {
	trim(text, len);
	return 0;
}

int
tripleSelector (int *len, char* text) {
	trim(text, len);
	return 0;
}

int
start (void) {
	yylex();
	return 0;
}

int
checkStart (void) {
	char buff[3];
	fread(buff, sizeof(char), 3, yyin);
	return strcmp(buff, "AUG");
}

void
init (void) {
	yyin=stdin;
	yyout=stdout;

	wbuff.size = WBUFF_SIZE;
	wbuff.curr = 0;
	wbuff.text = malloc(wbuff.size);
}

int
main (int argc, char** argv) {
	init();

	if (checkStart())
		return -1;
	else
		return start();

}