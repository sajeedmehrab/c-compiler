%{
#include <bits/stdc++.h>
#include "symbol.h"
using namespace std;

SymbolTable * symt;

//symboltable ends here

//int yydebug;
int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern char* yytext;
FILE * logy;
FILE * erry;
vector <string> argument_typ;
vector <SymbolInfo*> parameter_list_vec;
vector <SymbolInfo*> current_func;
vector <SymbolInfo*> declared_func_vec;
bool show_typ_mismatch = true;
int err_count = 0;

/*void yyerror(const char *s)
{
	fprintf(stderr,"%s\n",s);
	return;
}*/

void yyerror(const char *s)
{
	fprintf(erry, "%d: %s %s \n", line_count, s, yytext);
	err_count++;
	return;
}


%}

%union {SymbolInfo * sivar ;}

%token <sivar> IF
%token <sivar> FOR
%token <sivar> DO
%token <sivar> INT
%token <sivar> FLOAT
%token <sivar> VOID
%token <sivar> SWITCH
%token <sivar> DEFAULT
%token <sivar> ELSE
%token <sivar> WHILE
%token <sivar> BREAK
%token <sivar> CHAR
%token <sivar> DOUBLE
%token <sivar> RETURN
%token <sivar> CASE
%token <sivar> CONTINUE
%token <sivar> BITOP
%token <sivar> LPAREN
%token <sivar> RPAREN
%token <sivar> SEMICOLON
%token <sivar> COMMA
%token <sivar> LCURL
%token <sivar> RCURL
%token <sivar> LTHIRD
%token <sivar> CONST_INT
%token <sivar> RTHIRD
%token <sivar> PRINTLN
%token <sivar> ASSIGNOP
%token <sivar> LOGICOP
%token <sivar> RELOP
%token <sivar> ADDOP
%token <sivar> MULOP
%token <sivar> NOT
%token <sivar> CONST_FLOAT
%token <sivar> INCOP
%token <sivar> DECOP
%token <sivar> ID
%token <sivar> STRING
%token <sivar> CONST_CHAR

%type <sivar> start
%type <sivar> program
%type <sivar> unit
%type <sivar> func_declaration
%type <sivar> func_definition
%type <sivar> parameter_list
%type <sivar> compound_statement
%type <sivar> var_declaration
%type <sivar> type_specifier
%type <sivar> declaration_list
%type <sivar> statements
%type <sivar> statement
%type <sivar> expression_statement
%type <sivar> variable
%type <sivar> expression
%type <sivar> logic_expression
%type <sivar> rel_expression
%type <sivar> simple_expression
%type <sivar> term
%type <sivar> unary_expression
%type <sivar> factor
%type <sivar> argument_list
%type <sivar> arguments

%define parse.lac full
%define parse.error verbose

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {fprintf(logy, "At line number: %d start : program\n", line_count);
		string str = $1->getName() ;
		SymbolInfo* temp = new SymbolInfo (str, "nt");
		$$ = temp;
		fprintf(logy, "%s\n", str.c_str());}
		;

program : program unit {fprintf(logy, "At line number: %d program : program unit\n",line_count);
			string str = $1->getName()  + " " + $2->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	| unit {fprintf(logy, "At line number: %d program : unit\n", line_count);
			string str = $1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	;
	
unit : var_declaration {fprintf(logy, "At line number: %d unit : var_declaration\n", line_count);
			string str = $1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
     | func_declaration {fprintf(logy, "At line number: %d unit : func_declaration\n", line_count);
			string str = $1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
     | func_definition {fprintf(logy, "At line number: %d unit : func_definition\n", line_count);
			string str = $1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
     ;
     
func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON {fprintf(logy, "At line number: %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n",line_count);
			string str = $1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + "\n";
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							string func_name = $2->getName();
							bool func_exists_err = false;
							for(int i = 0; i < declared_func_vec.size(); i++){
								if(declared_func_vec[i]->getName() == func_name){
									func_exists_err = true;
								}
							} 
							SymbolInfo* tempp = symt->Lookup(func_name);
							if(tempp!=NULL || func_exists_err) {fprintf(erry, "At line no %d Function with this name already exists\n", line_count); err_count++;}
							else {
								SymbolInfo * fd = new SymbolInfo(func_name, "function");
								fd->func_ret_typ = $1->getName();
								fd->parameter_list_declared = "";	
								declared_func_vec.push_back(fd);
							}}
		| type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {fprintf(logy, "At line number: %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n", line_count);
					string str = $1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName()+ "\n";
							//cout << "qwertyuiop" << $4->getName();

							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							string func_name = $2->getName();
							bool func_exists_err = false;
							for(int i = 0; i < declared_func_vec.size(); i++){
								if(declared_func_vec[i]->getName() == func_name){
									func_exists_err = true;
								}
							} 
							SymbolInfo* tempp = symt->Lookup(func_name);
							if(tempp!=NULL || func_exists_err) { fprintf(erry, "At line no %d Function with this name already exists\n", line_count); err_count++;}
							else {
								SymbolInfo * fd = new SymbolInfo(func_name, "function");
								fd->func_ret_typ = $1->getName();
								fd->parameter_list_declared = $4->getName();	
								declared_func_vec.push_back(fd);
							}}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {bool executenormal = true;
							for(int i = 0 ; i < declared_func_vec.size(); i++){
								if(declared_func_vec[i]->getName() == $2->getName()){
									executenormal = false;
									SymbolInfo* a = declared_func_vec[i];
									if(a->func_ret_typ == $1->getName() && a->parameter_list_declared == $4->getName()) executenormal = true;
									else if (a->func_ret_typ != $1->getName()){
										fprintf(erry, "At line no %d Return type does not match with declaration\n",line_count);
										err_count++;	
									}
									else if (a->parameter_list_declared != $4->getName()){
										fprintf(erry, "At line no %d Argument list does not match with declaration\n", line_count);
										err_count++;
									}
								}
							}
						if(executenormal){
							string param_list = $4->getName();
							vector <string> tokens;
    							stringstream check1(param_list);
   							string intermediate;
							int no_of_parameters = 0;
    							while(getline(check1, intermediate, ','))
    							{
        							tokens.push_back(intermediate);
								no_of_parameters++;
    							}
							string param_typ = "";
							for(int i = 0; i < tokens.size(); i++){
								string bla = tokens[i];
								//cout << bla<<endl;
								vector <string> tokens2;
    								stringstream check1(bla);
   								string intermediate2 ;
    								while(getline(check1, intermediate2, ' '))
    								{
        								tokens2.push_back(intermediate2);
    								}
								if(tokens2.size() == 2){
									string typ_spec = tokens2[0];
									if(i == 0){
										param_typ = typ_spec;
									}
									else param_typ = param_typ + "," + typ_spec;
									string param_id = tokens2[1];
									SymbolInfo * si_param = new SymbolInfo(param_id, "function_param");
									si_param->var_typ = typ_spec;
									parameter_list_vec.push_back(si_param);
								}
								else if (tokens2.size() == 1) {
									string typ_spec = tokens2[0];
									if(i == 0){
										param_typ = typ_spec;
									}
									else param_typ = param_typ + "," + typ_spec;
								}
							}
							SymbolInfo * si = new SymbolInfo ($2->getName(), "ID");
							si->var_typ = $1->getName();
							cout << "assdfgh" << param_typ << endl; 
							si->param_list_typ = param_typ;
							si->parameter_amount = no_of_parameters;
							si->func_ret_typ = $1->getName();
							//printf("\t\t\t\t\t\t\t %s",si->func_ret_typ.c_str());
							current_func.push_back(si);
							if(symt->LookupCurrent($2->getName()) == NULL){
								if(symt->number_of_st == 0)
            								{
                								symt->EnterScope();
                								symt->Insert(si);
										//symt->PrintCurrent();
           		 						}
           		 						else
            								{
                								symt->Insert(si);
										//symt->PrintCurrent();
            								}
							}
							else{
								fprintf(erry, "At line no %d %s has already been declared\n",line_count,$2->getName().c_str());
								err_count++;
							}
							}	
} compound_statement {fprintf(logy, "At line number: %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n",line_count);
					string str = $1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $7->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							//cout<<endl;
							//cout << $4->getName()<<endl;
							//
							
							symt->PrintAll();
							//symt->ExitScope();
							}
		| type_specifier ID LPAREN RPAREN{bool executenormal = true;
						for(int i = 0 ; i < declared_func_vec.size(); i++){
								if(declared_func_vec[i]->getName() == $2->getName()){
									executenormal = false;
									SymbolInfo* a = declared_func_vec[i];
									if(a->func_ret_typ == $1->getName() && a->parameter_list_declared == "") executenormal = true;
									else if (a->func_ret_typ != $1->getName()){
										fprintf(erry, "At line no %d Return type does not match with declaration\n",line_count);
										err_count++;	
									}
									else if (a->parameter_list_declared != ""){
										fprintf(erry, "At line no %d Argument list does not match with declaration\n", line_count);
										err_count++;
									}
								}
							}
						if(executenormal){	
							int no_of_parameters = 0;
    							
							string param_typ = "";
							
							SymbolInfo * si = new SymbolInfo ($2->getName(), "ID");
							si->var_typ = $1->getName();
							
							si->param_list_typ = param_typ;
							si->parameter_amount = no_of_parameters;
							si->func_ret_typ = $1->getName();
							//printf("\t\t\t\t\t\t\t %s",si->func_ret_typ.c_str());
							current_func.push_back(si);
							if(symt->LookupCurrent($2->getName()) == NULL){
								if(symt->number_of_st == 0)
            								{
                								symt->EnterScope();
                								symt->Insert(si);
										//symt->PrintCurrent();
           		 						}
           		 						else
            								{
                								symt->Insert(si);
										//symt->PrintCurrent();
            								}
							}
							else{
								fprintf(erry, "At line no %d %s has already been declared\n",line_count,$2->getName().c_str());
								err_count++;
							}
						}	
} compound_statement {fprintf(logy, "At line number: %d func_definition : type_specifier ID LPAREN RPAREN compound_statement\n",line_count);
						string str = $1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $6->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							
							}
							//symt->ExitScope();}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {fprintf(logy, "At line number: %d parameter_list : parameter_list COMMA type_specifier ID \n",line_count);
					string str =$1->getName() + $2->getName() + $3->getName() + " " + $4->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
		| parameter_list COMMA type_specifier {fprintf(logy, "At line number: %d parameter_list : parameter_list COMMA type_specifier\n",line_count);
						string str =$1->getName() + $2->getName() + $3->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
 		| type_specifier ID {fprintf(logy, "At line number: %d parameter_list : type_specifier ID \n",line_count);
					string str =$1->getName() + " " + $2->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
		| type_specifier {fprintf(logy, "At line number: %d parameter_list : type_specifier\n",line_count);
					string str =$1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
 		;                        

 		
compound_statement : LCURL {	symt->EnterScope();
				while (!parameter_list_vec.empty()){
					SymbolInfo* si_param = parameter_list_vec.back();
					parameter_list_vec.pop_back();
					if(symt->number_of_st == 0)
            							{
                							symt->EnterScope();
                							symt->Insert(si_param);
									//symt->PrintCurrent();
           		 					}
           		 					else
            							{
                							symt->Insert(si_param);
									//symt->PrintCurrent();
            							}
				}
					} statements RCURL {fprintf(logy, "At line number: %d compound_statement : LCURL statements RCURL\n",line_count);
					string str =$1->getName() + "\n" + $3->getName() + " " + $4->getName()  + "\n";
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							symt->PrintAll();
							symt->ExitScope();
}
 		    | LCURL {symt->EnterScope();
			while (!parameter_list_vec.empty()){
			SymbolInfo* si_param = parameter_list_vec.back();
			parameter_list_vec.pop_back();
					if(symt->number_of_st == 0)
            							{
                							symt->EnterScope();
                							symt->Insert(si_param);
									//symt->PrintCurrent();
           		 					}
           		 					else
            							{
                							symt->Insert(si_param);
									//symt->PrintCurrent();
            							}
				}} RCURL {fprintf(logy, "At line number: %d compound_statement : LCURL RCURL\n",line_count);
						string str =$1->getName() + "\n" + $3->getName()  + "\n" ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							symt->PrintAll();
							symt->ExitScope();
}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON { 
							fprintf(logy, "At line number: %d var_declaration : type_specifier declaration_list SEMICOLON \n",line_count);
							string str = $1->getName() + " " + $2->getName() + " " + $3->getName()+ "\n";
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());;
							SymbolInfo * si = $2;
							string line = si->getName();
							vector <string> tokens;
    							stringstream check1(line);
   							string intermediate;
    							while(getline(check1, intermediate, ','))
    							{
        							tokens.push_back(intermediate);
    							}
							string t1;
							int arr_idx = -1;
							int end = 0;
							string var_name;
    							for(int i = 0; i < tokens.size(); i++){
								string bla = tokens[i];
								if(bla[bla.size()-1] == ']'){
								for(int j = 0; j<bla.size();j++){
									if(bla[j] == '[' && bla[bla.size()-1] == ']'){
										end = j-1;
										for(int k = j+1; k<bla.size();k++){
											char c = bla[k];
											if(c != ']'){
												t1.push_back(c);
											}
										}
										for(int l = 0; l<=end;l++){
											char c1 = bla[l];
											if(c1 != ' '){
												var_name.push_back(c1);
											}
										}
									}
								
								} 
								SymbolInfo * sitk = new SymbolInfo (var_name, "ID");
								sitk->var_typ = $1->getName();
								sitk->isArray = true;
								//cout << "1234" << sitk->var_typ <<endl;
								sitk->arr_idx = atoi(t1.c_str());
								//cout << "hahahahahaha" << atoi(t1.c_str())<<endl;
								if(symt->LookupCurrent(var_name) == NULL){
									if(symt->number_of_st == 0)
            								{
                								symt->EnterScope();
                								symt->Insert(sitk);
										//symt->PrintCurrent();
           		 						}
           		 						else
            								{
                								symt->Insert(sitk);
										//symt->PrintCurrent();
            								}
								}
								else{
									fprintf(erry, "At line no: %d %s has already been declared\n",line_count,var_name.c_str());
									err_count++;
								}
								}
								else {
								SymbolInfo * sitk = new SymbolInfo (bla, "ID");
								sitk->var_typ = $1->getName();
								if(symt->LookupCurrent(bla) == NULL){
									if(symt->number_of_st == 0)
            								{
                								symt->EnterScope();
                								symt->Insert(sitk);
										//symt->PrintCurrent();
           		 						}
           		 						else
            								{
                								symt->Insert(sitk);
										//symt->PrintCurrent();
            								}
								}
								else{
									fprintf(erry, "At line no: %d %s has already been declared\n",line_count,bla.c_str());
									err_count++;
								}
								}
							
							} }		
		 ;
 		 
type_specifier	: INT {fprintf(logy, "At line number: %d type_specifier : INT\n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
 		| FLOAT {fprintf(logy, "At line number: %d type_specifier : FLOAT\n",line_count);
				string str =$1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
 		| VOID {fprintf(logy, "At line number: %d type_specifier : VOID\n",line_count);
				string str =$1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
 		;
 		
declaration_list : declaration_list COMMA ID {fprintf(logy, "At line number: %d declaration_list : declaration_list COMMA ID\n",line_count);
						string str = $1->getName() + $2->getName() + $3->getName();
						SymbolInfo * temp = new SymbolInfo(str, "nt");
						fprintf(logy, "%s\n", str.c_str());
						$$ = temp;
						}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {fprintf(logy, "At line number: %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n",line_count);
					string str =$1->getName() + $2->getName() + $3->getName() + $4->getName() + $5->getName() + $6->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());;
					}
 		  | ID {
			string str = $1->getName();
			SymbolInfo * temp = new SymbolInfo(str, "nt");
			$$ = temp;
			fprintf(logy, "At line number: %d declaration_list : ID\n",line_count);
			fprintf(logy, "%s\n",str.c_str());}
 		  | ID LTHIRD CONST_INT RTHIRD {fprintf(logy, "At line number: %d declaration_list : ID LTHIRD CONST_INT RTHIRD \n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
 		  ;
 		  
statements : statement {fprintf(logy, "At line number: %d statements : statement\n",line_count);
				string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	   | statements statement {fprintf(logy, "At line number: %d statements : statements statement\n",line_count);
			string str =$1->getName() + " " + $2->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	   ;
	   
statement : var_declaration {fprintf(logy, "At line number: %d statement : var_declaration\n",line_count);
				string str =$1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	  | expression_statement {fprintf(logy, "At line number: %d statement : expression_statement\n",line_count);
				string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	  | compound_statement {fprintf(logy, "At line number: %d statement : compound_statement\n",line_count);
				string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {fprintf(logy, "At line number: %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName() + $7->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	  | IF LPAREN expression RPAREN statement {fprintf(logy, "At line number: %d statement : IF LPAREN expression RPAREN statement \n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());} %prec LOWER_THAN_ELSE ;
	  | IF LPAREN expression RPAREN statement ELSE statement {fprintf(logy, "At line number: %d statement : IF LPAREN expression RPAREN statement ELSE statement \n",line_count);
					string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " " + $6->getName() + $7->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	  | WHILE LPAREN expression RPAREN statement {fprintf(logy, "At line number: %d statement : WHILE LPAREN expression RPAREN statement\n",line_count);
			string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {fprintf(logy, "At line number: %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() + " " + $5->getName()+ "\n";
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
	  | RETURN expression SEMICOLON {fprintf(logy, "At line number: %d statement : RETURN expression SEMICOLON \n",line_count);
			string str =$1->getName() + " " + $2->getName() + " " + $3->getName()+ "\n";
							//printf("\t\t\t\t\t\t\t %s\n\n\n\n",$2->var_typ.c_str());
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							if(current_func.size()!=0){
								SymbolInfo* si_cur_func = current_func.back();
								current_func.pop_back();
								if($2->var_typ != si_cur_func->func_ret_typ){
									fprintf(erry, "At line no %d return type does not match\n",line_count);
									err_count++;
								}
							}
						}
	  ;
	  
expression_statement 	: SEMICOLON {fprintf(logy, "At line number: %d expression_statement : SEMICOLON\n",line_count);
				string str =$1->getName() +"\n" ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}			
			| expression SEMICOLON {fprintf(logy, "At line number: %d expression_statement : expression SEMICOLON\n",line_count);
				string str =$1->getName() + " " + $2->getName() + "\n" ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}	
			;
	  
variable : ID 	{fprintf(logy, "At line number: %d variable : ID\n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							SymbolInfo * temp2 = symt->Lookup(str);
							if(temp2 != NULL && temp2->isArray){
								fprintf(erry, "At line no %d index not used with array\n",line_count);
								err_count++;
							}
							if(temp2 == NULL){
								fprintf(erry, "At line no %d variable %s not found\n",line_count,str.c_str());
								err_count++;
							}
							else {
								temp->var_typ = temp2->var_typ;
							}
							temp->variable_name = $1->getName();
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}		
	 | ID LTHIRD expression RTHIRD  {fprintf(logy, "At line number: %d variable : ID LTHIRD expression RTHIRD\n",line_count);
			string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() ;
							string str2 = $1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							SymbolInfo * temp2 = symt->Lookup(str2);
							if(temp2 == NULL){
								
								fprintf(erry, "At line no %d variable %s not found\n",line_count, str2.c_str());
								err_count++;
							}
							else {
								temp->var_typ = temp2->var_typ;
							}
							if (temp2->isArray){
								if($3->var_typ != "int"){
									fprintf(erry, "At line no: %d Array index not integer\n", line_count);
									err_count++;
								}
							}
							else if (!(temp2->isArray)){
								fprintf(erry, "At line no %d %s is not an array\n", line_count, str2.c_str());
								show_typ_mismatch = false;
								err_count++;
							}
							temp->variable_name = $1->getName();
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}		
	 ;
	 
 expression : logic_expression	{fprintf(logy, "At line number: %d expression : logic_expression\n",line_count);
				string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->void_check = $1->void_check;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}	
	   | variable ASSIGNOP logic_expression {fprintf(logy, "At line number: %d expression : variable ASSIGNOP logic_expression\n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							string typ1 = $1->var_typ;
							string typ2 = $3->var_typ;
							if(show_typ_mismatch && typ1 != typ2 && typ1 != "unspecified" && typ2 != "unspecified"){
								fprintf(erry, "At line number: %d Type mismatch error\n",line_count);
								err_count++;
							}
							show_typ_mismatch = true;		
							if($3->void_check == "void") {fprintf(erry, "At line no %d void function cannot be called in expression\n", line_count); err_count++;}							
};
			
logic_expression : rel_expression {fprintf(logy, "At line number: %d logic_expression : rel_expression\n",line_count);
				string str =$1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->void_check = $1->void_check;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}	
		 | rel_expression LOGICOP rel_expression {fprintf(logy, "At line number: %d logic_expression : rel_expression LOGICOP rel_expression \n",line_count);
					string str =$1->getName() + " " + $2->getName() + " " + $3->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = "int";
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							if($1->void_check == "void" || $3->void_check == "void") {fprintf(erry, "At line no %d void function cannot be called in expression\n", line_count); err_count++;}}
		 ;
			
rel_expression	: simple_expression {fprintf(logy, "At line number: %d rel_expression : simple_expression\n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->void_check = $1->void_check;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
		| simple_expression RELOP simple_expression {fprintf(logy, "At line number: %d rel_expression : simple_expression RELOP simple_expression\n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = "int";
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							if($1->void_check == "void" || $3->void_check == "void") {fprintf(erry, "At line no %d void function cannot be called in expression\n", line_count); err_count++;} }
		;
				
simple_expression : term {fprintf(logy, "At line number: %d simple_expression : term\n",line_count);
			string str =$1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->void_check = $1->void_check;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
		  | simple_expression ADDOP term {fprintf(logy, "At line number: %d simple_expression : simple_expression ADDOP term\n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							//eieikhane temp er var type ki dibo
							string typ1 = $1->var_typ;
							string typ2 = $3->var_typ;
							if(typ1 == typ2){
								temp->var_typ = typ1;
							}
							else if (typ1 == "float" || typ2 == "float"){
								temp->var_typ = "float";
							}
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							if($1->void_check == "void" || $3->void_check == "void") {fprintf(erry, "At line no %d void function cannot be called in expression\n", line_count); err_count++;}}
		  ;
					
term :	unary_expression {fprintf(logy, "At line number: %d term : unary_expression\n",line_count);
			string str =$1->getName();
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->variable_name = $1->variable_name;
							temp->void_check = $1->void_check;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
     |  term MULOP unary_expression {fprintf(logy, "At line number: %d term : term MULOP unary_expression\n",line_count);
			string str =$1->getName() + " " + $2->getName() + " " + $3->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = "int";
							//eikhane temp er var type ki dibo?
							string typ1 = $1->var_typ;
							string typ2 = $3->var_typ;
							if(typ1 == typ2 && $2->getName() != "%"){
								temp->var_typ = typ1;
							}
							else if ((typ1 == "float" || typ2 == "float") && $2->getName() != "%"){
								temp->var_typ = "float";
							}
							else if ($2->getName() != "%"){
								temp->var_typ = "int";
							}
							if(($2->getName() == "%") && (typ1 != "int" || typ2 != "int")){
								fprintf(erry, "Error at line no : %d Both operator of modulus not integer\n",line_count);
								err_count++;
							}
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							if($1->void_check == "void" || $3->void_check == "void"){ fprintf(erry, "At line no %d void function cannot be called in expression\n", line_count); err_count++;}}
     ;

unary_expression : ADDOP unary_expression {fprintf(logy, "At line number: %d unary_expression : ADDOP unary_expression \n",line_count);
			string str =$1->getName() + " " + $2->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $2->var_typ;
							temp->variable_name = $2->variable_name;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							if($2->void_check == "void") { fprintf(erry, "At line no %d void function cannot be called in expression\n", line_count); err_count++;}} 
		 | NOT unary_expression {fprintf(logy, "At line number: %d unary_expression : NOT unary_expression \n",line_count);
			string str =$1->getName() + " " + $2->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $2->var_typ;
							temp->variable_name = $2->variable_name;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
							if($2->void_check == "void") {fprintf(erry, "At line no %d void function cannot be called in expression\n", line_count); err_count++;}} 
		 | factor {fprintf(logy, "At line number: %d unary_expression : factor\n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->variable_name = $1->variable_name;
							temp->void_check = $1->void_check;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());} 
		 ;
	
factor	: variable {fprintf(logy, "At line number: %d factor : variable\n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->variable_name = $1->variable_name;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());} 
	| ID LPAREN argument_list RPAREN {fprintf(logy, "At line number: %d factor : ID LPAREN argument_list RPAREN\n",line_count);
			string str =$1->getName() + " " + $2->getName() + " " + $3->getName() + " " + $4->getName() ;
							cout << "qwerty" << $3->getName() << endl;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							string str2 = $1->getName();
							string str3 = $3->param_list_typ;
							string str4 = $3->getName();
							cout << "argument list:" << $3->getName() << "a"<<endl;
							vector <string> tokens_arguments;
    							stringstream check1(str4);
   							string intermediate;
    							while(getline(check1, intermediate, ','))
    							{
        							tokens_arguments.push_back(intermediate);
    							}
							
							vector <string> tokens_argtyp;
    							stringstream check2(str3);
   							string intermediate2;
    							while(getline(check2, intermediate2, ','))
    							{
        							tokens_argtyp.push_back(intermediate2);
    							}
							bool print_argument_list_err = true; //make this global
							/*for(int i = 0 ; i < tokens_arguments.size() ; i++){
								if(tokens_argtyp[i] == "unspecified"){
									fprintf(erry, "At line no : %d %s has not been defined\n",line_count, tokens_arguments[i].c_str());
									print_argument_list_err = false;
								}
							}*/
							bool arrayerror = false;
							vector <string> tokens_argnames;
    							stringstream check3($3->getName());
   							string intermediate3;
    							while(getline(check3, intermediate3, ','))
    							{
        							tokens_argnames.push_back(intermediate3);
    							}
							for(int i = 0 ; i < tokens_argnames.size(); i++){
								SymbolInfo * tempp = symt->Lookup(tokens_argnames[i]);
								if(tempp != NULL && tempp->isArray == true){
									arrayerror = true;
								}
							}
							if(print_argument_list_err){
								SymbolInfo * temp = symt->Lookup ($1->getName());
								
								if(temp!=NULL) {string a1 = temp->param_list_typ;
								if((str3 != a1 || arrayerror)){
									printf("\t\t\tasdfghjkl a%sz a%sz\n\n",str3.c_str(),a1.c_str());
									fprintf(erry, "At line no : %d argument list does not match with definition\n",line_count);
									err_count++;
								}}
								
							}
							//cout << "heyheyhey" << str3 << endl;
							SymbolInfo* temp2 = symt->Lookup(str2);
							if(temp2 == NULL){
								fprintf(erry, "At line no %d variable %s not found\n",line_count,str2.c_str());
								err_count++;
							}
							else {
								temp->var_typ = temp2->var_typ;
							}
							SymbolInfo * a = symt->Lookup ($1->getName());
							if(a!=NULL){
								temp->void_check = a->func_ret_typ;
							}
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());} 
	| LPAREN expression RPAREN {fprintf(logy, "At line number: %d factor : LPAREN expression RPAREN\n",line_count);
				string str =$1->getName() + " " + $2->getName() + " " + $3->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $2->var_typ;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}
							
	| CONST_INT {fprintf(logy, "At line number: %d factor : CONST_INT\n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = "int";
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}  
	| CONST_FLOAT {fprintf(logy, "At line number: %d factor: CONST_FLOAT\n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = "float";
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}  
	| variable INCOP {fprintf(logy, "At line number: %d factor: variable INCOP\n",line_count);
			string str =$1->getName() + " " + $2->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->variable_name = $1->variable_name;
							if($1->var_typ != "unspecified" && $1->var_typ != "int") {
								fprintf(erry, "At line no %d INCOP needs integer variable\n", line_count);
								err_count++;
							}
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}  
	| variable DECOP {fprintf(logy, "At line number: %d factor: variable DECOP\n",line_count);
			string str =$1->getName() + " " + $2->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->var_typ = $1->var_typ;
							temp->variable_name = $1->variable_name;
							if($1->var_typ != "unspecified" && $1->var_typ != "int") {
								fprintf(erry, "At line no %d DECOP needs integer variable\n", line_count);
								err_count++;
							}
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}  
	;
	
argument_list : arguments {fprintf(logy, "At line number: %d argument_list: arguments\n",line_count);
				string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->param_list_typ = $1->param_list_typ;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}  
			  ;
	
arguments : arguments COMMA logic_expression {fprintf(logy, "At line number: %d arguments: arguments COMMA logic_expression\n",line_count);
			string str =$1->getName() + $2->getName() + $3->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->param_list_typ = $1->param_list_typ + "," + $3->var_typ;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());}  
	      | logic_expression {fprintf(logy, "At line number: %d arguments: logic_expression \n",line_count);
			string str =$1->getName() ;
							SymbolInfo* temp = new SymbolInfo (str, "nt");
							temp->param_list_typ = $1->var_typ;
							$$ = temp;
							fprintf(logy, "%s\n", str.c_str());
}  
		| { SymbolInfo * temp = new SymbolInfo ("","nt");
			temp->param_list_typ = "";
			$$ = temp;}
	      ;
 
%%

int main(int argc,char *argv[]){
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	logy= fopen("logy.txt","w");
	erry= fopen("erry.txt","w");
	symt = new SymbolTable(7, logy);
	symt->EnterScope();
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	yyin = fin;
	yyparse();
	fprintf(erry, "Total number of errors : %d\n", err_count);
	fclose(yyin);
	fclose(logy);
	
	return 0;
}
