%{
	#include "symtab.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE *yyin;
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
%token ID ICONST FCONST CCONST STRING

%start program

/* expression priorities and rules */

%%

program: MAINPROG ID SEMI declarations subprog_declarations compound_statement ;

declarations: type identifier_list SEMI declarations | /*empty*/ ;

identifier_list: ID | ID COMMA identifier_list;

type: standard_type | standard_type LBRACE ICONST RBRACE ;

standard_type: INT | FLOAT ;

subprog_declarations: subprog_declaration subprog_declarations | /*empty*/;

subprog_declaration: subprog_head declarations compound_statement;

subprog_head: FUNCTION ID arguments DDOT standard_type |
							PROCEDURE ID arguments SEMI
							;

arguments: LPAREN parameter_list RPAREN | /*empty*/ ;

parameter_list: identifier_list DDOT type | identifier_list DDOT type SEMI parameter_list;
/* c'est pourri, je ferai type identifier_list plutôt parce que là...*/


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

if_statement: IF expression DDOT statement ;

while_statement: WHILE expression DDOT statement {printf("while statement \n");};

for_statement: FOR expression IN expression DDOT statement {printf("for statement \n");};

print_statement: PRINT | PRINT LPAREN expression RPAREN;

variable: ID | ID LBRACE expression RBRACE;

procedure_statement: ID LPAREN actual_parameter_expression RPAREN;

actual_parameter_expression: /*empty*/ | expression_list;

expression_list: expression | expression COMMA expression_list;

expression: simple_expression | simple_expression relational_op simple_expression;

simple_expression: term | term additional_op simple_expression;

term: factor | factor multop term;

factor: ICONST | FCONST | variable | NOTOP factor | sign factor;

sign: ADDOP | SUBOP;

relational_op: RELOP | EQUOP | IN;

additional_op: ADDOP | SUBOP;

multop: DIVOP | MULOP;

%%

void yyerror ()
{
  fprintf(stderr, "Syntax error at line %d\n", lineNumber);
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
