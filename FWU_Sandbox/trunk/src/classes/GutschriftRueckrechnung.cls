global class GutschriftRueckrechnung {
	
	private static list<Rechnung__c> rechnung = new list<Rechnung__c>();
	
	webservice static String init(list<String> RechnungId, String isRueckrechnung) {
		if(!RechnungId.isEmpty() && RechnungId != null && isRueckrechnung != null) {
			getRechnung(RechnungId);
			if(Rechnung.get(0).is_Rueckrechnung__c != null && Rechnung.get(0).is_Rueckrechnung__c != '' )
			   return 'Nicht möglich wieder zu clicken';
			if(isRueckrechnung == 'True' && rechnung.get(0).REA211__c != 1 && rechnung.get(0).REA211__c != 7)
			   return 'Falsche Rechnungsart';
			nummerieren();
			congaActivation(isRueckrechnung);
			return 'true';
		}
		
		return 'Bitte etwas auswählen';
	}
	
	private static void getRechnung(list<String> RechnungId) {
		rechnung = [select id, nummer_Rechnung__c, is_Rueckrechnung__c, Conga_Workflow_for_Activation__c, REA211__c from Rechnung__c where id IN: RechnungId];
	}
	
	private static void nummerieren() {
		onRechnung.onInsert(rechnung, true);				
	}
	
	private static void congaActivation(String isRueckrechnung) {
		for(Rechnung__c r:rechnung) {
			r.Conga_Workflow_for_Activation__c = True;
			r.is_Rueckrechnung__c = isRueckrechnung;
		}
		update rechnung;			
	}
}