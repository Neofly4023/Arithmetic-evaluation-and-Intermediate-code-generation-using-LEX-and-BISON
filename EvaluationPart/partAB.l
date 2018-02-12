%{
#include "partAB.tab.h"
%}

nombre [0-9]+"."[0-9]*

%%

{nombre} {
	yylval.valeur_f = atof(yytext);
	return parameter;
    }
[+*/-] {
	yylval.valeur_c=(char)yytext[0]; 
	return (char)yytext[0]; }
	
[,()\n]	{
	yylval.valeur_c=(char)yytext[0]; 
	return (char)yytext[0]; }
"somme" {
	yylval.valeur_c='\0';
	return somme; 
	}
"moyenne" {
	yylval.valeur_c='\0';
	return moyenne;
	}
"variance" {
	yylval.valeur_c='\0';
	return variance;
	}
"ecartype" {
	yylval.valeur_c='\0';
	return ecartype;
	}	
" " {;}

. { 
	printf("\nErreur lexicale !\n");
	exit(-1);
	}
%%
