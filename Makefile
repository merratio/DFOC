flex mylex.l
yacc -d mysyn.y
cc lex.yy.c y.tab.c -o scanner
