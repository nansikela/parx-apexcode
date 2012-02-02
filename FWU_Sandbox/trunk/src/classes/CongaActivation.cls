global class CongaActivation {
	
	webservice static String init(list<String> OpportunityId) {
		
		//system.debug('ID OF THE opp ' + OpportunityId);
    		List<Opportunity> o=new list<Opportunity>([SELECT Id, Conga_Workflow_for_Activation__c FROM Opportunity WHERE Id IN: OpportunityId]);
    			
		if(!o.isEmpty()) {
			for(Opportunity oTemp:o){
				oTemp.Conga_Workflow_for_Activation__c = True;
			}
	  		update o;	
	  		return 'true';
		}
		else
			return system.Label.CongaBugMessage;
  	}
}