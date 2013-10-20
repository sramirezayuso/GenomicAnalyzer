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
	#define IN_BUFF(pos) ( ((pos) <= wbuff.curr) && ((pos) >= (wbuff.curr -wbuff.curr%WBUFF_SIZE)))?(TRUE):(FALSE)

	typedef enum {PRE_OUT, PRE_IN, CHOICE, POST_IN} state;

	typedef struct {
		char text[WBUFF_SIZE];
		int choicebuff[WBUFF_SIZE];
		int curr;
	} t_wbuff;

	typedef struct {
		char dic[3][6][26];
	} t_reverser;

	void swapSides (char* text, int i, int j);
	int posCheckerChar (int pos, char c);
	int posCheckerChar (int pos, char c);
	void writeBuffer (char* text, int len);
	void writeBufferChar (char c, int choice);
	int outterTrim (char* text, int len, int choice);
	int innerTrim (char* text, int *len, int choice, char* sol);
	int singleSelector (int len, char* text);
	int doubleSelector (int len, char* text);
	int tripleSelector (int len, char* text);

	t_wbuff wbuff;
	t_reverser rev;
}


%%


-		writeBufferChar('\n', -1);
GCT		writeBufferChar('A', 0);
GCC		writeBufferChar('A', 1);
GCA		writeBufferChar('A', 2);
GCG		writeBufferChar('A', 3);
TGT		writeBufferChar('C', 0);
TGC		writeBufferChar('C', 1);
GAT 	writeBufferChar('D', 0);
GAC 	writeBufferChar('D', 1);
GAA 	writeBufferChar('E', 0);
GAG 	writeBufferChar('E', 1);
TTT 	writeBufferChar('F', 0);
TTC 	writeBufferChar('F', 1);
GGT 	writeBufferChar('G', 0);
GGC 	writeBufferChar('G', 1);
GGA 	writeBufferChar('G', 2);
GGG 	writeBufferChar('G', 3);
CAT 	writeBufferChar('H', 0);
CAC 	writeBufferChar('H', 1);
ATT 	writeBufferChar('I', 0);
ATC 	writeBufferChar('I', 1);
ATA 	writeBufferChar('I', 2);
AAA 	writeBufferChar('K', 0);
AAG 	writeBufferChar('K', 1);
CTT 	writeBufferChar('L', 0);
CTC 	writeBufferChar('L', 1);
CTA 	writeBufferChar('L', 2);
CTG 	writeBufferChar('L', 3);
TTA 	writeBufferChar('L', 4);
TTG 	writeBufferChar('L', 5);
ATG		writeBufferChar('M', 0);
AAT 	writeBufferChar('N', 0);
AAC 	writeBufferChar('N', 1);
CCT 	writeBufferChar('P', 0);
CCC 	writeBufferChar('P', 1);
CCA 	writeBufferChar('P', 2);
CCG 	writeBufferChar('P', 3);
CAA 	writeBufferChar('Q', 0);
CAG 	writeBufferChar('Q', 1);
CGT 	writeBufferChar('R', 0);
CGC 	writeBufferChar('R', 1);
CGA 	writeBufferChar('R', 2);
CGG 	writeBufferChar('R', 3);
AGA 	writeBufferChar('R', 4);
AGG 	writeBufferChar('R', 5);
TCT 	writeBufferChar('S', 0);
TCC 	writeBufferChar('S', 1);
TCA 	writeBufferChar('S', 2);
TCG 	writeBufferChar('S', 3);
AGT 	writeBufferChar('S', 4);
AGC 	writeBufferChar('S', 5);
ACT 	writeBufferChar('T', 0);
ACC 	writeBufferChar('T', 1);
ACA 	writeBufferChar('T', 2);
ACG 	writeBufferChar('T', 3);
GTT 	writeBufferChar('V', 0);
GTC 	writeBufferChar('V', 1);
GTA 	writeBufferChar('V', 2);
GTG 	writeBufferChar('V', 3);
TGG		writeBufferChar('W', 0);
TAT 	writeBufferChar('Y', 0);
TAC 	writeBufferChar('Y', 1);

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

void
findInFile (void) {
	//TODO
}

char
checkReverser (int pos) {
	if (IN_BUFF(pos/3))
		return rev.dic[pos%3][wbuff.choicebuff[pos/3]][(int)wbuff.text[pos/3] -'A'];
	else
		findInFile(); //TODO
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
writeBufferChar (char c, int choice) {
	if (!(wbuff.curr%WBUFF_SIZE))
		fputs(wbuff.text, yyout);

	wbuff.text[wbuff.curr%WBUFF_SIZE] = c;
	wbuff.choicebuff[wbuff.curr%WBUFF_SIZE] = choice;
	wbuff.curr++;
	wbuff.text[wbuff.curr%WBUFF_SIZE] = '\0';
}

/*void
writeBuffer (char* text, int len) {
	int i;
	for (i=0; i<len ;i++)
		writeBufferChar(text[i]);
}*/

int
outterTrim (char* text, int len, int choice) {
	char* buff = malloc(len);

	int i, j, aux=len;

	for (i=j=0; i<len ;i++) {
		if (VALID_CHAR(text[i]))
			text[j++]=text[i];
		else if (text[i]=='{') {
			innerTrim(text+i, &aux, choice, buff);
			strncpy(text+i, buff, aux);
			j+=aux;
			i+=aux-1;
		}
	}
	swapSides(text, j, len);
	free(buff);
	return len-j;
}

int
innerTrim (char* text, int *len, int choice, char* sol) {
	int i, j, state, curr;

	for (i=j=0, state=PRE_OUT; i<*len ;i++) {

		switch (state) {
			case PRE_OUT:
				if (text[i]=='{') {
					if (!choice)
						state=CHOICE;
					else
						state=PRE_IN;
					curr=0;
				}
				break;

			case PRE_IN:
				if (text[i]==',' && ++curr == choice)
					state=CHOICE;
				break;
			case CHOICE:
				if (VALID_CHAR(text[i]))
					sol[j++]=text[i];
				else if (text[i]==',') {
					curr++;
					state=POST_IN;
				}
			case POST_IN:
				if (text[i]==',')
					curr++;
				else if (text[i]=='}') {
					*len=i;
					sol[j]='\0';
					return curr-choice;
				}
				break;
		}
	}
	return -1;
}

int
singleSelector (int len, char* text) {
	return outterTrim(text, len, 0);
}

int
doubleSelector (int len, char* text) {
	return outterTrim(text, len, 0);
}

int
tripleSelector (int len, char* text) {
	return outterTrim(text, len, 0);
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
initReverser (void) {
	strncpy(&(rev.dic['A'-'A']), "GCTGCCGCAGCG", 12);
	strncpy(&(rev.dic['C'-'A']), "TGTTGC", 6);
	strncpy(&(rev.dic['D'-'A']), "GATGAC", 6);
	strncpy(&(rev.dic['E'-'A']), "GAAGAG", 6);
	strncpy(&(rev.dic['F'-'A']), "TTTTTC", 6);
	strncpy(&(rev.dic['G'-'A']), "GGTGGCGGAGGG", 12);
	strncpy(&(rev.dic['H'-'A']), "CATCAC", 6);
	strncpy(&(rev.dic['I'-'A']), "ATTATCATA", 9);
	strncpy(&(rev.dic['K'-'A']), "AAAAAG", 6);
	strncpy(&(rev.dic['L'-'A']), "CTTCTCCTACTGTTATTG", 18);
	strncpy(&(rev.dic['M'-'A']), "ATG", 3);
	strncpy(&(rev.dic['N'-'A']), "AATAAC", 6);
	strncpy(&(rev.dic['P'-'A']), "CCTCCCCCACCG", 12);
	strncpy(&(rev.dic['Q'-'A']), "CAACAG", 6);
	strncpy(&(rev.dic['R'-'A']), "CGTCGCCGACGGAGAAGG", 18);
	strncpy(&(rev.dic['S'-'A']), "TCTTCCTCATCGAGTAGC", 18);
	strncpy(&(rev.dic['T'-'A']), "ACTACCACAACG", 12);
	strncpy(&(rev.dic['V'-'A']), "GTTGTCGTAGTG", 12);
	strncpy(&(rev.dic['W'-'A']), "TGG", 3);
	strncpy(&(rev.dic['Y'-'A']), "TATTAC", 6);
}

void
init (void) {
	yyin = fopen("input.txt", "r");
	yyout = fopen("output.txt", "w");;

	initReverser();

	wbuff.curr = 0;
	wbuff.text[wbuff.curr] = '\0';
}

int
main (int argc, char** argv) {
	init();

	if (checkStart())
		return -1;
	else
		return start();

}