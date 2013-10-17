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
.	 	printf("JUNK");
{ISOL}	printf("I");
{LEUC}	printf("L");
{VALI}	printf("V");
{PHEN}	printf("F");
{METH}	printf("M");
{CYST}	printf("C");
{ALAN}	printf("A");
{GLYC}	printf("G");
{PROL}	printf("P");
{THRE}	printf("T");
{SERI}	printf("S");
{TYRO}	printf("Y");
{TRYP}	printf("W");
{GLUT}	printf("Q");
{ASPA}	printf("N");
{HIST}	printf("H");
{GLUA}	printf("E");
{ASPR}	printf("D");
{LYST}	printf("K");
{ARGI}	printf("R");
STOP 	return 0;
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
#define VALID_CHAR(c) ((c)=='A' || (c)=='T' || (c)=='C' || (c)=='G')?(TRUE):(FALSE)

typedef enum {PRE, FIRST_IN, OTHERS_IN, POST} state;

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
	yylex();
	return 0;
}

int
checkStart (void) {
	char buff[3];
	fread(buff, sizeof(char), 3, yyin);
	return strcmp(buff, "AUG");
}

int
main (void) {
	yyin=stdin;
	yyout=stdout;

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