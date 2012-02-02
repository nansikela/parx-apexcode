global class DuplicateOpportunity {
	public static boolean Checker = false;
	webService static String init(String oppId){
		checker = True;
		String newOppId = cloneOpp(oppId);
		cloneOlis(newOppId, oppId);
		
		
		
		
		
		return newOppId;
	}
	 
	private static String cloneOpp(String oppId) {
		Opportunity newOpp = new Opportunity();
		Map<String,Schema.SObjectField> sObjectFieldsMap1 = newOpp.getSObjectType().getDescribe().fields.getMap();
		
		String query = 'select ';	
		for(String help1:sObjectFieldsMap1.keySet()) {
			query += help1 + ',';
		}	
		query = query.substring(0, query.length()-1) ;
		query += ' from Opportunity  where Id =: oppId';
		
		Opportunity oldOpp = Database.query(query);
		newOpp = oldOpp.clone(false, true);
		newOpp.StageName = 'In Erstellung';
		newOpp.REAR2A__c = 7;
		//newOpp.Rabatt__c = 0;
		newOpp.Rabattgutschrift__c = true;
		newOpp.Locked__c = false;
		newOpp.Zahl_der_Fakturierungen__c = 0;
		newOpp.RecordTypeId = [Select Id From RecordType where Name = 'Erfassung'].Id;
		system.debug('debug opp ' +  newOpp);
		
		insert newOpp;
		
		return newOpp.Id;
	}
	
	private static void cloneOlis(String newOppId, String oppId) {
		list<OpportunityLineItem> newOli = new list<OpportunityLineItem>();
		Map<String,Schema.SObjectField> sObjectFieldsMap1 = newOli.getSObjectType().getDescribe().fields.getMap();
		
		String query = 'select ';	
		for(String help1:sObjectFieldsMap1.keySet()) {
			query += help1 + ',';
		}	
		query = query.substring(0, query.length()-1) ;
		query += ' from OpportunityLineItem  where OpportunityId =: oppId';
		list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
		oliList = Database.query(query);
		OpportunityLineItem oTemp;
		for(OpportunityLineItem oli:oliList) {
			system.debug('oli produktyp: ' + oli.Produkttyp__c);
			oTemp = new OpportunityLineItem();
			oTemp = oli.clone(false, true);
			oTemp.STAT2D__c = null;
			oTemp.OpportunityId = newOppId;
	//		if((oTemp.medienart_id__c == '46' || oTemp.medienart_id__c == '42') && oTemp.Verkaufsprogramm__c == 'KO') {
			//	oTemp.UnitPrice = 0;
				oTemp.TotalPrice = null;
				oTemp.skip_Workflow__c = true;
	//		}
	//		else {
	//			oTemp.TotalPrice = null;
	//			oTemp.skip_Workflow__c = true;
	//		}
			
		//	oTemp.Discount = 0;
			oTemp.GELM2D__c = null;	
			if(!((oTemp.medienart_id__c == '55' || oTemp.medienart_id__c == '57') && oTemp.KreisListe__c != '' ) && oli.Produkttyp__c != 'Sammelnummer')
				newOli.add(oTemp);
		}
		
		insert newOli;
	/*	list<String> oliIds = new list<String>();
		for(OpportunityLineItem o:newOli ){
			oliIds.add(o.Id);
		}
		
		list<OpportunityLineItem> oliInsert = new list<OpportunityLineItem>([select id, Discount from OpportunityLineItem where Id IN: oliIds]);
		Integer i = 0;
		for(OpportunityLineItem oli:oliList) {
			if(!((oli.medienart_id__c == '55' || oli.medienart_id__c == '57') && oli.KreisListe__c != '' )){
				oliInsert.get(i).Discount = oli.Discount;
				i++;
			}
		}*/
		onOpportunityLineItem.inFutureContextStoredId = '';
	//	update oliInsert;
	}
}