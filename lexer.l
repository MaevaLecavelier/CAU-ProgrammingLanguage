%option noyywrap

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "symtab.h"
	#include "parser.tab.h"
	extern FILE *yyin;
	extern FILE *yyout;

	int lineNumber = 1; // initialize to 1
	int spaceNumber = 0;
	int tabNumber = 0;
	int type;
	int inf_type;
	void ret_print(char *token_type);
	void yyerror();
%}

%x ML_COMMENT

alpha 		[a-zA-Z]
digit 		[0-9]
alnum 		[a-zA-Z0-9]
print		[ -~]

ID 			[a-zA-Z]+[a-zA-Z0-9]*
ICONST		{digit}+
FCONST		{digit}*"."{digit}+
CCONST		(\'{print}\')|(\'\\[nftrbv]\')
STRING		\"{print}*\"

%%

"//".*					{ printf("// Comment at line %d\n", lineNumber); }

"/*"								{ printf("/* Comment from line %d ", lineNumber); BEGIN(ML_COMMENT); }
<ML_COMMENT>"*/" 		{ printf("to line %d */\n", lineNumber); BEGIN(INITIAL); }
<ML_COMMENT>[^*\n]+
<ML_COMMENT>"*"
<ML_COMMENT>"\n"		{ lineNumber += 1; }


"int"|"INT"							{ type = INT_TYPE; return INT; }
"float"|"FLOAT"					{ type = REAL_TYPE; return FLOAT; }
"if"|"IF"								{ printf("If statement at line %d\n", lineNumber); return IF; }
"else"|"ELSE"						{ printf("Else statement at line %d\n", lineNumber); return ELSE; }
"elif"|"ELIF"						{ printf("Elif statement at line %d\n", lineNumber); return ELIF; }
"while"|"WHILE"					{ printf("While statement at line %d\n", lineNumber); return WHILE; }
"for"|"FOR"							{ printf("For statement at line %d\n", lineNumber); return FOR; }
"return"|"RETURN"				{ return RETURN; }
"mainprog"|"MAINPROG" 	{ type = MAINPROG_TYPE; return MAINPROG; }
"function"|"FUNCTION" 	{ type = FUNCTION_TYPE; return FUNCTION; }
"procedure"|"PROCEDURE" { type = FUNCTION_TYPE; return PROCEDURE; }
"begin"|"BEGIN"					{ type = UNDEF; return TBEGIN; }
"end"|"END"							{ return END; }
"print"|"PRINT" 				{ printf("Print statement at line %d\n", lineNumber); return PRINT; }
"in"|"IN"								{ return IN; }



"+"								{ return ADDOP; }
"-"								{ return SUBOP; }
"*"								{ return MULOP; }
"/"								{ return DIVOP; }
"!"								{ return NOTOP; }
"=="|"!="					{ return EQUOP; }
">"|"<"|">="|"<="	{ return RELOP; }


"("				{ inf_type = 0; type = 0; return LPAREN; }
")"				{ return RPAREN; }
"["				{ inf_type = type; type = ARRAY_TYPE; return LBRACK; }
"]"				{ return RBRACK; }
"{"				{ return LBRACE; }
"}"				{ return RBRACE; }
";"				{ inf_type = 0; type = 0; return SEMI; }
":"				{ return DDOT; }
"."				{ return DOT; }
","				{ return COMMA; }
"="				{ return ASSIGN; }

{ID} 			{
					// insert identifier into symbol table
					insert(yytext, strlen(yytext), type, inf_type, lineNumber);
					return ID;
				}
{ICONST} 		{ return ICONST; }
{FCONST} 		{ return FCONST; }


[\n]?			{ lineNumber = lineNumber + 1; }
"  "?		{ tabNumber = tabNumber + 1; }
" "?		{ spaceNumber = spaceNumber + 1; }

"EOF"[\n]	{
		printf("End of file\n");
		yyout = fopen("symtab_dump.out", "w");
		symtab_dump(yyout);
		fclose(yyout);
		exit(0);
}

.				{ yyerror("Unrecognized character"); }

%%
