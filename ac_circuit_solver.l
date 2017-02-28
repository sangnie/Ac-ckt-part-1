%{
#include "code.h"
#include "ac_circuit_solver.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#define YYSTYPE elem
void yyerror(char *);
%}

Id ([A-Z a-z]+([0-9]*)?)+
Net ([A-Z a-z]+([0-9]*)?)+|0
Digit [0-9]+|[0-9]+"."[0-9]+
Unit "FH"|"PH"|"NH"|"UH"|"MH"|"KH"|"MEGH"|"F"|"PF"|"NF"|"UF"|"MF"|"KF"|"MEGF"|"P"|"N"|"U"|"M"|"K"|"MEG"|"H"|""

SrcId (I|V)[0-9]* 

%%

(" ")*{Id}(" "+{Net}){2}(" "+{Digit}{Unit})(" ")* { 
							int i=0,count=0;
							while(yytext[i]==' ')
							i++;
							while(yytext[i]!=' ')
							{
								(yylval.e).n[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).n[count]='\0';
							count=0;
							i++;
							yylval.e.net1 = malloc(sizeof(net));
							yylval.e.net2 = malloc(sizeof(net));
							while(yytext[i]!=' ')
							{
								(yylval.e).net1->name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net1->name[count]='\0';
							count=0;
							i++;
							while(yytext[i]!=' ')
							{
								(yylval.e).net2->name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net2->name[count]='\0';
							i++;
							(yylval.e).value=0;
							int flag=0;
							count=0;
							while(yytext[i]!='F' && yytext[i]!='P' && yytext[i]!='N' && yytext[i]!='U' && yytext[i]!='M' && yytext[i]!='H'&& yytext[i]!='K' && i!=yyleng && yytext[i]!=' ') 
							{
							if(yytext[i]=='.')
							flag=count;
							else
							(yylval.e).value=(yylval.e).value*10+yytext[i]-'0';
							i++;
							count++;
							}
							if(flag!=0)
							(yylval.e).value=(yylval.e).value/pow(10,count-flag-1);
							count=0;
							while(i<=yyleng && yytext[i]!=' ')
							{
								(yylval.e).unit[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).unit[count]='\0';
							if(strcmp((yylval.e).unit,"P")==0||strcmp((yylval.e).unit,"N")==0||strcmp((yylval.e).unit,"U")==0||strcmp((yylval.e).unit,"M")==0||strcmp((yylval.e).unit,"K")==0||strcmp((yylval.e).unit,"MEG")==0||strcmp((yylval.e).unit,"")==0) {yylval.e.type = 'r'; 		 
					return RES;}
							else if(strcmp((yylval.e).unit,"PF")==0||strcmp((yylval.e).unit,"NF")==0||strcmp((yylval.e).unit,"UF")==0||strcmp((yylval.e).unit,"MF")==0||strcmp((yylval.e).unit,"KF")==0||strcmp((yylval.e).unit,"MEGF")==0||strcmp((yylval.e).unit,"FF")==0||strcmp((yylval.e).unit,"F")==0) {yylval.e.type = 'c'; return CAP;}
							else if(strcmp((yylval.e).unit,"PH")==0||strcmp((yylval.e).unit,"NH")==0||strcmp((yylval.e).unit,"UH")==0||strcmp((yylval.e).unit,"MH")==0||strcmp((yylval.e).unit,"KH")==0||strcmp((yylval.e).unit,"MEGH")==0||strcmp((yylval.e).unit,"FH")==0||strcmp((yylval.e).unit,"H")==0) {yylval.e.type = 'i';return IND;}
							 else printf("invalid input unit\n");
						}

(" ")*{SrcId}(" "+{Net}){2}(" ")+"SINE"(" ")+\((" "+{Digit}){3}"Khz"(" "+{Digit})"S"(" "+{Digit})?(" ")\)(" ")* {
							int i=0,count=0;
							while(yytext[i]!=' ')
							{
								(yylval.e).n[count]=yytext[i];
								i++;
								count++;
							}
							(yylval.e).n[i]='\0';
							count=0;
							i++;
							yylval.e.net1 = malloc(sizeof(net));
							yylval.e.net2 = malloc(sizeof(net));
							while(yytext[i]!=' ')
							{
								(yylval.e).net1->name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net1->name[count]='\0';
							count=0;
							i++;
							while(yytext[i]!=' ')
							{
								(yylval.e).net2->name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net2->name[count]='\0';
							i++;
							(yylval.e).value=0;
							count=0;
							int j;
								for(j=0;j<4;j++)
								{
									(yylval.e).unit[count]=yytext[i];
									i++;
									count++;
								}
								while(yytext[i]!='S')
								{
									(yylval.e).unit[count]=yytext[i];
									i++;
									count++;
								}
									count--;
									(yylval.e).unit[count+1]=' ';
									(yylval.e).unit[count+2]='0';
									(yylval.e).unit[count+3]=' ';
									(yylval.e).unit[count+4]=')';
									(yylval.e).unit[count+5]='\0';
									if(yytext[i+2]==')')
									printf("Damping factor missing, assumed to be 0\n");
									else
									{	i=i+2;
										int x=0;
										while(yytext[i]!=' ')
										{
											if(yytext[i]!='.')
											x=x*10+yytext[i]-'0';
											i++;
										}
										if(x!=0)
										printf("Error: damping factor can only be 0. Value changed to 0\n");										
									}
								yylval.e.value=0;
							if((yylval.e).n[0]=='I')
							yylval.e.type = 'x';
							else yylval.e.type='v';
							return SOURCE;
							};

.* { yyerror("Invalid Input");
	}


%%

int yywrap(void) 
{
    return 1;
}
