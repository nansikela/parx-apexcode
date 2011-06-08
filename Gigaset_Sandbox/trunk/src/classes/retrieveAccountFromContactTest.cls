@isTest
private class retrieveAccountFromContactTest {

    static testMethod void myUnitTest() {
    	User u = [Select Id, ContactId From User Where ContactId != null and isactive=true limit 1];
    	list<String> ids = new list<String>();
    		
		Account tmp = null;
		
		for(Account a : [Select Id, ShippingStreet, ShippingPostalCode,ShippingCity, ShippingCountry,Firmenname_Lieferanschrift__c From Account limit 20]){
			ids.add(a.id);
			tmp = a;
		}
			
		String aID = ids.get(0);
    	System.runas(u){

    		retrieveAccountFromContact ctrl = new retrieveAccountFromContact(aid, null);	
    	}
    	
    		tmp.ShippingStreet = 'TestCity';
    		tmp.ShippingPostalCode = '12345';
    		tmp.ShippingCity = 'TestCity';
    		tmp.ShippingCountry = 'TestCountry';
    		tmp.Firmenname_Lieferanschrift__c = 'Test';
    		update tmp;
    	System.runas(u) {	
    		retrieveAccountFromContact ctrl = new retrieveAccountFromContact(tmp.Id, ids);	
			
    	}
    }
}