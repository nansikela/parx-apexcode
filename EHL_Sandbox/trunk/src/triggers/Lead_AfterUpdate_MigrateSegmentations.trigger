trigger Lead_AfterUpdate_MigrateSegmentations on Lead (after update) {

/*********************************************************************************************
 * Trigger to re-attach segmentations of a lead being converted to the newly created contact(s)
 *********************************************************************************************/
	/* Recordtype ID definitions */
	
	// Areas of interest
	String RT_PROSPECT_AOI 	= '0122000000050Kq';
	String RT_CONTACT_AOI 	= '0122000000050Kl';
	
	// Marketing preferences
	String RT_PROSPECT_MP 	= '0122000000050fb';
	String RT_CONTACT_MP	= '01220000000500C';

	List<Lead> currentlyConvertedLeadsList = new List <Lead>();
	List<segmentation__c> segmentationList = new List<segmentation__c>();

	// Old/new lead values
	Map<Id,Lead> oldLeadMap = Trigger.oldMap;
	List<Lead> newLeadList = Trigger.new;

	System.debug('***** Total Leads passed to trigger: ' + newLeadList.size());
	
	// Get flat list of leads currently being converted
	for(Lead lead : newLeadList) {	
		
		
 		if(oldLeadMap.containsKey(lead.Id)){
		
			if(lead.isConverted && !oldLeadMap.get(lead.Id).isConverted){
				
				currentlyConvertedLeadsList.add(lead);
				
			}
		}
	}
	
	
	// Get flat list of segmentations attached to any of the converted leads
	segmentationList = [Select s.Contact__c, s.Prospect__c, s.RecordTypeId From Segmentation__c s where s.Prospect__c in :currentlyConvertedLeadsList];
	

	// Update contact reference of each segmentation 		
	for(Lead lead : currentlyConvertedLeadsList) {
	
		for(segmentation__c currentSegmentation : segmentationList){
		
			if(currentSegmentation.Prospect__c == lead.id){
				
				currentSegmentation.Contact__c = lead.ConvertedContactId; 
				
				// Change record type when migrating
				if(currentSegmentation.RecordTypeId == RT_PROSPECT_AOI){
					currentSegmentation.RecordTypeId = RT_CONTACT_AOI;
				}
				else if(currentSegmentation.RecordTypeId == RT_PROSPECT_MP){
					currentSegmentation.RecordTypeId = RT_CONTACT_MP;
				}
				
			}
		
		}	
	
	}
	
	
	// Store updates
	try{
		
		update segmentationList;
	
	}catch(System.DMLException e){
		
    	System.debug('***** DMLException occured: ' + e);
    	
	}
	
	// TODO: check if there is already a contact id in segmentation -> what to do then?
		
	
	

}