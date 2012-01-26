trigger Account_insertUpdateDelete on Account (before insert, after insert, before update, after update, before delete) {
    
    if(!TriggerContext.getIsAccountUpdated()) {
	    AccountAddressModel accHandler = new AccountAddressModel();   
	    
	    if(Trigger.isInsert){
	        System.debug('**** Account> after insert trigger');
	        //insert new address if address in account is provided, create taks if city is not valid
	        if(Trigger.isBefore) {          
	            accHandler.accountBeforeInsert(Trigger.new);
	        } else {            
	            accHandler.accountAfterInsert(Trigger.new);	            
	    		TriggerContext.setAccountIsUpdated();
	        }
	        
	    }else if (Trigger.isUpdate){
	        if(Trigger.isBefore) {      
	            System.debug('**** Account> before update trigger');
	            accHandler.accountBeforeUpdate(Trigger.new, Trigger.oldMap);
	        } else {            
	            System.debug('**** Account> after update trigger');
	            accHandler.accountAfterUpdate(Trigger.new, Trigger.oldMap);
	    		TriggerContext.setAccountIsUpdated();
	        }
	        
	                
	    }else if (Trigger.isDelete){
	        System.debug('**** Account> before delete trigger');
	        //delete all address objects 
	        accHandler.accountBeforeDelete(Trigger.oldMap);        
	    	TriggerContext.setAccountIsUpdated();
	    }
    } else {
	    System.debug('**** Account already updated! ' + Trigger.isUpdate);
    }

}