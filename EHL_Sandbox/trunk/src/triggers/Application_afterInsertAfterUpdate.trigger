trigger Application_afterInsertAfterUpdate on Application__c (after insert, after update) {
	try{
		Set<Id> oppIdSet = new Set<Id>();
		
		for(Application__c a : Trigger.new){
			if(a.Opportunity__c != null){
				oppIdSet.add(a.Opportunity__c);
			}		
		}
		
		if(!oppIdSet.isEmpty()){
			Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select o.StageName, o.Id from Opportunity o where o.Id in :oppIdSet]);
			
			Map<String,String> codeMapping = new Map<String, String>();
			codeMapping.put('APP', 'Application in progress');
			codeMapping.put('DOR', 'Application in progress');
			codeMapping.put('CLO', 'Application cancelled');
			codeMapping.put('SUB', 'Application in progress');
			codeMapping.put('INC', 'Application Evaluation in progrress');
			codeMapping.put('EVL', 'Application Evaluation in progrress');
			codeMapping.put('RBS', 'Application rejected');
			codeMapping.put('INV', 'Application Evaluation completed');
			codeMapping.put('ADE', 'Application deferred');
			codeMapping.put('ADC', 'Application deferred');
			codeMapping.put('WDR', 'Application cancelled');
			codeMapping.put('TRT', 'Application transferred');
			codeMapping.put('SDP', 'Application Selection in progress');
			codeMapping.put('DCF', 'Application Selection in progress');
			codeMapping.put('SDC', 'Application Selection in progress');
			codeMapping.put('RAS', 'Application rejected');
			codeMapping.put('CON', 'Application accepted by EHL');
			codeMapping.put('OFF', 'Application accepted by EHL');
			codeMapping.put('DFC', 'Application accepted by EHL');
			codeMapping.put('DFD', 'Application accepted by EHL');
			codeMapping.put('WTL', 'Application Selection in progress');
			codeMapping.put('HLD', 'Application Selection in progress');
			
			codeMapping.put('ACC', 'Student enrolled'); //added 20100409
			codeMapping.put('DCL', 'Offer declined');
			codeMapping.put('DEF', 'Admission deferred');
			codeMapping.put('REV', 'Application rejected');
			
			List<Opportunity> oppToUpdate = new List<Opportunity>();
			
			for(Application__c a : Trigger.new){
				if(a.Application_Code__c != null && codeMapping.containsKey(a.Application_Code__c) && oppMap.containsKey(a.Opportunity__c)){
					Opportunity o = oppMap.get(a.Opportunity__c);
					if(o.StageName != codeMapping.get(a.Application_Code__c)){
						o.StageName = codeMapping.get(a.Application_Code__c);
						oppToUpdate.add(o);
					}
				}
			}
			
			update oppToUpdate;
		}
		
	}catch(System.Exception e){
        System.debug('**** Exception: ' +e);
        System.assert(false);   
    }
}