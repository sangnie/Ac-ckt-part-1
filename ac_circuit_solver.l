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
Unit "FH"|"PH"|"NH"|"UH"|"MH"|"KH"|"MEGH"|"F"|"PF"|"NF"|"UF"|"MF"|"KF"|"MEGF"|"P"|"N"|"U"|"M"|"K"|"MEG"|"H"|""|"FF"

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
									(yylval.e).rest[count]=yytext[i];
									i++;
									count++;
								}
								while(yytext[i]!='(')
								{
									(yylval.e).rest[count]=yytext[i];
									i++;
									count++;
								}
								int count2=0;
								int flag=0;
								(yylval.e).rest[count]=yytext[i];
								(yylval.e).rest[count+1]=' ';
								count=count+2;
								i=i+2;
								//SETTING DC
								(yylval.e).DC=0;
								while(yytext[i]!=' ')
								{
									if(yytext[i]=='.')
									flag=count2;
									else
									(yylval.e).DC=(yylval.e).DC*10+yytext[i]-'0';
									(yylval.e).rest[count]=yytext[i];
									count++;
									i++;
									count2++;
								}
								if(flag!=0)
								(yylval.e).DC=(yylval.e).DC/pow(10,count2-flag-1);
								count2=0;
								printf("DC=%f\n",(yylval.e).DC);		
								(yylval.e).rest[count]=' ';
								count++;
								i++;
								flag=0;
								count2=0;
								(yylval.e).amplitude=0;
								
								while(yytext[i]!=' ') 
								{
								if(yytext[i]=='.')
								flag=count2;
								else
								(yylval.e).amplitude=(yylval.e).amplitude*10+yytext[i]-'0';
								(yylval.e).rest[count]=yytext[i];
								count++;
								i++;
								count2++;
								}
								if(flag!=0)
								(yylval.e).amplitude=(yylval.e).amplitude/pow(10,count2-flag-1);
								count2=0;
								printf("amplitude=%f\n",(yylval.e).amplitude);
								
								(yylval.e).rest[count]=' ';
								count++;
								i++;
								flag=0;
								count2=0;
								(yylval.e).frequency=0;
								while(yytext[i]!='K' && yytext[i]!='h')
								{
								if(yytext[i]=='.')
								flag=count2;
								else
								(yylval.e).frequency=(yylval.e).frequency*10+yytext[i]-'0';
								(yylval.e).rest[count]=yytext[i];
								count++;
								i++;
								count2++;
								}
								if(flag!=0)
								(yylval.e).frequency=(yylval.e).frequency/pow(10,count2-flag-1);
								count2=0;
								printf("frequency=%f\n",(yylval.e).frequency);
								
								while(yytext[i]!=' ')
								{
									(yylval.e).unit[count2]=yytext[i];
									(yylval.e).rest[count]=yytext[i];
									i++;
									count2++;
									count++;
									
								}
								printf("unit=%s\n",(yylval.e).unit);
								
								(yylval.e).rest[count]=' ';
								count++;
								i++;
								flag=0;
								count2=0;
								(yylval.e).delay=0;
								
								while(yytext[i]!='S') 
								{
								if(yytext[i]=='.')
								flag=count2;
								else
								(yylval.e).delay=(yylval.e).delay*10+yytext[i]-'0';
								(yylval.e).rest[count]=yytext[i];
								count++;
								i++;
								count2++;
								}
								
								
								if(flag!=0)
								(yylval.e).delay=(yylval.e).delay/pow(10,count2-flag-1);
								count2=0;
								printf("delay=%f\n",(yylval.e).delay);
								(yylval.e).damp=0;
								/*while(yytext[i]!='S')
								{
									(yylval.e).rest[count]=yytext[i];
									i++;
									count++;
								}*/
									count--;
									(yylval.e).rest[count+1]=' ';
									(yylval.e).rest[count+2]='0';
									(yylval.e).rest[count+3]=' ';
									(yylval.e).rest[count+4]=')';
									(yylval.e).rest[count+5]='\0';
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
									printf("rest=%s",(yylval.e).rest);
								
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
