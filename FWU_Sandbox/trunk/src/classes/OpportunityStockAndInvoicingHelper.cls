public class OpportunityStockAndInvoicingHelper {

	public class globalwrapper {
		public map<Id, Rechnung__c> invoices;
		public map<Id, Opportunity> opportunities;
		public map<Id, Double> opportunitiesNoFak;
		public Boolean hasError;
		
		public globalwrapper() {
			invoices=new map<Id, Rechnung__c>();
			opportunities=new map<Id, Opportunity>();
			opportunitiesNoFak=new map<Id, Double>();
			hasError=false;
		}
	}
	
	public static void print(map<Id, Opportunity> opportunities, map<Id, Double> opportunitiesNoFak, map<id, Rechnung__c> invoices) {
		set<Id> oppidstoprint=new set<Id>();
		map<id, Opportunity> oppstoprint = new map<Id, Opportunity>();
		if (!opportunities.isEmpty()) {
			for (Id oppid: opportunities.keySet()) {
				if (opportunities.get(oppid).Zahl_der_Fakturierungen__c!=null && 
					((opportunities.get(oppid).Zahl_der_Fakturierungen__c==1 && opportunities.get(oppid).Zahl_der_Fakturierungen__c!=opportunitiesNoFak.get(oppid))
					|| 
					(opportunities.get(oppid).Zahl_der_Fakturierungen__c>opportunitiesNoFak.get(oppid)
					&& invoices.containsKey(oppid))
					)
					) {
					//auftraege_fak.get(oppid).Conga_Workflow_for_activation__c=true;
					//opportunities.get(oppid).Conga_Workflow_Trigger__c=true;
					oppidstoprint.add(oppid);
					//SystemSettings.logError('Auftrag zu drucken: ' + oppid);
				}
			}
			if (!oppidstoprint.isEmpty()) {
				for (Opportunity opp:[SELECT Id, Conga_Workflow_for_Activation__c FROM Opportunity WHERE Id IN :oppidstoprint]) {
					opp.Conga_Workflow_for_Activation__c=true;
					oppstoprint.put(opp.id, opp);
				}
			}
			Boolean hasError=updateOpportunities(oppstoprint);
			if (hasError && !SystemSettings.isDebug) {
				SystemSettings.logError('Print ist fehlgeschlagen!');
			}
		}
	}
	
	private static Boolean updateOpportunities(map<id, Opportunity> opportunities) {
		if (!opportunities.isEmpty() 
			) {
			try {
				update opportunities.values();
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				//if (SystemSettings.isDebug) throw e;
				return true;
			}
		}
		return false;
	}
	
	public static Boolean lockOpportunities(globalwrapper oppsandinvoices) {
		map<Id, Opportunity> oppstolock = new map<Id, Opportunity>();
		if (!oppsandinvoices.opportunities.isEmpty()) {
			for (Opportunity opp: [SELECT Id, Locked__c FROM Opportunity WHERE Id IN :oppsandinvoices.opportunities.keySet()]) {
				opp.Locked__c=true;
				oppstolock.put(opp.id, opp);
			}
		}
		Boolean hasError=updateOpportunities(oppstolock);
		if (hasError && !SystemSettings.isDebug) {
			SystemSettings.logError('Opp Sperre ist fehlgeschlagen!');
		}
		return hasError;
	}
	
	public static Boolean freeOpportunities(String[] oppids, globalwrapper oppsandinvoices) {
		list<Opportunity> oppstoupdate = new list<Opportunity>();
		if (!oppids.isEmpty() || !oppsandinvoices.opportunities.isEmpty()) {
			for (Id oppid: oppsandinvoices.opportunities.keySet()) {
				oppsandinvoices.opportunities.get(oppid).Aktive_Fakturierung__c=false;
			}
			for (Opportunity opp:[SELECT Id, Aktive_Fakturierung__c FROM Opportunity WHERE Id IN :oppids]) {
				opp.Aktive_Fakturierung__c=false;
				oppstoupdate.add(opp);
			}
		}
		try {
			update oppsandinvoices.opportunities.values();
			update oppstoupdate;
			return true;
		} catch (System.Dmlexception e) {
			SystemSettings.logError('Free Opportunity ' + e.getMessage(),'DEBUG');
			//if (SystemSettings.isDebug) throw e;
			return false;
		}
		return false;
	}

}