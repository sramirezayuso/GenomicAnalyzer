%option reentrant
%s INSIDE

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

%%
<INITIAL>{ANY} printf("JUNK");
<INITIAL>{ISOL}	printf("I");
<INITIAL>{LEUC}	printf("L");
<INITIAL>{VALI}	printf("V");
<INITIAL>{PHEN}	printf("F");
<INITIAL>{METH}	printf("M");
<INITIAL>{CYST}	printf("C");
<INITIAL>{ALAN}	printf("A");
<INITIAL>{GLYC}	printf("G");
<INITIAL>{PROL}	printf("P");
<INITIAL>{THRE}	printf("T");
<INITIAL>{SERI}	printf("S");
<INITIAL>{TYRO}	printf("Y");
<INITIAL>{TRYP}	printf("W");
<INITIAL>{GLUT}	printf("Q");
<INITIAL>{ASPA}	printf("N");
<INITIAL>{HIST}	printf("H");
<INITIAL>{GLUA}	printf("E");
<INITIAL>{ASPR}	printf("D");
<INITIAL>{LYST}	printf("K");
<INITIAL>{ARGI}	printf("R");
<INITIAL>STOP 	return 0;
<INITIAL>{SELE}{SELE}{SELE} {tripleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{ANY}{SELE}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{SELE}{ANY}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{SELE}{SELE}{ANY}	{doubleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{SELE}{ANY}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{ANY}{SELE}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{ANY}{ANY}{SELE}	{singleSelector(&yyleng, yytext); yyless(0);};

%%
#include <stdio.h>
#include <stdlib.h>

#define TRUE 1
#define FALSE !TRUE
#define VALID_CHAR(c) ((c)=='A' || (c)=='T' || (c)=='C' || (c)=='G')?(TRUE):(FALSE)

typedef enum{PRE, FIRST_IN, OTHERS_IN, POST} state;

void
trim (char* text, int *len) {
	int i, j, state;

	for (j=i=0, state=PRE; j<*len ;j++) {

		switch (state) {
			case PRE:
				if(text[j]=='{')
					state=FIRST_IN;
				else if(VALID_CHAR(text[j])){
					text[i]=text[j];
					i++;
				}
				break;
			case FIRST_IN:
				if(text[j]==',')
					state=OTHERS_IN;
				else if(VALID_CHAR(text[j])){
					text[i]=text[j];
					i++;
				}
				break;
			case OTHERS_IN:
				if(text[j]=='}')
					state=POST;
				break;
			case POST:
				if(VALID_CHAR(text[j])){
					text[i]=text[j];
					i++;
				} else if(text[j]=='{')
					state=FIRST_IN;
				break;
		}
	}
	memset(text+i, '\0', (*len)-i);
	*len=i;
	return ;
}

int
singleSelector (int *len, char* text) {
	trim(text, len);
	return 1;
}

int
doubleSelector (int *len, char* text) {
	trim(text, len);
	return 1;
}

int
tripleSelector (int *len, char* text) {
	trim(text, len);
	return 1;
}

int
start (void) {

	yyscan_t originalScanner;
	yylex_init(&originalScanner);
	yylex(originalScanner);
	yylex_destroy(originalScanner);
	return 0;
}

int
checkStart (void) {
	char buff[3];
	fread(buff, sizeof(char), 3, stdin);
	return strcmp(buff, "AUG");
}

int
main (void) {

	if (checkStart())
		return -1;
	else
		return start();

}


/*
int
singleSelector (int pos, int len, char* text) {

	char* c;
	char* d;
	char opts[5];
	char triplet[4];
	char toParse[13];
	char* pointer;
	int idx = 0;
	int idy = 0;
	int count = 0;
	c = text;
	d = opts;
	pointer = toParse;

	while( *c != '{' ){
		triplet[idy++] = *c;
		c++;
		count++;
	}

	idy++;
	c++;
	count++;

	while( *c != '}'){
		if( (*c != ' ') && (*c != ','))
			opts[idx++] = *c;
		c++;
		count++;
	}
	count++;
	c++;

	for( ; count < len; count++){
		c++;
		triplet[idy++] = *c;
		printf("%c\n", triplet[idy]);
	}
	
	opts[idx] = '\0';
	triplet[4] = '\0';

	printf("%s\n", opts);
	printf("%s\n", triplet);

	yyscan_t scanner;
	YY_BUFFER_STATE buf;
	yylex_init(&scanner);
	buf = yy_scan_string(toParse, scanner);
	yylex(scanner);
	yy_delete_buffer(buf, scanner);
	yylex_destroy(scanner);

	return 0;

}
*/