#include <stdio.h>
#include <stdlib.h>

#define TRUE 1
#define FALSE !TRUE
#define VALID_CHAR(c) ((c)=='A' || (c)=='T' || (c)=='C' || (c)=='G')?(TRUE):(FALSE)

typedef enum{PRE, FIRST_IN, OTHERS_IN, POST} state;

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
<INITIAL>{ISOL}	I;
<INITIAL>{LEUC}	L;
<INITIAL>{VALI}	V;
<INITIAL>{PHEN}	F;
<INITIAL>{METH}	M;
<INITIAL>{CYST}	C;
<INITIAL>{ALAN}	A;
<INITIAL>{GLYC}	G;
<INITIAL>{PROL}	P;
<INITIAL>{THRE}	T;
<INITIAL>{SERI}	S;
<INITIAL>{TYRO}	Y;
<INITIAL>{TRYP}	W;
<INITIAL>{GLUT}	Q;
<INITIAL>{ASPA}	N;
<INITIAL>{HIST}	H;
<INITIAL>{GLUA}	E;
<INITIAL>{ASPR}	D;
<INITIAL>{LYST}	K;
<INITIAL>{ARGI}	R;
<INITIAL>STOP 	return 0;
<INITIAL>{SELE}{SELE}{SELE} {tripleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{ANY}{SELE}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{SELE}{ANY}{SELE}	{doubleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{SELE}{SELE}{ANY}	{doubleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{SELE}{ANY}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{ANY}{SELE}{ANY}	{singleSelector(&yyleng, yytext); yyless(0);};
<INITIAL>{ANY}{ANY}{SELE}	{singleSelector(&yyleng, yytext); yyless(0);};

%%

int
main (void) {

	if (checkStart)
		return -1;
	else
		return start();

}

int
checkStart (void) {
	char buff[3];
	fread(buff, sizeof(char), 3, yyin);
	return strcmp(buff, "AUG");
}

int
start (void) {

	yyscan_t originalScanner;
	yylex_init(&originalScanner);
	yylex(originalScanner);
	yylex_destroy(originalScanner);
	return 0;
}

void
singleSelector (int *len, char* text) {
	trim(text, len);
	return ;
}

void
doubleSelector (int *len, char* text) {
	trim(text, len);
	return ;
}

void
tripleSelector (int *len, char* text) {
	trim(text, len);
	return ;
}

void
trim (char* text, int *len) {
	int i, j, state;

	for (j=i=0, state=PRE; j<*len ;j++) {
		switch (state) {
			case PRE:
				if(text[j]='{')
					state=FIRST_IN;
				else if(VALID_CHAR(text[j])){
					text[i]=text[j];
					i++;
				}
				break;
			case FIRST_IN:
				if(text[j]=',')
					state=OTHERS_IN;
				else if(VALID_CHAR(text[j])){
					text[i]=text[j];
					i++;
				}
				break;
			case OTHERS_IN:
				if(text[j]='}')
					state=POST;
				break;
			case POST:
				if(VALID_CHAR(text[j])){
					text[i]=text[j];
					i++;
				} else if(text[j]='{')
					state=FIRST_IN;
				break;
		}
	}
	*len=i;
	return ;
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