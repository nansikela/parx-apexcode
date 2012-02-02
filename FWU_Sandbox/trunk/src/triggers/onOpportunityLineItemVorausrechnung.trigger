trigger onOpportunityLineItemVorausrechnung on OpportunityLineItem (after update) {

	list<OpportunityLineItem> newolis=new list<OpportunityLineItem>();
	
	if (!onOpportunityLineItem.doNotRun) {
	for (OpportunityLineItem oli: trigger.new) {
		if (oli.LieferanzeigeId__c!=null 
					&& trigger.oldMap.get(oli.id).LieferanzeigeId__c==null
					&& oli.OppRechnungsArt__c==3 
					&& oli.STAT2D__c != 'Fakturiert'
					&& oli.STAT2D__c != 'Ausgelassen'
					&& oli.STAT2D__c != 'Gelöscht'
					&& oli.STAT2D__c != 'Freigabe') {
			sObject s = (OpportunityLineItem)oli;
			OpportunityLineItem newoli=(OpportunityLineItem)s.clone(false,true);
			newoli.OpportunityId=oli.LieferanzeigeId__c;
			newoli.LieferanzeigeId__c=null;
			newoli.TotalPrice=null;
			newoli.FRME2D__c=0;
			newoli.GELM2D__c=0;
			newoli.Liefermenge__c=0;
			newoli.KreisListe__c=null;
			if (oli.GELM2D__c!=null)
				newoli.Quantity-=oli.GELM2D__c;
			newoli.STAT2D__c=null;
			newoli.skip_Workflow__c=true;
			//if (oli.medienart_id__c!='55') newoli.KreisListe__c=null;
			newolis.add(newoli);
		}
	}
	
	if (!newolis.isEmpty()) {
		try {
			onOpportunityLineItem.doNotRun= true; //only run once
			insert newolis;
		} catch (System.Dmlexception e) {
			SystemSettings.logError(e.getMessage(),'DEBUG');
			if (SystemSettings.isDebug) throw e;
		}
		set<Id> newoliids = new set<Id>();
		set<Id> oppids = new set<Id>();
		map<Id, OpportunityLineItem> olistodelete = new map<Id, OpportunityLineItem>();
		for (OpportunityLineItem oli:newolis) {
			newoliids.add(oli.id);
			if (!oppids.contains(oli.OpportunityId)) oppids.add(oli.OpportunityId);
		}
		//SystemSettings.logError('newoliids.size: ' + newoliids.size() + ' newoliids first id ' + newolis.get(0).id,'DEBUG');
		if (!newoliids.isEmpty()) {
			map<Id, OpportunityLineItem> newolimap = new map<Id, OpportunityLineItem>();
			list<OpportunityLineItem> existingOlis=[SELECT Id, medienart_55__c, KreisListe__c, medienart_id__c, Product2Id__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :oppids];
			/*
			for (OpportunityLineItem oli:existingOlis) {
				if (oli.KreisListe__c==null && oli.medienart_id__c=='55' && !newoliids.contains(oli.id)) {
					olistodelete.put(oli.id, oli);
				}
			}
			if (!olistodelete.isEmpty()) {
				try {
					delete olistodelete.values();
				} catch (System.DmlException e) {
					SystemSettings.logError(e.getMessage(),'DEBUG');
					if (SystemSettings.isDebug) throw e;
				}
			}
			
			existingOlis=[SELECT Id, medienart_55__c, KreisListe__c, medienart_id__c, Product2Id__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :oppids];
			*/
			for (OpportunityLineItem oli:existingOlis) {
				if (!newolimap.containsKey(oli.id)) 
					newolimap.put(oli.id,oli);
			}
			if (!newolimap.isEmpty()) {
				map<Id, OpportunityLineItem> olimap = new map<Id, OpportunityLineItem>();
				for (OpportunityLineItem oli46: newolimap.values()) {
					if (oli46.medienart_id__c=='46' && oli46.medienart_55__c!=null && oli46.medienart_55__c!='' && !olimap.containsKey(Id.valueOf(oli46.medienart_55__c))) {
						for (OpportunityLineItem oli55: newolimap.values()) {
							if (oli55.medienart_id__c=='55' && Id.valueOf(oli55.Product2Id__c)==Id.valueOf(oli46.medienart_55__c) && oli55.OpportunityId==oli46.OpportunityId) {
								oli46.KreisListe__c=oli55.Id;
								oli55.KreisListe__c=oli46.Id;
								if (!olimap.containsKey(oli46.Id)) olimap.put(oli46.Id,oli46);
								if (!olimap.containsKey(oli55.Id)) olimap.put(oli55.Id,oli55);
							}
						}
					}
				}
				if (!olimap.isEmpty()) {
					try {
						update olimap.values();
					} catch (System.DmlException e) {
						SystemSettings.logError(e.getMessage(),'DEBUG');
						if (SystemSettings.isDebug) throw e;
					}
				}
			}	
		}
		
	}
	}
	
	SystemSettings.insertErrors();
}