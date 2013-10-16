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
STOP TAA|TAG|TGA
ANY  [ATCG]
SELE \{.*\}

%%
<INITIAL>AUG	printf("Start");
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
<INITIAL>{SELE}{SELE}{SELE} {tripleSelector(yyleng, yytext);};
<INITIAL>{ANY}{SELE}{SELE}	{doubleSelector(0, yyleng, yytext);};
<INITIAL>{SELE}{ANY}{SELE}	{doubleSelector(1, yyleng, yytext);};
<INITIAL>{SELE}{SELE}{ANY}	{doubleSelector(2, yyleng, yytext);};
<INITIAL>{SELE}{ANY}{ANY}	{singleSelector(0, yyleng, yytext);};
<INITIAL>{ANY}{SELE}{ANY}	{singleSelector(1, yyleng, yytext);};
<INITIAL>{ANY}{ANY}{SELE}	{singleSelector(2, yyleng, yytext);};

<INSIDE>AUG		{printf("Start");
				return 0;};
<INSIDE>ISOL	{printf("I");
				return 0;};
<INSIDE>LEUC	{printf("L");
				return 0;};
<INSIDE>VALI	{printf("V");
				return 0;};
<INSIDE>PHEN	{printf("F");
				return 0;};
<INSIDE>METH	{printf("M");
				return 0;};
<INSIDE>CYST	{printf("C");
				return 0;};
<INSIDE>ALAN	{printf("A");
				return 0;};
<INSIDE>GLYC	{printf("G");
				return 0;};
<INSIDE>PROL	{printf("P");
				return 0;};
<INSIDE>THRE	{printf("T");
				return 0;};
<INSIDE>SERI	{printf("S");
				return 0;};
<INSIDE>TYRO	{printf("Y");
				return 0;};
<INSIDE>TRYP	{printf("W");
				return 0;};
<INSIDE>GLUT	{printf("Q");
				return 0;};
<INSIDE>ASPA	{printf("N");
				return 0;};
<INSIDE>HIST	{printf("H");
				return 0;};
<INSIDE>GLUA	{printf("E");
				return 0;};
<INSIDE>ASPR	{printf("D");
				return 0;};
<INSIDE>LYST	{printf("K");
				return 0;};
<INSIDE>ARGI	{printf("R");
				return 0;};
%%

int
main(void){

	if(checkStart)
		return -1;
	else
		return start();

}

int
checkStart(void) {
	char buff[3];
	fread(buff, sizeof(char), 3, yyin);
	return strcmp(buff, "AUG");
}

int
start(void) {

	yyscan_t originalScanner;
	yylex_init ( &originalScanner );
	yylex ( originalScanner );
	yylex_destroy ( originalScanner );
	return 0;
}

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

/*int singleSelector (int pos, int len, char* text) {

	char* c;
	char* d;
	char opts[5];
	char triplet[4];
	char toParse[13];
	char* pointer;
	int idx = 0;
	int idy = 0;
	c = text;
	d = opts;
	//pointer = toParse;

	while( *c != '{' ){
		//triplet[idy++] = *c;
		c++;
	}
	idy++;
	c++;
	while( *c != '}'){
		if( (*c != ' ') && (*c != ','))
			opts[idx++] = *c;
		c++;
	}
	while(*c != '\0')
		//triplet[idy++] = *c;
	
	opts[idx] = '\0';
	printf("%s\n", opts);
	//triplet[idy] = '\0';

	//printf("%s\n", triplet);

	while( *d != '\0'){
		triplet[pos] = *d;
		d++;
		memcpy((void*)pointer, (void*)triplet, 3);
		pointer = pointer+3;
	}

	*pointer = '\0';

	yyscan_t scanner;
	YY_BUFFER_STATE buf;
	yylex_init(&scanner);
	len = 3;
	buf = yy_scan_string(toParse, scanner);
	yylex(scanner);
	yy_delete_buffer(buf, scanner);
	yylex_destroy(scanner);

	return 0;

}*/