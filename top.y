%{
#include "code.h"
 #include <stdio.h>
 #include <stdlib.h>
// int yylex(void);
// void yyerror(char *);
 int x=10,y=-10;
 extern FILE* yyout;
FILE* inp;
%}

%union{
	struct elem e;
	struct source s;
};


%token RES CAP IND SOURCE
%type <e>exp

%%
exp: RES {printf("resistor found\n"); fprintf(yyout,"<use x=\"%d\" y=\"%d\" xlink:href=\"#resistor\" transform=\"rotate(90,10,10)\" />", x,y); x=x+20; y=y-20;};
exp: CAP {printf("capacitor found\n"); fprintf(yyout,"<use x=\"%d\" y=\"%d\" xlink:href=\"#capacitor\" transform=\"rotate(90,10,10)\" />", x,y); x=x+20; y=y-20;};
exp: IND {printf("inductor found\n"); fprintf(yyout,"<use x=\"%d\" y=\"%d\" xlink:href=\"#inductor\" transform=\"rotate(90,10,10)\" />", x,y); x=x+20; y=y-20;};
exp: SOURCE {printf("source found\n");};
%%

void yyerror(char *s) {
 fprintf(stderr, "%s\n", s);
  exit(1);
}

//int main (int argc, char* argv[])
void main()
{
 extern FILE* yyin;
// yyin=fopen(argv[1],"r");        
yyout=fopen("out.svg","w");
inp=fopen("inp.txt","r");
char c;
c=getc(inp);
fprintf(yyout,"wtffff\n");
while(c!=EOF)
{
   putc(c, yyout);
  c = getc(inp);
}
 //fprintf(yyout, "%s\n", STARTSTRING);

           yyparse();

   fprintf(yyout, "\n</svg>\n");
}
