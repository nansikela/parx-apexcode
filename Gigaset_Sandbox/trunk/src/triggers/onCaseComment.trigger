trigger onCaseComment on CaseComment (after Update, after Delete, after Undelete, after Insert) {
    list<Case> Cases;
    map<Id, CaseComment> CaseComments = new map<Id, CaseComment>();
    
    list<Id> CaseIds = new list<Id>();
   if(trigger.isDelete) {
        for(CaseComment cc:trigger.old){
            CaseIds.add(cc.ParentId);
        }
    }
    else {
        for(CaseComment cc:trigger.new){
            if(cc.ParentId != null)
                CaseIds.add(cc.ParentId);
        }
    }
    Cases = new list<Case>([select id, Last_Comment_Date__c from Case where Id IN: CaseIds]);
    for(CaseComment cc:[select id, LastModifiedDate, isPublished, ParentId from CaseComment where ParentId IN: CaseIds]) {
        if(!CaseComments.containsKey(cc.ParentId) || CaseComments.get(cc.ParentId).LastModifiedDate < cc.LastModifiedDate) {
            CaseComments.put(cc.ParentId, cc);
        }
    }
    
    for(Case c:Cases){
        if(CaseComments.containsKey(c.Id)) {
        	c.Last_Comment_Type__c = CaseComments.get(c.Id).isPublished;
            c.Last_Comment_Date__c = CaseComments.get(c.Id).LastModifiedDate;
        }
        else {
        	c.Last_Comment_Type__c = false;
            c.Last_Comment_Date__c = null;
        }
    }
    update Cases;
}