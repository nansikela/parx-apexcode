global class OpportunityStockAndInvoicing {

	static final set<String> KO_VKP = new set<String>{'KO','K1','K2'};

	static map<Id, OpportunityLineItem> opportunitylineitems = new map<Id, OpportunityLineItem>();
	private static map<Id, String> opportunitylineitems_orig = new map<Id, String>();
	private static map<Id, Opportunity> newopps = new map<Id, Opportunity>();

	static set<Id> oppids = new set<Id>();
	
	private static map<Id, Product2> products=new map<Id, Product2>();
	private static map<Id, RechnungPosten__c> invoiceitems;
	private static map<Id, RechnungPosten__c> discountinvoiceitems;
	
	private static map<Id, Account> accounts = new map<Id, Account>();
	//private static map<Id, OpportunityLineItem> oppli = new map<Id, OpportunityLineItem>();

	private static OpportunityStockAndInvoicingHelper.globalwrapper oppsandinvoices=new OpportunityStockAndInvoicingHelper.globalwrapper();
	
	static final String oppwherecond=' StageNamePosition__c!=0 AND LFKZ2A__c=false AND (Opportunity.Zahlerkennzeichen__c<>\'S\' OR (Zahlerkennzeichen__c=\'S\' AND RA_Lagerabgang__c=1))';
	// StageNamePosition__c!=4 AND 
	static final String oppwhereorder=' ORDER BY WE_Kundennummer__c';
	
	private static String errormsg='';
	
	public static OpportunityStockAndInvoicingHelper.globalwrapper Run(list<sObject> olis, OpportunityStockAndInvoicingHelper.globalwrapper globaloppsandinvoices) {
		oppsandinvoices=globaloppsandinvoices;
		if (oppsandinvoices==null) oppsandinvoices=new OpportunityStockAndInvoicingHelper.globalwrapper();
		
		if (!olis.isEmpty()) {
			for (sObject s: olis) {
				OpportunityLineItem oli=(OpportunityLineItem)s;
				if (!opportunitylineitems.containsKey(oli.id)) opportunitylineitems.put(oli.id, oli);
				if (!oppids.contains(oli.OpportunityId)) oppids.add(oli.OpportunityId);
			}
		}
		system.debug('Size of oppids: '+ oppids.size());
		getKOLOpportunityLineItems();
		// to free memory
		olis.clear();
		run();
		return oppsandinvoices;
	}
	
	public static OpportunityStockAndInvoicingHelper.globalwrapper OppsRun(map<id, Opportunity> opps) {
		// we need to select the lineitems
		if (!opps.isEmpty()) {
			String localoliwherecond=' StatusPosition__c<3 AND Opportunity.StageNamePosition__c!=0 AND Opportunity.LFKZ2A__c=false AND (Opportunity.Zahlerkennzeichen__c<>\'S\' OR (Opportunity.Zahlerkennzeichen__c=\'S\' AND Opportunity.RA_Lagerabgang__c=1))';
			// AND Opportunity.StageNamePosition__c!=4 
			// (((KreisListe__c<>\'\' AND KreisListe__c<>null) AND medienart_id__c=\'55\') OR ((medienart_55__c==null OR medienart_55__c==\'\') AND MedSig1Prod__c=\'46\'))) AND
			String localoliwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c';
			String query='SELECT ';
			query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + 'OpportunityId IN ' + getIdListString(opps.keySet()) + localoliwhereorder;
			for (SObject soli: Database.query(query)) {
				system.debug('Has kol olis ...');
				OpportunityLineItem oli=(OpportunityLineItem)soli;
				if (!opportunitylineitems.containsKey(oli.id)) opportunitylineitems.put(oli.id, oli);
				if (!oppids.contains(oli.OpportunityId)) oppids.add(oli.OpportunityId);
			}
		}
		run();
		return oppsandinvoices;
	}
	
	private static void run() {
		//Savepoint startrun = database.setSavepoint();
		getMissingOpportunities();
		
		if (!oppsandinvoices.opportunities.isEmpty() && !locked() && unlockOpportunities() ) {
			saveOldInformation(); // save the old number of facturations
			updateOpportunityLineItems(); // set Liefermenge to 0
			collectProducts();
			freeStockQuantity();
			invoicing();
			accounts = new map<Id, Account>();
			sales(); 
			turnover();
			updateProducts();
			collectAccounts();
			salesAccounts();
			updateAccounts();
			//if (!lockOpportunities()) database.rollback(startrun);
		}
		// extended error handling
		if (errormsg!='') {
			String oppnumbers='';
			set<Id> recentoppids = new set<Id>();
			for (OpportunityLineItem oli:opportunitylineitems.values()) {
				if (!recentoppids.contains(oli.OpportunityId)) recentoppids.add(oli.OpportunityId);
			}
			for (Id oppid:recentoppids) {
				if (oppsandinvoices.opportunities.containsKey(oppid)) oppnumbers=oppnumbers==''?'':', ' + oppsandinvoices.opportunities.get(oppid).Name;
			}
			systemsettings.sendInformationalEmailToUser('Freigabe/Faktura','Fehler bei Freigabe oder Fakturierung der Aufträge ' + oppnumbers + ', bitte versuchen Sie es später erneut!');
		}
		SystemSettings.insertErrors();
	}

	private static void salesAccounts() {
		System.debug('opportunitylineitems size: ' + opportunitylineitems.size() + ' / accounts.size: ' + accounts.size() + ' / invoiceitems.size: ' + invoiceitems.size());
		if (!opportunitylineitems.isEmpty() && !accounts.isEmpty() && !invoiceitems.isEmpty()) {
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				if (oli.Produkttyp__c=='Signatur' && (SystemSettings.DebHaben.contains(oli.OppRechnungsart__c.intValue())
					||  SystemSettings.DebSoll.contains(oli.OppRechnungsart__c.intValue())
					)) {
					if (invoiceitems.containsKey(oli.id) && accounts.containsKey(oli.OppWarenempf_nger__c)) 
						accounts.get(Id.valueOf(oli.OppWarenempf_nger__c)).UMLJ02__c+=invoiceitems.get(oli.id).ZUA212__c==null?invoiceitems.get(oli.id).GNP212__c:0;
				
				}
			}
		}
	}
	
	private static void saveOldInformation() {
		for (Opportunity o: newopps.values()) {
			if (!oppsandinvoices.opportunitiesNoFak.containsKey(o.id)) oppsandinvoices.opportunitiesNoFak.put(o.id, o.Zahl_der_Fakturierungen__c==null?0.0:o.Zahl_der_Fakturierungen__c);
		}
	}
	
	//// Umsatz Absatz
	private static void sales() {
		// we have to update the umsatzzahlen of each artikel that has a invoice or similar
		// UMGS01__c, UMLJ01__c, UMMO01__c
		if (!products.isEmpty() && !opportunitylineitems.isEmpty()) {
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				Id oliProductId=oli.Product2Id__c;
				if (oli.Produkttyp__c=='Signatur' && (SystemSettings.DebHaben.contains(oli.OppRechnungsart__c.intValue())
					||  SystemSettings.DebSoll.contains(oli.OppRechnungsart__c.intValue())
					)) {
					Double sign=SystemSettings.DebHaben.contains(oli.OppRechnungsart__c.intValue())?-1:1;
					if (products.containsKey(oliProductId)) {
						if (products.get(oliProductId).UMLJ01__c==null) products.get(oliProductId).UMLJ01__c=0;
						if (products.get(oliProductId).UMGS01__c==null) products.get(oliProductId).UMGS01__c=0;
						if (products.get(oliProductId).UMMO01__c==null) products.get(oliProductId).UMMO01__c=0;
						products.get(oliProductId).UMLJ01__c+=oli.Liefermenge__c*sign*(oli.Gesamtpreis_netto__c/oli.quantity);
						products.get(oliProductId).UMGS01__c+=oli.Liefermenge__c*sign*(oli.Gesamtpreis_netto__c/oli.quantity);
						products.get(oliProductId).UMMO01__c+=oli.Liefermenge__c*sign*(oli.Gesamtpreis_netto__c/oli.quantity);
					}
				}
			}
		}
	}
	
	private static void turnover() {
		// we have to update the absatzzahlen of each artikel that has a stock movement
		// ABLJ01__c, ABMO01__c, ABGS01__c
		if (!products.isEmpty() && !opportunitylineitems.isEmpty()) {
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				Id oliProductId=oli.Product2Id__c;
				if (oli.Produkttyp__c=='Signatur' && (SystemSettings.Lagerzugang.contains(oli.OppRechnungsart__c.intValue())
					||  SystemSettings.Lagerabgang.contains(oli.OppRechnungsart__c.intValue())
					)) {
					Double sign=SystemSettings.Lagerzugang.contains(oli.OppRechnungsart__c.intValue())?-1:1;
					if (products.containsKey(oliProductId)) {
						if (products.get(oliProductId).ABMO01__c==null) products.get(oliProductId).ABMO01__c=0;
						if (products.get(oliProductId).ABGS01__c==null) products.get(oliProductId).ABGS01__c=0;
						if (products.get(oliProductId).ABLJ01__c==null) products.get(oliProductId).ABLJ01__c=0;
						products.get(oliProductId).ABMO01__c+=oli.Liefermenge__c*sign*oli.AbsatzMengeDerLizenz__c;
						products.get(oliProductId).ABGS01__c+=oli.Liefermenge__c*sign*oli.AbsatzMengeDerLizenz__c;
						products.get(oliProductId).ABLJ01__c+=oli.Liefermenge__c*sign*oli.AbsatzMengeDerLizenz__c;
					}
				}
			}			
		}
	}
	
	// Bestandspruefung
	// Status auf Auftrag
	private static void freeStockQuantity() {
		Savepoint free1 = database.setSavepoint();
		Boolean hasError=false;
		if (!oppsandinvoices.opportunities.isEmpty() && !opportunitylineitems.isEmpty() && !products.isEmpty()) {
			opportunitylineitems_orig=getOldOliStatus();
			setAvailableQuantity();
			setStockIn();
			setStockOut();
			KOLspecialcheck();
			setOpportunitylineitemsDeliverdQuantity();
		}
		
		hasError=updateOpportunitylineitemsWithInvoicing();
		if (hasError && !SystemSettings.isDebug) database.rollback(free1);
		else {
			//for (Id oid: oppsandinvoices.opportunities.keySet()) {
			for (OpportunityLineItem oli:opportunitylineitems.values()) {
				if (oppsandinvoices.opportunities.get(oli.OpportunityId).StageName!='Teillieferung' && oppsandinvoices.opportunities.get(oli.OpportunityId).StageName!='Gelöscht' ) oppsandinvoices.opportunities.get(oli.OpportunityId).StageName='Freigabe / Fakturierung';
			}
			hasError=updateOpportunities();
		} 
		if (hasError && !SystemSettings.isDebug) 
			database.rollback(free1);
		if (hasError) SystemSettings.logError('Freigabe HasError: ' + errormsg);
		SystemSettings.insertErrors();
	}
	
	private static map<Id, String> getOldOliStatus() {
		map<Id, String> oldstat = new map<Id, String>();
		for (OpportunityLineItem oli: opportunitylineitems.values()) {
			oldstat.put(oli.id, oli.STAT2D__c);
		}
		return oldstat;
	}
	
	private static void setAvailableQuantity() {
		for (OpportunityLineItem oli: opportunitylineitems.values()) {
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
	
	private static void setStockIn() {
		for (OpportunityLineItem oli: opportunitylineitems.values()) {
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
	
	private static void setStockOut() {
		for (Id oliid: opportunitylineitems.keySet()) {
			// Lagerabgang
			if (SystemSettings.Lagerabgang.contains(opportunitylineitems.get(oliid).OppRechnungsArt__c.intValue())) {
				opportunitylineitems.get(oliid).FRME2D__c=0;
				Id ProductId=opportunitylineitems.get(oliid).Product2Id__c;
				if (opportunitylineitems.get(oliid).STAT2D__c!='Freigabe'  && opportunitylineitems.get(oliid).STAT2D__c!='Fakturiert' && opportunitylineitems.get(oliid).STAT2D__c!='Gelöscht' && opportunitylineitems.get(oliid).STAT2D__c!='Ausgelassen'
					&& products.get(ProductId).PDKZ01__c<8
					&& products.get(ProductId).PDKZ01__c>=4
					&& opportunitylineitems.get(oliid).Produkttyp__c=='Signatur'
					&& !opportunitylineitems.get(oliid).Sperrkz__c
					&& opportunitylineitems.get(oliid).Fremdvertrieb__c==null
					) {
					// SystemSettings.logError('Kalkulierter freigebbarer Bestand: ' + getFreigebbarerBestand(artikel.get(aposten.get(oliid).Product2Id__c),aposten.get(oliid)));
					//SystemSettings.logError('Kalkulierter freigebbarer Bestand: ' + getFreigebbarerBestand(artikel.get(aposten.get(oliid).Product2Id__c),aposten.get(oliid)));
		
					opportunitylineitems.get(oliid).FRME2D__c=getFreeStockQuantity(products.get(ProductId),opportunitylineitems.get(oliid));
					opportunitylineitems.get(oliid).STAT2D__c='Freigabe';
					if (getFreeStockQuantity(products.get(ProductId),opportunitylineitems.get(oliid))==0
							|| 
							(opportunitylineitems.get(oliid).OppTeillieferung__c==0 
							&& getFreeStockQuantity(products.get(ProductId),opportunitylineitems.get(oliid))<opportunitylineitems.get(oliid).Lizenzmenge__c)
							) {
						opportunitylineitems.get(oliid).STAT2D__c='Rückstellung';
						opportunitylineitems.get(oliid).FRME2D__c=0;
					}
				
				} else if (opportunitylineitems.get(oliid).Produkttyp__c=='Signatur' && 
							(products.get(ProductId).PDKZ01__c>=8 || 
							 products.get(ProductId).PDKZ01__c<4 || 
							 opportunitylineitems.get(oliid).Sperrkz__c) && 
							 opportunitylineitems.get(oliid).STAT2D__c!='Fakturiert' && 
							 opportunitylineitems.get(oliid).STAT2D__c!='Gelöscht' && 
							 opportunitylineitems.get(oliid).STAT2D__c!='Ausgelassen') {
					opportunitylineitems.get(oliid).STAT2D__c='';
					if (products.get(ProductId).PDKZ01__c>=8) 
						opportunitylineitems.get(oliid).Sperrkz__c=true;
					
				} else if (opportunitylineitems.get(oliid).STAT2D__c!='Fakturiert' && opportunitylineitems.get(oliid).STAT2D__c!='Gelöscht' && opportunitylineitems.get(oliid).STAT2D__c!='Ausgelassen') {
					opportunitylineitems.get(oliid).STAT2D__c='Freigabe';
					opportunitylineitems.get(oliid).FRME2D__c=opportunitylineitems.get(oliid).Lizenzmenge__c;
				} 
				if (opportunitylineitems.get(oliid).Fremdvertrieb__c!=null && opportunitylineitems.get(oliid).STAT2D__c!='Fakturiert' && opportunitylineitems.get(oliid).STAT2D__c!='Gelöscht' && opportunitylineitems.get(oliid).STAT2D__c!='Ausgelassen') {
					opportunitylineitems.get(oliid).FRME2D__c=opportunitylineitems.get(oliid).Lizenzmenge__c;
					opportunitylineitems.get(oliid).STAT2D__c='Ausgelassen';
				}
				if (opportunitylineitems.get(oliid).Produkttyp__c=='Andere' && opportunitylineitems.get(oliid).STAT2D__c!='Fakturiert' && opportunitylineitems.get(oliid).STAT2D__c!='Gelöscht' && opportunitylineitems.get(oliid).STAT2D__c!='Ausgelassen') {
					opportunitylineitems.get(oliid).STAT2D__c='Freigabe';
					opportunitylineitems.get(oliid).FRME2D__c=opportunitylineitems.get(oliid).Quantity;
				}
			}
		}
	}
	
	private static Double getFreeStockQuantity(Product2 p, OpportunityLineItem oli) {
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
	
	private static void setOpportunitylineitemsDeliverdQuantity() {
		if (!opportunitylineitems.isEmpty() && !products.isEmpty()) {
			for (Id oliid:opportunitylineitems.keySet()) {
				// delivery only for real signatures and not for items already in Freigabe
				if (opportunitylineitems_orig.get(oliid)!='Freigabe' 
					&& SystemSettings.Lagerabgang.contains(opportunitylineitems.get(oliid).OppRechnungsArt__c.intValue()) 
					&& opportunitylineitems.get(oliid).Produkttyp__c=='Signatur') { 
					if (opportunitylineitems.get(oliid).Liefermenge__c==null) opportunitylineitems.get(oliid).Liefermenge__c=0;
					if (opportunitylineitems.get(oliid).GELM2D__c==null) opportunitylineitems.get(oliid).GELM2D__c=0;
					if (opportunitylineitems.get(oliid).FRME2D__c!=null 
							&& opportunitylineitems.get(oliid).FRME2D__c>0
							&& opportunitylineitems.get(oliid).Fremdvertrieb__c==null
							&& SystemSettings.Lagerabgang.contains(opportunitylineitems.get(oliid).OppRechnungsart__c.intValue())) {
						opportunitylineitems.get(oliid).GELM2D__c+=opportunitylineitems.get(oliid).FRME2D__c;
						opportunitylineitems.get(oliid).Liefermenge__c=opportunitylineitems.get(oliid).FRME2D__c/opportunitylineitems.get(oliid).AbsatzMengeDerLizenz__c;
					}
				}
				if (opportunitylineitems_orig.get(oliid)!='Freigabe' && opportunitylineitems.get(oliid).Produkttyp__c=='Andere') opportunitylineitems.get(oliid).Liefermenge__c=opportunitylineitems.get(oliid).FRME2D__c;
			}
		}
	}
	
	// this is a little bit tricky, we need to know the values of any assigned oli medium 46 -> 55 as well
	// by running in batches of lineitems, we don't have all olis of each opportunity
	// in this special case we need to select the missing olis as well and we need to run freeStockQuantity on them bevor we check this
	//
	// Implementation of new Kreisonline K1/K2 - AK behaves as KO here!
	// we need to controll the delivery by using the new licenses in KOL_Lizenzen
	private static void KOLspecialcheck() {
		map<Id, map<Id, OpportunityLineItem>> olimap = new map<Id, map<Id, OpportunityLineItem>>();
		if (!opportunitylineitems.isEmpty()) {
			for (OpportunityLineItem oli46: opportunitylineitems.values()) {
				if (oli46.Verkaufsprogramm__c=='AK') {
					ID oli46medienart55ID=oli46.medienart_55__c;
					//SystemSettings.logError('String medienart_55__c: ' + oli46.medienart_55__c + ' versus Id oli46medienart55ID: ' + oli46medienart55ID);
					System.debug('String medienart_55__c: ' + oli46.medienart_55__c + ' versus Id oli46medienart55ID: ' + oli46medienart55ID);
					if (oli46.StatusPosition__c<3) {
						if (!olimap.containsKey(oli46.OpportunityId)) olimap.put(oli46.OpportunityId, new map<Id, OpportunityLineItem>());
						if (oli46.medienart_55__c!=null && oli46.medienart_55__c!='' && oli46.medienart_id__c=='46' && !olimap.get(oli46.OpportunityId).containsKey(oli46medienart55ID)) {
							for (OpportunityLineItem oli55: opportunitylineitems.values()) {
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
		}	
		for (Id oliid: opportunitylineitems.keySet()) {
			if (opportunitylineitems.get(oliid).Verkaufsprogramm__c=='AK') {
				if (opportunitylineitems.get(oliid).FRME2D__c==null) 
					opportunitylineitems.get(oliid).FRME2D__c=0;
				ID oli46medienart55ID=opportunitylineitems.get(oliid).medienart_55__c;
				if (olimap.containsKey(opportunitylineitems.get(oliid).OpportunityId) && olimap.get(opportunitylineitems.get(oliid).OpportunityId).containsKey(oli46medienart55ID) && olimap.get(opportunitylineitems.get(oliid).OpportunityId).get(oli46medienart55ID).FRME2D__c==null) 
					opportunitylineitems.get(olimap.get(opportunitylineitems.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c=0; 
				// voraussetzungen ko (nicht nur das Verkaufsprogramm, sondern generell die Lizenzart), oli für 46 mit ref zu 55
				//SystemSettings.logError('Constraints for KOLCheck-olimap contains 55er Id: ' + olimap.get(aposten.get(oliid).OpportunityId).containsKey(oli46medienart55ID));
				//SystemSettings.logError('Constraints for KOLCheck-olimap 55er is 10206: ' + olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).Lizenznummer__c);
				if (KOL_Lizenzen().contains(opportunitylineitems.get(oliid).Lizenznummer__c)
						&& SystemSettings.Lagerabgang.contains(opportunitylineitems.get(oliid).OppRechnungsArt__c.intValue())
						&& opportunitylineitems.get(oliid).medienart_id__c=='46'
						&& opportunitylineitems.get(oliid).medienart_55__c!=null
						&& opportunitylineitems.get(oliid).medienart_55__c!=''
						&& opportunitylineitems.get(oliid).StatusPosition__c<3
						&& olimap.get(opportunitylineitems.get(oliid).OpportunityId).containsKey(oli46medienart55ID)
						&& KOL_Lizenzen().contains(olimap.get(opportunitylineitems.get(oliid).OpportunityId).get(oli46medienart55ID).Lizenznummer__c)
						//&& !aposten.get(oliid).Sperrkz__c
						 ) {
	
					// fehler, falls sich die freigebbare menge in bezug auf die quantity unterscheidet
					// --> freigebbare mengen jeweils 0 
					// --> Status jeweils Rückstellung
					// --> artikel bestand und reservierung rückgängig
					//SystemSettings.logError('Found 46er with FRME2D '+ aposten.get(oliid).FRME2D__c + ' / 46 Id: ' + aposten.get(oliid).Id );
					if (opportunitylineitems.get(oliid).FRME2D__c/opportunitylineitems.get(oliid).Lizenzmenge__c!=
								opportunitylineitems.get(olimap.get(opportunitylineitems.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c/opportunitylineitems.get(olimap.get(opportunitylineitems.get(oliid).OpportunityId).get(oli46medienart55ID).id).Lizenzmenge__c) {
						//SystemSettings.logError('55er with FRME2D '+ aposten.get(olimap.get(aposten.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c + ' / 55er Id: ' + oli46medienart55ID );
						opportunitylineitems.get(oliid).STAT2D__c='Rückstellung';
						opportunitylineitems.get(oliid).FRME2D__c=0;
						opportunitylineitems.get(olimap.get(opportunitylineitems.get(oliid).OpportunityId).get(oli46medienart55ID).id).STAT2D__c='Rückstellung';
						opportunitylineitems.get(olimap.get(opportunitylineitems.get(oliid).OpportunityId).get(oli46medienart55ID).id).FRME2D__c=0;
					}
				}
			}
		}
		
		if (!opportunitylineitems.isEmpty()) {
			map<Id, OpportunityLineItem> koolis = new map<Id, OpportunityLineItem>();
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				if (KO_VKP.contains(oli.Verkaufsprogramm__c))
					koolis.put(oli.id, oli);
			}
			// with new class this should be much easier
			KreisOnlinePackage kopkgs = new KreisOnlinePackage(koolis);
			
			// first of all we update the olis with the current information
			for (OpportunityLineItem oli: koolis.values()) {
				if (kopkgs.getKOpkgById(oli.id)!=null)
					kopkgs.getKOpkgById(oli.id).updateOli(oli);
			}
			for (OpportunityLineItem oli: koolis.values()) {
				if (kopkgs.getKOpkgById(oli.id)!=null && !kopkgs.getKOpkgById(oli.id).isDeliverable()) {	
					for (OpportunityLineItem pkgoli: kopkgs.getKOpkgById(oli.id).getOliList()) {
						opportunitylineitems.get(pkgoli.id).FRME2D__c=0;
						opportunitylineitems.get(pkgoli.id).STAT2D__c='Rückstellung';
					}
				}
			}
		}
	}
	
	// Erzeugung Rechnungsdaten und Belegdaten
	// Status auf Auftrag
	private static void invoicing() {
		Savepoint fak1 = database.setSavepoint();
		errormsg='';
		Boolean hasError=false;
		//collectAuftragspostenFaktura();
		// for all auftraege we assume that in the end they all will be fakturiert
		// if this is not the case we change the state for each opp if it is necessary
		invoiceitems = new map<Id, RechnungPosten__c>();
		discountinvoiceitems = new map<Id, RechnungPosten__c>();
		if (!oppsandinvoices.opportunities.isEmpty() && !opportunitylineitems.isEmpty() && !products.isEmpty()) {
			// the basic information lays in the auftragsposten (line items)
			setInventory();
			for (Id oliid: opportunitylineitems.keySet()) {
				// just to be sure ...
				// be aware: formular fields may have old values
				// Status "ausgelassen" for lineitem
				// this status is only necessary for "signatur" types
				// before we really set this status we should create some needed documents
				if (opportunitylineitems.get(oliid).STAT2D__c=='Freigabe' && opportunitylineitems.get(oliid).Produkttyp__c=='Signatur' && opportunitylineitems.get(oliid).OppRechnungsArt__c==2)
						opportunitylineitems.get(oliid).STAT2D__c='Ausgelassen';
				// now we create our invoices - we will have at least one item for them
				if (opportunitylineitems.get(oliid).STAT2D__c=='Freigabe' 
					&& opportunitylineitems.get(oliid).FRME2D__c!=null 
					&& opportunitylineitems.get(oliid).FRME2D__c>0) {
					// for each fakturierlauf we create only one invoice for each opp
					if (!oppsandinvoices.invoices.containsKey(opportunitylineitems.get(oliid).OpportunityId)) 
						createInvoice(oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId));
				}
			}
		}
		// update Artikel
		hasError=updateProducts();
		if (hasError && !SystemSettings.isDebug) database.rollback(fak1);
		// insertInvoices
		hasError=upsertInvoices();
		if (hasError && !SystemSettings.isDebug) {
			database.rollback(fak1);
		} else {
			// update Auftragsposten with Invoices
			if (!opportunitylineitems.isEmpty() && !oppsandinvoices.invoices.isEmpty()) {
				for (Id oliid:opportunitylineitems.keySet()) {
					if (opportunitylineitems.get(oliid).Liefermenge__c!=null && opportunitylineitems.get(oliid).Liefermenge__c>0) {
						for (Rechnung__c r: oppsandinvoices.invoices.values()) {
							if (opportunitylineitems.get(oliid).OpportunityId==r.AUN211__c) opportunitylineitems.get(oliid).Rechnung__c=r.id;
						}
					}
				}
			}
			hasError=updateOpportunitylineitemsWithInvoicing();
			if (hasError && !SystemSettings.isDebug) {
				database.rollback(fak1);
			} else {
				if (!oppsandinvoices.opportunities.isEmpty()) {
					if (!opportunitylineitems.isEmpty() && !products.isEmpty() && !oppsandinvoices.invoices.isEmpty()) {
						discountinvoiceitems = new map<Id, RechnungPosten__c>();
						invoiceitems = new map<Id, RechnungPosten__c>();
						for (Id oliid: opportunitylineitems.keySet()) {
							// lets create invoice items for auftragsposten // TODO pruefe, ob die Kriterien ok sind
							if (opportunitylineitems.get(oliid).STAT2D__c=='Freigabe'
								&& oppsandinvoices.invoices.containsKey(opportunitylineitems.get(oliid).OpportunityId) 
								&& oppsandinvoices.invoices.get(opportunitylineitems.get(oliid).OpportunityId).Id!=null) {
								createInvoiceItem(opportunitylineitems.get(oliid));
							}
						}
					}
					// insertLineItems
					hasError=insertInvoiceItems();
					if (hasError && !SystemSettings.isDebug) {
						database.rollback(fak1);
					}
					setOpportunitylineitemInvoiceStatus();
					setOpportunitiesInvoiceStatus();
					// updateAuftraege
					hasError=updateOpportunities();
					if (hasError && !SystemSettings.isDebug) {
						database.rollback(fak1);
					} else {
						hasError=updateOpportunitylineitemsWithInvoicing();
						if (hasError && !SystemSettings.isDebug) database.rollback(fak1);
					}
				}
			}
		}
		if (hasError) SystemSettings.logError('Faktura HasError: ' + errormsg);
		SystemSettings.insertErrors();
	}
	
	private static void setInventory() {
		for (OpportunityLineItem oli: opportunitylineitems.values()) {
			Id oliProductId=oli.Product2Id__c;
			if ((SystemSettings.Lagerabgang.contains(oli.OppRechnungsArt__c.intValue()) 
				|| SystemSettings.Lagerzugang.contains(oli.OppRechnungsArt__c.intValue()))
				&& oli.STAT2D__c=='Freigabe') {
				Double sign=SystemSettings.Lagerabgang.contains(oli.OppRechnungsart__c.intValue())?-1:1;
				if (oli.FRME2D__c!=null && oli.FRME2D__c>0 && oli.Produkttyp__c=='Signatur') {
					if (products.containsKey(oliProductId)) {
						if (products.get(oliProductId).RESB01__c==null) products.get(oliProductId).RESB01__c=0;
						if (products.get(oliProductId).GESB01__c==null) products.get(oliProductId).GESB01__c=0;
						if (products.get(oliProductId).AUEA01__c==null) products.get(oliProductId).AUEA01__c=0;
						products.get(oliProductId).RESB01__c+=oli.FRME2D__c*sign;
						products.get(oliProductId).GESB01__c+=oli.FRME2D__c*sign;
						products.get(oliProductId).AUEA01__c+=oli.FRME2D__c*sign;
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
			if (!oppsandinvoices.invoices.containsKey(o.id)) oppsandinvoices.invoices.put(o.id,r);
		}
	}
	
	private static void createInvoiceItem(OpportunityLineItem oli) {
		if (oli!=null && oli.id!=null && !oppsandinvoices.invoices.isEmpty() && (oli.Fremdvertrieb__c==null) && oli.Produkttyp__c!='Sammelnummer') {
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
				rp.GNP212__c=oli.Gesamtpreis_netto_f_r_Rechnung__c*(oli.Liefermenge__c.intValue()*faktor/(oli.Quantity.intValue()))*sign*vksign/faktor;
				//SystemSettings.logError('GNP: '+ rp.GNP212__c);
					
				rp.MWST_Betrag__c=oli.isMWST__c==0?0:((oli.Liefermenge__c.intValue()*faktor/(oli.Quantity.intValue()))*(oli.TotalPrice-oli.Gesamtpreis_netto_f_r_Rechnung__c)*sign*vksign)/faktor;
					
				if (oppsandinvoices.invoices.containsKey(oli.OpportunityId)) rp.REN212__c=oppsandinvoices.invoices.get(oli.OpportunityId).Id;
				// rp.RPN212__c=		// TODO Rechnungspositionsnummer
				// rp.STA212__c=		// TODO Status
				if (!invoiceitems.containsKey(oli.id)) invoiceitems.put(oli.id, rp);
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
					if (oppsandinvoices.invoices.containsKey(oli.OpportunityId)) rprabatt.REN212__c=oppsandinvoices.invoices.get(oli.OpportunityId).Id;
					// rp.RPN212__c=		// TODO Rechnungspositionsnummer
					// rp.STA212__c=		// TODO Status
					if (!discountinvoiceitems.containsKey(oli.id)) discountinvoiceitems.put(oli.id, rprabatt);
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
				if (oppsandinvoices.invoices.containsKey(oli.OpportunityId)) rprabatt.REN212__c=oppsandinvoices.invoices.get(oli.OpportunityId).Id;
				// rp.RPN212__c=		// TODO Rechnungspositionsnummer
				// rp.STA212__c=		// TODO Status
				if (!discountinvoiceitems.containsKey(oli.id)) discountinvoiceitems.put(oli.id, rprabatt);
			}
		}
	}
	
	private static void setOpportunitiesInvoiceStatus() {
		if (!oppsandinvoices.opportunities.isEmpty()) {
			// preset for "Vollständig Fakturiert" if an Opp does not earn this state we will change it later
			for (Id oliid: opportunitylineitems.keySet()) {
				if (oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).StageName!='Teillieferung') {
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).StageName='Vollständig Fakturiert';
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).Probability=100;
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).ForecastCategoryName='Closed';
				}
			}
			for (Id oliid: opportunitylineitems.keySet()) {
				// if any of the lineitems has an other State than "Fakturiert" or "Ausgelassen" or "Gelöscht" we have a part delivery
				if (opportunitylineitems.get(oliid).OppRechnungsart__c!=2 && opportunitylineitems.get(oliid).STAT2D__c==null 
						|| (
						opportunitylineitems.get(oliid).STAT2D__c!='Fakturiert' 
						&& opportunitylineitems.get(oliid).STAT2D__c!='Ausgelassen'
						&& opportunitylineitems.get(oliid).STAT2D__c!='Gelöscht'
						)
					) 
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).StageName='Teillieferung';
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).Probability=90;
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).ForecastCategoryName='Commit';
			}
			for (Id oppid: oppsandinvoices.opportunities.keySet()) {
				if (oppsandinvoices.opportunities.get(oppid).Zahl_der_Fakturierungen__c==null) oppsandinvoices.opportunities.get(oppid).Zahl_der_Fakturierungen__c=0;
				if (oppsandinvoices.invoices.containsKey(oppid)) oppsandinvoices.opportunities.get(oppid).Zahl_der_Fakturierungen__c=oppsandinvoices.opportunitiesNoFak.get(oppid)+1;
				// we need to be sure that this at least gets to 1
				if (oppsandinvoices.opportunities.get(oppid).Zahl_der_Fakturierungen__c==0) oppsandinvoices.opportunities.get(oppid).Zahl_der_Fakturierungen__c=1;
				// set letzte rechnung in opp
				if (!oppsandinvoices.invoices.isEmpty() && oppsandinvoices.invoices.containsKey(oppid)) oppsandinvoices.opportunities.get(oppid).Letzte_Rechnung__c=oppsandinvoices.invoices.get(oppid).Id;
				// Fakturierung einer umgewandelten Vorausrechnung
				//if (auftraege.get(oppid).REAR2A__c==3 && auftraege.get(oppid).RechnungsartVorUmwandlung__c!=null) auftraege.get(oppid).Conga_Workflow_for_activation__c=true;
			}
			// just to be sure!
			for (Id oppid: oppsandinvoices.opportunities.keySet()) {
				if (oppsandinvoices.opportunities.get(oppid).StageName=='Vollständig Fakturiert') {
					oppsandinvoices.opportunities.get(oppid).Probability=100;
					oppsandinvoices.opportunities.get(oppid).ForecastCategoryName='Closed';
				}
			}
		}
	}
	
	private static void setOpportunitylineitemInvoiceStatus() {
		if (!opportunitylineitems.isEmpty()) {
			for (Id oliid: opportunitylineitems.keySet()) {
				if (opportunitylineitems.get(oliid).GELM2D__c==null) opportunitylineitems.get(oliid).GELM2D__c=0;
				opportunitylineitems.get(oliid).FRME2D__c=0;
				if (opportunitylineitems.get(oliid).STAT2D__c=='Freigabe') {
					opportunitylineitems.get(oliid).STAT2D__c='Fakturiert';
					if (opportunitylineitems.get(oliid).STAT2D__c=='Freigabe'
							&& opportunitylineitems.get(oliid).OppTeillieferung__c==1
							&& !opportunitylineitems.get(oliid).Sperrkz__c 
							&& opportunitylineitems.get(oliid).Lizenzmenge__c!=opportunitylineitems.get(oliid).GELM2D__c
							&& opportunitylineitems.get(oliid).Produkttyp__c=='Signatur'
							&& SystemSettings.Lagerabgang.contains(opportunitylineitems.get(oliid).OppRechnungsArt__c.intValue())) {
						opportunitylineitems.get(oliid).STAT2D__c='Rückstellung';
					}
					if (opportunitylineitems.get(oliid).Fremdvertrieb__c!=null) opportunitylineitems.get(oliid).STAT2D__c='Ausgelassen';
					if (opportunitylineitems.get(oliid).Sperrkz__c && opportunitylineitems.get(oliid).OppRechnungsArt__c!=3) opportunitylineitems.get(oliid).STAT2D__c='Rückstellung';
				}
				if (opportunitylineitems.get(oliid).STAT2D__c=='Rückstellung') {
					// if we really have a part-delivery then we need to change the state of the opp
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).StageName='Teillieferung';
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).Probability=90;
					oppsandinvoices.opportunities.get(opportunitylineitems.get(oliid).OpportunityId).ForecastCategoryName='Commit';
				}
			}
		}
	}
	
	
	///// Collectors ////
	private static void getMissingOpportunities() {
		String query='SELECT ';
		if (getIdListString(oppids)!='')
			query+=getOppFields() + ' FROM Opportunity WHERE ' + oppwherecond + ' AND Id IN ' + getIdListString(oppids) + oppwhereorder;
		else
			query+=getOppFields() + ' FROM Opportunity WHERE ' + oppwherecond + oppwhereorder;
		if (!oppids.isEmpty()) {
			//Database.Querylocatoriterator oppdbl=Database.getQueryLocator(query).iterator();
			//while (oppdbl.hasNext()) {
			for (SObject s: Database.query(query)) {
				system.debug('Has missing opps ...');
				Opportunity o=(Opportunity)s;
				if (!oppsandinvoices.opportunities.containsKey(o.id)) {
					newopps.put(o.id, o);
				} else {
					oppsandinvoices.opportunities.remove(o.id);
				}
				o.StageName='Vollständig Fakturiert';
				o.Probability=100;
				o.ForecastCategoryName='Closed';
				oppsandinvoices.opportunities.put(o.id, o);
			}
		}
	}
	
	private static void getKOLOpportunityLineItems() {
		if (!opportunitylineitems.isEmpty()) {
			set<Id> kreislistenids = new set<Id>();
			set<Id> olioppids = new set<Id>();
			set<Id> signaturReferenceIds = new set<Id>();
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				if (oli.medienart_id__c=='46' && KOL_Lizenzen().contains(oli.Lizenznummer__c)) {
					if (!kreislistenids.contains(oli.id)) kreislistenids.add(oli.id);
					if (!olioppids.contains(oli.OpportunityId)) olioppids.add(oli.OpportunityId);
					if (!signaturReferenceIds.contains(oli.Product2Id__c)) signaturReferenceIds.add(oli.Product2Id__c);
					if (!signaturReferenceIds.contains(oli.Sig1Id__c)) signaturReferenceIds.add(oli.Sig1Id__c);
				}
				//else if (oli.medienart_id__c=='46' && KOL_Lizenzen().contains(oli.Lizenznummer__c) && oli.Verkaufsprogramm__c=='AK') {
					
				//}
			}
			if (!kreislistenids.isEmpty()) {
				//String localoliwherecond=' medienart_id__c=\'55\' AND Opportunity.StageNamePosition__c!=4 AND Opportunity.StageNamePosition__c!=0 AND Opportunity.LFKZ2A__c=false AND Opportunity.Zahlerkennzeichen__c<>\'S\'';
				// (((KreisListe__c<>\'\' AND KreisListe__c<>null) AND medienart_id__c=\'55\') OR ((medienart_55__c==null OR medienart_55__c==\'\') AND MedSig1Prod__c=\'46\'))) AND
				String localoliwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c';
				String query='SELECT ';
				query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + ' Kreisliste__c IN ' + getIdListString(kreislistenids) + localoliwhereorder;
				for (SObject soli: Database.query(query)) {
					system.debug('Has kol olis ...');
					OpportunityLineItem oli=(OpportunityLineItem)soli;
					if (!opportunitylineitems.containsKey(oli.id)) opportunitylineitems.put(oli.id, oli);
				}
			}
			if (!signaturReferenceIds.isEmpty()) {
				//String localoliwherecond=' medienart_id__c=\'55\' AND Opportunity.StageNamePosition__c!=4 AND Opportunity.StageNamePosition__c!=0 AND Opportunity.LFKZ2A__c=false AND Opportunity.Zahlerkennzeichen__c<>\'S\'';
				// (((KreisListe__c<>\'\' AND KreisListe__c<>null) AND medienart_id__c=\'55\') OR ((medienart_55__c==null OR medienart_55__c==\'\') AND MedSig1Prod__c=\'46\'))) AND
				String localoliwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c';
				String query='SELECT ';
				query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + ' Product2Id__c IN ' + getIdListString(signaturReferenceIds) + localoliwhereorder;
				for (SObject soli: Database.query(query)) {
					system.debug('Has kol olis ...');
					OpportunityLineItem oli=(OpportunityLineItem)soli;
					if (!opportunitylineitems.containsKey(oli.id)) opportunitylineitems.put(oli.id, oli);
				}
			}
			if (!signaturReferenceIds.isEmpty()) {
				//String localoliwherecond=' medienart_id__c=\'55\' AND Opportunity.StageNamePosition__c!=4 AND Opportunity.StageNamePosition__c!=0 AND Opportunity.LFKZ2A__c=false AND Opportunity.Zahlerkennzeichen__c<>\'S\'';
				// (((KreisListe__c<>\'\' AND KreisListe__c<>null) AND medienart_id__c=\'55\') OR ((medienart_55__c==null OR medienart_55__c==\'\') AND MedSig1Prod__c=\'46\'))) AND
				String localoliwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c';
				String query='SELECT ';
				query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + ' Sig1Id__c IN ' + getIdListString(signaturReferenceIds) + localoliwhereorder;
				for (SObject soli: Database.query(query)) {
					system.debug('Has kol olis ...');
					OpportunityLineItem oli=(OpportunityLineItem)soli;
					if (!opportunitylineitems.containsKey(oli.id)) opportunitylineitems.put(oli.id, oli);
				}
			}
			if (!olioppids.isEmpty()) {
				String localoliwherecond=' StatusPosition__c<3 AND (KreisListe__c=\'\' OR KreisListe__c=null) AND medienart_id__c=\'55\' AND MedSig1Prod__c=\'46\' AND Opportunity.StageNamePosition__c!=0 AND Opportunity.LFKZ2A__c=false AND (Opportunity.Zahlerkennzeichen__c<>\'S\' OR (Opportunity.Zahlerkennzeichen__c=\'S\' AND Opportunity.RA_Lagerabgang__c=1))';
				//  AND Opportunity.StageNamePosition__c!=4
				// (((KreisListe__c<>\'\' AND KreisListe__c<>null) AND medienart_id__c=\'55\') OR ((medienart_55__c==null OR medienart_55__c==\'\') AND MedSig1Prod__c=\'46\'))) AND
				String localoliwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c';
				String query='SELECT ';
				query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' +localoliwherecond + ' AND OpportunityId IN ' + getIdListString(olioppids) + localoliwhereorder;
				for (SObject soli: Database.query(query)) {
					system.debug('Has ak olis ...');
					OpportunityLineItem oli=(OpportunityLineItem)soli;
					if (!opportunitylineitems.containsKey(oli.id)) opportunitylineitems.put(oli.id, oli);
				}
			}
		}
	}
	
	// we should collect accounts on behalf of existing invoiceitems
	private static void collectAccounts() {
		if (!invoiceitems.isEmpty() && !opportunitylineitems.isEmpty()) {
			set<Id> accountids=new set<Id>();
			for (Id oliid: invoiceitems.keySet()) {
				if (opportunitylineitems.containsKey(oliid) && !accountids.contains(Id.valueOf(opportunitylineitems.get(oliid).OppWarenempf_nger__c))) accountids.add(Id.valueOf(opportunitylineitems.get(oliid).OppWarenempf_nger__c)); 
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
	
	private static void collectProducts() {
		if (!opportunitylineitems.isEmpty()) {
			Set<Id> pids =new Set<Id>();
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				if (!pids.contains(Id.valueOf(oli.Product2Id__c))) pids.add(Id.valueOf(oli.Product2Id__c));
			} 
			try {
				list<Product2> pkzmod=new list<Product2>();
				for (Product2 p: [SELECT Id, GESB01__c, RESB01__c, PDKZ01__c, ABLJ01__c, ABMO01__c, ABGS01__c, UMGS01__c, UMLJ01__c, UMMO01__c, AUEA01__c FROM Product2 WHERE Id IN:pids]) {
					if (p.GESB01__c!=null && p.GESB01__c==0 && p.PDKZ01__c==6) {
							p.PDKZ01__c=8;
							pkzmod.add(p);
					}
					if (!products.containsKey(p.id)) products.put(p.id, p);
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
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	//// Updates and Inserts ////
	private static Boolean updateOpportunities() {
		if (!oppsandinvoices.opportunities.isEmpty() 
			) {
			try {
				update oppsandinvoices.opportunities.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				errormsg=errormsg + ' / ' + e.getMessage();
				return true;
			}
		}
		return false;
	}
	
	private static void updateOpportunityLineItems() {
		list<OpportunityLineItem> olitonull = new list<OpportunityLineItem>();
		if (!opportunitylineitems.isEmpty()) {
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				if (oli.Liefermenge__c<>0) {
					opportunitylineitems.get(oli.id).Liefermenge__c=0;
					olitonull.add(opportunitylineitems.get(oli.id));
				}
			}
			try {
				update olitonull;
			} catch (System.Queryexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static Boolean updateAccounts() {
		if (!accounts.isEmpty()) {
			try {
				update accounts.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	private static Boolean unlockOpportunities() {
		if (!oppsandinvoices.opportunities.isEmpty()) {
			for (Id oppid: oppsandinvoices.opportunities.keySet()) {
				if (oppsandinvoices.opportunities.get(oppid).Locked__c)
					oppsandinvoices.opportunities.get(oppid).Locked__c=false;
			}
		}
		try {
			update oppsandinvoices.opportunities.values();
			return true;
		} catch (System.Dmlexception e) {
			SystemSettings.logError(e.getMessage(),'DEBUG');
			errormsg=errormsg + ' / ' + e.getMessage();
			//if (SystemSettings.isDebug) throw e;
			return false;
		}
		return false;
	}
	
	private static Boolean updateProducts() {
		if (!products.isEmpty()) {
			try {
				onProduct.inFutureContextStoredId='true';
				MediathekSammelnummer.createMedienpaketLizenzenOnce=true;
				update products.values();
				MediathekSammelnummer.createMedienpaketLizenzenOnce=false;
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;	
	}
	
	private static Boolean upsertInvoices() {
		if (!oppsandinvoices.invoices.isEmpty()) {
			try {
				upsert oppsandinvoices.invoices.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	private static Boolean updateOpportunitylineitemsWithInvoicing() {
		if (!opportunitylineitems.isEmpty() 
			) {
			list<OpportunityLineItem> ol = new list<OpportunityLineItem>();
			for (OpportunityLineItem oli: opportunitylineitems.values()) {
				if (oli.StatusPosition__c<3)
					ol.add(oli);
			}
			try {
				onOpportunityLineItem.doNotRun=true;
				update ol;
				onOpportunityLineItem.doNotRun=false;
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	private static Boolean insertInvoiceItems() {
		if (!invoiceitems.isEmpty()) {
			try {
				insert invoiceitems.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				errormsg=errormsg + ' / ' + e.getMessage();
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		if (!discountinvoiceitems.isEmpty()) {
			try {
				insert discountinvoiceitems.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				errormsg=errormsg + ' / ' + e.getMessage();
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	//// Helpers //////
	private static String getOppFields() {
		String fieldnames='';
		
		Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
		
		for (String fname: M.keySet()) {
			if (M.get(fname).getDescribe().isAccessible()
				) {
				if (fieldnames=='') fieldnames+=fname;
				else fieldnames+=', ' + fname;
			}
		}
		
		return fieldnames;
	}
	
	private static String getIdListString(set<id> setofids) {
		String idlist='';
		
		if (!setofids.isEmpty()) {
			for (String sid: setofids) {
				if (idlist=='') idlist+='( \'' + sid;
				else idlist+='\', \''+ sid;
			}
		}
		
		if (idlist.length()>0) idlist+= '\' )';
		SystemSettings.insertErrors();
		return idlist;
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
	
	private static set<String> KOL_Lizenzen() {
		set<String> ret=new set<String>();
		ret.add('10206');
	// for the new K1/K2 Verkaufsprogramm
		ret.add('10261');
		ret.add('10262');
		return ret;
	}
}