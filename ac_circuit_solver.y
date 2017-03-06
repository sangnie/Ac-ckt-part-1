%{
#include "code.h"
 #include <stdio.h>
 #include <stdlib.h>
#include <string.h>
#include <math.h>
// int yylex(void);
void yyerror(char *);

extern FILE* yyout;
FILE* inp;

elem comps[10000];
net* nets[10000];
int nNets[10000]={0};
float coeffs[10000][10000]={0.0};
int nSize=0, cSize=1, grounded=0;

#define V_SRC 0
#define I_SRC 1
int sourceType;
int mVsrc = 0;
%}

%union{
	elem e;
};

%token RES CAP IND VSRC ISRC
%type <e>exp RES CAP IND VSRC ISRC

%%
exp: RES {comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2));nSize++;}
	|CAP {comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	|IND { comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	|VSRC { comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); sourceType = V_SRC; nSize++; mVsrc++;}
	|ISRC { comps[nSize] = $1; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); sourceType = I_SRC; nSize++;}
	
	| exp RES {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	| exp CAP {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	| exp IND {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); nSize++;}
	| exp VSRC {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); sourceType= V_SRC; nSize++; mVsrc++;}
	| exp ISRC {comps[nSize] = $2; addNets(&(comps[nSize].net1)); addNets(&(comps[nSize].net2)); sourceType= I_SRC; nSize++;}
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
	nets[cSize]->idx = cSize-1;
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

void solve_matrix(){
	// printf("yay\n");
	int row=cSize-1+mVsrc,col=cSize-1+mVsrc;
	int row1=cSize-1+mVsrc,col1=1;
	int n=cSize-1+mVsrc,i,j,k,p;
	float c,d,e,sum,a;
	// float coeffs[10000][10000];
	float var[10000],b;
	// printf("yay1\n");

	// float** matrix = (float**) malloc (cSize * sizeof(float*));
	// for (i=0; i<cSize; i++){
 //    	coeffs[i] = (float *)malloc(cSize * sizeof(float));
 //    }
 //    printf("\n");
	// for(i=0;i<cSize-1;i++){
	// 	for(j=0;j<cSize; j++){
	// 		coeffs[i][j] = coeffs[i+1][j+1];
	// 		printf("%f ", coeffs[i][j]);
	// 	}
	// 	printf("\n");
	// }
	// printf("yay\n");
//Making Upper Triangular Matrix				
	for(k=0;k<n;k++){
		float a= coeffs[k][k],temp=0;
		int ind=k,l,m;
		
		// printf("yay1\n");
		for(l=k+1;l<n;l++){
			// printf("yay5\n");
			if(a<fabs(coeffs[l][k])){
				a= coeffs[l][k];
				ind = l;
				// printf("yay3\n");
			}
			else continue;
		
			for(m=0;m<n+1;m++){
				temp = coeffs[k][m];
				coeffs[k][m] = coeffs[ind][m];
				coeffs[ind][m] = temp;
				// printf("yay4\n");
			}
		}
		// printf("yay2\n");
		for(i=k+1;i<n;i++){
			c = (coeffs[i][k] / coeffs[k][k] ) ;

			for(j=k;j<n+1;j++){
				coeffs[i][j] = coeffs[i][j] -  c * coeffs[k][j] ;

				if(fabs(coeffs[i][j]) < 0.0000005){
					coeffs[i][j] = 0;
	            }
			}
		}
		// printf("yay3\n");
	}
	// printf("yay1\n");

	// Findind the rank of the Matrix
	int count,zerorows=0,aug_non_zero =0;
	
	for(i=0;i<row;i++){
		count = 0;
		for(j=0;j<col +1;j++){
			if(coeffs[i][j] == 0){
				count +=1;
			}
			else continue;
        }
			
		if(count == n){ zerorows +=1 ;}
		else if (count == n+1) {aug_non_zero +=1 ;}
	}
	// printf("yay2\n");

	int rankA,rankAB;

	rankA = row - zerorows;
	rankAB = row - aug_non_zero;

	//Checking the Solution
	if (rankA == rankAB && rankA == col){
	    printf("Unique Solution Exists \n");

		//Back Substitution
		var[n-1] = coeffs[n-1][n] /coeffs[n-1][n-1];
		for(i=0;i<n;i++){
			sum = 0;
			for(j=0;j<i;j++){
				b= var[n-j-1];
				a = coeffs[n-i-1][n-j-1];
				sum = sum +  a*b  ;
			}
			var[n-i-1] = (coeffs[n-i-1][n] - sum)/ coeffs[n-i-1][n-i-1] ;
		}

		for(i=0;i<n;i++){
			printf("X[%d] -> %g\n",i+1,var[i]);
		}
		// printf("yay3\n");
	}
	else{printf("No Finite Solution Exists");}
	// free(matrix);
}

int main (int argc, char* argv[])
{
	nets[0] = malloc(sizeof(net));
	nets[0]->x=50;
	nets[0]->y=50;
	nets[0]->setMin = 0;
	nets[0]->max = 0;
	nets[0]->name[0]='0';
	nets[0]->name[1]='\0';
	nets[0]->idx=-1;
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
	int i,j;

	// for(i=0; i<nSize; i++){
	// 	printf("%s ", comps[i].n);
	// 	printf("%c ", comps[i].type);
	// 	printf("(%s ", comps[i].net1->name);
	// 	printf("%d ",comps[i].net1->x);
	// 	printf("%d) ",comps[i].net1->y);
	// 	printf("(%s ", comps[i].net2->name);
	// 	printf("%d ",comps[i].net2->x);
	// 	printf("%d) ",comps[i].net2->y);
	// 	printf("%g", comps[i].value);
	// 	printf("%s\n", comps[i].unit);
	// }

	// printf("%d\n", cSize);

	
	// for(i=0; i<cSize; i++){
	// 	printf("%s ",nets[i]->name);
	// 	printf("%d ",nets[i]->x);
	// 	printf("%d ",nets[i]->y);
	// 	printf("%d ",nets[i]->min);
	// 	printf("%d ",nets[i]->max);
	// 	printf("%d\n", nNets[i]);
	// }
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
	// printf("\n%d %d\n", nSize ,cSize);

	// for(i=0;i<5;i++){
	// 	for(j=0;j<5;j++){
	// 		printf("%f ",coeffs[i][j] );
	// 	}
	// 	printf("\n");
	// }

	// if(sourceType == V_SRC){
	// 	int v_idx1,v_idx2;

	// 	for(i=0; i<nSize; i++){
	// 		// printf("%s ", comps[i].n);
	// 		// printf("%c ", comps[i].type);
	// 		// printf("(%s ", comps[i].net1->name);
	// 		// printf("%d ",comps[i].net1->x);
	// 		// printf("%d) ",comps[i].net1->y);
	// 		// printf("(%s ", comps[i].net2->name);
	// 		// printf("%d ",comps[i].net2->x);
	// 		// printf("%d) ",comps[i].net2->y);
	// 		// printf("%g", comps[i].value);
	// 		// printf("%s\n", comps[i].unit);
	// 		if(comps[i].type=='v'){
	// 			coeffs[comps[i].net1->idx][cSize] = -1*comps[i].amplitude;
	// 			coeffs[comps[i].net2->idx][cSize] = comps[i].amplitude;
	// 			continue;
	// 		}
	// 		printf("%d ",comps[i].net1->idx);
	// 		printf("%d ",comps[i].net2->idx );
	// 		printf("%f\n",comps[i].value);
	// 		coeffs[comps[i].net1->idx][comps[i].net1->idx] += 1.0/comps[i].value;
	// 		coeffs[comps[i].net1->idx][comps[i].net2->idx] -= 1.0/comps[i].value;

	// 		coeffs[comps[i].net2->idx][comps[i].net1->idx] -= 1.0/comps[i].value;
	// 		coeffs[comps[i].net2->idx][comps[i].net2->idx] += 1.0/comps[i].value;
	// 	}

	// 	for(i=0; i<cSize; i++){
	// 		for(j=0;j<=cSize;j++){
	// 			printf("%f ",coeffs[i][j]);
	// 		}
	// 		printf("\n");
	// 	}
	// 	solve_matrix();

	// } else {
	// 	for(i=0; i<nSize; i++){
	// 		printf("%s ", comps[i].n);
	// 		printf("%c ", comps[i].type);
	// 		printf("(%s ", comps[i].net1->name);
	// 		printf("%d ",comps[i].net1->x);
	// 		printf("%d) ",comps[i].net1->y);
	// 		printf("(%s ", comps[i].net2->name);
	// 		printf("%d ",comps[i].net2->x);
	// 		printf("%d) ",comps[i].net2->y);
	// 		printf("%g", comps[i].value);
	// 		printf("%s\n", comps[i].unit);
	// 		if(comps[i].type=='x'){
	// 			coeffs[comps[i].net1->idx][cSize] = -1*comps[i].amplitude;
	// 			coeffs[comps[i].net2->idx][cSize] = comps[i].amplitude;
	// 			continue;
	// 		}
	// 		printf("%d ",comps[i].net1->idx);
	// 		printf("%d ",comps[i].net2->idx );
	// 		printf("%f\n",comps[i].value);
	// 		coeffs[comps[i].net1->idx][comps[i].net1->idx] += 1.0/comps[i].value;
	// 		coeffs[comps[i].net1->idx][comps[i].net2->idx] -= 1.0/comps[i].value;

	// 		coeffs[comps[i].net2->idx][comps[i].net1->idx] -= 1.0/comps[i].value;
	// 		coeffs[comps[i].net2->idx][comps[i].net2->idx] += 1.0/comps[i].value;
	// 	}

	// 	for(i=0; i<cSize; i++){
	// 		for(j=0;j<=cSize;j++){
	// 			printf("%f ",coeffs[i][j]);
	// 		}
	// 		printf("\n");
	// 	}
	// 	solve_matrix();
	// }
	// printf("yay57487\n");

	// float** matrix = (float**) malloc ((cSize - 1 + mVsrc) * sizeof(float*));
	// for (i=0; i<(cSize - 1 + mVsrc); i++){
 //    	coeffs[i] = (float *)malloc((cSize - 1 + mVsrc) * sizeof(float));
 //    }
	// for(i=0; i<cSize - 1 + mVsrc; i++){
	// 	for(j=0;j<=cSize - 1 + mVsrc;j++){
	// 		printf("%f ",coeffs[i][j]);
	// 	}
	// 	printf("\n");
	// }
    int mV=0;
    printf("%d %d \n", cSize-1, mVsrc);
	for(i=0; i<nSize; i++){
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
		// if(comps[i].type=='x'){
		// 	coeffs[comps[i].net1->idx][cSize] = -1*comps[i].amplitude;
		// 	coeffs[comps[i].net2->idx][cSize] = comps[i].amplitude;
		// 	continue;
		// }
		printf("%d ",comps[i].net1->idx);
		printf("%d ",comps[i].net2->idx );
		printf("%f\n",comps[i].value);
		// coeffs[comps[i].net1->idx][comps[i].net1->idx] += 1.0/comps[i].value;
		// coeffs[comps[i].net1->idx][comps[i].net2->idx] -= 1.0/comps[i].value;

		// coeffs[comps[i].net2->idx][comps[i].net1->idx] -= 1.0/comps[i].value;
		// coeffs[comps[i].net2->idx][comps[i].net2->idx] += 1.0/comps[i].value;

		switch(comps[i].type){
			case 'x' :
				if(comps[i].net1->idx != -1) coeffs[comps[i].net1->idx][cSize-1 + mVsrc] = comps[i].amplitude;
				if(comps[i].net2->idx != -1) coeffs[comps[i].net2->idx][cSize-1 + mVsrc] = comps[i].amplitude;
				break;

			case 'v' :
				if(comps[i].net1->idx==-1){
					coeffs[comps[i].net2->idx][cSize-1 + mV] += -1.0;
					coeffs[cSize-1 + mV][comps[i].net2->idx] += -1.0;
				} else {
					if(comps[i].net2->idx==-1){
						coeffs[comps[i].net1->idx][cSize-1 + mV] += 1.0;
						coeffs[cSize-1 + mV][comps[i].net1->idx] += 1.0;
					} else {
						coeffs[comps[i].net1->idx][cSize-1 + mV] += 1.0;
						coeffs[comps[i].net2->idx][cSize-1 + mV] += -1.0;
						
						coeffs[cSize-1 + mV][comps[i].net1->idx] += 1.0;
						coeffs[cSize-1 + mV][comps[i].net2->idx] += -1.0;
					}
				}
				// if(comps[i].net1->idx==-1){
				// 	coeffs[comps[i].net2->idx][cSize-1 + mV] += -i;
				// 	coeffs[cSize-1 + mV][comps[i].net2->idx] += -i;
				// } else {
				// 	if(comps[i].net2->idx==-1){
				// 		coeffs[comps[i].net1->idx][cSize-1 + mV] += i;
				// 		coeffs[cSize-1 + mV][comps[i].net1->idx] += i;
				// 	} else {
				// 		coeffs[comps[i].net1->idx][cSize-1 + mV] += i;
				// 		coeffs[comps[i].net2->idx][cSize-1 + mV] += -i;
						
				// 		coeffs[cSize-1 + mV][comps[i].net1->idx] += i;
				// 		coeffs[cSize-1 + mV][comps[i].net2->idx] += -i;
				// 	}
				// }
				coeffs[cSize-1 + mV][cSize-1 + mVsrc] = comps[i].amplitude;
				mV++;
				break;

			case 'r' :
			case 'i' :
			case 'c' :
				if(comps[i].net1->idx==-1){
					coeffs[comps[i].net2->idx][comps[i].net2->idx] += 1.0/comps[i].value;
				} else {
					if(comps[i].net2->idx==-1){
						coeffs[comps[i].net1->idx][comps[i].net1->idx] += 1.0/comps[i].value;
					} else {
						coeffs[comps[i].net1->idx][comps[i].net1->idx] += 1.0/comps[i].value;
						coeffs[comps[i].net1->idx][comps[i].net2->idx] -= 1.0/comps[i].value;
						coeffs[comps[i].net2->idx][comps[i].net1->idx] -= 1.0/comps[i].value;
						coeffs[comps[i].net2->idx][comps[i].net2->idx] += 1.0/comps[i].value;
					}
				}
				// if(comps[i].net1->idx==-1){
				// 	coeffs[comps[i].net2->idx][comps[i].net2->idx] += i;
				// } else {
				// 	if(comps[i].net2->idx==-1){
				// 		coeffs[comps[i].net1->idx][comps[i].net1->idx] += i;
				// 	} else {
				// 		coeffs[comps[i].net1->idx][comps[i].net1->idx] += i;
				// 		coeffs[comps[i].net1->idx][comps[i].net2->idx] -= i;
				// 		coeffs[comps[i].net2->idx][comps[i].net1->idx] -= i;
				// 		coeffs[comps[i].net2->idx][comps[i].net2->idx] += i;
				// 	}
				// }
				break;

		}
	}

	for(i=0; i<cSize - 1 + mVsrc; i++){
		for(j=0;j<=cSize - 1 + mVsrc;j++){
			printf("%f ",coeffs[i][j]);
		}
		printf("\n");
	}
	solve_matrix();
	for(i=0; i<cSize - 1 + mVsrc; i++){
		for(j=0;j<=cSize - 1 + mVsrc;j++){
			printf("%f ",coeffs[i][j]);
		}
		printf("\n");
	}
}
