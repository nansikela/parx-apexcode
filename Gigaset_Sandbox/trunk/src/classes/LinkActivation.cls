global class LinkActivation {
    
    public PageReference action() {
        try {
        	String RecordId = System.currentPageReference().getParameters().get('Id');
        	String Check = System.currentPageReference().getParameters().get('Check');
        
       		if(RecordId != null && Check != null) {
        	    if(trigger_settings__c.getAll().containsKey('newsletter_registration_security_key')) {
        	        String algorithmName = 'hmacMD5';
       		        String key = trigger_settings__c.getAll().get('newsletter_registration_security_key').Value__c;
        	        Blob privateKey = EncodingUtil.base64Decode(key);
        	        Blob input = Blob.valueOf('Id=' + RecordId);
        	        
        	        if(Check == EncodingUtil.base64Encode( Crypto.generateMac(algorithmName, input, privateKey ))) {
        	        	system.debug(RecordID);
        	            list<Contact> c = new list<Contact>([select id, HasOptedOutOfEmail, Double_Opt_In_Timestamp__c from Contact where Id=:RecordId limit 1]);
        	            if(!c.isEmpty()) {
        	                c.get(0).HasOptedOutOfEmail = false;
        	                c.get(0).Double_Opt_In_Timestamp__c = system.now();
        	                update c;
        	            }
        	        }
        	    }
        	}
        } catch( Exception e ){
        	return new PageReference('/LinkActivationFailed');
        }
        return new PageReference('/LinkActivationSuccessful');
    }
    
    @isTest
    public static void testing() {
        system.assertEquals(trigger_settings__c.getAll().containsKey('newsletter_registration_security_key'), true);
        system.assertEquals(trigger_settings__c.getAll().containsKey('newsletter_registration_errorUrl'), true);
        system.assertEquals(trigger_settings__c.getAll().containsKey('newsletter_registration_successUrl'), true);
        
        Account a = new Account(Name = 'Company');
        insert a;
        Contact c = new Contact(LastName = 'test', AccountID= a.ID);
        insert c;
        String RecordId = c.Id;
        String algorithmName = 'hmacMD5';
        String key = trigger_settings__c.getAll().get('newsletter_registration_security_key').Value__c;
        blob privateKey = EncodingUtil.base64Decode(key);
        blob input = Blob.valueOf('Id=' + RecordId);
    
        String Check = EncodingUtil.base64Encode( Crypto.generateMac(algorithmName, input, privateKey ));
                    
        System.currentPageReference().getParameters().put('Id', RecordId);
        System.currentPageReference().getParameters().put('Check', Check);
        
        test.startTest();
        LinkActivation LA = new LinkActivation();
        LA.action();
        test.stopTest();
    } 
}