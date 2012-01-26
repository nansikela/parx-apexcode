trigger Opportunity_beforeUpdateInsert on Opportunity (before insert, before update) {
		// IF Bachelor, Master, Diploma or executive education: HANDLE OPPORTUNITY NAME (must be always name of program, not module)
		// IF Bachelor, Master, Diploma or executive education: check that accountid is always account from contact in field Contact_Student__c
		
		try{
			String BACHELOR_ID = '012200000004nPAAAY';
			String MASTER_ID = '0122000000052fsAAA';
			String DIPLOMA_ID = '0122000000057DyAAI';
			String EXECUTIVE_EDUCATION_ID = '0122000000059stAAA'; //LIVE
			//String EXECUTIVE_EDUCATION_ID = '012S00000000EqWIAU'; //SANDBOX
			
			String PROGRAMID = '012200000004y0dAAA';
			
			Set<String> RECORDTYPESET = new Set<String>{BACHELOR_ID, MASTER_ID, DIPLOMA_ID, EXECUTIVE_EDUCATION_ID};
			
			List<Id> contactIdList = new List<Id>();
			List<Id> oppIdList = new List<Id>();
			List<Opportunity> oppList = new List<Opportunity>();
			
			for(Opportunity o : Trigger.new){
				if(RECORDTYPESET.contains(o.RecordTypeId)){
					contactIdList.add(o.Contact_Student__c);
					oppList.add(o);
					oppIdList.add(o.Id);
				}
			}
			
			
			System.debug('contact size' + contactIdList.size());
			if(! contactIdList.isEmpty()){
				Map<Id, Contact> contactMap = new Map<Id, Contact>([Select c.AccountId, c.Name, c.Id from Contact c where c.Id in :contactIdList]);
				Map<Id, OpportunityLineItem> oppLineitemMap = new Map<Id, OpportunityLineItem>();
				Set<Id> productIdSet = new Set<Id>();
				
				List<OpportunityLineItem> oliList = [Select o.PricebookEntry.Product2Id, o.PricebookEntry.Name, o.OpportunityId From OpportunityLineItem o where o.OpportunityId in :oppIdList];
				for(OpportunityLineItem oppLinei : oliList){
					oppLineitemMap.put(oppLinei.OpportunityId, oppLinei);
					productIdSet.add(oppLinei.PricebookEntry.Product2Id);
				}
				
				Map<Id,Product2> productMap = new Map<Id, Product2>([Select p.Id, p.RecordTypeId, p.Name From Product2 p where p.Id in :productIdSet]);
		
				for(Opportunity o : oppList){
					//*************** check that accountid is always account from contact in field Contact_Student__c
					//*************** auto name CONTACT_NAME: PRODUCT_NAME (Product must be of type program, not module)
					if(o.Contact_Student__c != null && contactMap.containsKey(o.Contact_Student__c)){
						o.AccountId = contactMap.get(o.Contact_Student__c).AccountId;
						
						if(oppLineitemMap.containsKey(o.Id)){
							OpportunityLineItem oppLineItem = oppLineitemMap.get(o.Id);
							//only create name if product attached is program and not module
							
							if(productMap.containsKey(oppLineItem.PricebookEntry.Product2Id) && productMap.get(oppLineItem.PricebookEntry.Product2Id).RecordTypeId == PROGRAMID){
								o.Name = contactMap.get(o.Contact_Student__c).Name + ': ' + oppLineitemMap.get(o.Id).PricebookEntry.Name;
							}
						}else{
							o.Name = contactMap.get(o.Contact_Student__c).Name + ': -';
						}
					}
				}
			
			}
		}catch(System.Exception e){
			System.debug('**** Exception: ' + e);	
		}
}