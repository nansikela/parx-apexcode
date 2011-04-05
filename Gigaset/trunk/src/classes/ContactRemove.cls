global class ContactRemove {
	
	private static List<User> u = new list<User>();
	private static List<Contact> c = new list<Contact>();
	
	webservice static String remove(String ContactId) {
		u = [select id, IsPortalEnabled from User where contactId =: ContactId];
		
		//Cust Portal enabled
		removeUser();
		removeContact(ContactId);
		
		return 'true';
	} 
	
	@future(callout=true)
      private static void removeContact(String contactId) {
      	c = [select id, toDelete__c from Contact where Id =: contactId];
      	for(Contact cTemp:c) {
      		cTemp.toDelete__c = True;
      	}
      	if(!c.isEmpty()) {
      		try {
      			update c;
      		}
      		catch (exception e) {
      			String error = '';
      			for(Contact cTemp:c) {
      				error += cTemp.Id + ' ';
      			}
      			SystemSettings.logError(e.getMessage(), 'ContactRemove.removeContact', 'Bug on remove Contact', error, 'FATAL ERROR');
      		}
      	}
      		
      }
      
      public static void removeit() {
      	c = [select id from Contact where toDelete__c = True];
      	if(!c.isEmpty()) {
      		try {
      			delete c;  	
      		}
      		catch (exception e) {
      			String error = '';
      			for(Contact cTemp:c) {
      				error += cTemp.Id + ' ';
      			}
      			SystemSettings.logError(e.getMessage(), 'ContactRemove.removeit', 'Bug on removeit', error, 'FATAL ERROR');
      		}
      }
      }
      
	public static void init() {
		getContact();
		c = [Select Id, toDeactivate__c From Contact where toDeactivate__c = True];
		if(!c.isEmpty())		
			updateContact();
		removeUser(); 
      }
        
      private static void getContact() {
      	
      	u = [Select Id, IsPortalEnabled From User where Contact.toDeactivate__c = True];
      	
      }
       
      @future(callout=true) 
      private static void updateContact() {
      	c = [Select Id, toDeactivate__c From Contact where toDeactivate__c = True];
      	list<Contact> toUpdateC = new list<Contact>();
      	if(!c.isEmpty()) {
      		for(Contact cTemp:c) {
      			cTemp.toDeactivate__c = False;
      			toUpdateC.add(cTemp);
      		}
      		try{
      			update toUpdateC;  
      		}
      		catch(exception e) {
      			String error = '';
      			for(Contact con:toUpdateC) {
      				error += con.Id + ' ';
      			}
      			SystemSettings.logError(e.getMessage(), 'ContactRemove.updateContact', 'Bug on updateContact', error, 'FATAL ERROR');
      		}
      	} 
      } 
      
    	
      private static void removeUser() {
      	list<User> toUpdateU = new list<User>();
      	if(!u.isEmpty()) {
      		for(User uTemp:u) {
      			if(uTemp.isPortalEnabled != False) {
	      			uTemp.IsPortalEnabled = False;
	      			toUpdateU.add(uTemp);
      			}
      		}
      		try{
      			if(!toUpdateU.isEmpty())
     					update toUpdateU; 
      		}
      		catch(exception e) {
      			String error = '';
      			for(User temp:toUpdateU) {
      				error += temp.Id + ' ';
      			}
      			SystemSettings.logError(e.getMessage(), 'ContactRemove.RemoveUser', 'Bug on update User', error, 'FATAL ERROR');
      		}
      	}
      } 
       
}