trigger Application_propagateOwnerToSelections on Application__c (after insert, after update) {

	/*
	 *   Trigger to propagate owner information to all 
	 *   selections attached to an application (on appl. change)
 	 */


	List<Application__c> newApplicationList = Trigger.new;
	System.debug('**** Number of Apps passed to trigger: '+ newApplicationList.size());
	
	// Create list of application ID's
	List<id> applicationIdList = new List<id>();
	for (Application__c app : newApplicationList){
		applicationIdList.add(app.id);	
	}


	// All selections
	List<Selection__c> selectionsList = [Select s.id, s.Application__c, s.Application_Owner__c From Selection__c s where s.Application__c IN :applicationIdList];
	System.debug('**** Number of selections related to apps: '+ selectionsList.size());

	// update ownership data on the selections
	for (Application__c app : newApplicationList){
	
		id appId	= app.id;
		id appOwner = app.OwnerId;
		
		for (Selection__c selection : selectionsList){
		
			if(selection.Application__c == appId){
				
				// set application owner on selection
				selection.Application_Owner__c = appOwner;
			}
		
		}
		
	}
	
	update selectionsList;

}