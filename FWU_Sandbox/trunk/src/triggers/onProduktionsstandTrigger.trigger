trigger onProduktionsstandTrigger on Produktionsstand__c (after insert) {
	/*
	map<Id, Date> npdates =new map<Id, Date>();
	
	if (trigger.isAfter && trigger.isInsert) {
		for (Produktionsstand__c ps: trigger.new) {
			if (ps.Status__c=='05' && ps.Datum__c!=null && ps.Artikel__c!=null) {
				if (!npdates.containsKey(ps.Artikel__c)) npdates.put(ps.Artikel__c, ps.Datum__c);
			}
		}
	}
	
	if (!npdates.isEmpty() && !onProduct.alreadyRunning) 
		onProduktionsstandHelper.run(npdates);
	*/
}