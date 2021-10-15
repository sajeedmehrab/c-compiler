%option noyywrap

%{
#include <bits/stdc++.h>
#include "symbol.h"
using namespace std;
FILE *logout;
# include "y.tab.h"

int line_count=1;
int num_error = 0;
void yyerror (const char *);
FILE *tokenout;

//SymbolTable * symt;

//symboltable ends here


%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n

%%

{NEWLINE} {line_count++;}

{WHITESPACE} {printf("Ignored\n");}

"if"	{
			string name;
                	string type;
			name = yytext;
			type = "if";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return IF;
		}
		
"for" {
			string name;
                	string type;
			name = yytext;
			type = "for";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return FOR;

}

"do" {
			string name;
                	string type;
			name = yytext;
			type = "do";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return DO;
}

"int" {
			string name;
                	string type;
			name = yytext;
			type = "type_specifier";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return INT;
}

"float" {
			string name;
                	string type;
			name = yytext;
			type = "float";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return FLOAT;
}

"void" {
			string name;
                	string type;
			name = yytext;
			type = "void";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return VOID;
}

"switch" {
			string name;
                	string type;
			name = yytext;
			type = "switch";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return SWITCH;
}

"default" {
			string name;
                	string type;
			name = yytext;
			type = "default";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return DEFAULT;
}

"else" {
			string name;
                	string type;
			name = yytext;
			type = "else";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return ELSE;
}

"while" {
			string name;
                	string type;
			name = yytext;
			type = "while";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return WHILE;
}

"break" {
			string name;
                	string type;
			name = yytext;
			type = "break";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return BREAK;
}

"char" {
			string name;
                	string type;
			name = yytext;
			type = "char";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return CHAR;
}

"double" {
			string name;
                	string type;
			name = yytext;
			type = "double";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return DOUBLE;
}

"return" {
			string name;
                	string type;
			name = yytext;
			type = "return";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return RETURN;
}

"case" {
			string name;
                	string type;
			name = yytext;
			type = "case";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return CASE;
}

"continue" {
			string name;
                	string type;
			name = yytext;
			type = "continue";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return CONTINUE;
}

"printf"  {
			string name;
			string type;
			name = yytext;
			type = "printf";
			SymbolInfo* newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return PRINTLN;
}

['][\\]['] {
				//fprintf(logout, "Error at line number: %d .Incomplete character %s\n",line_count , yytext);
				num_error++;
}

(['](.)[']) {
			char c = yytext[1];
			fprintf(tokenout,"<CONST_CHAR, %c>\t",c);
			//fprintf(logout, "Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n", line_count, yytext);
			
}

['][\\][n][']   |
['][\\][t][']	|
['][\\][\\][']	|
['][\\]["][']	|
['][\\][a][']	|
['][\\][f][']	|
['][\\][r][']	|
['][\\][b][']	|
['][\\][v][']	|
['][\\][0][']   {
			char c;
			if(yytext[1] == '\\' && yytext[2] == 'n'){
				c = '\n';
			}
			else if (yytext[1] == '\\' && yytext[2] == 't') {
				c = '\t';
			}
			else if (yytext[1] == '\\' && yytext[2] == '\"') {
				c = '\"';
			}
			else if (yytext[1] == '\\' && yytext[2] == '\\'){
				c = '\\';
			}
			else if (yytext[1] == '\\' && yytext[2] == 'a'){
				c = '\a';
			}
			else if (yytext[1] == '\\' && yytext[2] == 'f'){
				c = '\f';
			}
			else if (yytext[1] == '\\' && yytext[2] == 'r'){
				c = '\r';
			}
			else if (yytext[1] == '\\' && yytext[2] == 'b'){
				c = '\b';
			}
			else if (yytext[1] == '\\' && yytext[2] == 'v'){
				c = '\v';
			}
			else if (yytext[1] == '\\' && yytext[2] == '0'){
				c = '\0';
			}
			string name;
                	string type;
			name = c;
			type = "char";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return CONST_CHAR;
			
}

{DIGIT}+ 	{
				string name;
                	string type;
			name = yytext;
			type = "const_int";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return CONST_INT;
				
}

[0-9]*\.?([0-9]+)?([E][+-]?[0-9]+)? {
			string name;
                	string type;
			name = yytext;
			type = "const_float";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return CONST_FLOAT;			
} 

[A-Za-z_][A-Za-z0-9_]* {
			//id
			string name;
                	string type;
			name = yytext;
			type = "ID";
			//printf("here\n");
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			//printf("here\n");
			yylval.sivar = newsymbol;
			//printf("here\n");
			return ID;			
}

[/][/](.*([\\]+[\n]?)*)* {
			for(int i = 2; i < strlen(yytext); i++){
				if (yytext[i] == '\\' && yytext[i+1] == '\n') {
					line_count++;
					i++;
				}
			}
			printf("comment\n");
			//fprintf(logout,"Line no %d: TOKEN <comment> Lexeme %s found\n",line_count, yytext);
}

"/*"([^*]|(\*+[^*/]))* {
			//fprintf(logout,"Error at line number: %d . Unfinished comment %s", line_count, yytext);
			for(int i = 2; i < strlen(yytext); i++){
				if (yytext[i] == '\n') {
					line_count++;
				}
			}
			//kaaj baki ase.
			num_error++;
}

"/*"([^*]|(\*+[^*/]))*[\*]+[/] {
			//fprintf(logout,"Line no %d: TOKEN <comment> Lexeme %s found\n",line_count, yytext);
			for(int i = 2; i < strlen(yytext)-2; i++){
				if (yytext[i] == '\n') {
					line_count++;
				}
			}
}

[\"][\"] {
			//fprintf(logout,"Error at line number: %d . Empty String %s", line_count, yytext);
			num_error++;
			
}

[\"](([\\][^"])*[^"\n]*)* {
			//fprintf(logout,"Error at line number: %d . Unfinished string %s\n", line_count, yytext);
			for(int i = 1; i < strlen(yytext) - 1; i++){
				if (yytext[i] == '\\' && yytext[i+1] == '\n') {
					i = i+1;
					line_count++;
				}
			}
			num_error++;
}

[\"](([\\][^"])*[^"\n]*)*[\"] {
			//fprintf(logout,"Line no %d: TOKEN <String> Lexeme %s found\n",line_count,yytext);
			string str;
			for(int i = 1; i < strlen(yytext) - 1; i++){
				if(yytext[i] == '\\' && yytext[i+1] == 'n'){
					char c = '\n';
					str.push_back('\n');
					i = i + 1;
				}
				else if (yytext[i] == '\\' && yytext[i+1] == 't'){
					char c = '\t';
					str.push_back('\t');
					i = i+1;
				}
				else if (yytext[i] == '\\' && yytext[i+1] == '\n') {
					i = i+1;
					line_count++;
				}
				else{
					char c = yytext[i];
					str.push_back(c);
				}
			}
			//fprintf(tokenout,"<String, %s>\t",str.c_str());
			string name;
                	string type;
			name = str;
			type = "string";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return STRING;
}


"+"		|

"-"		{
			string name;
                	string type;
			name = yytext;
			type = "addop";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return ADDOP;
}

"*"		|
"/"		|
"%"		{
			string name;
                	string type;
			name = yytext;
			type = "mulop";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return MULOP;
}


"++"		|
"--"		{
			string name;
                	string type;
			name = yytext;
			type = "incop";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return INCOP;
}

"<"		|
">"		|
"<="		|
">="		|
"=="		|
"!="		{
			string name;
                	string type;
			name = yytext;
			type = "relop";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return RELOP;		
}

"="		{
			string name;
                	string type;
			name = yytext;
			type = "assignop";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return ASSIGNOP;
}

"&&"		|
"||"		{
			string name;
                	string type;
			name = yytext;
			type = "logicop";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return LOGICOP;	
}

"&"		|
"|"		|
"^"		|
"<<"		|
">>"		{
			string name;
                	string type;
			name = yytext;
			type = "bitop";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return BITOP;
}

"!"		{
			string name;
                	string type;
			name = yytext;
			type = "not";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return NOT;
}

";"		{
			string name;
                	string type;
			name = yytext;
			type = "semicolon";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return SEMICOLON;
}	

"("		{
			string name;
                	string type;
			name = yytext;
			type = "lparen";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return LPAREN;
}

")"		{
			string name;
                	string type;
			name = yytext;
			type = "rparen";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return RPAREN;
}

"{"		{
			string name;
                	string type;
			name = yytext;
			type = "lcurl";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return LCURL;
}	

"}"		{
			string name;
                	string type;
			name = yytext;
			type = "rcurl";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return RCURL;
}

"["		{
			string name;
                	string type;
			name = yytext;
			type = "lthird";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return LTHIRD;
}

"]"		{
			string name;
                	string type;
			name = yytext;
			type = "rthird";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return RTHIRD;
}

","		{
			string name;
                	string type;
			name = yytext;
			type = "comma";
                	SymbolInfo * newsymbol = new SymbolInfo(name, type);
			yylval.sivar = newsymbol;
			return COMMA;
}				
		

[0-9]*\.[0-9]+(\.[0-9]*)+ {

				//fprintf(logout,"Error at line number: %d . Too many decimal places %s\n",line_count, yytext);
				num_error++;
}

([0-9]*\.?([0-9]+)?)([E][+-]?[0-9]*\..*) {
				//fprintf(logout,"Error at line number: %d . ILL FORMED NUMBER %s\n", line_count, yytext);
				num_error++;
}

[0-9]+[A-Za-z_]+ {
				//fprintf(logout,"Error at line number: %d . Invalid prefix on identifier or invalid suffix on number %s\n", line_count, yytext);
num_error++;
}

[']..+[']  {
				//fprintf(logout,"Error at line number: %d . Multi character constant error %s\n",line_count , yytext);
				num_error++;
}

[']. {
				//fprintf(logout,"Error at line number: %d .Unfinished character%s\n",line_count , yytext);
				num_error++;
}

['][^'\n]* {
				//fprintf(logout,"Error at line number: %d .Unfinished single quote%s\n",line_count , yytext);
				num_error++;
}

. {
				//fprintf(logout,"Error at line number: %d . Unrecognized character %s\n", line_count, yytext);
				num_error++;
}

%%

