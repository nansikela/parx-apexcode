global class rabattUpdate {
	public static list<OpportunityLineItem> listOLI = new list<OpportunityLineItem>();
	public static Opportunity opp = new Opportunity();
	
	webservice static String init(String OpportunityId) {
		opp =[select id, StageName, Rabatt__c, locked__c, REAR2A__c from Opportunity where Id =: OpportunityId ];
		if(opp.StageName != 'Vollständig Fakturiert' && opp.StageName != 'Gelöscht' && (opp.REAR2A__c == 0 || opp.REAR2A__c == 9)) {
			getOLIs(OpportunityId);
			updateThem();
			return 'true';
		}
		else
			return system.Label.rabatt_no_Update;
  	}
  	
  	private static void getOLIs(String OpportunityId) {
  		listOLI = [select id, Discount from OpportunityLineItem where OpportunityId =: OpportunityId AND
  												   STAT2D__c != 'Fakturiert' AND
  												   STAT2D__c != 'Ausgelassen' AND
  												   STAT2D__c != 'Gelöscht' AND
  				 								   rabattfaehig__c = 1];
  	}
  	
  	private static void updateThem() {
  		for(OpportunityLineItem oli:listOLI) {
  			oli.Discount = opp.Rabatt__c;
  		}
  		if(!listOLI.isEmpty()) {
  			boolean updateOpp = false;
  			if(opp.locked__c){
  				updateOpp = true;
  			}
  			
  			if(updateOpp) {
  				opp.locked__c = false;
  				update opp;
  			} 
  			list<OpportunityLineItem> oliUpdate = new list<OpportunityLineItem>();
  			for(OpportunityLineItem oli:listOLI) {
  				oliUpdate.add(oli);
  				if(oliUpdate.size() == 100) {
  					update oliUpdate;
  					oliUpdate = new list<OpportunityLineItem>();
  				}
  			}	
  			if(!oliUpdate.isEmpty())	
  				update oliUpdate;

  			if(updateOpp) {
  				opp.locked__c = true;
  				update opp;
  			} 	
  		}
  	}
}