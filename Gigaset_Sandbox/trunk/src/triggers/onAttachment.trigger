trigger onAttachment on Attachment (after insert) {
	
	/*Schreiben des Feldes „Last Attachment Date“ 
	wenn ein neues Attachment beim Case angehängt wird. Bei Löschung erfolgt nichts*/
	
	list<Id> CaseIds = new list<Id>();
	for(Attachment a:trigger.new) {
		if(a.ParentId != null && String.valueOf(a.ParentId).substring(0,3) == '500') {
			 CaseIds.add(a.ParentId);
		}
	}
	map<Id, Case> cases = new map<Id, Case>([select id, Last_Attachment_Date__c from Case where Id IN:CaseIds]);
	
	for(Attachment a:trigger.new) {
		if(cases.containsKey(a.ParentId)) {
			 cases.get(a.ParentId).Last_Attachment_Date__c = a.CreatedDate;
		}
	}
	if(!cases.isEmpty())
		update cases.values();
}