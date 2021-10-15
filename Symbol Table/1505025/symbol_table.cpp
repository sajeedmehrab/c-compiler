#include<bits/stdc++.h>

using namespace std;

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
            cout << i << " : " ;
            SymbolInfo * start = st[i];
            while(start != NULL)
            {
                cout << "< " << start->getName() <<" , " << start->getType() << " > " << "    ";
                start = start->nextinchain;
            }
            cout<<endl;
        }
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

int main()
{
    char c;
    int capacity;
    ifstream inFile;
    inFile.open("input.txt");

    if(!inFile){
        cerr << "Unable to open input.txt";
        exit(1);
    }
    inFile >> capacity;
    SymbolTable * symt = new SymbolTable(capacity);
    while( inFile >> c)
    {
        cout << c << "  ";
        if(c == 'I')
        {
            if(symt->number_of_st == 0)
            {
                symt->EnterScope();
                string name;
                string type;
                inFile >> name;
                inFile >> type;
                cout << name << "  " << type << endl;

                SymbolInfo * newsymbol = new SymbolInfo();
                newsymbol->setName(name);
                newsymbol->setType(type);
                newsymbol->nextinchain = NULL;
                if(symt->Insert(newsymbol)) cout << "of scope table with id " << symt->number_of_st << endl;

            }
            else
            {
                string name;
                string type;
                inFile >> name;
                inFile >> type;

                cout << name << "  " << type << endl;

                SymbolInfo * newsymbol = new SymbolInfo();
                newsymbol->setName(name);
                newsymbol->setType(type);
                newsymbol->nextinchain = NULL;
                if(symt->Insert(newsymbol)) cout << "of scope table with id " << symt->number_of_st << endl;

            }
        }
        else if (c == 'S')
        {
            symt->EnterScope();
            cout << "created scope table with id " << symt->number_of_st << endl;
        }
        else if (c == 'E')
        {
            symt->ExitScope();
        }
        else if (c == 'D')
        {
            string key;
            inFile >> key;
            cout << key << endl;
            symt->Remove(key);
        }
        else if (c == 'L'){
            string key;
            inFile >> key;
            cout << key << endl;
            symt->Lookup(key);
        }
        else if(c == 'P'){
            char c1;
            inFile >> c1;
            cout << c1 << endl;
            if(c1 == 'C'){
                symt->PrintCurrent();
            }
            else if (c1 == 'A'){
                symt->PrintAll();
            }
        }

    }
    return 0;
}

/*int main()
{
    char c;
    int capacity;
    cin >> capacity;
    SymbolTable * symt = new SymbolTable(capacity);
    while(1)
    {
        cin >> c;
        if(c == 'I')
        {
            if(symt->number_of_st == 0)
            {
                symt->EnterScope();
                string name;
                string type;
                cin >> name;
                cin >> type;

                SymbolInfo * newsymbol = new SymbolInfo();
                newsymbol->setName(name);
                newsymbol->setType(type);
                newsymbol->nextinchain = NULL;
                if(symt->Insert(newsymbol)) cout << "of scope table with id " << symt->number_of_st << endl;

            }
            else
            {
                string name;
                string type;
                cin >> name;
                cin >> type;

                SymbolInfo * newsymbol = new SymbolInfo();
                newsymbol->setName(name);
                newsymbol->setType(type);
                newsymbol->nextinchain = NULL;
                if(symt->Insert(newsymbol)) cout << "of scope table with id " << symt->number_of_st << endl;

            }
        }
        else if (c == 'S')
        {
            symt->EnterScope();
            cout << "created scope table with id " << symt->number_of_st << endl;
        }
        else if (c == 'E')
        {
            symt->ExitScope();
        }
        else if (c == 'D')
        {
            string key;
            cin >> key;
            symt->Remove(key);
        }
        else if (c == 'L'){
            string key;
            cin >> key;
            symt->Lookup(key);
        }
        else if(c == 'P'){
            char c1;
            cin >> c1;
            if(c1 == 'C'){
                symt->PrintCurrent();
            }
            else if (c1 == 'A'){
                symt->PrintAll();
            }
        }
    }

}*/

/*int main()
{
    char c;
    ScopeTable * st = new ScopeTable (5);

    while(1)
    {
        cin >> c;
        if(c == 'I')
        {
            string name;
            string type;
            cin >> name;
            cin >> type;

            SymbolInfo * newsymbol = new SymbolInfo();
            newsymbol->setName(name);
            newsymbol->setType(type);
            newsymbol->nextinchain = NULL;
            st->Insert(newsymbol);
        }
        else if (c == 'L')
        {
            string key;
            cin >> key;
            st->LookUp2(key);
        }
        else if (c == 'D')
        {
            string key;
            cin >> key;
            st->Delete(key);
        }
        else if (c == 'P'){
            st->Print();
        }
    }
    return 0;
}*/
