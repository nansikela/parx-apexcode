trigger onWerbemittelBestellung on Werbemittel_Bestellung__c (before update) {

	list<String> ctact = new list<String>();
	for(Werbemittel_Bestellung__c t:Trigger.new) {
		ctact.add(t.Besteller__c);
//		system.debug('BESTELLER ' +t.Besteller__c);	
	} 

	list<Contact> Item_contact = new list<Contact>([Select id, AccountId, Name From Contact where Id IN :ctact]);
	list<String> AccountIds = new list<String>();
	
	map<String, String> Kontakt = new map<String, String>();
	
	for(Contact c: Item_contact) {
		AccountIds.add(c.AccountId);
		Kontakt.put(c.Id,c.Name);
	}


	DEretrieveAccountFromContact bestellung = new DEretrieveAccountFromContact(AccountIds);

	Integer i = 0;
	if(!bestellung.bestellung.isEmpty()) {
		for(Werbemittel_Bestellung__c trig: Trigger.new) {
			if(trig.Firmenname__c == '' || trig.Firmenname__c == null)
				trig.Firmenname__c = bestellung.bestellung.get(i).Firmenname__c;		
			if(trig.Kontakt__c == '' || trig.Kontakt__c == null)
				trig.Kontakt__c = Kontakt.get(trig.Besteller__c);
			if(trig.Strasse__c == '' || trig.Strasse__c == null)
				trig.Strasse__c = bestellung.bestellung.get(i).Strasse__c;
			if(trig.Postleitzahl__c == '' || trig.Postleitzahl__c == null)
				trig.Postleitzahl__c = bestellung.bestellung.get(i).Postleitzahl__c;
			if(trig.Stadt__c == '' || trig.Stadt__c == null)	
				trig.Stadt__c = bestellung.bestellung.get(i).Stadt__c;
			if(trig.Land__c == '' || trig.Land__c == null)
				trig.Land__c = bestellung.bestellung.get(i).Land__c;
			i++;
		}
	}
}