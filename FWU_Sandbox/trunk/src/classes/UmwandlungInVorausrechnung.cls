public class UmwandlungInVorausrechnung {
	
	public static Boolean alreadyRun=false;
	static map<id, Opportunity> opps=new map<Id, Opportunity>();
	static list<Opportunity> lieferanzeigen=new list<Opportunity>();
	static map<Id, OpportunityLineItem> olistoupdate=new map<Id, OpportunityLineItem>();
	static map<Id, Id> opptolanz = new map<Id, Id>();
	static map<String, Product2> ptoupdate = new map<String, Product2>();
	static set<String> pids = new set<String>();
	static map<Id, map<Id, OpportunityLineItem>> olimap = new map<Id, map<Id, OpportunityLineItem>>();
	static set<id> oppidsset = new set<id>();
	
	
	public static void runUmwandlung(map<id, Opportunity> oppstrig) {
		
		oppidsset=oppstrig.keySet();
		// if number of lineitems > 0, then
		// create new lieferanzeige
		// get all opplineitems of opps where Status is not "Freigabe" and "Fakturiert"
		// update olis with refering lieferanzeige
		// with trigger: create new opplineitems for all Items with not status "Freigabe" und "Fakturiert"
		String[] ids=new String[]{};
		for (Id oppid: oppidsset) {
			ids.add(String.valueOf(oppid));
		}
		
		UmwandlungInVorausrechnungRun.umw(ids);
		getProducts();
		reduceReservedQuantity();
		
		updateProducts();
		//OpportunityFreigabeFakturierung.OpportunityFreigabeFakturierungRun(oppidsset);
		SystemSettings.insertErrors();
	}
	
	public static void UmwandlungInVorausrechnungRun(list<sObject> auftraege) {
		if (!auftraege.isEmpty()) {
			for (sObject s: auftraege) {
				Opportunity o=(Opportunity)s;
				if (!opps.containsKey(o.id)) opps.put(o.id, o);
			}
		}
		run();
		//OpportunityFreigabeFakturierung.OpportunityFreigabeFakturierungRun(opps);
		OpportunityStockAndInvoicingHelper.globalwrapper oppsandinvoices=new OpportunityStockAndInvoicingHelper.globalwrapper();
		oppsandinvoices=OpportunityStockAndInvoicing.OppsRun(opps);
		// jobs to do with opps and invoices ...
		if (oppsandinvoices!=null && !oppsandinvoices.opportunities.isEmpty()) {
			OpportunityStockAndInvoicingHelper.print(oppsandinvoices.opportunities, oppsandinvoices.opportunitiesNoFak, oppsandinvoices.invoices);
			OpportunityStockAndInvoicingHelper.lockOpportunities(oppsandinvoices);
		}
	}
	
	private static void run() {
		// iterate through all olis
		getOpportunityLineItems(opps.keySet());
		SystemSettings.logError('Umwandlung olimap size: ' + olimap.size());
		if (!olimap.isEmpty()) {
			for (Id oppid:opps.keySet()) {
				if (!olimap.get(oppid).isEmpty()) {
					Opportunity o=createLieferanzeige(opps.get(oppid));
					if (o!=null)
						lieferanzeigen.add(o);
				}
			}
			insertLieferanzeigen();
		}
		updateOppsWithId(opps);
		updateOliWithId();
		updateOlis();
	}
	
	private static Opportunity createLieferanzeige(Opportunity o) {
		sObject s = (Opportunity)o;
		Opportunity lieferanzeige=(Opportunity)s.clone(false,true);
		lieferanzeige.VAUF2A__c=o.id;
		lieferanzeige.REAR2A__c=8;
		lieferanzeige.StageName='In Erstellung';
		lieferanzeige.RecordTypeId=[SELECT Id FROM RecordType WHERE Name='Erfassung' AND SobjectType='Opportunity' limit 1].Id;
		lieferanzeige.Locked__c=false;
		lieferanzeige.RechnungsartVorUmwandlung__c=null;
		return lieferanzeige;
	}
	
	private static void getOpportunityLineItems(Set<Id> oppids) {
		if (!oppids.isEmpty()) {
			for (OpportunityLineItem oli: [SELECT Id, LieferanzeigeId__c, OpportunityId, Product2Id__c, Lizenzmenge__c FROM OpportunityLineItem WHERE OpportunityId IN :oppids AND Produkttyp__c!='Sammelnummer']) {
				if (!olistoupdate.containsKey(oli.id)) olistoupdate.put(oli.id,oli);
				if (!olimap.containsKey(oli.OpportunityId)) olimap.put(oli.OpportunityId, new map<Id, OpportunityLineItem>());
				if (!olimap.get(oli.OpportunityId).containsKey(oli.id)) olimap.get(oli.OpportunityId).put(oli.id, oli);
				if (!pids.contains(oli.Product2Id__c)) pids.add(oli.Product2Id__c);
			}	
		}
	}
	
	private static void getProducts() {
		if (ptoupdate.isEmpty() && !pids.isEmpty()) {
			for (Product2 p: [SELECT Id, RESB01__c FROM Product2 WHERE Id IN :pids for update]) {
				if (!ptoupdate.containsKey(String.valueOf(p.id).substring(0,15))) ptoupdate.put(String.valueOf(p.id).substring(0,15),p);
			} 
		}
	}
	
	private static void updateOppsWithId(map<id, Opportunity> oppsin) {
		if (!oppsin.isEmpty() && !opptolanz.isEmpty()) {
			//for (Id oppid: opptolanz.keySet()) {
			//	if (opps.containsKey(oppid)) opps.get(oppid).VAUF2A__c=opptolanz.get(oppid);
			//}
			list<Opportunity> oppstoupdate = new list<Opportunity>();
			for (Opportunity o: [SELECT Id, VAUF2A__c FROM Opportunity WHERE Id IN: opptolanz.keySet() for update]) {
				if (oppsin.containsKey(o.id)) o.VAUF2A__c=opptolanz.get(o.id);
				oppstoupdate.add(o);
			}
			if (!oppstoupdate.isEmpty()) {
				try {
					update oppstoupdate;
				} catch (System.Dmlexception e) {
					SystemSettings.logError(e.getMessage());
					// TODO think about a better exception handling
					//throw e;
					try {
						update oppstoupdate;
					} catch (System.DmlException e1) {
						try {
							update oppstoupdate;
						} catch (System.DmlException e2) {
							throw e2;
						}
					}
				}
			}
		}
	}
	
	private static void reduceReservedQuantity() {
		if (!olistoupdate.isEmpty() && !ptoupdate.isEmpty()) {
			for (OpportunityLineItem oli: olistoupdate.values()) {
				if (ptoupdate.containsKey(oli.Product2Id__c) && oli.Fremdvertrieb__c==null && !oli.Sperrkz__c) {
					if (ptoupdate.get(oli.Product2Id__c).RESB01__c==null) ptoupdate.get(oli.Product2Id__c).RESB01__c=0;
					ptoupdate.get(oli.Product2Id__c).RESB01__c-=oli.Lizenzmenge__c;
				} 
			}
		}
	}
	private static void updateOliWithId() {
		map<Id, OpportunityLineItem> updatedolis = new map<Id, OpportunityLineItem>();
		if (!olistoupdate.isEmpty() && !opptolanz.isEmpty()) {
			for (OpportunityLineItem oli: olistoupdate.values()) {
				if (opptolanz.containsKey(oli.OpportunityId)) {
					oli.LieferanzeigeId__c=opptolanz.get(oli.OpportunityId);
					if (!updatedolis.containsKey(oli.id)) updatedolis.put(oli.id,oli);
				}
			}
			olistoupdate.clear();
			olistoupdate=updatedolis.deepClone();
		}
	}
	
	@future
	private static void updateProducts() {
		if (!ptoupdate.isEmpty()) {
			try {
				update ptoupdate.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static void updateOlis() {
		if (!olistoupdate.isEmpty()) {
			if (olistoupdate.size()<=Limits.getLimitDmlRows()-Limits.getDmlRows()) {
				try {
					update olistoupdate.values();
				} catch (System.Dmlexception e) {
					SystemSettings.logError(e.getMessage(),'DEBUG');
					if (SystemSettings.isDebug) throw e;
				}
			}
		}
	}
	
	private static void insertLieferanzeigen() {
		if (!lieferanzeigen.isEmpty()) {
			try {
				insert lieferanzeigen;
				// we need this mapping to reference the right opp for the lineitems
				for (Opportunity lieferanzeige: lieferanzeigen) {
					if (!opptolanz.containsKey(lieferanzeige.VAUF2A__c)) opptolanz.put(lieferanzeige.VAUF2A__c,lieferanzeige.id);
				}
			} catch (System.DmlException e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
}