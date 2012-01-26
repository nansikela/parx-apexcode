trigger Opportunity_afterInsertUpdate on Opportunity (after insert, after update) {
	
	String OPPORTUNITY_STAGE = 'Contract';
	String OPPORTUNITY_CONSULTINGLHC_ID = '0122000000052OhAAI';
	
	String LHC_CONTRACT_ID = '0122000000052OmAAI';
	
	String CONTRACT_STATUS = 'Delivery';
	
	List<Contract> contractList = new List<Contract>();
	try{
		for(Opportunity opp : Trigger.new){
			//if opp recordtype = Consulting (LHC): create a new contract of type LHC Contract if Stage of Opportunity is changed to Contract
			Boolean createContract = false;
			if((opp.RecordTypeId == OPPORTUNITY_CONSULTINGLHC_ID) && Trigger.isInsert && (opp.StageName == OPPORTUNITY_STAGE)){
				createContract = true;
			}else if((opp.RecordTypeId == OPPORTUNITY_CONSULTINGLHC_ID) && Trigger.isUpdate && Trigger.oldMap.containsKey(opp.Id) && opp.StageName == OPPORTUNITY_STAGE){
				if(Trigger.oldMap.get(opp.Id).StageName != opp.StageName){
					createContract = true;
				}
			}
			
			if(createContract){
				//create a new contract	
				Contract contract = new Contract();
				contract.RecordTypeId = LHC_CONTRACT_ID;
				contract.Opportunity__c = opp.Id;
				contract.AccountId = opp.AccountId;
				contract.Status = CONTRACT_STATUS;
				contract.Opportunity_Amount__c = opp.Amount;
				contract.Contact_Student__c = opp.Contact_Student__c;
				
				contractList.add(contract);
			}
		}
		
		
		try{
			if(! contractList.isEmpty()){
				insert contractList;	
			}	
		}catch(System.DMLException e){	
			System.debug('*** Exception: ' + e);		
		}
		
	}catch(System.Exception e){
		System.debug('*** Final Exception: ' + e);	
	}
}