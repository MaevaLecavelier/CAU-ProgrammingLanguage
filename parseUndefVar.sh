bison -d parser.y
flex lexer.l
gcc -o program parser.tab.c lex.yy.c
rm symtab_dump.out
./program UndefVarError.c
cat symtab_dump.out
