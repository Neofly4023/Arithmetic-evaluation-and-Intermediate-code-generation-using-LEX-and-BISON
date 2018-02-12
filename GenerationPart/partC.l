%{
#include "partC.tab.h"

int pntrErr = 0;

%}

variable [a-z]([a-z]|[0-9])*
espace [ \t]+
operateur [\+\-*/]

%%

"temp"[0-9]+ {
    pntrErr += yyleng;
}

"somme" {
    pntrErr += yyleng; 
    return somme;
}

"produit" {
    pntrErr += yyleng; 
    return produit;
}

"moyenne" {
    pntrErr += yyleng; 
    return moyenne;
}

"variance" {
    pntrErr += yyleng; 
    return variance;
}

"ecartype" {
    pntrErr += yyleng; 
    return ecartype;
}

"," { 
    pntrErr += yyleng;
    return yytext[0]; 
}

{variable} {
    pntrErr += yyleng;
    return variable;
}

{espace}+ { 
    pntrErr += yyleng; 
}


"("|")" { 
    pntrErr += yyleng;
    return yytext[0]; 
}

{operateur} {
    pntrErr += yyleng; 
    return yytext[0]; 
}

. { 
    pntrErr += yyleng;
}
%%