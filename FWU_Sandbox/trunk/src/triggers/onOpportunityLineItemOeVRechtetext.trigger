trigger onOpportunityLineItemOeVRechtetext on OpportunityLineItem (before insert, before update) {

	map<id, OpportunityLineItem> olistoupdate = new map<id, OpportunityLineItem>();
	
	if (trigger.isBefore & trigger.isInsert) {
		for (OpportunityLineItem oli: trigger.new) {
			System.debug('Main OLI Values: OpportunityId: ' + oli.OpportunityId + '/ PricebookEntryId: ' + oli.PricebookEntryId + '/ Quantity: ' + oli.Quantity + '/ UnitPrice: ' + oli.UnitPrice==null?'null':String.valueOf(oli.UnitPrice) + '/ Product2Id: ' + oli.Product2Id__c + '/ TotalPrice: ' + oli.TotalPrice==null?'null':String.valueOf(oli.TotalPrice) + '/ Discount: ' + oli.Discount==null?'null':String.valueOf(oli.Discount) + '/ Lizenz: ' + oli.SCHL2D__c==null?'null':String.valueOf(oli.SCHL2D__c) + '/ AnzahlSchulen: ' + oli.Anzahl_Schulen__c==null?'null':String.valueOf(oli.Anzahl_Schulen__c) );
		}
	}

	if (trigger.isBefore) { 
		/*if (trigger.isInsert) {
			for (OpportunityLineItem oli: trigger.new) {
				olistoupdate.put(oli.id, oli);
			}
		}*/
		if (trigger.isUpdate) {
			for (OpportunityLineItem oli: trigger.new) {
			//	if (oli.Id!=trigger.oldMap.get(oli.id).Id) {
					if (!olistoupdate.containsKey(oli.id) && !oli.SkipTriggerfromDataloader__c) 
						olistoupdate.put(oli.id, oli);
			//	}
			}
		}
	}

	if (!olistoupdate.isEmpty() && !onOpportunityLineItem.doNotRun) {
		if (!OeVRechtetextHelper.isAlreadyRun) OeVRechtetextHelper.updateRechtetexte(olistoupdate);
	}

}