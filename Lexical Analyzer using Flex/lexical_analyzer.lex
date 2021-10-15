%option noyywrap

%{
#include <bits/stdc++.h>

using namespace std;

int line_count=1;
int num_error = 0;

FILE *logout;
FILE *tokenout;

//symboltable code starts here
class SymbolInfo
{
private:
    string name;
    string type;

public:
    SymbolInfo * nextinchain;
    string getName()
    {
        return name;
    }

    string getType()
    {
        return type;
    }

    void setName(string nm)
    {
        name = nm;
    }

    void setType(string typ)
    {
        type = typ;
    }
};

class ScopeTable
{
public:
    SymbolInfo ** st;
    int capacity;
    ScopeTable * parent;

    ScopeTable(int capacity)
    {
        this -> capacity = capacity;
        st = new SymbolInfo * [capacity];
        for(int i = 0; i < capacity; i++)
        {
            st[i] = NULL;
        }
        parent = NULL; // eta kaaje laga uchit
    }

    int HashFunc (string key)
    {
        long long int hash = 5381;
        int c;
        for(int i = 0; i < key.size(); i++)
        {
            c = key[i];
            hash = hash * 33 + c;
        }
        return hash % capacity;
    }

    SymbolInfo * LookUp (string key)
    {
        int idx = HashFunc(key);
        SymbolInfo * start = st[idx];
        SymbolInfo * result = NULL;
        while(start!= NULL)
        {
            string temp;
            if(start != NULL)
            {
                temp = start->getName();
            }
            if(temp == key)
            {
                result = start;
                return result;
            }
            start = start->nextinchain;
        }
        return NULL;
    }

    void LookUp2 (string key)
    {
        int idx = HashFunc(key);
        SymbolInfo * start = st[idx];
        SymbolInfo * result = NULL;
        int y = -1;
        while(start!= NULL)
        {
            y++;
            string temp;
            if(start != NULL)
            {
                temp = start->getName();
            }
            if(temp == key)
            {
                result = start;
                cout << "found at " << idx << "," << y << endl;
                return;
            }
            start = start->nextinchain;
        }
        cout << "not found" << endl;
        return;
    }

    bool Insert (SymbolInfo * newsymbol)
    {
        if(LookUp(newsymbol->getName()) != NULL)
        {
            SymbolInfo * temp = LookUp(newsymbol->getName());
            cout << "< " << temp->getName() << " ," << temp->getType() << " > " << "already exists in current scope table" << endl;
            return false;
        }
        string key = newsymbol->getName();
        int idx = HashFunc(key);

        SymbolInfo * prev = NULL;
        SymbolInfo * start = st[idx];

        int y = 0;

        while(start != NULL)
        {
            prev = start;
            start = start->nextinchain;
            y++;
        }
        if(start == NULL)
        {
            if(prev == NULL)
            {
                st[idx] = newsymbol;
                cout << "Inserted at " << idx << "," << y << " ";
                return true;
            }
            else
            {
                prev->nextinchain = newsymbol;
                cout << "Inserted at " << idx << "," << y << " ";
                return true;
            }
        }
    }

    bool Delete (string key)
    {
        int idx = HashFunc(key);
        SymbolInfo * start = st[idx];
        SymbolInfo * prev = NULL;

        LookUp2(key);
        int y = -1;
        while (start!=NULL)
        {
            y++;
            if(start->getName() == key)
            {
                if(prev == NULL)
                {
                    st[idx] = start->nextinchain;
                    cout<<"deleted at " << idx << "," << y << " ";
                    return true;
                }
                else
                {
                    prev->nextinchain = start->nextinchain;
                    cout<<"deleted at " << idx << "," << y << " ";
                    return true;
                }
            }
            prev = start;
            start = start->nextinchain;
        }
        return false;
    }

    void Print ()
    {
        for (int i = 0; i < capacity; i++)
        {
	    SymbolInfo * start = st[i];
            if(start != NULL){	
            	fprintf(logout, "%d: ", i);
            	SymbolInfo * start = st[i];
            	while(start != NULL)
            	{
                	//cout << "< " << start->getName() <<" , " << start->getType() << " > " << "    ";
			fprintf(logout, "< %s , %s >", start->getName().c_str(), start->getType().c_str());
                	start = start->nextinchain;
           	 }
            	fprintf(logout, "\n");
		}
        }
	fprintf(logout, "\n");
    }
    ~ScopeTable(){
        delete st;
    }
};
//st means scopetable
class SymbolTable
{
public:
    ScopeTable * currentst;
    int number_of_st;
    int capacity;
    SymbolTable (int cap)
    {
        number_of_st = 0;
        currentst = NULL;
        capacity = cap;
    }

    void EnterScope ()
    {
        if(number_of_st == 0)
        {
            currentst = new ScopeTable(capacity);
            number_of_st++;
        }
        else
        {
            ScopeTable * prev = currentst;
            ScopeTable * newst = new ScopeTable(capacity);
            newst->parent = prev;
            currentst = newst;
            number_of_st++;
        }
    }

    void ExitScope ()
    {
        if(number_of_st > 0)
        {
            currentst = currentst->parent;
            cout << "scope table with id " << number_of_st << " deleted" << endl;
            number_of_st -- ;
        }
        else cout << "There are no scopes to exit from" << endl;
    }

    bool Insert (SymbolInfo * newsymbol)
    {
        if(currentst->Insert(newsymbol)) return true;
        else return false;
    }

    bool Remove (string key)
    {
        if(number_of_st > 0)
        {
            if (currentst->Delete(key)) cout << "of scope table with id " << number_of_st << endl;
            return true;

        }
        else
        {
            cout << "there are no scopes to delete from" << endl;
            return false;
        }
    }

    SymbolInfo * Lookup (string key) {
        ScopeTable * temp = currentst;
        SymbolInfo * res;
        int temp_no_of_st = number_of_st;
        while (temp != NULL){
            if(temp->LookUp(key) != NULL){
                res = temp->LookUp(key);
                temp->LookUp2(key);
                cout << "in scope table with id " << temp_no_of_st << endl;
                return res;
            }
            temp = temp->parent;
            temp_no_of_st--;
        }
        cout << "not found" << endl;
        return NULL;
    }
    void PrintCurrent (){
        currentst->Print();
    }
    void PrintAll (){
        ScopeTable * temp = currentst;
        int temp_no_of_st = number_of_st;
        while (temp != NULL){
            cout << "Scopetable # " << temp_no_of_st << endl;
            temp->Print();
            temp = temp->parent;
            temp_no_of_st--;
            cout << "\n\n" << endl;
        }
    }

    ~SymbolTable(){
        delete currentst;
    }

};

SymbolTable * symt;

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
			fprintf(tokenout, "<IF>\t");
			fprintf(logout, "Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"for" {
			fprintf(tokenout, "<FOR>\t");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count, yytext);

}

"do" {
			fprintf(tokenout,"<DO>\t");
			fprintf(logout, "Line no %d: TOKEN <DO> Lexeme %s found\n",line_count, yytext);		
}

"int" {
			fprintf(tokenout,"<INT>\t");
			fprintf(logout, "Line no %d: TOKEN <INT> Lexeme %s found\n",line_count, yytext);
}

"float" {
			fprintf(tokenout,"<FLOAT>\t");
			fprintf(logout, "Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count, yytext);
}

"void" {
			fprintf(tokenout,"<VOID>\t");
			fprintf(logout, "Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count, yytext);
}

"switch" {
			fprintf(tokenout,"<SWITCH>\t");
			fprintf(logout, "Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count, yytext);
}

"default" {
			fprintf(tokenout,"<DEFAULT>\t");
			fprintf(logout, "Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count, yytext);
}

"else" {
			fprintf(tokenout,"<ELSE>\t");
			fprintf(logout, "Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count, yytext);
}

"while" {
			fprintf(tokenout,"<WHILE>\t");
			fprintf(logout, "Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count, yytext);
}

"break" {
			fprintf(tokenout,"<BREAK>\t");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count, yytext);
}

"char" {
			fprintf(tokenout,"<CHAR>\t");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count, yytext);
}

"double" {
			fprintf(tokenout,"<DOUBLE>\t");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count, yytext);
}

"return" {
			fprintf(tokenout,"<RETURN>\t");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count, yytext);
}

['][\\]['] {
				fprintf(logout, "Error at line number: %d .Incomplete character %s\n",line_count , yytext);
}

(['](.)[']) {
			char c = yytext[1];
			fprintf(tokenout,"<CONST_CHAR, %c>\t",c);
			fprintf(logout, "Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n", line_count, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "CONST_CHAR";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "CONST_CHAR";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}
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
				c = '\0s';
			}
			fprintf(tokenout,"<CONST_CHAR, %c>\t",c);
			fprintf(logout, "Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n", line_count, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "CONST_CHAR";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "CONST_CHAR";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}
}

{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT,%s>\t",yytext);
				fprintf(logout, "Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "CONST_INT";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "CONST_INT";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}
}

[0-9]*\.?([0-9]+)?([E][+-]?[0-9]+)? {
			fprintf(tokenout,"<CONST_FLOAT, %s\t", yytext);
			fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "CONST_FLOAT";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "CONST_FLOAT";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}			
} 

[A-Za-z_][A-Za-z0-9_]* {
			fprintf(tokenout,"<ID, %s>\t", yytext);
			fprintf(logout,"Line no %d: TOKEN <ID, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "ID";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "ID";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}	
}

[/][/](.*([\\]+[\n]?)*)* {
			for(int i = 2; i < strlen(yytext); i++){
				if (yytext[i] == '\\' && yytext[i+1] == '\n') {
					line_count++;
					i++;
				}
			}
			fprintf(logout,"Line no %d: TOKEN <comment> Lexeme %s found\n",line_count, yytext);
}

"/*"([^*]|(\*+[^*/]))* {
			for(int i = 2; i < strlen(yytext); i++){
				if (yytext[i] == '\n') {
					line_count++;
				}
			}
			//kaaj baki ase.
			fprintf(logout,"Error at line number: %d . Unfinished comment %s", line_count, yytext);
}

"/*"([^*]|(\*+[^*/]))*[\*]+[/] {
			for(int i = 2; i < strlen(yytext)-2; i++){
				if (yytext[i] == '\n') {
					line_count++;
				}
			}
			fprintf(logout,"Line no %d: TOKEN <comment> Lexeme %s found\n",line_count, yytext);
}

[\"][\"] {
			fprintf(logout,"Error at line number: %d . Empty String %s", line_count, yytext);
}

[\"](([\\][^"])*[^"\n]*)* {
			fprintf(logout,"Error at line number: %d . Unfinished string %s\n", line_count, yytext);
}

[\"](([\\][^"])*[^"\n]*)*[\"] {
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
			fprintf(tokenout,"<String, %s>\t",str.c_str());
			fprintf(logout,"Line no %d: TOKEN <String> Lexeme %s found\n",line_count,yytext);
}

"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP,%s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "ADDOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "ADDOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}
}

"*"		|
"/"		|
"%"		{
			fprintf(tokenout,"<MULOP, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "MULOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "MULOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}
}


"++"		|
"--"		{
			fprintf(tokenout,"<INCOP, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "INCOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "INCOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}
}

"<"		|
">"		|
"<="		|
">="		|
"=="		|
"!="		{
			fprintf(tokenout,"<RELOP, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "RELOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "RELOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}			
}

"="		{
			fprintf(tokenout,"<ASSIGNOP, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "ASSIGNOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "ASSIGNOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}
}

"&&"		|
"||"		{
			fprintf(tokenout,"<LOGICOP, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "LOGICOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "LOGICOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}	
}

"&"		|
"|"		|
"^"		|
"<<"		|
">>"		{
			fprintf(tokenout,"<BITOP, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <BITOP, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "BITOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "BITOP";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}	
}

"!"		{
			fprintf(tokenout,"<NOT, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOT, %s> Lexeme %s found\n",line_count,yytext, yytext);
			if(symt->number_of_st == 0)
            			{
                			symt->EnterScope();
                			string name;
                			string type;
					name = yytext;
					type = "NOT";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
           		 	}
           		 	else
            			{
                			string name;
                			string type;
					name = yytext;
					type = "NOT";
                			SymbolInfo * newsymbol = new SymbolInfo();
                			newsymbol->setName(name);
                			newsymbol->setType(type);
                			newsymbol->nextinchain = NULL;
					if(symt->Insert(newsymbol)){
						symt->PrintAll();
					}
            			}	
}

"("		{
			fprintf(tokenout,"<LPAREN, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN, %s> Lexeme %s found\n",line_count,yytext, yytext);
}

")"		{
			fprintf(tokenout,"<RPAREN, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN, %s> Lexeme %s found\n",line_count,yytext, yytext);
}

"{"		{
			fprintf(tokenout,"<LCURL, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL, %s> Lexeme %s found\n",line_count,yytext, yytext);
}	

"}"		{
			fprintf(tokenout,"<RCURL, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL, %s> Lexeme %s found\n",line_count,yytext, yytext);
}

"["		{
			fprintf(tokenout,"<LTHIRD, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <LTHIRD, %s> Lexeme %s found\n",line_count,yytext, yytext);
}

"]"		{
			fprintf(tokenout,"<RTHIRD, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <RTHIRD, %s> Lexeme %s found\n",line_count,yytext, yytext);
}

","		{
			fprintf(tokenout,"<COMMA, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA, %s> Lexeme %s found\n",line_count,yytext, yytext);
}	

";"		{
			fprintf(tokenout,"<SEMICOLON, %s>\t",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON, %s> Lexeme %s found\n",line_count,yytext, yytext);
}				
		

[0-9]*\.[0-9]+(\.[0-9]*)+ {

				fprintf(logout,"Error at line number: %d . Too many decimal places %s\n",line_count, yytext);
}

([0-9]*\.?([0-9]+)?)([E][+-]?[0-9]*\..*) {
				fprintf(logout,"Error at line number: %d . ILL FORMED NUMBER %s\n", line_count, yytext);
}

[0-9]+[A-Za-z_]+ {
				fprintf(logout,"Error at line number: %d . Invalid prefix on identifier or invalid suffix on number %s", line_count, yytext);
}

[']..+[']  {
				fprintf(logout,"Error at line number: %d . Multi character constant error %s\n",line_count , yytext);
}

[']. {
				fprintf(logout,"Error at line number: %d .Unfinished character%s\n",line_count , yytext);
}

['][^'\n]* {
				fprintf(logout,"Error at line number: %d .Unfinished single quote%s\n",line_count , yytext);
}

[\"].* {
				fprintf(logout,"Error at line number: %d .Unfinished String%s\n",line_count , yytext);
}

. {
				fprintf(logout,"Error at line number: %d . Unrecognized character %s\n", line_count, yytext);
}

%%

int main(int argc,char *argv[]){
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	

	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");
	symt = new SymbolTable (7);
	yyin= fin;	
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
