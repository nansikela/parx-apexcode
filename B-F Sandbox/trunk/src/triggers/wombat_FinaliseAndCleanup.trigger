trigger wombat_FinaliseAndCleanup on wombat_Sync_Session__c (after update) {
	for (wombat_Sync_Session__c wss: Trigger.new) {
		System.debug('finalised on client: ' + wss.Finalised_On_Client__c + ', inprogres: ' + wss.InProgress__c + ', status: ' + wss.Status__c);
		if (wss.InProgress__c == false && wss.Status__c == 'Success' && wss.Finalised_On_Client__c == true) {
			List<wombat_Transaction_Items__c> items = [SELECT Id FROM wombat_Transaction_Items__c WHERE wombat_Sync_Session__c = :wss.Id];
			
			delete items; 
		}
	}
}