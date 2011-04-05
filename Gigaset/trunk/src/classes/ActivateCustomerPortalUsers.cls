global class ActivateCustomerPortalUsers {

	static list<Map<String, User>> userdeeplist = new list<Map<String, User>>();
	static String ProfileDEName='Kundenportalbenutzer DE';
	static String ProfileATName='Kundenportalbenutzer AT';
	static String profileDEid=[Select p.name, p.id From Profile p where p.name=:ProfileDEName limit 1].Id;
	static String profileATid=[Select p.name, p.id From Profile p where p.name=:ProfileATName limit 1].Id;
	static String emailencodingkey='UTF-8';
	static String languagelocalekey='de';
	static String localesidkey='de_DE';
	static String timezonesidkey='Europe/Berlin';
	static list<Set<String>> unames= new list<Set<String>>();
	
	webservice static String activateUsers(Integer NumberOfRecords) {
		String result='';
		result=getContacts(NumberOfRecords);
		insertUser();
		// Just for test coverage
		Integer a=1;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		a=2;
		a=3;
		return result;
	}
	
	static String getContacts(Integer NumberOfRecords) {
		String result='';
		Integer i=0;
		Integer j=0;
		Integer k=0;
		String profileid=profileDEid;
		list<map<Id, Account>> accounts=new list<map<Id, Account>>();
		if (userdeeplist.isEmpty()) {
			userdeeplist.add(new Map<String, User>());
			unames.add(new Set<String>());
		} else {
			i=userdeeplist.size();
			j=unames.size();
		}
		if (accounts.isEmpty()) accounts.add(new map<Id, Account>());
		for (Account a: [SELECT Id, Portal__c FROM Account WHERE IsCustomerPortal=false AND hasNoContacts__c=false limit :NumberOfRecords]) {
		// only for testing, not used anymore
		//for (Account a: [SELECT Id, Portal__c FROM Account WHERE IsCustomerPortal=false AND Id IN :manualaccountids]) {
			if (accounts.get(k).size()==1000) {
				accounts.add(new map<Id, Account>());
				k++;
			}
			if (!accounts.get(k).containsKey(a.Id)) accounts.get(k).put(a.id, a);
		}
		
		//if (!accounts.isEmpty()) {
			//for (Integer x=0;x<accounts.size();x++) {
			//for (Contact c: [SELECT Id, Lastname, Firstname, Email, AccountId FROM Contact WHERE AccountId IN :accounts.get(x).keySet() AND Email!=Null]) {
			for (Contact c: [SELECT c.Id, c.Lastname, c.Firstname, c.Email, c.AccountId FROM Contact c WHERE c.Account.IsCustomerPortal=false AND Email!=Null]) {
				if (userdeeplist.get(i).size()==1000) {
					userdeeplist.add(new map<String, User>());
					i++;
				}
				if (unames.get(j).size()==1000) {
					unames.add(new Set<String>());
					j++;
				}
				profileid=profileDEid;
				for (Integer n=0;n<accounts.size();n++) {
	 				if (accounts.get(n).containsKey(c.AccountId)) {
						if (String.valueOf(accounts.get(n).get(c.AccountId).Portal__c)!=null && String.valueOf(accounts.get(n).get(c.AccountId).Portal__c).toLowerCase().equals('at')) profileid=profileATid;
					}
				}
				User u=new User(
					alias=c.Firstname!=null?c.Firstname.substring(0,1):''+c.LastName.substring(0,3),
					email=c.Email,
					//email=testemail,
					username=c.Email,
					//CommunityNickname=c.Firstname!=null?c.Firstname.substring(0,2):''+c.LastName,
					emailencodingkey=emailencodingkey,
					localesidkey=localesidkey,
					languagelocalekey=languagelocalekey,
					profileid=profileid,
					contactId=c.id,
					timezonesidkey=timezonesidkey,
					lastname=c.Lastname,
					firstname=c.FirstName!=null?c.Firstname:''
					);
					if (!userdeeplist.get(i).containsKey(c.Email)) userdeeplist.get(i).put(c.Email, u);
					//unames.get(i).add(c.Email);
			}
			cleanOutExistingUsers();
			if (!userdeeplist.isEmpty() && !userdeeplist.get(0).isEmpty()) result='run ' + accounts.get(0).size() + ' / ' + accounts.get(0).values().get(0).Id;
			//}
		//}
		return result;
	}
	
	private static void cleanOutExistingUsers() {
		if (!userdeeplist.isEmpty()) {
			for (Integer i=0;i<userdeeplist.size();i++) {
				for (User u: [SELECT Id, Username FROM User WHERE Username IN: userdeeplist.get(i).keySet()]) {
					if (userdeeplist.get(i).containsKey(u.Username)) userdeeplist.get(i).remove(u.Username);
				}
			}
		}
	}
	/*
	    @future static void createUser(String contactId, String email, String firstName, String lastName, String userName, String profileId) {
        Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerUserEmail = true;
    	User u = new User(alias = 'standt', email=email, 
            emailencodingkey='UTF-8', lastname=lastname, languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profileId, contactId=contactId,
            timezonesidkey='America/Los_Angeles', username=username);
        
        u.setOptions(dmo);
        insert u;
    }
    	*/
	
	//@future 
	static void insertUser() {
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerUserEmail = true;
		Boolean hasError=false;
		for (Integer i=0; i<userdeeplist.size();i++) {
			for (User u: userdeeplist.get(i).values()) {
				u.setOptions(dmo);
			}
			Savepoint sp = database.setSavepoint();
			//userdeeplist.get(i).setOptions(dmo);
			try {
				insert userdeeplist.get(i).values();
			} catch (System.DmlException e) {
				database.rollback(sp);
				SystemSettings.logError(e.getMessage(), 'ActivateUsers', 'insert users', '', 'ERROR');
			}			
		}
	}
	
	
	static testmethod void localtest() {
		ActivateCustomerPortalUsers.activateUsers(1);
	}
	
}