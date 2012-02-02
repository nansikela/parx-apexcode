public class OeVRechtetextHelper {

	public static boolean isAlreadyRun=false;
	
	private static map<Id, Product2> artikel=new map<Id, Product2>();
	private static map<Id, Id> pbe2p = new map<Id, Id>();
	
	public static void updateRechtetexte(map<id, OpportunityLineItem> olis) {
		getArtikel(olis);
		updateTexte(olis);
	} 


	private static void getArtikel(map<Id, OpportunityLineItem> olis) {
		if (artikel.isEmpty() && !olis.isEmpty()) {
			set<Id> pbeids=new set<Id>();
			// find pricebookentries for olis
			for (OpportunityLineItem oli: olis.values()) {
				if (!pbeids.contains(oli.PricebookEntryId)) pbeids.add(oli.PricebookEntryId);
			}
			// find products for pbes
			if (!pbeids.isEmpty()) {
				for (PricebookEntry pbe: [SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN: pbeids]) {
					if (!pbe2p.containsKey(pbe.id)) pbe2p.put(pbe.id, pbe.Product2Id);
				}
				// get products
				if (!pbe2p.isEmpty()) {
					for (Product2 p: [SELECT Id, TXT013__c, OeV_Rechtetext__c, VRKZ01__c FROM Product2 WHERE Id IN :pbe2p.values() ]) {
						if (!artikel.containsKey(p.id)) artikel.put(p.id,p);
					}
				}
			}
		}
	}
	
	private static void updateTexte(map<id, OpportunityLineItem> olis) {
		if (!artikel.isEmpty() && !olis.isEmpty()) {
			for (OpportunityLineItem oli: olis.values()) {
				if (pbe2p.containsKey(oli.PricebookEntryId)) {
					if (artikel.containsKey(pbe2p.get(oli.PricebookEntryId))) {
						Product2 p=artikel.get(pbe2p.get(oli.PricebookEntryId));
						if (p.VRKZ01__c=='+') 
							oli.OeV_Rechtetext__c=p.TXT013__c;
						else 
							oli.OeV_Rechtetext__c=p.OeV_Rechtetext__c;
					}
				}
			}
		}
	}

}