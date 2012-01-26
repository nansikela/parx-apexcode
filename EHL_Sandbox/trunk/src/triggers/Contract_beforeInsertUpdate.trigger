trigger Contract_beforeInsertUpdate on Contract (before insert, before update) {
	
	//if is internship contract. update contact/student with student of corresponding opp
	
	String INTERNSHIP_CONTRACT_RECORDTYPE = '012200000004uOmAAI';
	
	try{
		Set<Id> oppIdSet = new Set<Id>();
		for(Contract contract : Trigger.new){
			if(contract.RecordTypeId == INTERNSHIP_CONTRACT_RECORDTYPE && contract.Opportunity__c != null){
				oppIdSet.add(contract.Opportunity__c);
			}
		}
		
		Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>([Select o.Id, o.Contact_Student__c from Opportunity o where o.Id in :oppIdSet]);
		for(Contract contract : Trigger.new){
			if(contract.RecordTypeId == INTERNSHIP_CONTRACT_RECORDTYPE && oppMap.containsKey(contract.Opportunity__c)){
				contract.Contact_Student__c = oppMap.get(contract.Opportunity__c).Contact_Student__c;
			}
		}
	}catch(System.Exception e){
		System.debug('**** Final Exception: ' + e);	
	}	 

}