%{
#include "code.h"
#include "top.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "top.tab.h"
#define YYSTYPE struct elem
void yyerror(char *);
%}

Id ([A-Z a-z]+([0-9]*)?)+
Net ([A-Z a-z]+([0-9]*)?)+|0
Digit [0-9]+|[0-9]+"."[0-9]+
Unit "FH"|"PH"|"NH"|"UH"|"MH"|"KH"|"MEGH"|"F"|"PF"|"NF"|"UF"|"MF"|"KF"|"FF"|"MEGF"|"P"|"N"|"U"|"M"|"K"|"MEG"

SrcId (I|V)[0-9]* 

%%

{Id}(" "+{Net}){2}(" "+{Digit}{Unit}?) { 
							int i=0,count=0;
							while(yytext[i]!=' ')
							{
								(yylval.e).n[i]=yytext[i];
								i++;
							}
							(yylval.e).n[i]='\0';
							printf("name: %s\n",(yylval.e).n);
							count=0;
							i++;
							while(yytext[i]!=' ')
							{
								(yylval.e).net1.name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net1.name[count]='\0';
							printf("net1 %s\n",(yylval.e).net1.name);
							count=0;
							i++;
							while(yytext[i]!=' ')
							{
								(yylval.e).net2.name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net2.name[count]='\0';
							printf("net2 %s\n",(yylval.e).net2.name);
							i++;
							(yylval.e).value=0;
							int flag;
							count=0;
							while(yytext[i]!='F' && yytext[i]!='P' && yytext[i]!='N' && yytext[i]!='U' && yytext[i]!='M' && yytext[i]!='H'&& yytext[i]!='K' && i!=yyleng) 
							{
							if(yytext[i]=='.')
							flag=count;
							else
							(yylval.e).value=(yylval.e).value*10+yytext[i]-'0';
							i++;
							count++;
							}
							printf("flag: %d\n",flag);
							(yylval.e).value=(yylval.e).value/pow(10,count-flag-1);
							printf("value: %f\n",(yylval.e).value);
							count=0;
							if(i==yyleng) { (yylval.e).unit[0]=' '; (yylval.e).unit[0]='\0'; return RES; }
							while(i<=yyleng)
							{
								(yylval.e).unit[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).unit[count+1]='\0';
							printf("unit: %s\n",(yylval.e).unit);
							if(strcmp((yylval.e).unit,"P")==0||strcmp((yylval.e).unit,"N")==0||strcmp((yylval.e).unit,"U")==0||strcmp((yylval.e).unit,"M")==0||strcmp((yylval.e).unit,"K")==0||strcmp((yylval.e).unit,"MEG")==0||strcmp((yylval.e).unit,"")==0) return RES;
							else if(strcmp((yylval.e).unit,"PF")==0||strcmp((yylval.e).unit,"NF")==0||strcmp((yylval.e).unit,"UF")==0||strcmp((yylval.e).unit,"MF")==0||strcmp((yylval.e).unit,"KF")==0||strcmp((yylval.e).unit,"MEGF")==0||strcmp((yylval.e).unit,"F")==0||strcmp((yylval.e).unit,"FF")==0) return CAP;
							else if(strcmp((yylval.e).unit,"PH")==0||strcmp((yylval.e).unit,"NH")==0||strcmp((yylval.e).unit,"UH")==0||strcmp((yylval.e).unit,"MH")==0||strcmp((yylval.e).unit,"KH")==0||strcmp((yylval.e).unit,"MEGH")==0||strcmp((yylval.e).unit,"FH")==0) return IND;
							else printf("invalid input\n");
						}

{SrcId}(" "+{Net}){2}(" ")+"SINE"(" ")+\((" "+{Digit}){3}"Khz"(" "+{Digit})"S"(" "+{Digit})(" ")\) {
							printf("source identified\n");
							int i=0,count=0;
							while(yytext[i]!=' ')
							{
								(yylval.e).n[i]=yytext[i];
								i++;
							}
							(yylval.e).n[i]='\0';
							printf("name: %s\n",(yylval.e).n);
							count=0;
							i++;
							while(yytext[i]!=' ')
							{
								(yylval.e).net1.name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net1.name[count]='\0';
							printf("net1 %s\n",(yylval.e).net1.name);
							count=0;
							i++;
							while(yytext[i]!=' ')
							{
								(yylval.e).net2.name[count]=yytext[i];
								count++;
								i++;
							}
							(yylval.e).net2.name[count]='\0';
							printf("net2 %s\n",(yylval.e).net2.name);
							i++;
							(yylval.e).value=0;
							count=0;
							while(i<=yyleng)
							{
								(yylval.e).unit[count]=yytext[i];
								count++;
								i++;
							}
							return SOURCE;
							};



%%

int yywrap(void) 
{
    return 1;
}
