trigger onContact on Contact (after insert, after update, before delete) {
    /**
     * Trigger should react on contact changes if contact is primary contact
     *Conditions: 
     *  -
     *          
     * @date    04/23/2012
     * @author  Michael Mickiewicz
     */
    set<ID> selectedOpinionLeaderIDs = new set<ID>();
    set<ID> unselectedOpinionLeaderIDs = new set<ID>();
    
  	for(Contact c : trigger.new)
    	if(c.Primary_Contact__c && (c.KAM_supervising_OPL__c != null || c.KAM_supervising_OPL__c != '')) {
    		if(!selectedOpinionLeaderIDs.contains(c.ID)) {
    			selectedOpinionLeaderIDs.add(c.ID);
    		}
	} else {
		if(!unselectedOpinionLeaderIDs.contains(c.ID)) {
    		unselectedOpinionLeaderIDs.add(c.ID);
		}
	}	
	
    if(trigger.isAfter) {  	
    		
        if(trigger.isInsert || trigger.isUpdate) {
        	system.debug('onupsert');
        	//Proceed the selected contacts as primary contacts
    		OpinionLeaderHelper.onUpsert(selectedOpinionLeaderIDs);
 			//Additionally, proceed the unselected contacts as primary contacts by reusing the onDelete method
    		OpinionLeaderHelper.onDelete(unselectedOpinionLeaderIDs);
        }
        
    } else if(trigger.isBefore) {
       	
        if(trigger.isDelete) {
        	system.debug('ondelete');
        	OpinionLeaderHelper.onDelete(selectedOpinionLeaderIDs);
        }
        
    }
}