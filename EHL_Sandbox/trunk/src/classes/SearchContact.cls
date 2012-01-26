public class SearchContact {
    public Contact searchObject { get; set; }
    public List<cContact> contactList {get; set;}
    public String query {get;set;}
    public SearchContact(){
        searchObject = new Contact();
        contactList = new List<cContact>();
    } 
    //This method uses a simple SOQL query to return a List of Contacts
        public PageReference doSOQL(){
            
            query = 'SELECT c.Id, c.Contact_ID__c, c.AccountId, c.Account.Name, c.Email, c.FirstName, c.LastName, c.Name FROM Contact c WHERE c.AccountId<>\'\' ';
            
            if(searchObject.firstname != null)
            {
                query+= ' AND c.Firstname=\'' + searchObject.firstname+'\' ';
            }
            if(searchObject.lastname != null)
            {
                query+= + ' AND c.Lastname=\'' + searchObject.lastname+'\' ';
            }
            
            query+= ' ORDER BY Firstname';
            System.debug('**********query:'+query);
            
            contactList = new List<cContact>();
            for(Contact c: Database.Query(query))
            {
                contactList.add(new cContact(c));
            } 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'query: ' + query ));
            
            return null;
         }
    public boolean getIsResult()
    {
        if(contactList.size()>0)
        {
                return true;
        }
        else
        {
                return false;
        }
    }
    public class cContact {
        public Contact con {get; set;}
        public boolean selected {get; set;}
        
            public cContact(Contact c) {
                con = c;
                selected = false;
            }
    }
}