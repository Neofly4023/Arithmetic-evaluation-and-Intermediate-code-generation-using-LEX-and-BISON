%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

extern char* yytext;
extern int Ligne;
extern int indiceTemp;
extern char resultat[100];
extern int pntrErr;

int yylex();
int sommet=0;
int indiceTemp=0;
int Ligne=1;

void yyerror(const char *s);
void Quad();
void Quad_somme();
void Quad_produit();
void Quad_moyenne(int size);
void Quad_varianceInit();
void Quad_variancePre(int size);
void Quad_variance(int size);
void Quad_ecartype();

char pile[100][10];
char temp[10] = "";
char resultat[100] = "";

%}

%error-verbose

%union 
{ 
	int var; 
}

%token <var> variable somme produit moyenne variance ecartype

%left '-' '+'
%left '*' '/'

%type <var> Expr Produit_args Moyenne_args Variance_args

%%

Expr: Expr '-' { strcpy(pile[++sommet], yytext); } Expr { Quad(); }
    | Expr '+' { strcpy(pile[++sommet], yytext); } Expr { Quad(); }
    | Expr '/' { strcpy(pile[++sommet], yytext); } Expr { Quad(); }
    | Expr '*' { strcpy(pile[++sommet], yytext); } Expr { Quad(); }
    | '(' Expr ')' {}
    | variable { strcpy(pile[++sommet], yytext); }
    | Function {}
   

Function: somme '(' Moyenne_args ')' { }
        | moyenne '(' Moyenne_args ')' { Quad_moyenne($3); } 
        | produit '(' Produit_args ')' { }
        | variance '(' Variance_args ')' { Quad_variance($3); }
        | ecartype '(' Variance_args ')' { Quad_variance($3); Quad_ecartype($3); }
        ;

Moyenne_args: Moyenne_args { strcpy(pile[++sommet], yytext); } ',' {} Expr { Quad_somme(); $$++; } 
            | Expr { $$ = 1;}
            ;

Produit_args: Produit_args { strcpy(pile[++sommet], yytext); } ',' {} Expr { Quad_produit(); }
            | Expr {}
            ;

Variance_args: Variance_args { strcpy(pile[++sommet], yytext); } ',' {} Expr { Quad_variancePre($$++); }
             | Expr { Quad_varianceInit(); $$ = 1; }
             ;

%%

// JEU D'ESSAI : a+b*somme(c,somme(d,e,f),variance(a,b,c,d,e))

int main(int argc, char **argv)
{
    printf("Donner une expression : ");
	yyparse();
}


int yywrap() 
{
	return 1;
}

void yyerror(const char *s) {
    
    printf("Erreur à l'indice (%d) de votre expression\n%s\n",(pntrErr),s);

    pntrErr=0;

    exit(-1);
}

void Quad()
{
    sprintf(temp, "temp%d", indiceTemp++);

    sprintf(resultat, "%s := %s %s %s", temp, pile[sommet - 2], pile[sommet - 1], pile[sommet]);

    printf("%02d %s\n", Ligne++, resultat);

    sommet -= 2;

    strcpy(pile[sommet], temp);

}

void Quad_somme()
{
    sprintf(temp, "temp%d", indiceTemp++);

    sprintf(resultat, "%s := %s + %s", temp, pile[sommet - 2], pile[sommet]);

    printf("%02d %s\n", Ligne++, resultat);

    sommet -= 2;

    strcpy(pile[sommet], temp);

}

void Quad_produit()
{
    sprintf(temp, "temp%d", indiceTemp++);

    sprintf(resultat, "%s := %s * %s", temp, pile[sommet - 2], pile[sommet]);

    printf("%02d %s\n", Ligne++, resultat);

    sommet -= 2;

    strcpy(pile[sommet], temp);
}

void Quad_moyenne(int size)
{
    sprintf(temp, "temp%d", indiceTemp++);

    sprintf(resultat, "%s := %s / %d", temp, pile[sommet], size);

    printf("%02d %s\n", Ligne++, resultat);

    strcpy(pile[sommet], temp);
}

void Quad_varianceInit()
{
    sprintf(temp, "temp%d", indiceTemp++);

    sprintf(resultat, "%s := %s * %s", temp, pile[sommet], pile[sommet]);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(temp, "temp%d", indiceTemp++);

    sprintf(resultat, "%s := %s", temp, pile[sommet]);

    printf("%02d %s\n", Ligne++, resultat);

    sommet--;
}

void Quad_variancePre(int size)
{
    indiceTemp++;

    sprintf(temp, "temp%d", indiceTemp - size);

    sprintf(resultat, "%s := %s * %s", temp, pile[sommet], pile[sommet]);

    printf("%02d %s\n", Ligne++, resultat);

    char ancienTemp[10] = "";

    sprintf(ancienTemp, "temp%d", indiceTemp - (size + 1));

    sprintf(resultat, "%s := %s + %s", ancienTemp, ancienTemp, pile[sommet]);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(ancienTemp, "temp%d", indiceTemp - (size + 2));

    sprintf(resultat, "%s := %s + %s", ancienTemp, ancienTemp, temp);

    printf("%02d %s\n", Ligne++, resultat);

    sommet--;
}

void Quad_variance(int size)
{
    char ancienTemp[10] = "";

    sprintf(ancienTemp, "temp%d", indiceTemp - size - 1);

    sprintf(resultat, "%s := %s / %d", ancienTemp, ancienTemp, size);

    printf("%02d %s\n", Ligne++, resultat);

    char prevTemp2[10] = "";

    sprintf(prevTemp2, "temp%d", indiceTemp - size);

    sprintf(resultat, "%s := %s / %d", prevTemp2, prevTemp2, size);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "%s := %s * %s", prevTemp2, prevTemp2, prevTemp2);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(temp, "temp%d", indiceTemp++);

    sprintf(resultat, "%s := %s - %s", prevTemp2, prevTemp2, ancienTemp);

    printf("%02d %s\n", Ligne++, resultat);

    indiceTemp -= size + 1;

    sprintf(temp, "temp%d", indiceTemp);

    sommet -= size - 2;

    strcpy(pile[sommet], temp);
}

void Quad_ecartype()
{
    char temp1[10] = "";

    sprintf(temp1, "temp%d", indiceTemp++); 

    char temp2[10] = "";

    sprintf(temp, "temp%d", indiceTemp++);  

    sprintf(temp2, "temp%d", indiceTemp++); 

    sprintf(resultat, "%s := %s / 2", temp, temp1);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "%s := 0", temp2);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "COMP %s %s", temp, temp2); 

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "JE GOTO %d", Ligne + 6);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "%s := %s", temp2, temp);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "%s := %s / %s", temp, temp1, temp2);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "%s := %s + %s", temp, temp, temp2);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "%s := %s / 2", temp, temp);

    printf("%02d %s\n", Ligne++, resultat);

    sprintf(resultat, "JMP GOTO %d", Ligne - 6);

    printf("%02d %s\n", Ligne++, resultat);

    strcpy(pile[sommet], temp);
}