trigger onProduct on Product2 (before update, after update, before insert, after insert) {
	//we are in the second chunk of the batch (a batch of 200 rows is automatically divided into 2 chunks of 100 rows each)
	
	if((/*trigger.isBefore ||*/ (/*trigger.isAfter && */onProduct.inFutureContextStoredId != String.valueOf(trigger.new[0].Id))) && onProduct.inFutureContextStoredId != 'true' && onProduct.inFutureContextStoredId!= '' )
	//if((trigger.isBefore || (trigger.isAfter && onProduct.inFutureContextStoredId != String.valueOf(trigger.new[0].Id))) && onProduct.inFutureContextStoredId != 'true' && onProduct.inFutureContextStoredId!= '' )
		onOpportunity.clearStaticVariable();
		
	// replacing the onProduktionsstandHelper
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			for (Product2 p: trigger.new) {
				if (p.PDKZ01__c==4) p.Datum_Neuproduktion__c=p.Aenderung_Produktionsstufe__c;
			}
		}
		if (trigger.isUpdate) {
			for (Product2 p: trigger.new) {
				if (p.PDKZ01__c==4 && trigger.oldMap.get(p.id).PDKZ01__c<4 ) p.Datum_Neuproduktion__c=p.Aenderung_Produktionsstufe__c;
			}
		}
	} 
		
	if(onProduct.inFutureContextStoredId == '' && onOpportunityLineItem.inFutureContextStoredId == '') {
		system.debug('Should come one time here2');
		//onProduct.inFutureContext = True;f
		onProduct.inFutureContextStoredId = 'true';
		if(trigger.isAfter)
			onProduct.inFutureContextStoredId = trigger.new[0].Id;
		if(trigger.isUpdate && trigger.isBefore) {
			onProduct.onUpdate(trigger.new, trigger.old);
	//		onProduct.inFutureContext = False;
			list<String> Ids = new list<String>();
			boolean willSendData2Magento = false;
			for(Product2 p:trigger.new) {
				Ids.add(p.Id);
				if(p.GESB01__c!=trigger.oldMap.get(p.id).GESB01__c || p.RESB01__c!=trigger.oldMap.get(p.id).RESB01__c || p.BESB01__c!=trigger.oldMap.get(p.id).BESB01__c)
					willSendData2Magento = true;
				if (p.PDKZ01__c==4 && trigger.oldMap.get(p.id).PDKZ01__c<4) p.Datum_Neuproduktion__c=p.Aenderung_Produktionsstufe__c;
			}/*  no more used, it will be replaced by the help of talend which will generate a CSV and store it in a FTP directory.
			if(willSendData2Magento){
				//please look at the method onOpportunity.toFutureContext to understand 
				//the meaning of this "strange" operation
				if(!onOpportunity.inFutureMethod)
					salesforce2magento.job(Ids, false, true);
				else
					salesforce2magento.job2(Ids, false, true);
			}*/
		}
		
		if(trigger.isInsert && trigger.isAfter) {
			onProduct.onInsert(trigger.new); 		
		}
		
		if(trigger.isBefore) {
			onProduct.inFutureContextStoredId = '';
			onProduct.orderQuerverweis(trigger.new);
		}
		// JS, 5.9.11: ist optimierbar: Preisberechnung findet nur dann onProduct neu statt, wenn sich der Signaturverweis geändert hat!
		// und nur fuer Artikel des Typs Signatur
		if(trigger.isAfter) {
                  map<Id, Product2> products = new map<Id, Product2>();
                  
                  for(Product2 trig:trigger.new) {   
                       if (trig.RecordType.Name == 'Signatur'
                        	&& (trigger.isInsert || (trigger.isUpdate &&
                        	(trig.SIG1__c!=trigger.oldMap.get(trig.id).SIG1__c 
                        	|| trig.SIG2__c!=trigger.oldMap.get(trig.id).SIG2__c
                        	|| trig.SIG3__c!=trigger.oldMap.get(trig.id).SIG3__c
                        	|| trig.SIG4__c!=trigger.oldMap.get(trig.id).SIG4__c
                        	|| trig.SIG5__c!=trigger.oldMap.get(trig.id).SIG5__c
                        	|| trig.SIG6__c!=trigger.oldMap.get(trig.id).SIG6__c)
                        	)))
                        	if (!products.containsKey(trig.id)) products.put(trig.id, trig);
                  }
                  
                  if(!onOpportunity.inFutureMethod && trigger.size > 1)
                        try {
                             onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise_future(products.keySet());
                        }
                        catch(system.Asyncexception e) { //we got an Asyncexception: Future method cannot be called from a future method
                             onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise_alreadyfuture(products.values());
                        }
                  else
                        onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise_alreadyfuture(products.values());
        }
	}
	// now we have everything up and running, we need to run the trigger for the Mediathek price calculation
	
	map<Id, Product2> changedProducts=new map<Id, Product2>();
	if(onProduct.inFutureContextStoredId != 'true' && (trigger.isInsert || trigger.isUpdate) && trigger.isAfter && !MediathekSammelnummer.createMedienpaketLizenzenOnce && !MediathekSammelnummer.updatePricesOnce) {
		for (Product2 p: trigger.new) {
			if (trigger.isInsert && p.RecordTypeId==MediathekSammelnummer.SignaturRecordTypeId && p.IsActive && p.PDKZ01__c>=4 && p.PDKZ01__c<6 && p.Mediathek__c!=null && MediathekSammelnummer.getConfigArtikelKennzeichen().contains(p.Mediathek__c))
				changedProducts.put(p.id,p);
			if (trigger.isUpdate  
				&& (MediathekSammelnummer.validProduktionsstufen.contains(p.PDKZ01__c)!=MediathekSammelnummer.validProduktionsstufen.contains(trigger.oldMap.get(p.id).PDKZ01__c) 
				|| (p.Mediathek__c!=null && trigger.oldMap.get(p.id).Mediathek__c==null)
				|| (p.Mediathek__c==null && trigger.oldMap.get(p.id).Mediathek__c!=null)
				|| (p.Mediathek__c!=null && trigger.oldMap.get(p.id).Mediathek__c!=null && p.Mediathek__c!=trigger.oldMap.get(p.id).Mediathek__c)
				|| p.IsActive!=trigger.oldMap.get(p.id).isActive
				|| p.RecordTypeId!=trigger.oldMap.get(p.id).RecordTypeId
				)
				)
				changedProducts.put(p.id,p);
		}
		if (!changedProducts.isEmpty()) MediathekSammelnummer.createMedienpaketLizenzen(changedProducts);
	}
	
	if(onProduct.inFutureContextStoredId != 'true' && (trigger.isInsert || trigger.isUpdate) && trigger.isAfter && !MediathekSammelnummer.updatePricesOnce && MediathekSammelnummer.createMedienpaketLizenzenOnce) {
		// find the changed set of packages
		set<String> mtkennzeichen = new set<String>();
		for (Product2 p:trigger.new) {
			if (p.Mediathek__c!=null && !mtkennzeichen.contains(p.Mediathek__c)) mtkennzeichen.add(p.Mediathek__c);
		}
		if (trigger.isUpdate) {
			for (Product2 p:trigger.old) {
				if (p.Mediathek__c!=null && !mtkennzeichen.contains(p.Mediathek__c)) mtkennzeichen.add(p.Mediathek__c);
			}
		}
		if (!mtkennzeichen.isEmpty()) MediathekSammelnummer.updatePrices(mtkennzeichen);
	}
}