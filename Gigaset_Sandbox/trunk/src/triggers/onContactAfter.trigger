trigger onContactAfter on Contact (after delete, after insert, after undelete, 
after update) {

    list<Id> accountids = new list<Id>();
    if (trigger.isAfter) {
        if (trigger.isDelete) {
            for (Contact c: trigger.old) {
                if (c.Gigaset_Pro__c) accountids.add(c.AccountId);
            }
        }
        if (trigger.isInsert || trigger.isUnDelete) {
            for (Contact c: trigger.new) {
                if (c.Gigaset_Pro__c) accountids.add(c.AccountId);
            }
        }
        if (trigger.isUpdate) {
            for (Contact c: trigger.new) {
                //if (c.Gigaset_Pro__c != trigger.oldMap.get(c.id).Gigaset_Pro__c) 
                accountids.add(c.AccountId);
            }
        }
    }
    
    if (!accountids.isEmpty()) changeAccounts.ChangeAccounts(accountids);
    
    
    
    
    if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter) {
    	list<Contact> contact2Update = new list<Contact>();
    	list<Contact> Contacts = new list<Contact>([select id, SecurityId__c, HasOptedOutOfEmail, Newsletter_Security_Link__c, Info_per_Email__c from Contact where Id IN: trigger.new]);
	    for(Contact c:Contacts) {
	    	Boolean needsUpdate = false;
	    	
	    	if(trigger.isInsert && (c.Newsletter_Security_Link__c != null || c.Newsletter_Security_Link__c != '')) {
	    		c.Newsletter_Security_Link__c = '';
	    		needsUpdate = true;
	    	}
	    	
	    	if(c.SecurityId__c == null || c.SecurityId__c == '') {
		        String algorithmName = 'hmacSHA512';
		        String key = '';
		        key = FN__FindNearby__c.getOrgDefaults().KontaktformularKey__c;
		        Blob privateKey = EncodingUtil.base64Decode(key);
		        Blob input = Blob.valueOf(String.valueOf(c.Id).substring(0,15)); 
		        c.SecurityId__c = EncodingUtil.urlEncode(EncodingUtil.base64Encode( Crypto.generateMac(algorithmName, input, privateKey )), 'UTF-8');
		        needsUpdate = true;
		    }
		    if((trigger.isInsert || (trigger.isUpdate && c.HasOptedOutOfEmail)) && c.Info_per_Email__c && (c.Newsletter_Security_Link__c == null || c.Newsletter_Security_Link__c == '')) {
	    		String algorithmName = 'hmacMD5';
       			String key = '';
       			if(trigger_settings__c.getAll().containsKey('newsletter_registration_security_key'))
       			    key = trigger_settings__c.getAll().get('newsletter_registration_security_key').Value__c;
       			else {
       				c.addError(System.Label.lead_convert_newsletter_activation_security_key);
       			}
       			Blob privateKey = EncodingUtil.base64Decode(key);
       			Blob input = Blob.valueOf('Id=' + c.Id);
       			c.Newsletter_Security_Link__c = 'Id=' + c.Id + '&Check='+ EncodingUtil.urlEncode(EncodingUtil.base64Encode( Crypto.generateMac(algorithmName, input, privateKey )), 'UTF-8');    
	  			needsUpdate = true;
	    	}
	    	
	    	if(needsUpdate)
	    		contact2Update.add(c);
	    }
	    if(!contact2Update.isEmpty())
	       update contact2Update;
    }
}