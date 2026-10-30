%{
#include <stdio.h>
#include "y.tab.h"

//Oconnor Burton
//This file contains the tokens to be returned to the parser once recognized
%}

%%
δ                           return DELTA;
\{                          return OCURLY;
\}                          return CCURLY;
\(                          return OBRACE;
\)                          return EBRACE;
[a-z0-9]                       yylval.val= yytext[0]; return CHAR;/*returns the character that is recognized so it can be used in the parser*/
","                         return COMMA;
=                           return EQUALSIGN;
[a-zA-Z][a-zA-Z0-9]*        yylval.name= strdup(yytext);   return IDEN;
\n                                ;                 //ignores newline
[ \t]+                            ;                 //ignores whitespaces
"//".*                            ;  
%%
