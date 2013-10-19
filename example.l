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

%top{
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

	int posChecker (int len, char* text);
	int posCheckerChar (int pos, char c);
	void writeBuffer (char* text, int len);
	void writeBufferChar (char c);
	void trim (char* text, int *len);
	int singleSelector (int *len, char* text);
	int doubleSelector (int *len, char* text);
	int tripleSelector (int *len, char* text);

	t_wbuff wbuff;
}

%%
.	 		writeBuffer("|JUNK|", 6);
{ISOL}		writeBufferChar('I');
{LEUC}		writeBufferChar('L');
{VALI}		writeBufferChar('V');
{PHEN}		writeBufferChar('F');
{METH}		writeBufferChar('M');
{CYST}		writeBufferChar('C');
{ALAN}		writeBufferChar('A');
{GLYC}		writeBufferChar('G');
{PROL}		writeBufferChar('P');
{THRE}		writeBufferChar('T');
{SERI}		writeBufferChar('S');
{TYRO}		writeBufferChar('Y');
{TRYP}		writeBufferChar('W');
{GLUT}		writeBufferChar('Q');
{ASPA}		writeBufferChar('N');
{HIST}		writeBufferChar('H');
{GLUA}		writeBufferChar('E');
{ASPR}		writeBufferChar('D');
{LYST}		writeBufferChar('K');
{ARGI}		writeBufferChar('R');
{POS}{ANY}			{if(!posChecker(yyleng, yytext)) return -1;};
{POS}{SELE}			{;};
{REPN}				{;};
{STOP} 				{fwrite(wbuff.text, wbuff.curr%wbuff.size, 1, yyout); return 0;};
{SELE}{SELE}{SELE}	{tripleSelector(&yyleng, yytext); yyless(0);};
{ANY}{SELE}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
{SELE}{ANY}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
{SELE}{SELE}{ANY}	{doubleSelector(&yyleng, yytext); yyless(0);};
{SELE}{ANY}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
{ANY}{SELE}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
{ANY}{ANY}{SELE}	{singleSelector(&yyleng, yytext); yyless(0);};

%%

int
posCheckerChar (int pos, char c) {
	if (wbuff.curr>=pos && wbuff.text[pos]==c)
		return TRUE;
	return FALSE;
}

int
posChecker (int len, char* text) {
	return posCheckerChar(atoi(text+1), text[len-1]);
}

void
writeBufferChar (char c) {
	if (!(wbuff.curr%wbuff.size))
		fwrite(wbuff.text, wbuff.curr, 1, yyout);
	wbuff.text[wbuff.curr++] = c;
}

void
writeBuffer (char* text, int len) {
	int i;
	for (i=0; i<len ;i++)
		writeBufferChar(text[i]);
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