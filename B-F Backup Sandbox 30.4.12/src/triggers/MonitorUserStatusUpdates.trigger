trigger MonitorUserStatusUpdates on User (before update) {

	List<String> phrases = new List<String>();
	for (Chatter_Phrases__c phrase: Chatter_Phrases__c.getAll().values()) {
		phrases.Add(phrase.name);
	}
	
	for (Integer i = 0; i < trigger.new.size(); i++) {
        if ( trigger.new[i].CurrentStatus != null && trigger.old[i].CurrentStatus != trigger.new[i].CurrentStatus) {
        	for (String p : phrases) {
        		if (trigger.new[i].CurrentStatus.contains(p)) {
           			trigger.new[i].CurrentStatus.addError('Unwanted Status: ' + trigger.new[i].CurrentStatus); // Prevent Update      			
        		}
        	}	
        } 
	}
}