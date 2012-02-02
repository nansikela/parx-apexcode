public class OpportunityStockAndInvoicingHelper {

	public class globalwrapper {
		public map<Id, Rechnung__c> invoices;
		public map<Id, Opportunity> opportunities;
		public map<Id, Double> opportunitiesNoFak;
		
		public globalwrapper() {
			invoices=new map<Id, Rechnung__c>();
			opportunities=new map<Id, Opportunity>();
			opportunitiesNoFak=new map<Id, Double>();
		}
	}
	
	public static void print(map<Id, Opportunity> opportunities, map<Id, Double> opportunitiesNoFak, map<id, Rechnung__c> invoices) {
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
					opportunities.get(oppid).Conga_Workflow_Trigger__c=true;
					//SystemSettings.logError('Auftrag zu drucken: ' + oppid);
				}
			}
			Boolean hasError=updateOpportunities(opportunities);
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
		if (!oppsandinvoices.opportunities.isEmpty()) {
			for (Id oppid: oppsandinvoices.opportunities.keySet()) {
				oppsandinvoices.opportunities.get(oppid).Locked__c=true;
				oppsandinvoices.opportunities.get(oppid).Conga_Workflow_Trigger__c=false;
			}
		}
		try {
			update oppsandinvoices.opportunities.values();
			return true;
		} catch (System.Dmlexception e) {
			SystemSettings.logError(e.getMessage(),'DEBUG');
			//if (SystemSettings.isDebug) throw e;
			return false;
		}
		return false;
	}

}