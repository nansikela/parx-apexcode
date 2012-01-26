global class ContactNameCheck_Schedulable implements Schedulable{
    
    
    global void execute(SchedulableContext SC) {
        System.debug('********************** execute methode der Klasse ContactNameCheck_Schedulable');
        
        ContactNameCheck_OpportunityBatchable oppBatchJob = new ContactNameCheck_OpportunityBatchable();
		System.debug('********************** ContactNameCheck_OpportunityBatchable batchprocessid:' + Database.executeBatch(oppBatchJob,50));
		
        ContactNameCheck_ApplicationBatchable appBatchJob = new ContactNameCheck_ApplicationBatchable();
		System.debug('********************** ContactNameCheck_ApplicationBatchable batchprocessid:' + Database.executeBatch(appBatchJob,50));
		
		
				
//   		AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
//      		FROM AsyncApexJob WHERE ID =: batchprocessid ];
//		
//		System.debug('AsyncApexJob TotalJobItems:' + aaj.TotalJobItems);      		
    }

}