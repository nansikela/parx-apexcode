@isTest
private class onContactAfterTest {

    static testMethod void myUnitTest() {
     	
     	User u = [SELECT Id, Name FROM User WHERE Id = :Userinfo.getUserId()];
     	list<Contact> massDML = new list<Contact>();
     	
     	System.runAs(u){
     		Account a1 = new Account(Name = 'Test Company');
     		Account a2 = new Account(Name = 'Rofl Company');
     		
     		insert a1;
     		insert a2;
 
     		massDML.add(new Contact(Lastname = 'Mustermann', AccountId = a1.Id, Gigaset_pro__c = true));
     		massDML.add(new Contact(Lastname = 'Musterfrau', AccountId = a2.Id, Gigaset_pro__c = true));
     		massDML.add(new Contact(Lastname = 'Sample', AccountId = a1.Id, Gigaset_pro__c = false));
     		massDML.add(new Contact(Lastname = 'Mueller', AccountId = a2.Id, Gigaset_pro__c = false));
     		
     		insert massDML;
     		
     		massDML.get(0).Gigaset_pro__c = false;
     		update massDML;
     		
     		delete massDML;
     	}
    }
}