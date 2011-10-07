trigger BeforeOnOpportunity on Opportunity (before delete, before insert, before update) {
	
	//List<Opportunity> osToUpdate = new List<Opportunity>();
	List<Opportunity> osToInsert = new List<Opportunity>();
	//List<Opportunity> osToDelete = new List<Opportunity>();
	Map<Id, Double> osToUpdate = new Map<Id, Double>();
	Map<Id, Double> osToDelete = new Map<Id, Double>();
	System.debug('This Trigger will only run for offene Seminare');
	String DSoffeneSeminareId='012200000004Y3HAAU';
	
	for (Integer i=0; i<Trigger.size; i++) {
	 	System.debug('Trigger - before update/delete - fired.');
	 	if (Trigger.isUpdate) {
	 		if (Trigger.new[i].RecordTypeId==DSoffeneSeminareId && 
	 			Trigger.old[i].Stornokosten__c != Trigger.new[i].Stornokosten__c) {	 			
	 				osToUpdate.put(Trigger.new[i].Seminar__c,Trigger.new[i].Stornokosten__c-Trigger.old[i].Stornokosten__c);
	 		}
	 	}
	 	else if (Trigger.isInsert) {
	 		//psToInsert.add(Trigger.new[i]);
	 	}
	 	else if (Trigger.old[i].RecordTypeId==DSoffeneSeminareId && Trigger.isDelete && 
	 		Trigger.old[i].Stornokosten__c>0) {
	 			osToDelete.put(Trigger.old[i].Seminar__c,Trigger.old[i].Stornokosten__c);
	 	}
	}
	if (Trigger.isUpdate && !osToUpdate.isEmpty()) {	 	
	 	System.debug('PARX: UPDATE - BeforeOnOpportunity');
	 	akademie.UpdateProduct2(osToUpdate,'update');	 	
	 }
	/*
	if (Trigger.isInsert && !osToInsert.isEmpty()) {	 	
	 	System.debug('PARX: INSERT BeforeOnOpportunity');	 	
	 }
	*/
	if (Trigger.isDelete && !osToDelete.IsEmpty()) {
	 	System.debug('PARX: DELETE BeforeOnOpportunity');
	 	akademie.UpdateProduct2(osToDelete,'delete');	
	 }
}