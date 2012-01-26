trigger Address_insertUpdateDelete on Address__c (before insert, after insert, before update, after update, after delete) {
    

    if(!TriggerContext.getIsAddressUpdated()) {
	    //**************************** initalize *************************
	    AddressModelAccount accHandler = new AddressModelAccount();
	    AddressModelContact contactHandler = new AddressModelContact();
	    
	    Set<Id> contactRecordTypeIdSet = new Set<Id>{SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE, SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE,
													    SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE, SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE, 
													    SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE, SystemSettings.CONTACT_ADDRESS_PERMANENT_RECORDTYPE};
													    
	    List<Address__c> addrCorrespondingToAccount = new List<Address__c>();
	    List<Address__c> addrCorrespondingToContact = new List<Address__c>();
	
	    if(!Trigger.isDelete){
	        for(Address__c a : Trigger.new){
	            if(a.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE || a.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE){
	                addrCorrespondingToAccount.add(a);
	            }else if(contactRecordTypeIdSet.contains(a.RecordTypeId)){
	                addrCorrespondingToContact.add(a);
	            }
	        }   
	    }else{
	        for(Address__c a : Trigger.old){
	            if(a.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE || a.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE){
	                addrCorrespondingToAccount.add(a);
	            }else if(contactRecordTypeIdSet.contains(a.RecordTypeId)){
	                addrCorrespondingToContact.add(a);
	            }
	        }   
	    }
	    System.debug('**** addr> Contact '+ addrCorrespondingToContact.size());
	    System.debug('**** addr> Account '+addrCorrespondingToAccount.size());
	    
	    //**************************** ACCOUNT *************************
	    if(! addrCorrespondingToAccount.isEmpty()){
	        if(Trigger.isInsert){
	            if(Trigger.isBefore){
					//check if already a preferred address for this account, if yes -> error, validation
					System.debug('**** addr> before insert trigger');
					accHandler.addressBeforeInsert(addrCorrespondingToAccount);
				} else {
					//update account
					System.debug('**** addr> after insert trigger');
					accHandler.addressAfterInsert(addrCorrespondingToAccount);
	    			TriggerContext.setAddressIsUpdated();				
				}
	        
	        }else if (Trigger.isUpdate){
	    		if(Trigger.isBefore){
					//if preferred changed to true, check
	            	//if account is updated check if already has preferred -> error
					System.debug('**** addr> before update trigger');
	            	accHandler.addressBeforeUpdate(addrCorrespondingToAccount, Trigger.oldMap);
				} else {
					//update account
					System.debug('**** addr> after update trigger');
	            	accHandler.addressAfterUpdate(addrCorrespondingToAccount, Trigger.oldMap);
	    			TriggerContext.setAddressIsUpdated();				
				}
				
	        }else if (Trigger.isDelete){
	            if(Trigger.isAfter){
	                System.debug('**** addr> delete after trigger');
	                accHandler.addressAfterDelete(addrCorrespondingToAccount);	                
	    			TriggerContext.setAddressIsUpdated();
	            }
	        }
	    }
	    
	    
	    //**************************** CONTACT *************************
	    if(! addrCorrespondingToContact.isEmpty()){
	        if(Trigger.isInsert){
	    		if(Trigger.isBefore){
					//check if already a preferred address for this account, if yes -> error, validation
					System.debug('**** addr> before insert trigger - Contact');
	            	contactHandler.addressBeforeInsert(addrCorrespondingToContact);
				} else {
					//
					System.debug('**** addr> after insert trigger - Contact');
	            	contactHandler.addressAfterInsert(addrCorrespondingToContact);	
	    			TriggerContext.setAddressIsUpdated();		
				}
	        }else if (Trigger.isUpdate){
	            
	    		if(Trigger.isBefore){
					//if address is updated check if already has preferred -> error
		            System.debug('**** addr> before update trigger - Contact');
		            contactHandler.addressBeforeUpdate(addrCorrespondingToContact, Trigger.oldMap);
		    		TriggerContext.setAddressIsUpdated();
				} else {
					//
		            System.debug('**** addr> after update trigger - Contact');
		            contactHandler.addressAfterUpdate(addrCorrespondingToContact, Trigger.oldMap);	
	    			TriggerContext.setAddressIsUpdated();		
				}
	            
	        }else if (Trigger.isDelete){
	            if(Trigger.isAfter){
	                System.debug('**** addr> delete trigger - Contact');
	                contactHandler.addressAfterDelete(addrCorrespondingToContact);
	   				TriggerContext.setAddressIsUpdated();
	            }
	        }
	    }
    } else {
	    System.debug('**** Address already updated!');
    }
    
}