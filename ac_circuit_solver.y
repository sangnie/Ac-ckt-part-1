%{
#include "code.h"
 #include <stdio.h>
 #include <stdlib.h>
#include <string.h>
// int yylex(void);
void yyerror(char *);

extern FILE* yyout;
FILE* inp;

elem comps[10000];
net* nets[10000];
int nNets[10000]={0};
int bNets[10000]={0};
int nSize=0, cSize=1, grounded=0;
%}

%union{
	elem e;
};

%token RES CAP IND SOURCE 
%type <e>exp RES CAP IND SOURCE

%%
exp: RES {comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2));nSize++;}
	|CAP {comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	|IND { comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	|SOURCE {comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	| exp RES {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	| exp CAP {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	| exp IND {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	| exp SOURCE {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	;
%%

void yyerror(char *s) {
 fprintf(stderr, "%s\n", s);
}


void addNets(net **n1){
	int i;
	for(i=1;i<cSize;i++){
		if(strcmp(nets[i]->name,(*n1)->name)==0){
			nNets[i]++;
			*n1 = nets[i];
			return;
		}
	}
	if(strcmp("0",(*n1)->name)==0){
		nNets[0]++;
		*n1 = nets[0];
		return;
	}
	nets[cSize] = malloc(sizeof(net));
	nNets[cSize] = 1;
	nets[cSize] = *n1;
	nets[cSize]->x = 50 + cSize*100;
	nets[cSize]->y = 50;
	nets[cSize]->setMin = 0;
	nets[cSize]->max = 0;
	cSize++;
	return;
}

void print(elem e, char i, int x, int y, int x2, int y2)
{
	char* id=calloc(100,sizeof(char));
	int offsetx,offsety,width,height;
	int minx,miny,maxx,maxy,shift;
	if(x<=x2)
	{minx=x; miny=y; maxx=x2; maxy=y2;}
	else
	{minx=x2; miny=y2; maxx=x; maxy=y;}
	if(i=='r') {id="#resistor"; offsetx=12; offsety=-10; width=76; height=20; shift=2;}
	else if(i=='i') {id="#inductor"; offsetx=1; offsety=-10; width=43; height=20; shift=10;}
	else if(i=='c') {id="#capacitor"; offsetx=12; offsety=-10; width=15; height=20; shift=10;}
	else if(i=='v') {id="#voltage"; offsetx=3; offsety=-10; width=20; height=20; shift=10;}
	else if(i=='x') {id="#current"; offsetx=3; offsety=-10; width=40; height=20; shift=10;}
	fprintf(yyout,"<svg><line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" /></svg>\n",minx,miny,maxx,maxy);
	fprintf(yyout,"<svg width=\"1000\" height=\"1000\"><rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\" style=\"fill:white;stroke:white;stroke-width:0.1;opacity:1\"/></svg>\n",minx+offsetx+shift,miny+offsety,width,height);	
	fprintf(yyout,"<use x=\"%d\" y=\"%d\" xlink:href=\"%s\" />\n", minx+shift,miny,id);
	fprintf(yyout,"<svg><circle r=\"2\" cx=\"%d\" cy=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" /></svg>\n",minx,miny);
	fprintf(yyout,"<svg><circle r=\"2\" cx=\"%d\" cy=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" /></svg>\n",maxx,maxy);
	if(i=='v'||i=='x')
    fprintf(yyout,"<svg><text x=\"%d\" y=\"%d\" fill=\"black\" font-size=\"10\">%s %s</text></svg>\n",minx+shift+15,miny-14,e.n,e.unit);
    else
    fprintf(yyout,"<svg><text x=\"%d\" y=\"%d\" fill=\"black\" font-size=\"10\">%s %g %s</text></svg>\n",minx+shift+15,miny-14,e.n,e.value,e.unit);


}

void prtCmps(){
	int i,y,j;
	for(i=0; i<nSize; i++){
		/*printf("%s ", comps[i].n);
		printf("%c ", comps[i].type);
		printf("(%s ", comps[i].net1->name);
		printf("%d ",comps[i].net1->x);
		printf("%d) ",comps[i].net1->y);
		printf("(%s ", comps[i].net2->name);
		printf("%d ",comps[i].net2->x);
		printf("%d) ",comps[i].net2->y);
		printf("%g", comps[i].value);
		printf("%s\n", comps[i].unit);*/
		y = (comps[i].net1->y > comps[i].net2->y) ? comps[i].net1->y : comps[i].net2->y;
		print(comps[i],comps[i].type,comps[i].net1->x,y,comps[i].net2->x,y);
		
		if(comps[i].net1->setMin ==0){
			comps[i].net1->min = y;
			comps[i].net1->max = y;
			comps[i].net1->setMin = 1;
		}
		if(comps[i].net2->setMin ==0){
			comps[i].net2->min = y;
			comps[i].net2->max = y;
			comps[i].net2->setMin = 1;
		}
		if(y>comps[i].net1->max){
			//printf("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&\n");
			comps[i].net1->max = y;
		}
		if(y>comps[i].net2->max){
			//printf("***********************************\n");
			comps[i].net2->max = y;
		}
		/*ALL IN DIFFEREMT LINES*/
		y+=55;
		comps[i].net1->y =y-20;
		comps[i].net2->y =y+30;
		// if(comps[i].net1->y == y){comps[i].net1->y +=80;}
		// if(comps[i].net2->y == y){comps[i].net2->y +=80;}	
		// if(comps[i].net1->x > comps[i].net2->x){comps[i].net2->y +=30;}
		// else {comps[i].net1->y +=30;}
		/*printf("%s ", comps[i].n);
		printf("(%s ", comps[i].net1->name);
		printf("%d ",comps[i].net1->x);
		printf("%d) ",comps[i].net1->y);
		printf("(%s ", comps[i].net2->name);
		printf("%d ",comps[i].net2->x);
		printf("%d) ",comps[i].net2->y);
		printf("%g", comps[i].value);
		printf("%s\n", comps[i].unit);*/
	}

	if(nNets[0]>0){
fprintf(yyout,"<svg><line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" /></svg>\n",nets[0]->x,nets[0]->min,nets[0]->x,nets[0]->max);
nets[0]->max += 5;
fprintf(yyout,"<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" />\n",nets[0]->x-10,nets[0]->max,nets[0]->x+10,nets[0]->max);
fprintf(yyout,"<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" />\n",nets[0]->x-5,nets[0]->max+5,nets[0]->x+5,nets[0]->max+5);
fprintf(yyout,"<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" />\n",nets[0]->x-2,nets[0]->max+10,nets[0]->x+2,nets[0]->max+10);
}

for(i=1;i<cSize;i++){
fprintf(yyout,"<svg><line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" style=\"stroke:rgb(0,0,0);stroke-width:1px\" /></svg>\n",nets[i]->x,nets[i]->min,nets[i]->x,nets[i]->max);
}
	}


int main (int argc, char* argv[])
// void main()
{
	nets[0] = malloc(sizeof(net));
	nets[0]->x=50;
	nets[0]->y=50;
	nets[0]->setMin = 0;
	nets[0]->max = 0;
	nets[0]->name[0]='0';
	nets[0]->name[1]='\0';
	nNets[0] = 0;

	yyout=fopen("out.svg","w");
	inp=fopen("inp.txt","r");
	char c;
	c=getc(inp);
	while(c!=EOF)
	{
	   putc(c, yyout);
	  c = getc(inp);
	}
	fclose(inp);

	extern FILE* yyin;
	yyin=fopen(argv[1],"r");        
	
	yyparse();
	prtCmps();
	int i;

	/*for(i=0; i<nSize; i++){
		printf("%s ", comps[i].n);
		printf("%c ", comps[i].type);
		printf("(%s ", comps[i].net1->name);
		printf("%d ",comps[i].net1->x);
		printf("%d) ",comps[i].net1->y);
		printf("(%s ", comps[i].net2->name);
		printf("%d ",comps[i].net2->x);
		printf("%d) ",comps[i].net2->y);
		printf("%g", comps[i].value);
		printf("%s\n", comps[i].unit);
	}

	printf("%d\n", cSize);

	for(i=0; i<cSize; i++){
		printf("%s ",nets[i]->name);
		printf("%d ",nets[i]->x);
		printf("%d ",nets[i]->y);
		printf("%d ",nets[i]->min);
		printf("%d ",nets[i]->max);
		printf("%d\n", nNets[i]);
	}*/
		for(i=0; i<cSize; i++){
		fprintf(yyout,"<svg><text x=\"%d\" y=\"%d\" fill=\"black\" font-size=\"10\">%s</text></svg>\n",nets[i]->x-3,nets[i]->min-3,nets[i]->name);
	}
		fprintf(yyout, "\n</svg>\n");
	if(nNets[0]==0){
		fprintf(stderr,"No ground present.\n");
	}

	for(i=0; i<cSize; i++){
		if(nNets[i]==1){
			printf("Invalid Circuit-dangling wire present.\n");
			break;
		}
	}
}
