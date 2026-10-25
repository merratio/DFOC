yacc -d mysyn.y
flex mylex.l
cc lex.yy.c y.tab.c -o scanner
./scanner < input.txt
open dfa.svg
