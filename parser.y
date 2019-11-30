%{
	#include "symtab.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE *yyin;
	extern FILE *yyverb;
	extern FILE *yyout;
	extern int lineNumber;
	extern int spaceNumber;
	extern int tabNumber;
	extern int yylex();
	void yyerror();
%}

/* token definition */
%token INT FLOAT
%token IF ELSE ELIF WHILE FOR
%token RETURN MAINPROG FUNCTION PROCEDURE TBEGIN END IN PRINT
%token ADDOP SUBOP MULOP DIVOP NOTOP EQUOP RELOP
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE SEMI DDOT DOT COMMA ASSIGN
%token ID ICONST FCONST

%start program

/* expression priorities and rules */

%%

program: MAINPROG ID SEMI declarations subprog_declarations compound_statement ;

declarations: type identifier_list SEMI declarations | /*empty*/ ;

identifier_list: ID | ID COMMA identifier_list;

type: standard_type | standard_type LBRACK ICONST RBRACK ;

standard_type: INT | FLOAT ;

subprog_declarations: subprog_declaration subprog_declarations | /*empty*/;

subprog_declaration: subprog_head declarations compound_statement;

subprog_head: FUNCTION ID arguments DDOT standard_type |
							PROCEDURE ID arguments SEMI
							;

arguments: LPAREN parameter_list RPAREN | /*empty*/ ;

parameter_list: type DDOT identifier_list | type DDOT identifier_list SEMI parameter_list;


compound_statement: TBEGIN statement_list END;

statement_list: statement SEMI| statement SEMI statement_list;

statement: 	variable ASSIGN expression |
						print_statement |
						procedure_statement |
						compound_statement |
						if_statement |
						while_statement |
						for_statement |
						RETURN expression
						;

if_statement: IF expression DDOT statement_list elif_statement else_statement |
							IF expression DDOT statement_list else_statement |
							IF expression DDOT statement_list
							;

else_statement: ELSE DDOT statement;

elif_statement: ELIF expression DDOT statement_list;

while_statement: WHILE expression DDOT statement;

for_statement: FOR simple_expression IN expression DDOT statement;

print_statement: PRINT | PRINT LPAREN expression RPAREN;

variable: ID | ID LBRACK expression RBRACK;

procedure_statement: ID LPAREN actual_parameter_expression RPAREN;

actual_parameter_expression: /*empty*/ | expression_list;

expression_list: expression | expression COMMA expression_list;

expression: simple_expression | simple_expression relational_op simple_expression;

simple_expression: term | term additional_op simple_expression;

term: factor | factor multop term;

factor: variable | ICONST | FCONST | NOTOP factor | sign factor;

sign: ADDOP | SUBOP;

relational_op: RELOP | EQUOP | IN;

additional_op: ADDOP | SUBOP;

multop: DIVOP | MULOP;

%%

void yyerror ()
{
  fprintf(stderr, "Syntax error at line %d\n", lineNumber);
	exit(1);
}

int main (int argc, char *argv[]){

	// initialize symbol table
	init_hash_table();

	// parsing
	int flag;
	yyin = fopen(argv[1], "r");
	flag = yyparse();
	fclose(yyin);

	// symbol table dump
	yyout = fopen("symtab_dump.out", "w");
	symtab_dump(yyout);
	fclose(yyout);




	return flag;
}
