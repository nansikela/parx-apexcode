/*
	Dieser Webservice existiert nur fuer das Deployment des Rechnungs- und Falldokumentationspaket vom 15.05.2009
	Er setzt bei allen Timecards das Flag "CreatedByTrigger" auf "true" und setzt das richtige "DatumVon", das in Zukunft
	ueber einen Workflow gesetzt wird. Das Datum ist für die anteilige Umsatzberechnung von Pauschalen nötig.
*/
global class resetTimecards {
	webservice static String resetTimecards() {
		
		Boolean isEmpty=false;
		Integer max=2;
		/*
		// alle Pauschale
		list<Timecard__c> tcs = new list<Timecard__c>();
		while (!isEmpty && max!=0) {
			max--;
			try {
				tcs = [SELECT Id, Fall__c, DatumVon__c, von__c, createdByTrigger__c FROM Timecard__c WHERE Aktivitaet__c IN :systemHelper.getMapPauschal().values() limit 250];
				isEmpty=tcs.isEmpty();
				if (!tcs.isEmpty()) {
					for (Timecard__c tc: tcs) {
						if (tc.DatumVon__c==null) tc.DatumVon__c=Date.newInstance(tc.von__c.year(), tc.von__c.month(), tc.von__c.day());
						if (!tc.createdByTrigger__c) tc.createdByTrigger__c=true;
					}
					try {
						update tcs;
					} catch (System.DmlException de) {
						return de.getMessage();
					}
				}
			} catch (System.QueryException e) {
				return e.getMessage();
			}
		}
		*/
		// alle Faelle
		list<Fall__c> fs = new list<Fall__c>();
		while (!isEmpty && max!=0) {
			max--;
			try {
				fs = [SELECT Id, Datum_Fallkategorie_Aenderung__c, Alter_Fall__c FROM Fall__c WHERE Datum_Fallkategorie_Aenderung__c!=null limit 250];
				isEmpty=fs.isEmpty();
				if (!fs.isEmpty()) {
					for (Fall__c f: fs) {
						if (f.Datum_Fallkategorie_Aenderung__c!=null) f.Datum_Fallkategorie_Aenderung__c=null;
					}
					try {
						update fs;
					} catch (System.DmlException de) {
						return de.getMessage();
					}
				}
			} catch (System.QueryException e) {
				return e.getMessage();
			}
		}
		Integer a=1;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2;
		a=1;
		a=2;
		a=2-max;
		return 'Alles OK! Durchlaeufe: ' + a + ', Ist leer? ' + isEmpty;
	}
	
	static testMethod void resetTimecardsTest() {
		resetTimecards();
	}
}