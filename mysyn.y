%{
//Oconnor Burton
#include <stdio.h>
#include <string.h>

//implicit deefinition of function to handle errors
void yyerror(const char *);

//symbol table
typedef struct{
	char *name;
	int type;
} Symbols;

int count=0;
Symbols table[1000];

//function to add symbol to symbol table
void addSymbol(char *name, int type ){
	table[count].name = name;
	table[count].type = type;
	count++;
}

//function to search for character in symbol table
int getSymbol(char *name){
	for(int i =0; i<count; i++){
		if(strcmp(name, table[i].name) == 0) {
			return table[i].type;
		}
	}

	return -1;
}
	
int yywrap(){
	return 1;
}

int yylex();

%}

%union{
	char *name;
	int type;
}

%token DELTA OBRACE EBRACE OCURLY CCURLY START COMMA FINAL ALPHA STATES DFA STATE NUMBER EQUALSIGN 
%token <name> IDEN
%token <name> CHAR

%%
/*This file contains the grammar of the language and some static semantic for simple functionality*/
program: IDEN EQUALSIGN OBRACE states COMMA alphabet COMMA DELTA COMMA start COMMA final EBRACE statements 
	;

states:
	OCURLY state_elements CCURLY
	;

state_elements:/*When a state is being added there is a check to make sure that the state was not already added*/
	IDEN
	{
		addSymbol($1, 1);
	}
	|IDEN COMMA state_elements
	{
		 if(getSymbol($1) != -1){
                        yyerror("definition error");
                        printf("%s cannot be defined more than once", $1);
                        YYABORT;
                }
                addSymbol($1, 1);
	}
	;

alphabet:
	OCURLY alphabet_elements CCURLY
	;

alphabet_elements:/*The elements of the alphabet must occur once*/
	CHAR
	{
		addSymbol($1, 2);
	}
	|CHAR COMMA alphabet_elements
	{
		addSymbol($1, 2);
	}
	;

start:/*Checks to make sure that the start state is apart of the defined set of states in the description*/
	IDEN
	{
		if(getSymbol($1) != 1){
			yyerror("State not found in description\n");
			YYABORT;
		}
	}
	;

final:
        OCURLY final_list CCURLY
        ;

final_list:/*Checks to make sure final state set is made up of elements from state set*/
        IDEN
        |IDEN COMMA final_list
        {
                if(getSymbol($1) != 1){
                        yyerror("State not found\n");
                        YYABORT;
                }
        }
        ;


statements: 
	|statement statements
	;

statement: /*each function call checks to make sure the states and the characters being used were defined in the description 
	     as being apart of the set of states and alphabet respectively*/

	DELTA OBRACE IDEN COMMA CHAR EBRACE EQUALSIGN IDEN
	{
		if(getSymbol($3) == -1){
			printf("%s was not declared as a state in the dfa description above\n", $3);
			YYABORT;
		}

		if(getSymbol($5) == -1){
			printf("%s was not defined in the alphabet in the dfa description above\n", $5);
			YYABORT;
		}
		
		 if(getSymbol($8) == -1){
                        printf("%s was not declared as a state in the dfa description above\n", $8);
                        YYABORT;
                }
	}
	;
	
%%

int main(void){
	yyparse();
}

void yyerror(const char *s){
	fprintf(stderr, "error: %s\n", s);

}

