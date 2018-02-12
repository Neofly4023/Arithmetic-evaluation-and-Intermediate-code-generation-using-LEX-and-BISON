%{
#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct Arguments {
	float argument;
	struct Arguments* next;
} Arguments,*ArgsPntr;
typedef float (*PntrFonction) (ArgsPntr);

void yyerror(const char* s);


float somme_fonction(ArgsPntr args);
float moyenne_fonction(ArgsPntr args);
float variance_fonction(ArgsPntr args);
float ecartype_fonction(ArgsPntr args);

int yylex();



%}

%error-verbose

%union {
	
	ArgsPntr list_args;
	PntrFonction pntr_fonct;
	float valeur_f;
	char valeur_c;
}

%token <valeur_f> parameter
%token <valeur_c> somme moyenne variance ecartype

%type <valeur_f> Ligne Expr T F G
%type <pntr_fonct> Fonction
%type <list_args> Arguments

%%

Ligne : Expr'\n'  {printf("Résultat =  %.3f\n", $1); return 0;}
;
Expr :Expr '+' T {$$ = $1 + $3;}
	| Expr '-' T {$$ = $1 - $3;}
	| T
;
T :   T '*' F {$$ = $1 * $3;}
	| T '/' F {$$ = $1 / $3; }
	| F
;
F : '-' G {$$ = -$2;}
	| G
;
G : '('Expr')' {$$ = $2;}
	| Fonction '('Arguments')'{$$=$1($3);}
	| parameter
;
Fonction : somme {$$=somme_fonction;}
	| moyenne {$$=moyenne_fonction;}
	| variance {$$=variance_fonction;}
	| ecartype {$$=ecartype_fonction;}
;
Arguments : Expr {ArgsPntr args = (ArgsPntr)malloc(sizeof(Arguments));
			args->argument=$1;
			args->next=NULL;
			$$=args;}
	| Arguments ',' Expr {ArgsPntr args=$1;
			ArgsPntr args_new = (ArgsPntr)malloc(sizeof(Arguments));
			args_new->argument=$3;
			args_new->next=args;
			$$=args_new;}
;

%%

int yywrap() 
{
	return 1;
}

void yyerror(const char *s) 
{
	exit(-1);
}

float somme_fonction(ArgsPntr args){
	if(args==NULL)
		return 0;
	
	float resultat;
	ArgsPntr argument;
	
	for(resultat=0,argument=args;argument;argument=argument->next)
		resultat += argument->argument;
	return resultat;
}

float moyenne_fonction(ArgsPntr args){
	if(args==NULL)
		return 0;
	
	int count;
	float resultat;
	ArgsPntr argument;
	
	for(resultat=0,count=0,argument=args;argument;argument=argument->next,count++)
		resultat += argument->argument;
	return (resultat/count);
}

float variance_fonction(ArgsPntr args){
	if(args==NULL)
		return 0;
	
	float average = moyenne_fonction(args);
	float resultat,Esperance;
	int count;
	ArgsPntr argument;
	
	for(resultat=0,count=0,argument=args;argument;argument=argument->next,count++){
		Esperance=(argument->argument - average);
		resultat += Esperance*Esperance;
	}
	return (resultat/count);
}

float ecartype_fonction(ArgsPntr args) {
	if(args==NULL)
		return 0;

	//return sqrtf(variance_fonction(args));
}


int main(int argc, char **argv){
	printf("Donner une expression : ");
	yyparse();
}
