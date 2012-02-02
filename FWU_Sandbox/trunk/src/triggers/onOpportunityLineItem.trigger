trigger onOpportunityLineItem on OpportunityLineItem (before delete, before update, before insert, after insert) {
	
	// JS, K1/K2
	set<String> KO_VKP = new set<String>();
	KO_VKP.add('KO');
	KO_VKP.add('K1');
	KO_VKP.add('K2');
	
	if (!onOpportunityLineItem.doNotRun) {
	Boolean CheckOrigin = false;
	if(trigger.isInsert) {
		CheckOrigin = true;
		for(OpportunityLineItem oli:trigger.new) {
			if(!oli.SkipTriggerfromDataloader__c) { //if at least one of the row should has not the tag, we have to run the full trigger.
				CheckOrigin = false;
				break;
			}
		}
	}
	
	// K1/K2 Sync
	if (trigger.isUpdate && trigger.isBefore && !onOpportunityLineItem.doNotRunKOSync) {
		map<Id, OpportunityLineItem> koolisOld = new map<Id, OpportunityLineItem>();
		map<Id, OpportunityLineItem> koolisNew = new map<Id, OpportunityLineItem>();
		for(OpportunityLineItem oli:trigger.new) {
			if(!oli.SkipTriggerfromDataloader__c && KO_VKP.contains(oli.Verkaufsprogramm__c) 
						&& (oli.OppStageName__c=='In Erstellung' || oli.OppStageName__c=='Bereit zur Freigabe')
						&& (
						(
						oli.Quantity!=trigger.oldMap.get(oli.id).Quantity ||
						oli.Discount!=trigger.oldMap.get(oli.id).Discount ||
						oli.UnitPrice!=trigger.oldMap.get(oli.id).UnitPrice ||
						oli.Sperrkz__c!=trigger.oldMap.get(oli.id).Sperrkz__c ||
						oli.STAT2D__c!=trigger.oldMap.get(oli.id).STAT2D__c
						|| oli.Anzahl_Schulen__c!=trigger.oldMap.get(oli.id).Anzahl_Schulen__c
						)
						|| (oli.OppStageName__c=='Bereit zur Freigabe')
						)
				) {
				if (oli.Preis465557__c==null) oli.Preis465557__c=0;
				if (oli.K1_K2_Zahl_der_Vervielf_ltigungen__c==null) oli.K1_K2_Zahl_der_Vervielf_ltigungen__c='0';
				if (oli.Discount==null) oli.Discount=0;
				koolisNew.put(oli.id, oli);
				koolisOld.put(oli.id, trigger.oldMap.get(oli.id));
			}
		}
		if (!koolisNew.isEmpty()) {
			onOpportunityLineItem.doNotRunKOSync=true;
			onOpportunityLineItem.syncOFK1K2OpportunityLineItems(koolisNew, koolisOld);
		}
	}
	
	if(!CheckOrigin) {
		if((trigger.isUpdate || trigger.isInsert) && onOpportunityLineItem.inFutureContextStoredId != String.valueOf(trigger.new[0].Id) && onOpportunityLineItem.inFutureContextStoredId != 'true'&& onOpportunityLineItem.inFutureContextStoredId!= '' && onOpportunityLineItem.ForcePassage)
			onOpportunity.clearStaticVariable();
		
		//onOpportunity.inFutureContextStoredId = 'true'; 
		//now directly handled in the opp trigger
		
		if(!onOpportunityLineItem.onSignatureAfterInsert && trigger.isAfter && trigger.isInsert && !onOpportunityLineItem.doNotRun) {
			//the signature, I mean the 55 of the KO/K1/K2 has been inserted but in order to maintain a good link
			//between the 46 and the 55, we need to add the Id of the 55 in the field KreisListe of the 46.
			//we can do it only on after insert because we don't know before its id.
			// JS, 12.09.2011: this will run for new K1/K2 too
			// JS, K1/K2
			// adds the other OpportunityLineItems to complete the package
	 		system.debug('onsignatureafterinsert');	
			onOpportunityLineItem.onSignatureAfterInsert = true;
			list<String> Ids = new list<String>();
			for(OpportunityLineItem oli:trigger.new) {
				if(!oli.SkipTriggerfromDataloader__c)
					Ids.add(oli.KreisListe__c);
			}
			map<id, OpportunityLineItem> olis46 = new map<id, OpportunityLineItem>([select id, KreisListe__c, KreisOnlineCopyId__c from OpportunityLineItem where Id IN: Ids]);
			
			for(OpportunityLineItem oli:trigger.new) {
				if(!oli.SkipTriggerfromDataloader__c && oli.Lizenznummer__c!='10269')
					olis46.get(oli.KreisListe__c).KreisListe__c = oli.Id;
			}
			
			if(!olis46.isEmpty())
				update olis46.values();
		}
			
		if(onOpportunityLineItem.inFutureContextStoredId == '' && !onOpportunityLineItem.doNotRun) {
			system.debug('test onOpportunityLineItem.inFutureContextStoredId');	
			onOpportunityLineItem.inFutureContextStoredId = 'true';
			if(trigger.isAfter)
				onOpportunityLineItem.inFutureContextStoredId = trigger.new[0].Id;
				
			list<OpportunityLineItem> olis = new list<OpportunityLineItem>();
			list<OpportunityLineItem> olis2 = new list<OpportunityLineItem>();
			if(trigger.isDelete && trigger.isBefore) {
				for(OpportunityLineItem oli:trigger.old) {
					if(!oli.SkipTriggerfromDataloader__c && oli.OppStageName__c!='In Erstellung')
						olis.add(oli);
				}
				if(!olis.isEmpty())
					onOpportunityLineItem.ondelete(olis);	
			}
			/*
			// KO Sync
			if(trigger.isUpdate && trigger.isBefore) { //if the menge from an opportunity product is changed, we have to update the value in the product itself
				for(OpportunityLineItem oli:trigger.new) {
					if(!oli.SkipTriggerfromDataloader__c) {
						olis.add(oli);
						olis2.add(trigger.oldMap.get(oli.id));
					}
				}
				if(!olis.isEmpty()) {
					// KO Sync - TODO replace by using the new class
					onOpportunityLineItem.onupdate(olis, olis2);
				}
				
			}
			*/
			
			if(trigger.isInsert && trigger.isAfter) {
			//	onOpportunityLineItem.inFutureContext = true;
				for(OpportunityLineItem oli:trigger.new) {
					if(!oli.SkipTriggerfromDataloader__c)
						olis.add(oli);
				}
				if(!olis.isEmpty())
					onOpportunityLineItem.oninsert_after(olis);
				for(OpportunityLineItem trig:trigger.new) {
					if(!trig.SkipTriggerfromDataloader__c 
						//&& trig.Verkaufsprogramm__c == 'KO'
						// JS, K1/K2 
						&& KO_VKP.contains(trig.Verkaufsprogramm__c)
						&& trig.Produkttyp__c == 'Signatur' 
						&& (trig.medienart_id__c == '42' || trig.medienart_id__c == '46') ) {
						onOpportunityLineItem.doNotRunKOSync=true;
						onOpportunityLineItem.listtoSend.add(trig);			
					}
				}
				
				if(!onOpportunityLineItem.listtoSend.isEmpty())
					onOpportunityLineItem.onSignature(trigger.new); 
			} 
			 
			if(trigger.isInsert && trigger.isBefore) {
				for(OpportunityLineItem oli:trigger.new) {
					if(!oli.SkipTriggerfromDataloader__c)
						olis.add(oli);
				}
				if(!olis.isEmpty())
					onOpportunityLineItem.oninsert_before(olis);
						
			//	list<String> ArtikelIds = new list<String>();
				//list<String> OppIds = new list<String>();
				//list<String> ArtikelIds_55 = new list<String>();
			//	list<String> Ids = new list<String>();
	
				
				for(OpportunityLineItem oli:trigger.new){
					system.debug('debug O2 KO Normal ' + oli.AL_Preis__c + ' ' +  oli.Anzahl_Schulen_berechnet__c + ' ' + oli.OppVKP_Einzelpreis__c);
					
					/****************** for O2-KO-Normal... *********/
					if(oli.Produkttyp__c == 'Signatur' && !oli.SkipTriggerfromDataloader__c) {
						//For all O2 or for KO just the 46. the 55 is calculated without the anzahl schulen.
						if(oli.Anzahl_Schulen_berechnet__c > 0 &&
							(oli.Verkaufsprogramm__c == 'O2'||					//O2
							// JS, K1/K2
							// oli.Verkaufsprogramm__c == 'KO'
							(KO_VKP.contains(oli.Verkaufsprogramm__c) && (oli.medienart_id__c == '55' ||oli.medienart_id__c == '57')) /*||				//KO
							((oli.medienart_id__c == '55' || oli.medienart_id__c == '42' || oli.medienart_id__c == '46' || oli.medienart_id__c == '57') && oli.Lizenznummer__c == '10306')*/)) { //10306
							oli.UnitPrice = oli.Anzahl_Schulen_berechnet__c * oli.OppVKP_Einzelpreis__c;
							system.debug('kopien rabatt debug.. ' + oli.Kopien_Rabatt__c);
							if(oli.Kopien_Rabatt__c)
								oli.UnitPrice *= 2;
							//oli.Preis465557__c = oli.UnitPrice;
						}
						/****************** EndOf for O2 ***********/
						else{ //we just add the licence price to the unit price
							if(DuplicateOpportunity.Checker == false && oli.UnitPrice == null)
								oli.UnitPrice = 0; 
						//	oli.Preis465557__c = 0;
						}
						//It lacks some information. The rest of this calculation is done in the Workflows
						//because we cannot retrieve easily the price of the licence product on insert Before
					}
										
				//	Ids.add(oli.OpportunityId);
				}
		/*
				map<String, Opportunity> OppsMap = new map<String, Opportunity>([select id, Rabatt__c from Opportunity where Id IN: Ids]);
			
			//	integer i = 0;
				for(OpportunityLineItem trig:trigger.new) {
					if(trig.OppAnzahlSchulen__c != null && (trig.medienart_id__c == '42' || trig.medienart_id__c == '46' || trig.medienart_id__c == '55' || trig.medienart_id__c == '57')  ) {	   	
					   	ArtikelIds.add(trig.Product2Id__c);				
						system.debug('ARtikel Ids 1 ' + trig.Product2Id__c)	;
					}
				}
				*/
				onOpportunityLineItem.inFutureContextStoredId = '';
				
			/*	
				list<ArtikelLizenz__c> Artikel = new list<ArtikelLizenz__c>([select id, Artikel__c, VPR015__c, LZN015__c, Sig1Id__c from ArtikelLizenz__c where Artikel__c IN :ArtikelIds AND LZN015__c IN ('10206', '10306')]);			
		
				for(OpportunityLineItem trig:trigger.new) {
					for(ArtikelLizenz__c Art:Artikel) {
						if(trig.Product2Id__c == Art.Artikel__c && trig.Verkaufsprogramm__c == 'KO' && (trig.medienart_id__c == '46' || trig.medienart_id__c == '42') && Art.LZN015__c == '10206') {
							if(trig.MedSig1Prod__c == '55' || trig.MedSig1Prod__c == '57') {	
								ArtikelIds_55.add(trig.Sig1Id__c);    // 55/57 is here but we still need to test if it is a 10206
								OppIds.add(trig.OpportunityId);	//however, if it is a 55, it is a 10206 (according to the validation rule)
							}							
							trig.Preis465557__c = trig.Anzahl_Schulen_berechnet__c * trig.OppVKP_Einzelpreis__c + Art.VPR015__c;
						}
					}		
				}
				
				*/	
				
			/*	if(!ArtikelIds_55.isEmpty()) {
					list<ArtikelLizenz__c> Artikel55sort = new list<ArtikelLizenz__c>([select id, Artikel__c, VPR015__c from ArtikelLizenz__c where Artikel__c IN :ArtikelIds_55 AND LZN015__c = '10206']);			
					list<OpportunityLineItem>list55 = new list<OpportunityLineItem>();
					map<Id, map<Id, OpportunityLineItem>>map55 = new map<Id, map<Id, OpportunityLineItem>>();
					map<Id, OpportunityLineItem>map55toUpdate = new map<Id, OpportunityLineItem>();
				*/	
			//		list55 = [select id, Product2Id__c, UnitPrice, OpportunityId from OpportunityLineItem where Product2Id__c IN :ArtikelIds_55 AND OpportunityId IN: OppIds ];				
					
				/*	for(OpportunityLineItem oli55:list55) {
						if(!map55.containsKey(oli55.OpportunityId)) {
							map55.put(oli55.OpportunityId, new map<Id, OpportunityLineItem>{
								    oli55.Product2Id__c => 
								    oli55});
	
						}
						else {
							map55.get(oli55.OpportunityId).put(oli55.Product2Id__c, oli55);
						}
						
					}*/
				/*	
					for(ArtikelLizenz__c Art55:Artikel55sort) {
						for(ArtikelLizenz__c Art:Artikel) {
							if(Art.Sig1Id__c == Art55.Artikel__c) {  //a 55 match a 46
								for(OpportunityLineItem trig:trigger.new) {
									if(trig.Product2Id__c == Art.Artikel__c && trig.Verkaufsprogramm__c == 'KO' && (trig.medienart_id__c == '42' || trig.medienart_id__c == '46') && Art.LZN015__c == '10206') {   //a 46 ** 55 matches an OLI
										trig.Preis465557__c += Art55.VPR015__c;
									//	map55.get(trig.OpportunityId).get(trig.Sig1Id__c).UnitPrice = Art55.VPR015__c;
									//	if(!map55toUpdate.containsKey(map55.get(trig.OpportunityId).get(trig.Sig1Id__c).Id))
									//		map55toUpdate.put(map55.get(trig.OpportunityId).get(trig.Sig1Id__c).Id, map55.get(trig.OpportunityId).get(trig.Sig1Id__c));
									}
								}
							}
						}
					}*/
				//	if(!map55toUpdate.isEmpty())
				//		update map55toUpdate.values();
			//	}
				
					
	
				
			}
			if(trigger.isUpdate && trigger.isBefore) {
				
				list<String> ArtikelIds = new list<String>();
				list<String> ArtikelIds_55 = new list<String>();
				Integer i = 0;
				for(OpportunityLineItem oli:trigger.new) {
					if(!oli.isSammelnummernOLI__c && !oli.SkipTriggerfromDataloader__c){
						
						if(oli.Verkaufsprogramm__c == 'KO' && oli.OppAnzahlSchulen__c != null 
						   && (oli.medienart_id__c == '46' || oli.medienart_id__c == '42') ) {	   	
						   	ArtikelIds.add(oli.Product2Id__c);
		
							system.debug('ARtikel Ids 1 ' + oli.Product2Id__c)	;
						}
			
						/****************** for O2-KO-Normal... Preis Berechnung *********/
						if(oli.Produkttyp__c == 'Signatur') {
							if(oli.Kopien_Rabatt__c != trigger.old[i].Kopien_Rabatt__c) {
								if(oli.Kopien_Rabatt__c)
									oli.UnitPrice = oli.AL_Preis__c / 2;
								else
									oli.UnitPrice = oli.AL_Preis__c;
								if(oli.medienart_id__c == '55' || oli.medienart_id__c == '57') 
									oli.UnitPrice += oli.Anzahl_Schulen_berechnet__c * oli.OppVKP_Einzelpreis__c;
							}
								
							
							if(oli.medienart_id__c == '55' || oli.medienart_id__c == '57') //for 02 or KO, no need to test, anzahl schulen berechnet is set to 0 in other cases
								oli.UnitPrice += (oli.Anzahl_Schulen_berechnet__c - trigger.old[i].Anzahl_Schulen_berechnet__c) * oli.OppVKP_Einzelpreis__c;
						
							if(oli.rabattfaehig__c == 0) { //product no rabatfaehig
								oli.Discount = 0;
								/*if(oli.Discount == null)
									oli.Discount = 0;
								if(oli.UnitPrice != trigger.old[i].UnitPrice ) {
									if(oli.Anzahl_Schulen_berechnet__c > 0  &&
									(oli.Verkaufsprogramm__c == 'O2'|| 										//O2
									(oli.Verkaufsprogramm__c == 'KO' && (oli.medienart_id__c == '55' || oli.medienart_id__c == '57')) ||				//KO
									((oli.medienart_id__c == '55' || oli.medienart_id__c == '46' || oli.medienart_id__c == '42' || oli.medienart_id__c == '57') && oli.Lizenznummer__c == '10306'))) { //10306
										oli.Discount = 100 * (oli.AL_Preis__c + oli.Anzahl_Schulen_berechnet__c * oli.OppVKP_Einzelpreis__c - oli.UnitPrice) / (oli.AL_Preis__c + oli.Anzahl_Schulen_berechnet__c * oli.OppVKP_Einzelpreis__c);
									}
									else {//we just add the licence price to the unit price
										if(oli.AL_Preis__c != 0)
											oli.Discount = 100 * (oli.AL_Preis__c - oli.UnitPrice) / oli.AL_Preis__c ;
									}
								} 
								else if(oli.Discount != trigger.old[i].Discount || oli.SCHL2D__c != trigger.old[i].SCHL2D__c  || (oli.Anzahl_Schulen__c != trigger.old[i].Anzahl_Schulen__c && oli.Verkaufsprogramm__c == 'KO')){
									//we have to calculate the new price if the licence is changed. up to now, the formula is running perfectly on "isbefore" 
									if(oli.Anzahl_Schulen_berechnet__c > 0  &&
									(oli.Verkaufsprogramm__c == 'O2'|| 										//O2
									(oli.Verkaufsprogramm__c == 'KO' && (oli.medienart_id__c == '55' || oli.medienart_id__c == '57')) ||				//KO
									((oli.medienart_id__c == '55' || oli.medienart_id__c == '46' || oli.medienart_id__c == '42' || oli.medienart_id__c == '57') && oli.Lizenznummer__c == '10306'))) { //10306
										oli.UnitPrice = (oli.AL_Preis__c + oli.Anzahl_Schulen_berechnet__c * oli.OppVKP_Einzelpreis__c) * (1- oli.Discount/100);
									}
									else{ //we just add the licence price to the unit price
										oli.UnitPrice = oli.AL_Preis__c * (1- oli.Discount/100);
									}
								}*/
							}
							else {
								
							/*	if(oli.Anzahl_Schulen_berechnet__c > 0  &&
									(oli.Verkaufsprogramm__c == 'O2'|| 										//O2
									(oli.Verkaufsprogramm__c == 'KO' && (oli.medienart_id__c == '55' || oli.medienart_id__c == '57')) ||				//KO
									((oli.medienart_id__c == '55' || oli.medienart_id__c == '46' || oli.medienart_id__c == '42' || oli.medienart_id__c == '57') && oli.Lizenznummer__c == '10306'))) { //10306
										oli.UnitPrice = oli.AL_Preis__c + oli.Anzahl_Schulen_berechnet__c * oli.OppVKP_Einzelpreis__c;
									}
									else{ //we just add the licence price to the unit price
										oli.UnitPrice = oli.AL_Preis__c ;
									}*/
							}
						
						}
						/****************** End of for O2-KO-Normal... Preis Berechnung *********/
						i++;	
					}			
				}
		/*
				list<ArtikelLizenz__c> Artikel = new list<ArtikelLizenz__c>([select id, Artikel__c, VPR015__c, Sig1Id__c from ArtikelLizenz__c where Artikel__c IN :ArtikelIds AND LZN015__c = '10206']);			
		
				for(OpportunityLineItem trig:trigger.new) {
					if(!trig.isSammelnummernOLI__c){
						for(ArtikelLizenz__c Art:Artikel) {
							if(trig.Product2Id__c == Art.Artikel__c) {
								if(trig.MedSig1Prod__c == '55' || trig.MedSig1Prod__c == '57') {	
									ArtikelIds_55.add(trig.Sig1Id__c);    // 55/57 is here but we still need to test if it is a 10206
																//however, if it is a 55, it is a 10206 (according to the validation rule)
								}							
		
								trig.Preis465557__c = trig.Anzahl_Schulen_berechnet__c * trig.OppVKP_Einzelpreis__c + Art.VPR015__c;
							}
						}
					}		
				}*/
	
			/*	if(!ArtikelIds_55.isEmpty()) {
					list<ArtikelLizenz__c> Artikel55sort = new list<ArtikelLizenz__c>([select id, Artikel__c, VPR015__c from ArtikelLizenz__c where Artikel__c IN :ArtikelIds_55 AND LZN015__c = '10206']);			
	
					for(ArtikelLizenz__c Art55:Artikel55sort) {
						for(ArtikelLizenz__c Art:Artikel) {
							if(Art.Sig1Id__c == Art55.Artikel__c) {  //a 55 match a 46
								for(OpportunityLineItem trig:trigger.new) {
									if(trig.Product2Id__c == Art.Artikel__c && !trig.isSammelnummernOLI__c) {   //a 46 ** 55 matches an OLI
										trig.Preis465557__c += Art55.VPR015__c;
									}
								}
							}
						}
					}
				}*/
			}
		}
		if(!onOpportunityLineItem.ForcePassage && trigger.isAfter &&trigger.isUpdate)	
			onOpportunityLineItem.ForcePassage = true; //we reinit for the next chunk
		
		system.debug('onOpportunityLineItem.ForcePassage ' + onOpportunityLineItem.ForcePassage)	;
	}
			}
}