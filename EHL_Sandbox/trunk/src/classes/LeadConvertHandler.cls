public class LeadConvertHandler {
	
	/*
	*	attaches profile and experience objects also to newly created contact
	*	deletes all created opportunities
	*/
    public Boolean updateProfileANDExperienceDeleteOpp(List<Lead> newLeadList, Map<Id,Lead> oldLeadMap){
        Boolean hasError = false;
        try{
        	List<Profile_Experience__c> profileExpToUpdateList = new List<Profile_Experience__c>();
	        
	        Map<Id,Id> leadIdContactIdMap = new Map<Id,Id>();
	        List<Id> opportunityListToDelete = new List<Id>();
	        
	        for(Lead lead : newLeadList){
	        	//update state and country
	        	if(oldLeadMap.containsKey(lead.Id)){
					
					if(lead.isConverted && !oldLeadMap.get(lead.Id).isConverted){
						//lead is just converted
						leadIdContactIdMap.put(lead.Id, lead.ConvertedContactId);
						if(lead.ConvertedOpportunityId != null ){
							opportunityListToDelete.add(lead.ConvertedOpportunityId);
						}
					}
	        	}
			}
			
			//select all relevant profile and experience object
			profileExpToUpdateList = [Select p.Contact__c, p.Prospect__c From Profile_Experience__c p where p.Prospect__c in :leadIdContactIdMap.keySet()];
			System.debug('***** number of profile and ex: ' + profileExpToUpdateList.size());
			
			for(Profile_Experience__c p: profileExpToUpdateList){
				if(leadIdContactIdMap.containsKey(p.Prospect__c)){
					p.Contact__c = leadIdContactIdMap.get(p.Prospect__c);
				}
			}
			
			//update profile and experience
			try{
				update profileExpToUpdateList;
			}catch(System.DMLException e){
            	System.debug('***** DMLException occured: ' + e);
			}
			
			//delete created opps
			System.debug('***** number of opps to delete: ' + opportunityListToDelete.size());
			
			if(!opportunityListToDelete.isEmpty()){
				List<Opportunity> oppToDeleteList = [Select o.Id from Opportunity o where o.Id in :opportunityListToDelete];
				try{
					delete oppToDeleteList;
				}catch(System.DMLException e){
	            	System.debug('***** DMLException occured: ' + e);
				}
			}
			
		}catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
            hasError = true;
        }
        
        return hasError;
    }
}