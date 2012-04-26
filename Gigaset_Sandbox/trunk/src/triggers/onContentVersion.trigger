trigger onContentVersion on ContentVersion (after insert) {
	list<Id> CaseIds = new list<Id>();
	list<ContentVersion> CVs = new list<ContentVersion>();
    for(ContentVersion cv:trigger.new) {
    	if(cv.FirstPublishLocationId!= null && String.valueOf(cv.FirstPublishLocationId).startsWith('005')) {
    		CVs.add(cv);
    		CaseIds.add(cv.Id);
    	}
    }
    
    map<Id, Case> Cases = new map<Id, Case>([select id, Article_Description__c, Article_Links__c from Case where Id IN: CaseIds]);
    
    for(ContentVersion cv:CVs) {
        Cases.get(cv.FirstPublishLocationId).Article_Description__c = cv.Description;
        if(Cases.get(cv.FirstPublishLocationId).Article_Links__c == null)
            Cases.get(cv.FirstPublishLocationId).Article_Links__c = '';
        Cases.get(cv.FirstPublishLocationId).Article_Links__c += cv.Id + '\n';
    }
    
    if(!Cases.isEmpty())
        update Cases.values();
}