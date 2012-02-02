global class OpportunityFreigabeFakturierung {
/*
	private static final String oliwherecond=' AND Produkttyp__c<>\'Sammelnummer\' FOR Update';
	// ?? AND StatusPosition__c=2 
	// AND Sperrkz__c=false 
	
	private static final String KO_LIZENZ='10206';

	private static map<Id, Opportunity> auftraege=new map<Id, Opportunity>();
	private static map<Id, Double> auftraegeNoFak = new map<Id, Double>();
	//private static map<Id, map<Id, OpportunityLineItem>> auftragsposten = new map<Id, map<Id, OpportunityLineItem>>();
	private static map<Id, OpportunityLineItem> aposten = new map<Id, OpportunityLineItem>();
	private static map<Id, String> aposten_orig = new map<Id, String>();
	
	// private static map<Id, Opportunity> auftraege_free=new map<Id, Opportunity>();
	//private static map<Id, map<Id, OpportunityLineItem>> auftragsposten_free = new map<Id, map<Id, OpportunityLineItem>>();
	//private static map<Id, OpportunityLineItem> aposten_free = new map<Id, OpportunityLineItem>();
	
	
	//private static map<Id, Opportunity> auftraege_fak=new map<Id, Opportunity>();
	//private static map<Id, map<Id, OpportunityLineItem>> auftragsposten_fak = new map<Id, map<Id, OpportunityLineItem>>();
	//private static map<Id, OpportunityLineItem> aposten_fak = new map<Id, OpportunityLineItem>();

	private static map<Id, Product2> artikel=new map<Id, Product2>();

	//private static map<Id, Product2> artikel_free=new map<Id, Product2>();
	
	//private static map<Id, Product2> artikel_fak=new map<Id, Product2>();

	private static map<Id, Rechnung__c> rechnungmap;
	
	private static map<Id, RechnungPosten__c> rechnungpostenmap;
	private static map<Id, RechnungPosten__c> rabatterpmap;
	
	private static Map<String, Schema.SObjectField> OliFieldMap;
	
	private static map<Id, Account> accounts;
	
	public static void OpportunityFreigabeFakturierungRun(list<sObject> opps) {
		if (!opps.isEmpty()) {
			for (sObject s: opps) {
				Opportunity o=(Opportunity)s;
				if (!auftraege.containsKey(o.id)) auftraege.put(o.id, o);
			}
		}
		// to free memory
		opps.clear();
		run();
	}
	
	@future
	public static void OpportunityFreigabeFakturierungRun(String query) {
		List<sObject> L = Database.query(query);
		OpportunityFreigabeFakturierungRun(L);
	}
	
	public static void OpportunityFreigabeFakturierungRun(map<Id, Opportunity> opps) {
		if (!opps.isEmpty()) {
			auftraege=opps.clone();
			//for (sObject s: opps) {
			//	Opportunity o=(Opportunity)s;
			//	if (!auftraege.containsKey(o.id)) auftraege.put(o.id, o);
			//}
		}
		run();
	}
	
	public static void OpportunityFreigabeFakturierungRun(Set<Id> oppids) {
		if (!oppids.isEmpty()) {
			list<String> oids = new list<String>();
			for (Id oid:oppids) {
				oids.add(oid);
			}
			OpportunityFreigabeFakturierungRun.fak(oids);
		}
		// vermutlich quark dieses run(), da die auftragsliste leer sein müsste, aber wer weiss ...
		// TODO Test ohne dieses run()
		run();
	}
	
	private static void run() {
		Savepoint startrun = database.setSavepoint();
		if (!auftraege.isEmpty() && !locked() && unlockAuftraege()) {
			saveOldInformation();
			collectAuftragsposten();
			collectArtikel();
			freigabe();
			fakturierung();
			accounts = new map<Id, Account>();
			umsatz(); 
			absatz();
			updateArtikelAbsatzUmsatz();
			print();
			collectAccounts();
			umsatzAccounts();
			updateAccounts();
			if (!lockAuftraege()) database.rollback(startrun);
		}
		SystemSettings.insertErrors();
	}
	
	private static void saveOldInformation() {
		for (Opportunity o: auftraege.values()) {
			auftraegeNoFak.put(o.id, o.Zahl_der_Fakturierungen__c);
		}
	}
	
	private static Boolean unlockAuftraege() {
		if (!auftraege.isEmpty()) {
			for (Id oppid: auftraege.keySet()) {
				auftraege.get(oppid).Locked__c=false;
			}
		}
		try {
			update auftraege.values();
			return true;
		} catch (System.Dmlexception e) {
			SystemSettings.logError(e.getMessage(),'DEBUG');
			//if (SystemSettings.isDebug) throw e;
			return false;
		}
		return false;
	}
	
	private static Boolean lockAuftraege() {
		if (!auftraege.isEmpty()) {
			for (Id oppid: auftraege.keySet()) {
				auftraege.get(oppid).Locked__c=true;
				auftraege.get(oppid).Conga_Workflow_Trigger__c=false;
			}
		}
		try {
			update auftraege.values();
			return true;
		} catch (System.Dmlexception e) {
			SystemSettings.logError(e.getMessage(),'DEBUG');
			//if (SystemSettings.isDebug) throw e;
			return false;
		}
		return false;
	}
	
	private static Boolean locked() {
		for (Inventur__c iv:Inventur__c.getAll().values()) {
			if (iv.Beginn__c<=System.today()) {
				if (iv.Ende__c==null) return true;
				if (iv.Ende__c!=null && iv.Ende__c>=System.today()) return true;
			}
		}
		return false;
	}
	
	private static void print() {
		if (!auftraege.isEmpty()) {
			for (Id oppid: auftraege.keySet()) {
				if (auftraege.get(oppid).Zahl_der_Fakturierungen__c!=null && 
					((auftraege.get(oppid).Zahl_der_Fakturierungen__c==1 && auftraege.get(oppid).Zahl_der_Fakturierungen__c!=auftraegeNoFak.get(oppid))
					|| 
					(auftraege.get(oppid).Zahl_der_Fakturierungen__c>auftraegeNoFak.get(oppid)
					&& rechnungmap.containsKey(oppid))
					)
					) {
					//auftraege_fak.get(oppid).Conga_Workflow_for_activation__c=true;
					auftraege.get(oppid).Conga_Workflow_Trigger__c=true;
					//SystemSettings.logError('Auftrag zu drucken: ' + oppid);
				}
			}
			Boolean hasError=updateAuftraege();
			if (hasError && !SystemSettings.isDebug) {
				SystemSettings.logError('Print ist fehlgeschlagen!');
			}
		}
	}
	
	private static void collectAuftragsposten() {
		String query='SELECT ';
		list<OpportunityLineItem> olitonull = new list<OpportunityLineItem>();
		if (!auftraege.isEmpty()) {
			query=query + getOliFields() + ' FROM OpportunityLineItem WHERE OpportunityId IN ' + getOppIdListString(auftraege.keySet()) + oliwherecond;
			System.debug('PARX collectAuftragsposten Query: ' + query);
			try {
				for (OpportunityLineItem oli: Database.query(query)) {
					//if (oli.StatusPosition__c<3) {
						//if (!auftragsposten.containsKey(oli.OpportunityId)) auftragsposten.put(oli.OpportunityId, new map<Id, OpportunityLineItem>());
						//if (!auftragsposten.get(oli.OpportunityId).containsKey(oli.id)) auftragsposten.get(oli.OpportunityId).put(oli.id,oli);
						if (!aposten.containsKey(oli.id)) aposten.put(oli.id,oli);
					//} else {
					if (oli.Liefermenge__c<>0) {
						oli.Liefermenge__c=0;
						olitonull.add(oli);
					}
				}
				try {
					update olitonull;
				} catch (System.Queryexception e) {
					SystemSettings.logError(e.getMessage(),'DEBUG');
					//if (SystemSettings.isDebug) throw e;
				}
			} catch (System.Queryexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static void collectArtikel() {
		if (!aposten.isEmpty()) {
			Set<Id> pids =new Set<Id>();
			for (OpportunityLineItem oli: aposten.values()) {
				if (!pids.contains(Id.valueOf(oli.Product2Id__c))) pids.add(Id.valueOf(oli.Product2Id__c));
			} 
			try {
				list<Product2> pkzmod=new list<Product2>();
				for (Product2 p: [SELECT Id, GESB01__c, RESB01__c, PDKZ01__c, ABLJ01__c, ABMO01__c, ABGS01__c, UMGS01__c, UMLJ01__c, UMMO01__c, AUEA01__c FROM Product2 WHERE Id IN:pids]) {
					if (p.GESB01__c!=null && p.GESB01__c==0 && p.PDKZ01__c==6) {
							p.PDKZ01__c=8;
							pkzmod.add(p);
					}
					if (!artikel.containsKey(p.id)) artikel.put(p.id, p);
				}
				// if a product runs out it will set to pkz 8 so that it can not be sold anymore
				if (!pkzmod.isEmpty()) {
					try {
						update pkzmod;
					} catch (System.DMLException dmle) {
						SystemSettings.logError(dmle.getMessage(),'DEBUG');
					}
				}
			} catch (System.Queryexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	// we should collect accounts on behalf of existing invoiceitems
	private static void collectAccounts() {
		if (!rechnungpostenmap.isEmpty() && !aposten.isEmpty()) {
			set<Id> accountids=new set<Id>();
			for (Id oliid: rechnungpostenmap.keySet()) {
				if (aposten.containsKey(oliid) && !accountids.contains(Id.valueOf(aposten.get(oliid).OppWarenempf_nger__c))) accountids.add(Id.valueOf(aposten.get(oliid).OppWarenempf_nger__c)); 
			}
			// now we have our set of interessting account ids
			// lets get the accounts
			if (!accountids.isEmpty()) {
				for (Account a: [SELECT id, UMLJ02__c FROM Account WHERE Id IN :accountids]) {
					if (a.UMLJ02__c==null) a.UMLJ02__c=0;
					if (!accounts.containsKey(a.id)) accounts.put(a.id, a);
				}
			}
		}
		
	}
	
	private static String getOliFields() {
		String fieldnames='';
		
		OliFieldMap = Schema.SObjectType.OpportunityLineItem.fields.getMap();
		
		for (String fname: OliFieldMap.keySet()) {
			if (OliFieldMap.get(fname).getDescribe().isAccessible() ||
				OliFieldMap.get(fname).getDescribe().isUpdateable()
				) {
				if (fieldnames=='') fieldnames+=fname;
				else fieldnames+=', ' + fname;
			}
		}
		
		return fieldnames;
	}
	
	private static String getOppIdListString(Set<Id> oppids) {
		String idlist='';
		if (oppids!=null && !oppids.isEmpty()) {
			for (Id sid: oppids) {
				if (idlist=='') idlist+='( \'' + sid;
				else idlist+='\', \''+ sid;
			}
		}
		if (idlist.length()>0) idlist+= '\' )';
		return idlist;
	}

	
	// Freigabe und Fakturierung von Auftraegen
	//
	// Initial: Pruefung des Aufrufs: Entweder mit einer Liste von Opp Ids oder
	// ohne jegliche Ids
	// ??Ohne IDs: Selection mit Query Locator
	//
	// Freigabe: Pruefung von Bestaenden
	// Fakturierung: Anlage von Rechnungsdaten (und Belegen)
	//

	// Bestandspruefung
	// Status auf Auftrag
	private static void freigabe() {
		Savepoint free1 = database.setSavepoint();
		Boolean hasError=false;
		if (!auftraege.isEmpty() && !aposten.isEmpty() && !artikel.isEmpty()) {
			aposten_orig=getOldOliStatus();
			setFreigegebeneMenge();
			setLagerzugang();
			setLagerabgang();
			KOLspecialcheck();
			setAuftragspostenGELM();
		}

		hasError=updateAuftragsposten();
		if (hasError && !SystemSettings.isDebug) database.rollback(free1);
		else {
			for (Id oid: auftraege.keySet()) {
				if (auftraege.get(oid).StageName!='Teillieferung' && auftraege.get(oid).StageName!='Gelöscht' ) auftraege.get(oid).StageName='Freigabe / Fakturierung';
			}
			hasError=updateAuftraege();
		} 
		if (hasError && !SystemSettings.isDebug) 
			database.rollback(free1);
		if (hasError) SystemSettings.logError('Freigabe HasError: ' + hasError);
		
		// just clone the map to keep status information
		//auftraege=auftraege.deepClone();
		
		//aposten=aposten.deepClone();
	}
	
	private static map<Id, String> getOldOliStatus() {
		map<Id, String> oldstat = new map<Id, String>();
		for (OpportunityLineItem oli: aposten.values()) {
			oldstat.put(oli.id, oli.STAT2D__c);
		}
		return oldstat;
	}
	
	private static void KOLspecialcheck() {
		map<Id, map<Id, OpportunityLineItem>> olimap = new map<Id, map<Id, OpportunityLineItem>>();
		if (!aposten.isEmpty()) {
			for (OpportunityLineItem oli46: aposten.values()) {
				ID oli46medienart55ID=oli46.medienart_55__c;
				//SystemSettings.logError('String medienart_55__c: ' + oli46.medienart_55__c + ' versus Id oli46medienart55ID: ' + oli46medienart55ID);
				System.debug('String medienart_55__c: ' + oli46.medienart_55__c + ' versus Id oli46medienart55ID: ' + oli46medienart55ID);
				if (oli46.StatusPosition__c<3) {
					if (!olimap.containsKey(oli46.OpportunityId)) olimap.put(oli46.OpportunityId, new map<Id, OpportunityLineItem>());
					if (oli46.medienart_55__c!=null && oli46.medienart_55__c!='' && oli46.medienart_id__c=='46' && !olimap.get(oli46.OpportunityId).containsKey(oli46medienart55ID)) {
						for (OpportunityLineItem oli55: aposten.values()) {
							if (oli55.StatusPosition__c<3 
									&& Id.valueOf(oli55.Product2Id__c)==oli46medienart55ID 
									&& oli55.medienart_id__c=='55' 
									&& oli55.OpportunityId==oli46.OpportunityId) 
								olimap.get(oli46.OpportunityId).put(Id.valueOf(oli55.Product2Id__c),oli55);
						}
					}
				}
			}
		}	
		for (Id oliid: aposten.keySet()) {
			if (aposten.get(oliid).FRME2D__c==null) 
				aposten.get(oliid).FRME2D__c=0;
			ID oli46medienart55ID=aposten.get(oliid).medienart_55__c;
			if (olimap.containsKey(aposten.get(oliid).OpportunityId) && olimap.get(aposten.get(oliid).OpportunityId).containsKey(oli46medienart55ID) && olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).FRME2D__c==null) 
				aposten.get(olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c=0; 
			// voraussetzungen ko (nicht nur das Verkaufsprogramm, sondern generell die Lizenzart), oli für 46 mit ref zu 55
			//SystemSettings.logError('Constraints for KOLCheck-olimap contains 55er Id: ' + olimap.get(aposten.get(oliid).OpportunityId).containsKey(oli46medienart55ID));
			//SystemSettings.logError('Constraints for KOLCheck-olimap 55er is 10206: ' + olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).Lizenznummer__c);
			if (aposten.get(oliid).Lizenznummer__c==KO_LIZENZ
					&& SystemSettings.Lagerabgang.contains(aposten.get(oliid).OppRechnungsArt__c.intValue())
					&& aposten.get(oliid).medienart_id__c=='46'
					&& aposten.get(oliid).medienart_55__c!=null
					&& aposten.get(oliid).medienart_55__c!=''
					&& aposten.get(oliid).StatusPosition__c<3
					&& olimap.get(aposten.get(oliid).OpportunityId).containsKey(oli46medienart55ID)
					&& olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).Lizenznummer__c==KO_LIZENZ
					//&& !aposten.get(oliid).Sperrkz__c
					 ) {

				// fehler, falls sich die freigebbare menge in bezug auf die quantity unterscheidet
				// --> freigebbare mengen jeweils 0 
				// --> Status jeweils Rückstellung
				// --> artikel bestand und reservierung rückgängig
				//SystemSettings.logError('Found 46er with FRME2D '+ aposten.get(oliid).FRME2D__c + ' / 46 Id: ' + aposten.get(oliid).Id );
				if (aposten.get(oliid).FRME2D__c/aposten.get(oliid).Lizenzmenge__c!=
							aposten.get(olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c/aposten.get(olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).id).Lizenzmenge__c) {
					//SystemSettings.logError('55er with FRME2D '+ aposten.get(olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c + ' / 55er Id: ' + oli46medienart55ID );
					aposten.get(oliid).STAT2D__c='Rückstellung';
					aposten.get(oliid).FRME2D__c=0;
					aposten.get(olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).id).STAT2D__c='Rückstellung';
					aposten.get(olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c=0;
				}
			}
		}
	}
	
	private static void setLagerzugang() {
		for (OpportunityLineItem oli: aposten.values()) {
			if (oli.STAT2D__c!='Freigabe' && oli.STAT2D__c!='Fakturiert' && oli.STAT2D__c!='Gelöscht' && oli.STAT2D__c!='Ausgelassen'
					&& SystemSettings.Lagerzugang.contains(oli.OppRechnungsArt__c.intValue()) 
					) {
				oli.FRME2D__c=oli.Lizenzmenge__c;
				oli.STAT2D__c='Freigabe';
				if (oli.Fremdvertrieb__c!=null) {
					oli.FRME2D__c=oli.Lizenzmenge__c;
					oli.STAT2D__c='Ausgelassen';
				}
				// TODO wie wirkt sich hier das Sperrkennzeichen aus?
				if (!oli.Sperrkz__c) 
					oli.Liefermenge__c=oli.Quantity;
				// Bei fremdvertrieb soll keine Menge angegeben werden!
				if (oli.Fremdvertrieb__c!=null)
					oli.Liefermenge__c=0;
			}
		}
	}
	
	private static void setFreigegebeneMenge() {
		for (OpportunityLineItem oli: aposten.values()) {
			// wir können bei den genannten Rechnungsarten ohne Lagerbewegung alles freigeben.
			// bei Fremdvertrieb darf nicht fakturiert werden!
			// das Sperrkennzeichen ist nur bei REA 3 nicht gültig, hier muss auch alles Gesperrte fakturiert werden
			if (oli.STAT2D__c!='Freigabe' && oli.STAT2D__c!='Fakturiert' && oli.STAT2D__c!='Gelöscht'  && oli.STAT2D__c!='Ausgelassen'
				&& !SystemSettings.Lagerabgang.contains(oli.OppRechnungsArt__c.intValue()) 
				&& !SystemSettings.Lagerzugang.contains(oli.OppRechnungsArt__c.intValue()) 
				) {
				oli.FRME2D__c=0;
				oli.Liefermenge__c=0;
				if (!oli.Sperrkz__c && (oli.Fremdvertrieb__c==null)) {
					oli.STAT2D__c='Freigabe';
					oli.FRME2D__c=oli.Lizenzmenge__c;
				}
				// for vorausrechnung every item will be calculated
				if (oli.OppRechnungsArt__c==3) {
					oli.STAT2D__c='Freigabe';
					oli.FRME2D__c=oli.Lizenzmenge__c;
				}
				if ((oli.Fremdvertrieb__c!=null) || oli.OppRechnungsArt__c==2) {
					oli.STAT2D__c='Ausgelassen';
					oli.FRME2D__c=oli.Lizenzmenge__c;
				}
				if (oli.Fremdvertrieb__c==null) oli.Liefermenge__c=oli.FRME2D__c/oli.AbsatzMengeDerLizenz__c;
			}
		}
	}
	
	private static void setLagerabgang() {
		for (Id oliid: aposten.keySet()) {
			// Lagerabgang
			if (SystemSettings.Lagerabgang.contains(aposten.get(oliid).OppRechnungsArt__c.intValue())) {
				aposten.get(oliid).FRME2D__c=0;
				Id ProductId=aposten.get(oliid).Product2Id__c;
				if (aposten.get(oliid).STAT2D__c!='Freigabe'  && aposten.get(oliid).STAT2D__c!='Fakturiert' && aposten.get(oliid).STAT2D__c!='Gelöscht' && aposten.get(oliid).STAT2D__c!='Ausgelassen'
					&& artikel.get(ProductId).PDKZ01__c<8
					&& artikel.get(ProductId).PDKZ01__c>=4
					&& aposten.get(oliid).Produkttyp__c=='Signatur'
					&& !aposten.get(oliid).Sperrkz__c
					&& aposten.get(oliid).Fremdvertrieb__c==null
					) {
					// SystemSettings.logError('Kalkulierter freigebbarer Bestand: ' + getFreigebbarerBestand(artikel.get(aposten.get(oliid).Product2Id__c),aposten.get(oliid)));
					//SystemSettings.logError('Kalkulierter freigebbarer Bestand: ' + getFreigebbarerBestand(artikel.get(aposten.get(oliid).Product2Id__c),aposten.get(oliid)));
		
					aposten.get(oliid).FRME2D__c=getFreigebbarerBestand(artikel.get(ProductId),aposten.get(oliid));
					aposten.get(oliid).STAT2D__c='Freigabe';
					if (getFreigebbarerBestand(artikel.get(ProductId),aposten.get(oliid))==0
							|| 
							(aposten.get(oliid).OppTeillieferung__c==0 
							&& getFreigebbarerBestand(artikel.get(ProductId),aposten.get(oliid))<aposten.get(oliid).Lizenzmenge__c)
							) {
						aposten.get(oliid).STAT2D__c='Rückstellung';
						aposten.get(oliid).FRME2D__c=0;
					}
				
				} else if (aposten.get(oliid).Produkttyp__c=='Signatur' && 
							(artikel.get(ProductId).PDKZ01__c>=8 || 
							 artikel.get(ProductId).PDKZ01__c<4 || 
							 aposten.get(oliid).Sperrkz__c) && 
							 aposten.get(oliid).STAT2D__c!='Fakturiert' && 
							 aposten.get(oliid).STAT2D__c!='Gelöscht' && 
							 aposten.get(oliid).STAT2D__c!='Ausgelassen') {
					aposten.get(oliid).STAT2D__c='';
					if (artikel.get(ProductId).PDKZ01__c>=8) 
						aposten.get(oliid).Sperrkz__c=true;
					
				} else if (aposten.get(oliid).STAT2D__c!='Fakturiert' && aposten.get(oliid).STAT2D__c!='Gelöscht' && aposten.get(oliid).STAT2D__c!='Ausgelassen') {
					aposten.get(oliid).STAT2D__c='Freigabe';
					aposten.get(oliid).FRME2D__c=aposten.get(oliid).Lizenzmenge__c;
				} 
				if (aposten.get(oliid).Fremdvertrieb__c!=null && aposten.get(oliid).STAT2D__c!='Fakturiert' && aposten.get(oliid).STAT2D__c!='Gelöscht' && aposten.get(oliid).STAT2D__c!='Ausgelassen') {
					aposten.get(oliid).FRME2D__c=aposten.get(oliid).Lizenzmenge__c;
					aposten.get(oliid).STAT2D__c='Ausgelassen';
				}
				if (aposten.get(oliid).Produkttyp__c=='Andere' && aposten.get(oliid).STAT2D__c!='Fakturiert' && aposten.get(oliid).STAT2D__c!='Gelöscht' && aposten.get(oliid).STAT2D__c!='Ausgelassen') {
					aposten.get(oliid).STAT2D__c='Freigabe';
					aposten.get(oliid).FRME2D__c=aposten.get(oliid).Quantity;
				}
			}
		}
	}
	
	private static Double getFreigebbarerBestand(Product2 p, OpportunityLineItem oli) {
		Double bestand=0;
		
		if (oli!=null && p!=null && p.PDKZ01__c!=null && p.PDKZ01__c>=4 && p.PDKZ01__c<8 && !oli.Sperrkz__c) {
			if (oli.GELM2D__c==null) oli.GELM2D__c=0;
			if (p.GESB01__c==null) p.GESB01__c=0;
			Double mengederlizenz=0;
			if (oli.Lizenzmenge__c!=null)
			// quantity can never be 0, this is a salesforce principle!
				mengederlizenz=oli.Lizenzmenge__c.intValue()/oli.Quantity.intValue();
			if (p.GESB01__c-oli.Lizenzmenge__c+oli.GELM2D__c>=0) {
				// now we have enough quantity with p
				bestand=oli.Lizenzmenge__c-oli.GELM2D__c;
			} else if (p.GESB01__c>=mengederlizenz) {
				// we can't free enough quantity for oli, but have the possibility of part delivery
				bestand=p.GESB01__c-Math.mod(p.GESB01__c.longValue(),mengederlizenz.longValue().intValue());
			}
		}
		return bestand;
	}
	
	private static void setAuftragspostenGELM() {
		if (!aposten.isEmpty() && !artikel.isEmpty()) {
			for (Id oliid:aposten.keySet()) {
				// delivery only for real signatures and not for items already in Freigabe
				if (aposten_orig.get(oliid)!='Freigabe' 
					&& SystemSettings.Lagerabgang.contains(aposten.get(oliid).OppRechnungsArt__c.intValue()) 
					&& aposten.get(oliid).Produkttyp__c=='Signatur') { 
					if (aposten.get(oliid).Liefermenge__c==null) aposten.get(oliid).Liefermenge__c=0;
					if (aposten.get(oliid).GELM2D__c==null) aposten.get(oliid).GELM2D__c=0;
					if (aposten.get(oliid).FRME2D__c!=null 
							&& aposten.get(oliid).FRME2D__c>0
							&& aposten.get(oliid).Fremdvertrieb__c==null
							&& SystemSettings.Lagerabgang.contains(aposten.get(oliid).OppRechnungsart__c.intValue())) {
						aposten.get(oliid).GELM2D__c+=aposten.get(oliid).FRME2D__c;
						aposten.get(oliid).Liefermenge__c=aposten.get(oliid).FRME2D__c/aposten.get(oliid).AbsatzMengeDerLizenz__c;
					}
				}
				if (aposten_orig.get(oliid)!='Freigabe' && aposten.get(oliid).Produkttyp__c=='Andere') aposten.get(oliid).Liefermenge__c=aposten.get(oliid).FRME2D__c;
			}
		}
	}
	
	// Erzeugung Rechnungsdaten und Belegdaten
	// Status auf Auftrag
	private static void fakturierung() {
		Savepoint fak1 = database.setSavepoint();
		Boolean hasError=false;
		//collectAuftragspostenFaktura();
		// for all auftraege we assume that in the end they all will be fakturiert
		// if this is not the case we change the state for each opp if it is necessary
		rechnungmap = new map<Id, Rechnung__c>();
		rechnungpostenmap = new map<Id, RechnungPosten__c>();
		if (!auftraege.isEmpty() && !aposten.isEmpty() && !artikel.isEmpty()) {
			// the basic information lays in the auftragsposten (line items)
			setInventory();
			for (Id oliid: aposten.keySet()) {
				// just to be sure ...
				// be aware: formular fields may have old values
				// Status "ausgelassen" for lineitem
				// this status is only necessary for "signatur" types
				// before we really set this status we should create some needed documents
				if (aposten.get(oliid).STAT2D__c=='Freigabe' && aposten.get(oliid).Produkttyp__c=='Signatur' && aposten.get(oliid).OppRechnungsArt__c==2)
						aposten.get(oliid).STAT2D__c='Ausgelassen';
				// now we create our invoices - we will have at least one item for them
				if (aposten.get(oliid).STAT2D__c=='Freigabe' 
					&& aposten.get(oliid).FRME2D__c!=null 
					&& aposten.get(oliid).FRME2D__c>0) {
					// for each fakturierlauf we create only one invoice for each opp
					if (!rechnungmap.containsKey(aposten.get(oliid).OpportunityId)) 
						createInvoice(auftraege.get(aposten.get(oliid).OpportunityId));
				}
			}
		}
		// update Artikel
		hasError=updateArtikelFaktura();
		if (hasError && !SystemSettings.isDebug) database.rollback(fak1);
		// insertInvoices
		hasError=insertInvoices();
		if (hasError && !SystemSettings.isDebug) {
			database.rollback(fak1);
		} else {
			// update Auftragsposten with Invoices
			if (!aposten.isEmpty() && !rechnungmap.isEmpty()) {
				for (Id oliid:aposten.keySet()) {
					if (aposten.get(oliid).Liefermenge__c!=null && aposten.get(oliid).Liefermenge__c>0) {
						for (Rechnung__c r: rechnungmap.values()) {
							if (aposten.get(oliid).OpportunityId==r.AUN211__c) aposten.get(oliid).Rechnung__c=r.id;
						}
					}
				}
			}
			hasError=updateAuftragsposten();
			if (hasError && !SystemSettings.isDebug) {
				database.rollback(fak1);
			} else {
				if (!auftraege.isEmpty()) {
					if (!aposten.isEmpty() && !artikel.isEmpty() && !rechnungmap.isEmpty()) {
						rabatterpmap = new map<Id, RechnungPosten__c>();
						rechnungpostenmap = new map<Id, RechnungPosten__c>();
						for (Id oliid: aposten.keySet()) {
							// lets create invoice items for auftragsposten // TODO pruefe, ob die Kriterien ok sind
							if (aposten.get(oliid).STAT2D__c=='Freigabe'
								&& rechnungmap.containsKey(aposten.get(oliid).OpportunityId) 
								&& rechnungmap.get(aposten.get(oliid).OpportunityId).Id!=null) {
								createInvoiceItem(aposten.get(oliid));
							}
						}
					}
					// insertLineItems
					hasError=insertInvoiceItems();
					if (hasError && !SystemSettings.isDebug) {
						database.rollback(fak1);
					}
					setAuftragspostenFakturaStatus();
					setAuftraegeFakturaStatus();
					// updateAuftraege
					hasError=updateAuftraege();
					if (hasError && !SystemSettings.isDebug) {
						database.rollback(fak1);
					} else {
						hasError=updateAuftragsposten();
						if (hasError && !SystemSettings.isDebug) database.rollback(fak1);
					}
				}
			}
		}
		if (hasError) SystemSettings.logError('Faktura HasError: ' + hasError);
		
		//if (!hasError) {
		//	aposten_fak=aposten.deepClone();
		//	aposten.clear();
		//	auftraege_fak=auftraege.deepClone();
		//	auftraege_fak.clear();
		//}
		
		SystemSettings.insertErrors();
	}
	
	private static void setInventory() {
		for (OpportunityLineItem oli: aposten.values()) {
			Id oliProductId=oli.Product2Id__c;
			if ((SystemSettings.Lagerabgang.contains(oli.OppRechnungsArt__c.intValue()) 
				|| SystemSettings.Lagerzugang.contains(oli.OppRechnungsArt__c.intValue()))
				&& oli.STAT2D__c=='Freigabe') {
				Double sign=SystemSettings.Lagerabgang.contains(oli.OppRechnungsart__c.intValue())?-1:1;
				if (oli.FRME2D__c!=null && oli.FRME2D__c>0 && oli.Produkttyp__c=='Signatur') {
					if (artikel.containsKey(oliProductId)) {
						if (artikel.get(oliProductId).RESB01__c==null) artikel.get(oliProductId).RESB01__c=0;
						if (artikel.get(oliProductId).GESB01__c==null) artikel.get(oliProductId).GESB01__c=0;
						if (artikel.get(oliProductId).AUEA01__c==null) artikel.get(oliProductId).AUEA01__c=0;
						artikel.get(oliProductId).RESB01__c+=oli.FRME2D__c*sign;
						artikel.get(oliProductId).GESB01__c+=oli.FRME2D__c*sign;
						artikel.get(oliProductId).AUEA01__c+=oli.FRME2D__c*sign;
					}
				}
			}
		}
	}
	
	private static void createInvoice(Opportunity o) {
		if (o!=null && o.id!=null && o.AccountId!=null) {
			Rechnung__c r = new Rechnung__c(KDW211__c=o.KDWE2A__c
								,AUN211__c=o.id
								,KDR211__c=o.AccountId
								//,MWB211__c=o.MWSt_Betrag__c // SOLVED by Rollup
								//,MWS211__c=o.MWST2A__c // SOLVED by Formular
								//,NRB211__c=o.Beleg_Nettobetrag__c  // // SOLVED by Rollup
								//,MWB211__c=o.Beleg_MWSt_Betrag__c
								,RED211__c=System.today()
								);
			if (!rechnungmap.containsKey(o.id)) rechnungmap.put(o.id,r);
		}
	}
	
	private static void createInvoiceItem(OpportunityLineItem oli) {
		if (oli!=null && oli.id!=null && !rechnungmap.isEmpty() && (oli.Fremdvertrieb__c==null) && oli.Produkttyp__c!='Sammelnummer') {
			// negativ bei 1, 5, 6, 7
			// 0 beträge bei 4 und 5
			set<Double> negREAR = new set<Double>{ 1.0, 5.0, 6.0, 7.0};
			set<Double> nullREAR = new set<Double>{4.0 , 5.0};
			Double sign=negREAR.contains(oli.OppRechnungsart__c)?-1:1;
			Double vksign=nullREAR.contains(oli.OppRechnungsart__c)?0:1;
			// normalfall
			if (oli.OppRabattgutschrift__c==0) {
				Integer faktor=100000;
				RechnungPosten__c rp=new RechnungPosten__c();
				rp.GEM212__c=sign*oli.Liefermenge__c;
				rp.OpportunityLineItemId__c=oli.id;
				rp.LZN212__c=oli.SCHL2D__c;
				rp.LMG212__c=oli.FRME2D__c*sign;
				rp.VKP212__c=oli.Einzelpreis_f_r_Kunde__c;
				rp.Artikel__c=Id.valueOf(oli.Product2Id__c);
				if (oli.Produkttyp__c=='Andere') {
					rp.ZUA212__c='DZ';
					//rp.MWST_Betrag__c=0;
					rp.GNP212__c=oli.Quantity*oli.Einzelpreis_f_r_Kunde__c;
				} 
				//SystemSettings.logError('Liefermenge: ' + oli.Liefermenge__c.intValue() + ' / Quantity: ' + oli.Quantity.intValue() + ' / DIV: ' + oli.Liefermenge__c.intValue()/oli.Quantity.intValue() +  ' // Gesamtpreis_netto: ' + oli.Gesamtpreis_netto__c + ' // sign,vksign: ' + sign + ' ,' + vksign);
				rp.GNP212__c=oli.Gesamtpreis_netto__c*(oli.Liefermenge__c.intValue()*faktor/(oli.Quantity.intValue()))*sign*vksign/faktor;
				//SystemSettings.logError('GNP: '+ rp.GNP212__c);
					
				rp.MWST_Betrag__c=oli.isMWST__c==0?0:((oli.Liefermenge__c.intValue()*faktor/(oli.Quantity.intValue()))*(oli.TotalPrice-oli.Gesamtpreis_netto__c)*sign*vksign)/faktor;
					
				if (rechnungmap.containsKey(oli.OpportunityId)) rp.REN212__c=rechnungmap.get(oli.OpportunityId).Id;
				// rp.RPN212__c=		// TODO Rechnungspositionsnummer
				// rp.STA212__c=		// TODO Status
				if (!rechnungpostenmap.containsKey(oli.id)) rechnungpostenmap.put(oli.id, rp);
				// Rabattposition
				if (oli.Betrag_Rabatt__c!=null && oli.Betrag_Rabatt__c!=0) {
					RechnungPosten__c rprabatt=new RechnungPosten__c();
					rprabatt.Artikel__c=Id.valueOf(oli.Product2Id__c);
					rprabatt.GEM212__c=sign*oli.Liefermenge__c;
					rprabatt.ZUA212__c='PA';
					rprabatt.GNP212__c=(oli.Liefermenge__c.intValue()/oli.Quantity.intValue())*oli.Betrag_Rabatt_netto__c*(-1)*sign*vksign; 
					rprabatt.VKP212__c=(oli.Liefermenge__c.intValue()/oli.Quantity.intValue())*oli.Betrag_Rabatt__c*(-1)*sign*vksign;
					rprabatt.LZN212__c=oli.SCHL2D__c;
					//rp.LZN212__c=oli.SCHL2D__c;
					rprabatt.LMG212__c=sign*oli.FRME2D__c;
					rprabatt.OpportunityLineItemId__c=oli.id;
					//rp.VKP212__c=oli.TotalPrice; // TODO Abschlagskennzeichen??? / TODO Beleg_Gesamtpreis
					if (rechnungmap.containsKey(oli.OpportunityId)) rprabatt.REN212__c=rechnungmap.get(oli.OpportunityId).Id;
					// rp.RPN212__c=		// TODO Rechnungspositionsnummer
					// rp.STA212__c=		// TODO Status
					if (!rabatterpmap.containsKey(oli.id)) rabatterpmap.put(oli.id, rprabatt);
				}
			} else {
				// now we have a "Rabattgutschrift"
				RechnungPosten__c rprabatt=new RechnungPosten__c();
				rprabatt.Artikel__c=Id.valueOf(oli.Product2Id__c);
				rprabatt.GEM212__c=sign*oli.Liefermenge__c;
				rprabatt.ZUA212__c='PA';
				rprabatt.GNP212__c=oli.UnitPrice*sign*oli.Quantity*vksign*(-1); // TODO Beleg Rabatt!!
				//rp.LZN212__c=oli.SCHL2D__c;
				rprabatt.LMG212__c=sign*oli.FRME2D__c;
				rprabatt.OpportunityLineItemId__c=oli.id;
				rprabatt.LZN212__c=oli.SCHL2D__c;
				rprabatt.VKP212__c=0; // wird explizit auf 0 gesetzt, damit nicht null!
				//rp.VKP212__c=oli.TotalPrice; // TODO Abschlagskennzeichen??? / TODO Beleg_Gesamtpreis
				if (rechnungmap.containsKey(oli.OpportunityId)) rprabatt.REN212__c=rechnungmap.get(oli.OpportunityId).Id;
				// rp.RPN212__c=		// TODO Rechnungspositionsnummer
				// rp.STA212__c=		// TODO Status
				if (!rabatterpmap.containsKey(oli.id)) rabatterpmap.put(oli.id, rprabatt);
			}
		}
	}
	
	private static void setAuftraegeFakturaStatus() {
		if (!auftraege.isEmpty()) {
			// preset for "Vollständig Fakturiert" if an Opp does not earn this state we will change it later
			for (Id oliid: aposten.keySet()) {
				auftraege.get(aposten.get(oliid).OpportunityId).StageName='Vollständig Fakturiert';
				auftraege.get(aposten.get(oliid).OpportunityId).Probability=100;
				auftraege.get(aposten.get(oliid).OpportunityId).ForecastCategoryName='Closed';
			}
			for (Id oliid: aposten.keySet()) {
				// if any of the lineitems has an other State than "Fakturiert" or "Ausgelassen" or "Gelöscht" we have a part delivery
				if (aposten.get(oliid).OppRechnungsart__c!=2 && aposten.get(oliid).STAT2D__c==null 
						|| (
						aposten.get(oliid).STAT2D__c!='Fakturiert' 
						&& aposten.get(oliid).STAT2D__c!='Ausgelassen'
						&& aposten.get(oliid).STAT2D__c!='Gelöscht'
						)
					) 
					auftraege.get(aposten.get(oliid).OpportunityId).StageName='Teillieferung';
					auftraege.get(aposten.get(oliid).OpportunityId).Probability=90;
					auftraege.get(aposten.get(oliid).OpportunityId).ForecastCategoryName='Commit';
			}
			for (Id oppid: auftraege.keySet()) {
				if (auftraege.get(oppid).Zahl_der_Fakturierungen__c==null) auftraege.get(oppid).Zahl_der_Fakturierungen__c=0;
				if (rechnungmap.containsKey(oppid)) auftraege.get(oppid).Zahl_der_Fakturierungen__c+=1;
				// we need to be sure that this at least gets to 1
				if (auftraege.get(oppid).Zahl_der_Fakturierungen__c==0) auftraege.get(oppid).Zahl_der_Fakturierungen__c=1;
				// set letzte rechnung in opp
				if (!rechnungmap.isEmpty() && rechnungmap.containsKey(oppid)) auftraege.get(oppid).Letzte_Rechnung__c=rechnungmap.get(oppid).Id;
				// Fakturierung einer umgewandelten Vorausrechnung
				//if (auftraege.get(oppid).REAR2A__c==3 && auftraege.get(oppid).RechnungsartVorUmwandlung__c!=null) auftraege.get(oppid).Conga_Workflow_for_activation__c=true;
			}
			// just to be sure!
			for (Id oppid: auftraege.keySet()) {
				if (auftraege.get(oppid).StageName=='Vollständig Fakturiert') {
					auftraege.get(oppid).Probability=100;
					auftraege.get(oppid).ForecastCategoryName='Closed';
				}
			}
		}
	}
	
	private static void setAuftragspostenFakturaStatus() {
		if (!aposten.isEmpty()) {
			for (Id oliid: aposten.keySet()) {
				if (aposten.get(oliid).GELM2D__c==null) aposten.get(oliid).GELM2D__c=0;
				aposten.get(oliid).FRME2D__c=0;
				if (aposten.get(oliid).STAT2D__c=='Freigabe') {
					aposten.get(oliid).STAT2D__c='Fakturiert';
					if (aposten.get(oliid).STAT2D__c=='Freigabe'
							&& aposten.get(oliid).OppTeillieferung__c==1
							&& !aposten.get(oliid).Sperrkz__c 
							&& aposten.get(oliid).Lizenzmenge__c!=aposten.get(oliid).GELM2D__c
							&& aposten.get(oliid).Produkttyp__c=='Signatur'
							&& SystemSettings.Lagerabgang.contains(aposten.get(oliid).OppRechnungsArt__c.intValue())) {
						aposten.get(oliid).STAT2D__c='Rückstellung';
					}
					if (aposten.get(oliid).Fremdvertrieb__c!=null) aposten.get(oliid).STAT2D__c='Ausgelassen';
					if (aposten.get(oliid).Sperrkz__c && aposten.get(oliid).OppRechnungsArt__c!=3) aposten.get(oliid).STAT2D__c='Rückstellung';
				}
				if (aposten.get(oliid).STAT2D__c=='Rückstellung') {
					// if we really have a part-delivery then we need to change the state of the opp
					auftraege.get(aposten.get(oliid).OpportunityId).StageName='Teillieferung';
					auftraege.get(aposten.get(oliid).OpportunityId).Probability=90;
					auftraege.get(aposten.get(oliid).OpportunityId).ForecastCategoryName='Commit';
				}
			}
		}
	}
	
	//// Umsatz Absatz
	private static void umsatz() {
		// we have to update the umsatzzahlen of each artikel that has a invoice or similar
		// UMGS01__c, UMLJ01__c, UMMO01__c
		if (!artikel.isEmpty() && !aposten.isEmpty()) {
			for (OpportunityLineItem oli: aposten.values()) {
				Id oliProductId=oli.Product2Id__c;
				if (oli.Produkttyp__c=='Signatur' && (SystemSettings.DebHaben.contains(oli.OppRechnungsart__c.intValue())
					||  SystemSettings.DebSoll.contains(oli.OppRechnungsart__c.intValue())
					)) {
					Double sign=SystemSettings.DebHaben.contains(oli.OppRechnungsart__c.intValue())?-1:1;
					if (artikel.containsKey(oliProductId)) {
						if (artikel.get(oliProductId).UMLJ01__c==null) artikel.get(oliProductId).UMLJ01__c=0;
						if (artikel.get(oliProductId).UMGS01__c==null) artikel.get(oliProductId).UMGS01__c=0;
						if (artikel.get(oliProductId).UMMO01__c==null) artikel.get(oliProductId).UMMO01__c=0;
						artikel.get(oliProductId).UMLJ01__c+=oli.Liefermenge__c*sign*(oli.Gesamtpreis_netto__c/oli.quantity);
						artikel.get(oliProductId).UMGS01__c+=oli.Liefermenge__c*sign*(oli.Gesamtpreis_netto__c/oli.quantity);
						artikel.get(oliProductId).UMMO01__c+=oli.Liefermenge__c*sign*(oli.Gesamtpreis_netto__c/oli.quantity);
					}
				}
			}
		}
	}
	
	private static void absatz() {
		// we have to update the absatzzahlen of each artikel that has a stock movement
		// ABLJ01__c, ABMO01__c, ABGS01__c
		if (!artikel.isEmpty() && !aposten.isEmpty()) {
			for (OpportunityLineItem oli: aposten.values()) {
				Id oliProductId=oli.Product2Id__c;
				if (oli.Produkttyp__c=='Signatur' && (SystemSettings.Lagerzugang.contains(oli.OppRechnungsart__c.intValue())
					||  SystemSettings.Lagerabgang.contains(oli.OppRechnungsart__c.intValue())
					)) {
					Double sign=SystemSettings.Lagerzugang.contains(oli.OppRechnungsart__c.intValue())?-1:1;
					if (artikel.containsKey(oliProductId)) {
						if (artikel.get(oliProductId).ABMO01__c==null) artikel.get(oliProductId).ABMO01__c=0;
						if (artikel.get(oliProductId).ABGS01__c==null) artikel.get(oliProductId).ABGS01__c=0;
						if (artikel.get(oliProductId).ABLJ01__c==null) artikel.get(oliProductId).ABLJ01__c=0;
						artikel.get(oliProductId).ABMO01__c+=oli.Liefermenge__c*sign*oli.AbsatzMengeDerLizenz__c;
						artikel.get(oliProductId).ABGS01__c+=oli.Liefermenge__c*sign*oli.AbsatzMengeDerLizenz__c;
						artikel.get(oliProductId).ABLJ01__c+=oli.Liefermenge__c*sign*oli.AbsatzMengeDerLizenz__c;
					}
				}
			}			
		}
	}
	
	private static void umsatzAccounts() {
		if (!aposten.isEmpty() && !accounts.isEmpty() && !rechnungpostenmap.isEmpty()) {
			for (OpportunityLineItem oli: aposten.values()) {
				if (oli.Produkttyp__c=='Signatur' && (SystemSettings.DebHaben.contains(oli.OppRechnungsart__c.intValue())
					||  SystemSettings.DebSoll.contains(oli.OppRechnungsart__c.intValue())
					)) {
					if (rechnungpostenmap.containsKey(oli.id) && accounts.containsKey(oli.OppWarenempf_nger__c)) 
						accounts.get(Id.valueOf(oli.OppWarenempf_nger__c)).UMLJ02__c+=rechnungpostenmap.get(oli.id).ZUA212__c==null?rechnungpostenmap.get(oli.id).GNP212__c:0;
				
				}
			}
		}
	}
	
	//// Updates and Inserts ////
	private static Boolean updateAuftraege() {
		if (!auftraege.isEmpty() 
			) {
			try {
				update auftraege.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	private static Boolean updateAuftragsposten() {
		if (!aposten.isEmpty() 
			) {
			list<OpportunityLineItem> ol = new list<OpportunityLineItem>();
			for (OpportunityLineItem oli: aposten.values()) {
				if (oli.StatusPosition__c<3)
					ol.add(oli);
			}
			try {
				onOpportunityLineItem.doNotRun=true;
				update ol;
				onOpportunityLineItem.doNotRun=false;
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	private static Boolean updateArtikelFaktura() {
		if (!artikel.isEmpty()) {
			try {
				onProduct.inFutureContextStoredId='true';
				MediathekSammelnummer.createMedienpaketLizenzenOnce=true;
				update artikel.values();
				MediathekSammelnummer.createMedienpaketLizenzenOnce=false;
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;	
	}
	
	private static Boolean updateArtikelAbsatzUmsatz() {
		if (!artikel.isEmpty()) {
			try {
				onProduct.inFutureContextStoredId='true';
				MediathekSammelnummer.createMedienpaketLizenzenOnce=true;
				update artikel.values();
				MediathekSammelnummer.createMedienpaketLizenzenOnce=false;
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;	
	}
	
	
	// private static Boolean updateAuftragsposten() {
	//	if (!aposten.isEmpty() 
	//		) {
	//		list<OpportunityLineItem> ol = new list<OpportunityLineItem>();
	//		for (OpportunityLineItem oli: aposten.values()) {
	//			if (oli.StatusPosition__c<3)
	//				ol.add(oli);
	//		}
	//		try {
	//			update ol;
	//		} catch (System.Dmlexception e) {
	//			SystemSettings.logError(e.getMessage(),'DEBUG');
	//			//if (SystemSettings.isDebug) throw e;
	//			return true;
	//		}
	//	}
	//	return false;
	//}
	
	
	private static Boolean insertInvoices() {
		if (!rechnungmap.isEmpty()) {
			try {
				insert rechnungmap.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	private static Boolean insertInvoiceItems() {
		if (!rechnungpostenmap.isEmpty()) {
			try {
				insert rechnungpostenmap.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		if (!rabatterpmap.isEmpty()) {
			try {
				insert rabatterpmap.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	private static Boolean updateAccounts() {
		if (!accounts.isEmpty()) {
			try {
				update accounts.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	*/
}