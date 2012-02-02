trigger onArtikelLizenz on ArtikelLizenz__c (after insert, after update) {
	if(onProduct.inFutureContextStoredId == '') {
		onProduct.inFutureContextStoredId = 'true';
		//list<String> ALzaehlnummer = new list<String>();
		list<String> willbetriggerd = new list<String>();
		//list<ArtikelLizenz__c> ALtoSend = new list<ArtikelLizenz__c>();
		set<String> Lizenznumbers = new set<String>();
		Lizenznumbers.add('10001');
		Lizenznumbers.add('10002');
		Lizenznumbers.add('10206');
		Lizenznumbers.add('10261');
		Lizenznumbers.add('10262');
		Lizenznumbers.add('40100');
		set<String> Medienarten = new set<String>();
		Medienarten.add('55');
		Medienarten.add('46');
		Medienarten.add('57');
		Medienarten.add('42');
		
		for(ArtikelLizenz__c a:Trigger.new) {
			if((a.Medienart__c == '46' || a.Medienart__c == '42' /*|| a.Medienart__c == '55' || a.Medienart__c == '57'*/) &&
			   (a.LZN015__c == '10001' || a.LZN015__c == '10002')) {
				willbetriggerd.add(a.Artikel__c);
			}
			// it will not work on update
			// but this is not neccessary because every new license created by the licence trigger should be locked
			// so every new ArtikelLizenz has to be unlocked manually
			if (trigger.isInsert && Lizenznumbers.contains(a.LZN015__c) && Medienarten.contains(a.Medienart__c))
				 willbetriggerd.add(a.Artikel__c);
			// calculation will have to take place with unlocking these
			if (trigger.isUpdate && Lizenznumbers.contains(a.LZN015__c) && Medienarten.contains(a.Medienart__c) && !a.SPK015__c && trigger.oldMap.get(a.id).SPK015__c)
				 willbetriggerd.add(a.Artikel__c);
		}
		//system.debug(' test 1!!!!! ' + ALzaehlnummer);

		map<Id, Product2> products = new map<Id, Product2>([select id, ProductCode, medienartSig1__c, name, SIG1__c, SIG2__c, 
										SIG3__c, SIG4__c, SIG5__c, SIG6__c, medienartnummer__c, AUSW01__c
										,Sig1Zaehlnummer__c from Product2 where Id IN: willbetriggerd OR Sig1__c IN: willbetriggerd ]);
		
		if(!products.isEmpty()) {
		//	list<product2> p = new list<product2>();
		//	p = onProduct.orderQuerverweis(product);
		// JS, 5.9.11: small change using try catch to avoid problems in future 
			if(trigger.size > 1) //we avoid a useless callout for small update (trigger == 1)
				try {
					onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise_future(products.keySet());
				}
                catch(system.Asyncexception e) { //we got an Asyncexception: Future method cannot be called from a future method
                     onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise_alreadyfuture(products.values());
                }
			else
				onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise(products.values());
		}   
	}
									 
}