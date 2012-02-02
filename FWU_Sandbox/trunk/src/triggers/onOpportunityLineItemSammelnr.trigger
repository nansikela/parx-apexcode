trigger onOpportunityLineItemSammelnr on OpportunityLineItem (after insert) {
  
	if (trigger.isAfter) { 
		//map<Id, OpportunityLineItem> olimap = new map<Id, OpportunityLineItem>();
		list<String> Ids = new list<String>();
		list<String> MediathekIds = new list<String>();
		
		
		for(OpportunityLineItem trig:trigger.new) {
			if (trig.Verkaufsprogramm__c!='MT' && trig.Produkttyp__c=='Sammelnummer' && trig.OppStageName__c=='In Erstellung' && !trig.SkipTriggerfromDataloader__c)
				Ids.add(trig.id);
			else if (trig.Verkaufsprogramm__c=='MT' && trig.Produkttyp__c=='Sammelnummer' && trig.OppStageName__c=='In Erstellung' && !trig.SkipTriggerfromDataloader__c)
				MediathekIds.add(trig.id);
		}
		if (trigger.isAfter && trigger.isInsert && !onOpportunityLineItemHelper.alreadyRun && !Ids.isEmpty()) 
			try {
				onOpportunityLineItemHelper.startfuture(Ids);
			} catch (System.Exception e) {
				systemsettings.logError('Fehler bei Sammelnummer: ' + e.getMessage());
				systemsettings.sendInformationalEmailToUser('Erfassung Sammelnummer', 'Die Sammelnummer wurde nicht erfolgreich aufgelöst! Bitte versuchen Sie es ein wenig später erneut!');
			}
		if (trigger.isAfter && trigger.isInsert && !onOpportunityLineItemHelper.alreadyRun && !MediathekIds.isEmpty()) 
			//try {
				onOpportunitySammelnummerRun.Run(MediathekIds);
			//} catch (System.Exception e) {
			//	systemsettings.logError('Fehler bei Sammelnummer: ' + e.getMessage());
			//	systemsettings.sendInformationalEmailToUser('Erfassung Sammelnummer', 'Die Sammelnummer wurde nicht erfolgreich aufgelöst! Bitte versuchen Sie es ein wenig später erneut!');
			//}
	}

}