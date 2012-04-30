trigger beforeInsertMonitorEntityFeeds on FeedItem (before insert) {

	List<String> phrases = new List<String>();
	for (Chatter_Phrases__c phrase: Chatter_Phrases__c.getAll().values()) {
		phrases.Add(phrase.name);
	}

    for (FeedItem f: trigger.new)
    {
        if ( f.Type=='LinkPost' && f.Body != null) {
        	for (String p : phrases) {
        		if (f.Body.contains(p)) {
           			f.Body.addError('Unwanted FeedItem');      			
        		}
        	}	
        }
    } 
}