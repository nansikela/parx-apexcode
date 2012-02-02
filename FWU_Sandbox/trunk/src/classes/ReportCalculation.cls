public class ReportCalculation {
/*
	static ReportKonfiguration__c rkonf;
	static ReportResult__c rresult;
	static map<Id, RechnungPosten__c> rpmap = new map<Id, RechnungPosten__c>();
	static map<Id, OpportunityLineItem> olimap = new map<Id, OpportunityLineItem>();
	static map<Id, map<Id, RechnungPosten__c>> rpforolimap = new map<Id, map<Id, RechnungPosten__c>>();
	static set<Id> alreadySelectedInvoiceItems = new set<Id>();
	static map<Id, String> rp_recordtype = new map<Id, String>();
	static String LIZENZUMSATZ='Lizenzumsatz';

	public static ReportResult__c ReportCalculationRun(list<sObject> olis, ReportKonfiguration__c rk, ReportResult__c rr) {
		rkonf=rk;
		rresult=rr;
		initResult();
		if (!olis.isEmpty()) {
			for (sObject s: olis) {
				OpportunityLineItem oli=(OpportunityLineItem)s;
				if (!olimap.containsKey(oli.id)) olimap.put(oli.id, oli);
			}
		}
		getRechnungpostenRecordtypes();
		run();
		return rresult;
	}
	
	public static void run () {
		// get Rechnungsposten
		// decide which is Absatz/Umsatz and sum up in the result record
		getRechnungsposten();
		calculate();
	}
	
	private static void getRechnungpostenRecordtypes() {
		try {
			for (RecordType rt: [SELECT Id, Name FROM RecordType WHERE SObjectType='RechnungPosten__c' AND isActive=true]) {
				if (!rp_recordtype.containsKey(rt.id)) rp_recordtype.put(rt.id, rt.Name);
			}
		} catch (System.Exception e) {}
	}
	
	private static void getRechnungsposten() {
		if (!olimap.isEmpty()) {
			for (RechnungPosten__c rp:[SELECT Id
						, OpportunityLineItemId__c
						, Artikel__c
						, Bericht_MedienartenSTAT__c
						, Bericht_StdKriterien__c
						, GEM212__c
						, GNP212__c
						, LMG212__c
						, LZN212__c
						, Medienart__c
						, Medienart_Klartext__c
						, MWST_Betrag__c
						, Rabattbetrag_netto__c
						, Rechnungsdatum__c
						, REN212__c
						, Umsatz_Ausland__c
						, Umsatz_Inland__c
						, VKP212__c
						, SIZ212__c
						, ZUA212__c
						, RA_Statistik__c
						, RecordTypeId
						, SignaturZ_hlnummer__c
						, REN212__r.AUN211__r.Id 
						FROM RechnungPosten__c 
						WHERE SignaturZ_hlnummer__c<>29999
						AND RA_Statistik__c=1
						AND OpportunityLineItemId__c IN : olimap.keySet()
						AND Rechnungsdatum__c!=null
						AND (
						(Rechnungsdatum__c<=:Date.valueOf(rkonf.APEX_QueryArea01End__c))
						OR
						(Rechnungsdatum__c<=:Date.valueOf(rkonf.APEX_QueryArea02End__c))
						)
						]) {
				if (!alreadySelectedInvoiceItems.contains(rp.id)) alreadySelectedInvoiceItems.add(rp.id);
				if (!rpmap.containsKey(rp.id)) rpmap.put(rp.id, rp);
				if (!rpforolimap.containsKey(rp.OpportunityLineItemId__c)) rpforolimap.put(rp.OpportunityLineItemId__c, new map<Id, RechnungPosten__c>());
				if (!rpforolimap.get(rp.OpportunityLineItemId__c).containsKey(rp.id)) rpforolimap.get(rp.OpportunityLineItemId__c).put(rp.id, rp);
			}
			*/
			/*
			for (RechnungPosten__c rp:[SELECT Id
						, OpportunityLineItemId__c
						, Artikel__c
						, Bericht_MedienartenSTAT__c
						, Bericht_StdKriterien__c
						, GEM212__c
						, GNP212__c
						, LMG212__c
						, LZN212__c
						, Medienart__c
						, Medienart_Klartext__c
						, MWST_Betrag__c
						, Rabattbetrag_netto__c
						, Rechnungsdatum__c
						, REN212__c
						, Umsatz_Ausland__c
						, Umsatz_Inland__c
						, VKP212__c
						, SIZ212__c
						, ZUA212__c
						, RA_Statistik__c
						, RecordTypeId
						, SignaturZ_hlnummer__c
						, REN212__r.AUN211__r.Id 
						FROM RechnungPosten__c 
						WHERE ID NOT IN :alreadySelectedInvoiceItems
						AND SignaturZ_hlnummer__c<>29999
						AND RA_Statistik__c=1
						// perhaps there are invoiceitems without olis
						//AND OpportunityLineItemId__c IN : olimap.keySet()
						AND Rechnungsdatum__c!=null
						AND (
						(Rechnungsdatum__c>=:Date.valueOf(rkonf.APEX_QueryArea01Start__c) AND Rechnungsdatum__c<=:Date.valueOf(rkonf.APEX_QueryArea01End__c))
						OR
						(Rechnungsdatum__c>=:Date.valueOf(rkonf.APEX_QueryArea02Start__c) AND Rechnungsdatum__c<=:Date.valueOf(rkonf.APEX_QueryArea02End__c))
						)
						]) {
				System.debug('Check for Dates - invoice date: ' + rp.Rechnungsdatum__c + ' - 01Start: ' + Date.valueOf(rkonf.APEX_QueryArea01Start__c) + ' - 01End: ' + Date.valueOf(rkonf.APEX_QueryArea01End__c) + ' - 02Start: ' + Date.valueOf(rkonf.APEX_QueryArea02Start__c) + ' - 02End: ' + Date.valueOf(rkonf.APEX_QueryArea02End__c));
				if (!rpmap.containsKey(rp.id)) rpmap.put(rp.id, rp);
				if (!rpforolimap.containsKey(rp.OpportunityLineItemId__c)) rpforolimap.put(rp.OpportunityLineItemId__c, new map<Id, RechnungPosten__c>());
				if (!rpforolimap.get(rp.OpportunityLineItemId__c).containsKey(rp.id)) rpforolimap.get(rp.OpportunityLineItemId__c).put(rp.id, rp);
			}
			*//*
		}
	}
	
	private static void initResult() {
		if (rresult.Report_Konfiguration__c==null && rkonf!=null) rresult.Report_Konfiguration__c=rkonf.id;
		if (rresult.ABLJ__c==null) rresult.ABLJ__c=0;
		if (rresult.ABLM__c==null) rresult.ABLM__c=0;
		if (rresult.ABVJ__c==null) rresult.ABVJ__c=0;
		if (rresult.ABVM__c==null) rresult.ABVM__c=0;
		if (rresult.INLJ__c==null) rresult.INLJ__c=0;
		if (rresult.INLM__c==null) rresult.INLM__c=0;
		if (rresult.INVJ__c==null) rresult.INVJ__c=0;
		if (rresult.INVM__c==null) rresult.INVM__c=0;
		if (rresult.LIAULJ__c==null) rresult.LIAULJ__c=0;
		if (rresult.LIAULM__c==null) rresult.LIAULM__c=0;
		if (rresult.LIAUVJ__c==null) rresult.LIAUVJ__c=0;
		if (rresult.LIAUVM__c==null) rresult.LIAUVM__c=0;
		if (rresult.LIINLJ__c==null) rresult.LIINLJ__c=0;
		if (rresult.LIINLM__c==null) rresult.LIINLM__c=0;
		if (rresult.LIINVJ__c==null) rresult.LIINVJ__c=0;
		if (rresult.LIINVM__c==null) rresult.LIINVM__c=0;
		if (rresult.UAULJ__c==null) rresult.UAULJ__c=0;
		if (rresult.UAULM__c==null) rresult.UAULM__c=0;
		if (rresult.UAUVJ__c==null) rresult.UAUVJ__c=0;
		if (rresult.UAUVM__c==null) rresult.UAUVM__c=0;
		if (rresult.UINLJ__c==null) rresult.UINLJ__c=0;
		if (rresult.UINLM__c==null) rresult.UINLM__c=0;
		if (rresult.UINVJ__c==null) rresult.UINVJ__c=0;
		if (rresult.UINVM__c==null) rresult.UINVM__c=0;
		if (rresult.X42LJ__c==null) rresult.X42LJ__c=0;
		if (rresult.X42LM__c==null) rresult.X42LM__c=0;
		if (rresult.X42VJ__c==null) rresult.X42VJ__c=0;
		if (rresult.X42VM__c==null) rresult.X42VM__c=0;
		if (rresult.X46LJ__c==null) rresult.X46LJ__c=0;
		if (rresult.X46LM__c==null) rresult.X46LM__c=0;
		if (rresult.X46VJ__c==null) rresult.X46VJ__c=0;
		if (rresult.X46VM__c==null) rresult.X46VM__c=0;
		if (rresult.X55LJ__c==null) rresult.X55LJ__c=0;
		if (rresult.X55LM__c==null) rresult.X55LM__c=0;
		if (rresult.X55VJ__c==null) rresult.X55VJ__c=0;
		if (rresult.X55VM__c==null) rresult.X55VM__c=0;
		if (rresult.X66LJ__c==null) rresult.X66LJ__c=0;
		if (rresult.X66LM__c==null) rresult.X66LM__c=0;
		if (rresult.X66VJ__c==null) rresult.X66VJ__c=0;
		if (rresult.X66VM__c==null) rresult.X66VM__c=0;
		if (rresult.XXXLJ__c==null) rresult.XXXLJ__c=0;
		if (rresult.XXXLM__c==null) rresult.XXXLM__c=0;
		if (rresult.XXXVJ__c==null) rresult.XXXVJ__c=0;
		if (rresult.XXXVM__c==null) rresult.XXXVM__c=0;
	}
	
	private static void calculate() {
		// Auftragsbestand
		if (!olimap.isEmpty()) {
			for (OpportunityLineItem oli: olimap.values()) {
				Date CreatedDate=Date.newInstance(oli.CreatedDate.year(),oli.CreatedDate.month(),oli.CreatedDate.day());
				if (oli.OppBestelldatum__c!=null) CreatedDate=Date.newInstance(oli.OppBestelldatum__c.year(),oli.OppBestelldatum__c.month(),oli.OppBestelldatum__c.day());
				Double gelieferteMenge=oli.GELM2D__c==null?0:oli.GELM2D__c;
				//if (oli.STAT2D__c!='Fakturiert') {
					// Jahresvergleich
					// aktueller Status, ist leicht
					if (CreatedDate.year()==Integer.valueOf(rkonf.Basisjahr__c)) {
						rresult.ABLJ__c+=(oli.Quantity-gelieferteMenge)*oli.Verkaufspreis_Netto__c;
					}
					// Monatsvergleich
					if (CreatedDate>=rkonf.Basismonat_von__c && CreatedDate<=rkonf.Basismonat_bis__c) {
						rresult.ABLM__c+=(oli.Quantity-gelieferteMenge)*oli.Verkaufspreis_Netto__c;
					} else {
						rresult.ABVM__c+=(oli.Quantity-gelieferteMenge)*oli.Verkaufspreis_Netto__c;
					}
				
					// Auftragsbestand des Vergleichsjahres kann nur ein oli sein, dass vor dem 31.12. des Vergleichsjahres angelegt wurde und nicht Lieferanzeige ist!
					if (CreatedDate.year()<=Integer.valueOf(rkonf.Vergleichsjahr__c) && !rpforolimap.isEmpty() && rpforolimap.containsKey(oli.id)) {
						// wir suchen nun je oli den letzten Auftragsbestand bezogen auf das Vergleichsjahr, 
						// die sich durch die jeweiligen Rechnungen ergeben
						// olis, die innerhalb des Vergleichsjahres Vollständig Fakturiert wurden, 
						// zählen nicht zum Auftragsbestand <- Schlechter Ansatz, da wir dies nicht wissen könnne
						// besser:
						// dazu gehen wir die Rechnungen durch, die innerhalb des Vergleichsjahres zum 
						// betreffenden oli existieren. Der Gesamtpreis_netto__c des Oli minus die Summe von 
						// GNP212__c der Rechnungsposten ergibt den passenden Auftragsbestand innerhalb des Vergleichsjahres 
						rresult.ABVJ__c+=oli.Gesamtpreis_netto__c;
						for (RechnungPosten__c rp: rpforolimap.get(oli.id).values()) {
							if (rp.Rechnungsdatum__c.year()==Integer.valueOf(rkonf.Vergleichsjahr__c)) {
								rresult.ABVJ__c-=rp.GNP212__c;
							}
						}
						// Monatsvergleich
						if (CreatedDate>=rkonf.Vergleichsmonat_von__c && CreatedDate<=rkonf.Vergleichsmonat_bis__c) {
							rresult.ABLM__c+=(oli.Quantity-gelieferteMenge)*oli.Verkaufspreis_Netto__c;
						} else {
							rresult.ABVM__c+=(oli.Quantity-gelieferteMenge)*oli.Verkaufspreis_Netto__c;
						}
						
					}
				}
				
			//}
		}
		// Umsatz
		if (!rpmap.isEmpty()) {
			for (RechnungPosten__c rp: rpmap.values()) {
				// Jahresvergleich, nur fuer Statistik-Relevante Rechnungsarten
				if (rp.Rechnungsdatum__c.year()==Integer.valueOf(rkonf.Basisjahr__c) && rp.Medienart__c!=null) {
					if (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999) {
						rresult.UAULJ__c+=rp.Umsatz_Ausland__c;
						rresult.UINLJ__c+=rp.Umsatz_Inland__c;
					}
					if (rp_recordtype.get(rp.RecordTypeId)==LIZENZUMSATZ && (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999)) {
						rresult.LIAULJ__c+=rp.Umsatz_Ausland__c;
						rresult.LIINLJ__c+=rp.Umsatz_Inland__c;
					} else  { 
						if (rp.SignaturZ_hlnummer__c>=29990 && rp.SignaturZ_hlnummer__c<=29999) {
							//rresult.XXXLJ__c+=rp.GNP212__c;
						} else {
							if (Integer.valueOf(rp.Medienart__c)==42) {
								rresult.X42LJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)==46) {
								rresult.X46LJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=55 && Integer.valueOf(rp.Medienart__c)<=57) {
								rresult.X55LJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=66 && Integer.valueOf(rp.Medienart__c)<=67) {
								rresult.X66LJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=02 && Integer.valueOf(rp.Medienart__c)<=09) {
								rresult.INLJ__c+=rp.GNP212__c;
							} else {
								rresult.XXXLJ__c+=rp.GNP212__c;
							}
						}
					}
				} else if (rp.Rechnungsdatum__c.year()!=Integer.valueOf(rkonf.Basisjahr__c) && rp.Medienart__c!=null) {
					if (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999) {
						rresult.UAUVJ__c+=rp.Umsatz_Ausland__c;
						rresult.UINVJ__c+=rp.Umsatz_Inland__c;
					}
					if (rp_recordtype.get(rp.RecordTypeId)==LIZENZUMSATZ && (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999)) {
						rresult.LIAUVJ__c+=rp.Umsatz_Ausland__c;
						rresult.LIINVJ__c+=rp.Umsatz_Inland__c;
					} else  { 
						if (rp.SignaturZ_hlnummer__c>=29990 && rp.SignaturZ_hlnummer__c<=29999) {
							//rresult.XXXVJ__c+=rp.GNP212__c;
						} else {
							if (Integer.valueOf(rp.Medienart__c)==42) {
								rresult.X42VJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)==46) {
								rresult.X46VJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=55 && Integer.valueOf(rp.Medienart__c)<=57) {
								rresult.X55VJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=66 && Integer.valueOf(rp.Medienart__c)<=67) {
								rresult.X66VJ__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=02 && Integer.valueOf(rp.Medienart__c)<=09) {
								rresult.INVJ__c+=rp.GNP212__c;
							} else {
								rresult.XXXVJ__c+=rp.GNP212__c;
							}
						}
					}
				}
				// Monatsvergleich, nur fuer Statistik-Relevante Rechnungsarten
				if (rp.Rechnungsdatum__c.year()==rkonf.Basismonat_von__c.year() && rp.Rechnungsdatum__c.month()==rkonf.Basismonat_von__c.month() && rp.Medienart__c!=null) {
					if (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999) {
						rresult.UAULM__c+=rp.Umsatz_Ausland__c;
						rresult.UINLM__c+=rp.Umsatz_Inland__c;
					}
					if (rp_recordtype.get(rp.RecordTypeId)==LIZENZUMSATZ && (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999)) {
						rresult.LIAULM__c+=rp.Umsatz_Ausland__c;
						rresult.LIINLM__c+=rp.Umsatz_Inland__c;
					} else { 
						if (rp.SignaturZ_hlnummer__c>=29990 && rp.SignaturZ_hlnummer__c<=29999) {
							//rresult.XXXLM__c+=rp.GNP212__c;
						} else {
							if (Integer.valueOf(rp.Medienart__c)==42) {
								rresult.X42LM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)==46) {
								rresult.X46LM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=55 && Integer.valueOf(rp.Medienart__c)<=57) {
								rresult.X55LM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=66 && Integer.valueOf(rp.Medienart__c)<=67) {
								rresult.X66LM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=02 && Integer.valueOf(rp.Medienart__c)<=09) {
								rresult.INLM__c+=rp.GNP212__c;
							} else {
								rresult.XXXLM__c+=rp.GNP212__c;
							}
						}
					}
				} else 
				if (rp.Rechnungsdatum__c.year()==rkonf.Vergleichsmonat_von__c.year() && rp.Rechnungsdatum__c.month()==rkonf.Vergleichsmonat_von__c.month() && rp.Medienart__c!=null) {
					if (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999) {
						rresult.UAUVM__c+=rp.Umsatz_Ausland__c;
						rresult.UINVM__c+=rp.Umsatz_Inland__c;
					}
					if (rp_recordtype.get(rp.RecordTypeId)==LIZENZUMSATZ && (rp.SignaturZ_hlnummer__c<29990 || rp.SignaturZ_hlnummer__c>29999)) {
						rresult.LIAUVM__c+=rp.Umsatz_Ausland__c;
						rresult.LIINVM__c+=rp.Umsatz_Inland__c;
					} else { 
						if (rp.SignaturZ_hlnummer__c>=29990 && rp.SignaturZ_hlnummer__c<=29999) {
							//rresult.XXXVM__c+=rp.GNP212__c;
						} else {
							if (Integer.valueOf(rp.Medienart__c)==42) {
								rresult.X42VM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)==46) {
								rresult.X46VM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=55 && Integer.valueOf(rp.Medienart__c)<=57) {
								rresult.X55VM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=66 && Integer.valueOf(rp.Medienart__c)<=67) {
								rresult.X66VM__c+=rp.GNP212__c;
							} else
							if (Integer.valueOf(rp.Medienart__c)>=02 && Integer.valueOf(rp.Medienart__c)<=09) {
								rresult.INVM__c+=rp.GNP212__c;
							} else {
								rresult.XXXVM__c+=rp.GNP212__c;
							}
						}
					}
				}
				// Ende
			}
		}
	}
	*/
}