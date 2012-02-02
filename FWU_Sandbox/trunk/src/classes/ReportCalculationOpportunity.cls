public class ReportCalculationOpportunity {
	
	static ReportKonfiguration__c rkonf;
	static ReportResult__c rresult;
	static map<Id, RechnungPosten__c> rpmap = new map<Id, RechnungPosten__c>();
	static map<Id, OpportunityLineItem> olimap = new map<Id, OpportunityLineItem>();
	static map<Id, map<Id, RechnungPosten__c>> rpforolimap = new map<Id, map<Id, RechnungPosten__c>>();
	static map<Id, String> rp_recordtype = new map<Id, String>();
	static set<Id> oppids = new set<Id>();
	static map<Id, Opportunity> opps = new map<Id, Opportunity>();

	public static ReportResult__c ReportCalculationRun(list<sObject> olis, ReportKonfiguration__c rk, ReportResult__c rr) {
		rkonf=rk;
		rresult=rr;
		initResult();
		if (!olis.isEmpty()) {
			for (sObject s: olis) {
				OpportunityLineItem oli=(OpportunityLineItem)s;
				if (!olimap.containsKey(oli.id)) olimap.put(oli.id, oli);
				if (!oppids.contains(oli.OpportunityId)) oppids.add(oli.OpportunityId);
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
		getOpportunities();
		calculate();
	}
	
	private static void getOpportunities() {
		if (!oppids.isEmpty()) {
			for (Opportunity o:[SELECT Id, Name, Letzte_Rechnung__c, Letzte_Rechnung__r.RED211__c FROM Opportunity WHERE Id IN :oppids]) {
				if (!opps.containsKey(o.id)) opps.put(o.id,o);
			}
		}
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
						WHERE OpportunityLineItemId__c IN : olimap.keySet()
						//AND ZUA212__c!='PA'
						//AND RA_Statistik__c=1 
						AND Rechnungsdatum__c!=null
						AND (
						(Rechnungsdatum__c<=:Date.valueOf(rkonf.APEX_QueryArea01End__c))
						OR
						(Rechnungsdatum__c<=:Date.valueOf(rkonf.APEX_QueryArea02End__c))
						)
						]) {
				if (!rpmap.containsKey(rp.id)) rpmap.put(rp.id, rp);
				if (!rpforolimap.containsKey(Id.ValueOf(rp.OpportunityLineItemId__c))) rpforolimap.put(Id.valueOf(rp.OpportunityLineItemId__c), new map<Id, RechnungPosten__c>());
				if (!rpforolimap.get(Id.ValueOf(rp.OpportunityLineItemId__c)).containsKey(rp.id)) rpforolimap.get(Id.ValueOf(rp.OpportunityLineItemId__c)).put(rp.id, rp);
			}
		}
	}
	
	private static void initResult() {
		if (rresult.Report_Konfiguration__c==null && rkonf!=null) rresult.Report_Konfiguration__c=rkonf.id;
		if (rresult.ABLJ__c==null) rresult.ABLJ__c=0;
		if (rresult.ABLM__c==null) rresult.ABLM__c=0;
		if (rresult.ABVJ__c==null) rresult.ABVJ__c=0;
		if (rresult.ABVM__c==null) rresult.ABVM__c=0;
	}
	
	private static void calculate() {
		// Auftragsbestand
		if (!olimap.isEmpty()) {
			for (OpportunityLineItem oli: olimap.values()) {
				Date CreatedDate=Date.newInstance(oli.CreatedDate.year(),oli.CreatedDate.month(),oli.CreatedDate.day());
				if (oli.OppBestelldatum__c!=null) CreatedDate=Date.newInstance(oli.OppBestelldatum__c.year(),oli.OppBestelldatum__c.month(),oli.OppBestelldatum__c.day());
				
				// Jahressumme OLIS
				//if ((opps.get(oli.OpportunityId).Letzte_Rechnung__c==null && CreatedDate.year()<=Integer.valueOf(rkonf.Basisjahr__c)) || opps.get(oli.OpportunityId).Letzte_Rechnung__r.RED211__c<=rkonf.Basismonat_bis__c) {
				if (CreatedDate<=rkonf.Basismonat_bis__c) {
					rresult.ABLJ__c+=oli.Gesamtpreis_netto__c;
					// abzueglich der zugehoerigen RechnungPosten
					if (rpforolimap.containsKey(oli.id)) {
						for (RechnungPosten__c rp: rpforolimap.get(oli.id).values()) {
							if (rp.Rechnungsdatum__c<=rkonf.Basismonat_bis__c) {
								rresult.ABLJ__c-=rp.GNP212__c;
							}
						}
					}
				}
				//if ((opps.get(oli.OpportunityId).Letzte_Rechnung__c==null && CreatedDate.year()<=Integer.valueOf(rkonf.Vergleichsjahr__c)) || opps.get(oli.OpportunityId).Letzte_Rechnung__r.RED211__c<=rkonf.Vergleichsmonat_bis__c) {
				if (CreatedDate<=rkonf.Vergleichsmonat_bis__c) {
					rresult.ABVJ__c+=oli.Gesamtpreis_netto__c;
					// abzueglich der zugehoerigen RechnungPosten
					if (rpforolimap.containsKey(oli.id)) {
						for (RechnungPosten__c rp: rpforolimap.get(oli.id).values()) {
							if (rp.Rechnungsdatum__c<=rkonf.Vergleichsmonat_bis__c) {
								rresult.ABVJ__c-=rp.GNP212__c;
							}
						}
					}
				}
				// Monatssumme OLIS
				if (CreatedDate>=rkonf.Basismonat_von__c && CreatedDate<=rkonf.Basismonat_bis__c) {
					rresult.ABLM__c+=oli.Gesamtpreis_netto__c;
					// abzueglich der zugehoerigen RechnungPosten
					if (rpforolimap.containsKey(oli.id)) {
						for (RechnungPosten__c rp: rpforolimap.get(oli.id).values()) {
							if (rp.Rechnungsdatum__c<=rkonf.Basismonat_bis__c) {
								rresult.ABLM__c-=rp.GNP212__c;
							}
						}
					}
				}
				if (CreatedDate>=rkonf.Vergleichsmonat_von__c && CreatedDate<=rkonf.Vergleichsmonat_bis__c) {
					rresult.ABVM__c+=oli.Gesamtpreis_netto__c;
					// abzueglich der zugehoerigen RechnungPosten
					if (rpforolimap.containsKey(oli.id)) {
						for (RechnungPosten__c rp: rpforolimap.get(oli.id).values()) {
							if (rp.Rechnungsdatum__c<=rkonf.Vergleichsmonat_bis__c) {
								rresult.ABVM__c-=rp.GNP212__c;
							}
						}
					}
				}
				
				
			}
			/*
			for (OpportunityLineItem oli: olimap.values()) {
				Date CreatedDate=Date.newInstance(oli.CreatedDate.year(),oli.CreatedDate.month(),oli.CreatedDate.day());
				if (oli.OppBestelldatum__c!=null) CreatedDate=Date.newInstance(oli.OppBestelldatum__c.year(),oli.OppBestelldatum__c.month(),oli.OppBestelldatum__c.day());
				Double gelieferteMenge=oli.GELM2D__c==null?0:oli.GELM2D__c;
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
			*/
		}
	}
}