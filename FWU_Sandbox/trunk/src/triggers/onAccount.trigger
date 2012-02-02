trigger onAccount on Account (before delete, after insert) {
	if(trigger.isDelete) {
		
		Integer i;
		String Fehler = Label.AccountLoeschenFehler;
		
		list<String> AccId = new list<String>();
		for (Account acc: trigger.old) {  //we retrieve all the Acc which should be deleted
			AccId.add(acc.Id);
		}
		list<Opportunity> OppList = new list<Opportunity>([select Id, KDWE2A__c, AccountId 
							from Opportunity where KDWE2A__c IN :AccId OR AccountId IN :AccId]);	
		
		for (Account acc: trigger.old) {  //we now check if the Id of the Account is used
			for(i = 0; i < OppList.size() ; i++) {
				if(acc.Id == OppList.get(i).KDWE2A__c || acc.Id == OppList.get(i).AccountId || acc.hatUmsatz__c) {
					//acc.addError(Fehler);
					break;
				}			
			}
		}
	}
	
	if(!salesforce2magento.inFutureContext && (trigger.isInsert)) {

		list<String> Ids = new list<String>();
		for(Account a:trigger.new){
			if(a.IsPersonAccount && (a.MagentoId__pc == null || a.MagentoId__pc == ''))  //run only for personen Account
				Ids.add(a.Id);
		}
		if(!Ids.isEmpty()) {
			salesforce2magento.job(Ids, true, false);
		}
	}

}