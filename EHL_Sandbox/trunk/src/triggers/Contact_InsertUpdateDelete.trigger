trigger Contact_InsertUpdateDelete on Contact (before update, after update, before insert, after insert, before delete) {
	
    
    try{
    	if(!TriggerContext.getIsContactUpdated()) {
    		
	        //initalize handlers with constant values
	        ContactAddressModel contactHandler = new ContactAddressModel();
	        ContactLastnameFormat lastNameFormatter = new ContactLastnameFormat();       
	        
	        if(Trigger.isInsert){            
	            if (Trigger.isBefore) {
	            	System.debug('**** Contact> before insert trigger');
		            //validate address
		            contactHandler.contactBeforeInsert(Trigger.new);
	            } else {
	            	System.debug('**** Contact> after insert trigger');
		            //insert new address if address in contact is provided
		            contactHandler.contactAfterInsert(Trigger.new);
		            TriggerContext.setContactIsUpdated();
	            }
	 
	        }else if (Trigger.isUpdate){
	            System.debug('**** Contact> before update trigger');            
	            if (Trigger.isBefore) {
	            	System.debug('**** Contact> before update trigger');
		            //validate address
		            contactHandler.contactBeforeUpdate(Trigger.new, Trigger.oldMap);
	            	lastNameFormatter.formatContacts(Trigger.new);
	            } else {
	            	System.debug('**** Contact> after update trigger');	            
		            contactHandler.contactAfterUpdate(Trigger.new, Trigger.oldMap);
		            TriggerContext.setContactIsUpdated();
	            }
	                        
	        }else if (Trigger.isDelete){
	            if(Trigger.isBefore){
	                System.debug('**** Contact> before delete trigger');
	                //delete all address objects
	                contactHandler.contactBeforeDelete(Trigger.oldMap);
	            }
	        }
	        
    	}
     }catch(System.Exception e){
         System.debug('**** Final Exception Contact Trigger' + e);
    }

}