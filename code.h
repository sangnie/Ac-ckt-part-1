void yyerror(char* s);

struct net
{
	char name[100];
	int x;
	int y;
};

struct elem
{
	char n[100];
	struct net net1;
	struct net net2;
	float value;
	char unit[100];
};

struct source
{
	char n[100];
	struct net net1;
	struct net net2;
	char rest[100];
};
