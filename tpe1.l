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
SELE \{{ANY}+(?:,{ANY}+)+\}
SELU \{{ANY}+\}
REPE {SELU}\*
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
		int pos;
	} t_wbuff;

	int posChecker (int len, char* text);
	int posCheckerChar (int pos, char c);
	void writeBuffer (char* text, int len);
	void writeBufferChar (char c);
	int trim (char* text, int len);
	int singleSelector (int len, char* text);
	int doubleSelector (int len, char* text);
	int tripleSelector (int len, char* text);

	t_wbuff wbuff;
}

%x FINISHED

%%

<FINISHED>. {writeBufferChar('-'); fwrite(wbuff.text, wbuff.curr%wbuff.size, 1, yyout);}

-			writeBufferChar('\n');
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
{STOP} 				{fputs(wbuff.text, yyout); return 0;};
{SELE}{SELE}{SELE}	{yyless(tripleSelector(yyleng, yytext));};
{ANY}{SELE}{SELE}	{yyless(doubleSelector(yyleng, yytext));};
{SELE}{ANY}{SELE}	{yyless(doubleSelector(yyleng, yytext));};
{SELE}{SELE}{ANY}	{yyless(doubleSelector(yyleng, yytext));};
{SELE}{ANY}{ANY}	{yyless(singleSelector(yyleng, yytext));};
{ANY}{SELE}{ANY}	{yyless(singleSelector(yyleng, yytext));};
{ANY}{ANY}{SELE}	{yyless(singleSelector(yyleng, yytext));};
.	return -1;


%% 

void
swapSides (char* text, int i, int j) {
	for (i--, j--; i>=0 ;i--, j--)
		text[j]= text[i];
	return ;
}

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
	if (!(wbuff.curr%wbuff.size)){
		fputs(wbuff.text, yyout);
		wbuff.pos = 0;
		wbuff.text[0] = '\0';
	}
	wbuff.curr++;
	wbuff.text[wbuff.pos++] = c;
	wbuff.text[wbuff.pos] = '\0';
}

void
writeBuffer (char* text, int len) {
	int i;
	for (i=0; i<len ;i++)
		writeBufferChar(text[i]);
}

int
trim (char* text, int len) {
	int i, j, state;

	for (j=i=0, state=PRE; j<len ;j++) {

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

	swapSides(text, i, len);
	return len-i;
}

int
singleSelector (int len, char* text) {
	return trim(text, len);
}

int
doubleSelector (int len, char* text) {
	return trim(text, len); 
}

int
tripleSelector (int len, char* text) {
	return trim(text, len);
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
	yyin = fopen("input.txt", "r");
	yyout = fopen("output.txt", "w");;

	wbuff.size = WBUFF_SIZE;
	wbuff.curr = 0;
	wbuff.pos = 0;	
	wbuff.text = malloc(wbuff.size + 1);
	wbuff.text[0] = '\0';
}

int
main (int argc, char** argv) {
	init();

	if (checkStart())
		return -1;
	else
		return start();

}