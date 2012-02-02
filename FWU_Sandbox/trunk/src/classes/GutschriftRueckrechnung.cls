global class GutschriftRueckrechnung {
	
	private static list<Rechnung__c> rechnung = new list<Rechnung__c>();
	
	webservice static String init(list<String> RechnungId, String isRueckrechnung) {
		if(!RechnungId.isEmpty()) {
			getRechnung(RechnungId);
			nummerieren();
			congaActivation(isRueckrechnung);
			return 'true';
		}
		
		return 'no datas';
	}
	
	private static void getRechnung(list<String> RechnungId) {
		rechnung = [select id, nummer_Rechnung__c, is_Rueckrechnung__c, Conga_Workflow_for_Activation__c from Rechnung__c where id IN: RechnungId];
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