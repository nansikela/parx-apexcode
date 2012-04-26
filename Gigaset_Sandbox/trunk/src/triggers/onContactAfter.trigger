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
    	list<Contact> Contacts = new list<Contact>([select id, SecurityId__c from Contact where Id IN: trigger.new]);
	    for(Contact c:Contacts) {
	    	if(c.SecurityId__c == null || c.SecurityId__c == '') {
		        String algorithmName = 'hmacSHA512';
		        String key = '';
		        key = FN__FindNearby__c.getOrgDefaults().KontaktformularKey__c;
		        Blob privateKey = EncodingUtil.base64Decode(key);
		        Blob input = Blob.valueOf(String.valueOf(c.Id).substring(0,15)); 
		        c.SecurityId__c = EncodingUtil.urlEncode(EncodingUtil.base64Encode( Crypto.generateMac(algorithmName, input, privateKey )), 'UTF-8');
		        contact2Update.add(c);
		    }
	    }
	    if(!contact2Update.isEmpty())
	       update contact2Update;
    }
}