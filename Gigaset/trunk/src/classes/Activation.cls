global with sharing class Activation {
	
	webservice static String init(String ContactId, Boolean Deactivation) {

    		Contact c=[SELECT Id, toActivate__c, toDeactivate__c, Email FROM Contact WHERE Id =:ContactId];
		
		if(c != null) {
			if(c.toActivate__c == True || c.toDeactivate__c == True) {
	  			return System.label.please_wait;
	  		}
	  		
	  		User u = new User();
	  		try {
	  			u = [select id from User where contactId =: ContactId];
	  		}
	  		catch (exception e) {}
	  		
			if(Deactivation == False) {
	  			if(u.Id == null) {	
		  			c.toActivate__c = True;

		  			if(c.Email == null || c.Email == '')
		  				return System.label.Email_not_null;
					try{
		  				update c;
		  			}
		  			catch(exception e) {
		  				if(c.Email == null || c.Email == '')
		  					return System.label.Email_not_null;
		  				else 
		  					return System.label.unknown_problem;
		  				
		  			}
		  			return 'true';
	  			}
	  			else {
	  				return System.label.Kontakt_schon_aktiviert;
	  			}	  		
			}
			else {
				if(u.Id == null) {
					return System.label.Kontakt_noch_nicht_aktiviert;
				}
				else {
		  			c.toDeactivate__c = True;

					try{
		  				update c;
		  			}
		  			catch(exception e) {
	  					return System.label.unknown_problem;
		  			}
		  			return 'true';
		  		}
			}
		}

		return System.label.unknown_problem;
  	}
}