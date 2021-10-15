#include <bits/stdc++.h>
using namespace std;
class SymbolInfo
{
private:
    string name;
    string type;
	

public:
	int arr_idx;
	string var_typ;
    SymbolInfo * nextinchain;
	string param_list_typ;
	int parameter_amount;
	string variable_name;
	bool isArray;
	bool isFunc;
	string func_ret_typ;
	string parameter_list_declared;
	string void_check;
	string symbol;
	string arrtype;
	string code;
	string paramsname;
	vector <string> ass_param_vec;
	SymbolInfo(string nm, string typ){
	name = nm;
	type = typ;
	nextinchain = NULL;
	arr_idx = -1;
	var_typ = "unspecified";
	param_list_typ = "";//for function
	parameter_amount = -1;		
	variable_name = "notvariable";
	isArray = false;
	isFunc = false;
	func_ret_typ = "not set";
	parameter_list_declared = "";
	void_check = "unnecessary";
	code = "";
	symbol = "undefined";
	paramsname = "";
}
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

    void Print (FILE * logy)
    {
        for (int i = 0; i < capacity; i++)
        {
	    SymbolInfo * start = st[i];
            if(start != NULL){	
            	fprintf(logy, "%d: ", i);
            	SymbolInfo * start = st[i];
            	while(start != NULL)
            	{
                	//cout << "< " << start->getName() <<" , " << start->getType() << " > " << "    ";
			fprintf(logy, "< %s , %s >", start->getName().c_str(), start->getType().c_str());
                	start = start->nextinchain;
           	 }
            	fprintf(logy, "\n");
		}
        }
	fprintf(logy, "\n");
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
	int scope_id;
    int capacity;
	FILE * logy;
	
    SymbolTable (int cap, FILE * lgy)
    {
        number_of_st = 0;
	scope_id = 0;
        currentst = NULL;
        capacity = cap;
	logy = lgy;
    }

    void EnterScope ()
    {
        if(number_of_st == 0)
        {
            currentst = new ScopeTable(capacity);
            number_of_st++;
		scope_id++;
		fprintf(logy, "scopetable with id %d created\n",number_of_st);
        }
        else
        {
            ScopeTable * prev = currentst;
            ScopeTable * newst = new ScopeTable(capacity);
            newst->parent = prev;
            currentst = newst;
            number_of_st++;
		scope_id++;
		fprintf(logy, "scopetable with id %d created\n",number_of_st);
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
	SymbolInfo* LookupCurrent (string key){
		return currentst->LookUp(key);
	}
    void PrintCurrent (){
        currentst->Print(logy);
    }
    void PrintAll (){
        ScopeTable * temp = currentst;
        int temp_no_of_st = number_of_st;
        while (temp != NULL){
            fprintf(logy, "Scopetable # %d\n", temp_no_of_st);
            temp->Print(logy);
            temp = temp->parent;
            temp_no_of_st--;
            cout << "\n\n" << endl;
        }
    }

    ~SymbolTable(){
        delete currentst;
    }

};

