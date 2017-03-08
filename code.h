void yyerror(char* s);
#include <complex.h>
typedef struct 
{
	char name[100];
	int x;
	int idx;
	int y;
	int min;
	int max;
	int setMin;
	int setMax;
} net;

typedef struct 
{
	char type;
	char n[100];
	net* net1;
	net* net2;
	double value;
	double frequency;
	double DC;
	double amplitude;
	double delay;
	double damp;
	double complex impedence;
	char unit[100];
	char dcoffsetunit[100];
	char rest[100];
	int x1,y1,x2,y2;
} elem;

typedef struct {
	float val;
	float jval;
} impedance;

void addNets(net** e);
void print(elem e,char i, int x, int y, int x2, int y2);
void printlines();
void drawline(int x, int y, int x2, int y2);
