%{
//Oconnor Burton
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//transition function
//typedef struct{
//current

typedef struct{
	char *name;	
} State;

typedef struct{
	char val;

} AlphaSym;

typedef struct{
	char *current;
	char input;
	char *next;

} Transition;

typedef struct{
	//states
	State states[100];
	int state_count;

	//alphabet
	AlphaSym alphabet[100];
	int alpha_count;

	//transition function
	Transition transitions[10000];
	int trans_count;

	//start state
	State state;

	//final state
	State finalStates[100];
	int finalState_count;
}DFA;

DFA dfa;


void addState(char *name){
	dfa.states[dfa.state_count].name = name;
	dfa.state_count++;
}

void addAlpha(char val){
	dfa.alphabet[dfa.alpha_count].val = val;
	dfa.alpha_count++;
}

void addTrans(char *curr, char input, char *next){
	dfa.transitions[dfa.trans_count].current = curr;
	dfa.transitions[dfa.trans_count].input = input;
	dfa.transitions[dfa.trans_count].next = next;
	dfa.trans_count++;
}

void addFinalStates(char *name){
	dfa.finalStates[dfa.finalState_count].name = name;
	dfa.finalState_count++;
}

void initStart(char *state){
	dfa.state.name = state;
}

//implicit definition of function to handle errors
void yyerror(const char *);
extern int yylineno;


//function to search for character in symbol table
int getState(char *name){
	for(int i =0; i<dfa.state_count; i++){
		if(strcmp(name, dfa.states[i].name) == 0) {
			return i;
		}
	}

	return -1;
}

int getFinalState(char *name){
	for(int i =0; i<dfa.finalState_count; i++){
		if(strcmp(name, dfa.finalStates[i].name) == 0) {
			return i;
		}
	}

	return -1;
}

int getChar(char val){
	for(int i =0; i<dfa.alpha_count; i++){
		if(val == dfa.alphabet[i].val) {
			return i;
		}
	}

	return -1;
}

int getTrans(char *curr, char inp){
	for(int i =0; i<dfa.trans_count; i++){
		if(strcmp(curr, dfa.transitions[i].current) == 0 && inp == dfa.transitions[i].input) {
			return i;
		}
	}

	return -1;
}

int checkComplete(){
	int complete = 1;

	for(int i = 0; i < dfa.state_count; i++){
		for(int j = 0; j < dfa.alpha_count; j++){
			if(getTrans(dfa.states[i].name, dfa.alphabet[j].val) == -1){
				printf("Missing transition: δ(%s, %c)\n", dfa.states[i].name, dfa.alphabet[j].val);
				complete = 0;
			}
		}
	}
	return complete;
}

/*Writes the DFA to a Graphviz .dot file.
  Final states are drawn as double circles and the start state gets an incoming arrow.
  Transitions that share the same source and destination are merged into one edge (e.g. "a,b")*/
void renderDFA(const char *filename){
	FILE *f = fopen(filename, "w");
	if(f == NULL){
		perror("could not open dot file");
		return;
	}

	fprintf(f, "digraph DFA {\n");
	fprintf(f, "\trankdir=LR;\n");
	fprintf(f, "\t__start [shape=point, label=\"\"];\n");

	for(int i = 0; i < dfa.state_count; i++){
		const char *shape = (getFinalState(dfa.states[i].name) != -1) ? "doublecircle" : "circle";
		fprintf(f, "\t\"%s\" [shape=%s];\n", dfa.states[i].name, shape);
	}

	fprintf(f, "\t__start -> \"%s\";\n", dfa.state.name);

	for(int i = 0; i < dfa.trans_count; i++){
		int seen = 0;
		for(int j = 0; j < i; j++){
			if(strcmp(dfa.transitions[j].current, dfa.transitions[i].current) == 0 &&
			   strcmp(dfa.transitions[j].next, dfa.transitions[i].next) == 0){
				seen = 1;
				break;
			}
		}
		if(seen) continue;

		fprintf(f, "\t\"%s\" -> \"%s\" [label=\"", dfa.transitions[i].current, dfa.transitions[i].next);

		int first = 1;
		for(int k = i; k < dfa.trans_count; k++){
			if(strcmp(dfa.transitions[k].current, dfa.transitions[i].current) == 0 &&
			   strcmp(dfa.transitions[k].next, dfa.transitions[i].next) == 0){
				fprintf(f, first ? "%c" : ",%c", dfa.transitions[k].input);
				first = 0;
			}
		}
		fprintf(f, "\"];\n");
	}

	fprintf(f, "}\n");
	fclose(f);
}
	
int yywrap(){
	return 1;
}

int yylex();

%}

%union{
	
	char *name;
	char val;
}

%token DELTA OBRACE EBRACE OCURLY CCURLY START COMMA EQUALSIGN 
%token <name> IDEN
%token <val> CHAR

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
		addState($1);
	}
	|IDEN COMMA state_elements
	{
        	if(getState($1) != -1){
                        yyerror("definition error");
                        printf("%s cannot be defined more than once", $1);
                        YYABORT;
                }

		addState($1);
	}
	;

alphabet:
	OCURLY alphabet_elements CCURLY
	;

alphabet_elements:/*The elements of the alphabet must occur once*/
	CHAR
	{
		addAlpha($1);
	}
	|CHAR COMMA alphabet_elements
	{
		if(getChar($1) != -1){
                        yyerror("definition error");
                        printf("%c cannot be defined more than once", $1);
                        YYABORT;
                }

		addAlpha($1);
	}
	;

start:/*Checks to make sure that the start state is apart of the defined set of states in the description*/
	IDEN
	{
		if(getState($1) == -1){
			yyerror("State not found in description\n");
			YYABORT;
		}
		initStart($1);
	}
	;

final:
        OCURLY final_list CCURLY
        ;

final_list:/*Checks to make sure final state set is made up of elements from state set*/
        IDEN
	{
                if(getState($1) == - 1){
			yyerror("Definition error");
			printf("Final state %s not found\n", $1);
                        YYABORT;
                }
		addFinalStates($1);
        }

        |IDEN COMMA final_list
        {
                if(getState($1) == -1){
                        yyerror("Definition error");
			printf("Final state %s not found\n", $1);
                        YYABORT;
                }

		if(getFinalState($1) != -1){
                        yyerror("definition error");
                        printf("%s cannot be defined more than once", $1);
                        YYABORT;
                }
		

		addFinalStates($1);
        }
        ;


statements: 
	|statement statements
	;

statement: /*each function call checks to make sure the states and the characters being used were defined in the description 
	     as being apart of the set of states and alphabet respectively*/
	DELTA OBRACE IDEN COMMA CHAR EBRACE //syntactic sugar
	{
		if(getState($3) == -1){
			yyerror(strcat($3," was not declared as a state in the dfa description above\n"));
			YYABORT;
		}

		if(getChar($5) == -1){
			yyerror("A character was not defined in the alphabet in the dfa description above\n");
			YYABORT;
		}
		
		if(getTrans($3,$5) != -1){
                        yyerror("Transition already exists.Cannot have multiple\n");
                        YYABORT;
                }


		addTrans($3, $5, $3);
	}
	
	|DELTA OBRACE IDEN COMMA CHAR EBRACE EQUALSIGN IDEN
	{
		if(getState($3) == -1){
			yyerror(strcat($3, " was not declared as a state in the dfa description above\n"));
			YYABORT;
		}

		if(getChar($5) == -1){
			yyerror("A character was not defined in the alphabet in the dfa description above\n");
			YYABORT;
		}
		
		if(getState($8) == -1){
                        yyerror(strcat($8, " was not declared as a state in the dfa description above\n"));
                        YYABORT;
                }

		if(getTrans($3,$5) != -1){
                        yyerror("Transition already exists.Cannot have multiple\n");
                        YYABORT;
                }


		addTrans($3, $5, $8);
	}
	;
	
%%

int main(void){
	if(yyparse() != 0){
		return 1;	/* syntax error or YYABORT: nothing is rendered */
	}
 
	if(!checkComplete()){
		printf("DFA is incomplete: not every state has a transition for every symbol\n");
		return 1;
	}
 
	printf("DFA is valid and complete\n");
	renderDFA("dfa_output.dot");
	if(system("dot -Tsvg dfa_output.dot -o dfa_output.svg") == 0){
		printf("DFA diagram written to dfa_output.svg (source: dfa_output.dot)\n");
	}else{
		printf("Wrote dfa_output.dot. Install Graphviz and run: dot -Tsvg dfa_output.dot -o dfa_output.svg\n");
	}
	return 0;
}

void yyerror(const char *s){
	fprintf(stderr, "error: %s(line %d)\n", s, yylineno);

}

