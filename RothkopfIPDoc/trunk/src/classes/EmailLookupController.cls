public with sharing class EmailLookupController {
    public String categorieChoosen {get;set;}
    public list<inCategorieClass> inCategories {get;set;}
    public String Criterium {get;set;}
    
    public class inCategorieClass {
        public String value{get;set;}
        public String name{get;set;}

    }
    
    public List<SelectOption> getCategories() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('user','Users'));
        options.add(new SelectOption('contact','Contacts'));
        options.add(new SelectOption('profile','Profiles'));
        options.add(new SelectOption('userrole','Roles'));
        return options;
    }
    
    public EmailLookupController() {
        categorieChoosen = 'user';
        Criterium = '';
        inCategories = new list<inCategorieClass>();
        inCategorieClass inCategorie;
        for(User s:[select lastname, firstname, email from User limit 20]) {
            inCategorie = new inCategorieClass();
            inCategorie.name = (s.firstname!=null?(s.firstname + ' '):'') + s.lastname;
            inCategorie.value = s.email;
            inCategories.add(inCategorie);
        }
    }
    
    public void updateInCategorie() {
        inCategories = new list<inCategorieClass>();
        inCategorieClass inCategorie;
        if(categorieChoosen == 'user' || categorieChoosen == 'contact'){
            String query = 'select lastname, firstname, email from ' + categorieChoosen + ' where lastname LIKE \'%' + Criterium + '%\' or firstname LIKE \'%' + Criterium + '%\'  limit 20';
            for(sObject s:Database.query(query)) {
                inCategorie = new inCategorieClass();
                inCategorie.name = (String.valueOf(s.get('firstname'))!=null?(String.valueOf(s.get('firstname')) + ' '):'')  + String.valueOf(s.get('lastname'));
                inCategorie.value = String.valueOf(s.get('email'));
                inCategories.add(inCategorie);
            }
        }
        else {
            String query = 'select name from ' + categorieChoosen + ' where name LIKE \'%' + Criterium + '%\'  limit 20';
            for(sObject s:Database.query(query)) {
                inCategorie = new inCategorieClass();
                inCategorie.name = String.valueOf(s.get('name'));
                inCategorie.value = '{\'' + (categorieChoosen=='userrole'?'role':categorieChoosen) + '\',\'' + String.valueOf(s.get('name')) + '\'}';
                inCategories.add(inCategorie);
            }
        }
        
    }
    

}