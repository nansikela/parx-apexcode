trigger onOpportunityVorausrechnung on Opportunity (before update, after update) {

	// will create a new opportunity with rechnungsart 8
	// this opp will get a clone of all LineItems with Status not Fakturiert
	// umwandlung führt zu freigabe / faktura von vorrausrechnung
	// in der Lieferanzeige muss die Rechnungsnummer hinterlegt werden
	
	// things to be done before the update is done
	if (trigger.isBefore) {
		for (Opportunity o : trigger.new) {
			if(!o.SkipTriggerfromDataloader__c) {
				if (o.VKPG2A__c!='MT' && o.StageNamePosition__c>0 && o.StageNamePosition__c<4 && o.REAR2A__c==3 && trigger.oldMap.get(o.id).REAR2A__c!=o.REAR2A__c && !o.LFKZ2A__c) {
					o.RechnungsartVorUmwandlung__c=trigger.oldMap.get(o.id).REAR2A__c;
				} else if (o.StageNamePosition__c>0 && o.StageNamePosition__c<4 && o.REAR2A__c==3 && trigger.oldMap.get(o.id).REAR2A__c!=o.REAR2A__c && o.LFKZ2A__c) {
					o.addError('Auftrag gesperrt, Umwandlung kann nicht durchgeführt werden!');
				} else if (o.VKPG2A__c=='MT' && o.StageNamePosition__c>0 && o.StageNamePosition__c<4 && o.REAR2A__c==3 && trigger.oldMap.get(o.id).REAR2A__c!=o.REAR2A__c && !o.LFKZ2A__c) {
					o.addError('Mediathek Aufträge können nicht umgewandelt werden, bitte die normale Fakturierung nutzen!');
				}
			}
		}
	}
	
	
	// things to be done after the update
	if (trigger.isAfter) {
		map<Id, Opportunity> opps = new map<Id, Opportunity>();
		
		for (Opportunity o : trigger.new) {
			if (!o.SkipTriggerfromDataloader__c && o.StageNamePosition__c>0 && o.StageNamePosition__c<4 && o.REAR2A__c==3 && trigger.oldMap.get(o.id).REAR2A__c!=o.REAR2A__c && !o.LFKZ2A__c) {
				if (!opps.containsKey(o.id)) opps.put(o.id, o);
			}
		}
		
		if (!opps.isEmpty() && !UmwandlungInVorausrechnung.alreadyRun) {
			UmwandlungInVorausrechnung.alreadyRun=true;
			UmwandlungInVorausrechnung.runUmwandlung(opps);
		}
	}
}