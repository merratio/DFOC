flex mylex.l
yacc mysyn.y
cc lex.yy.c y.tab.c -o scanner
./scanner < input.txt
