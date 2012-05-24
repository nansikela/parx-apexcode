public class onRechnungHelper {
	private static boolean alreadyRun = false;

	public static boolean hasAlreadyRun() {
		return alreadyRun;
	}
	
	//public static void setAlreadyRun() {
	//	alreadyRun = true;
	//}
	
	//public static void resetAlreadyRun() {
	//	alreadyRun = false;
	//}
	
	/*
	* Addiert die Betraege vom Feld Gutschriftbetrag der jeweiligen Rechnung
	*/ 
	public static void updateInvoices(map<id, Double> invoiceCreditNoteAmount) {
		System.debug('PARX updateInvoices START');
		list<Debitoren_Rechnung__c> restoupdate = new list<Debitoren_Rechnung__c>();
		list<Id> rechnungIds = new list<Id>();
		System.debug('PARX updateInvoices SOQL 1');
		for (Debitoren_Rechnung__c r: [select id, Status__c, Gutschriftbetrag__c, Betrag_brutto__c, Betrag_Gutschrift__c from Debitoren_Rechnung__c where id in: invoiceCreditNoteAmount.keySet()]) {
			rechnungIds.add(r.Id);
			if (r.Gutschriftbetrag__c==null || r.Gutschriftbetrag__c==0.0) {
				r.Gutschriftbetrag__c=invoiceCreditNoteAmount.get(r.id);
			} else {
 				r.Gutschriftbetrag__c=r.Gutschriftbetrag__c+invoiceCreditNoteAmount.get(r.id);
			}
			//r.Betrag_Gutschrift__c = r.Betrag_brutto__c;
			//r.Betrag_Gutschrift__c =  r.Betrag_brutto__c - r.Gutschriftbetrag__c;
			r.Betrag_Gutschrift__c = 0; 
			r.Betrag_Gutschrift__c = r.Gutschriftbetrag__c;
			// eine stornierte Rechnung muss den status 'storniert' haben
			r.Status__c='storniert';
			restoupdate.add(r);
		}
		
		if (!restoupdate.isEmpty()) {
			try {
				System.debug('PARX updateInvoices DML 1');
				update restoupdate;
			} catch (System.DmlException e) {
				System.debug('PARX Update Fehler restoupdate ' + e.getMessage());
			}
		} 
		System.debug('PARX updateInvoices ENDE');
	}
	
	/*
	* Setzt das Datum der Letzte_Rechnung__c im Fall auf das der letzten Rechnung
	* zurueck, falls die juengste Rechnung geloescht wird
	*/
	public static void updateFieldLastInvoice(List<Id> fallids) {
		System.debug('PARX updateFieldLastInvoice START');
		Map<Id, DateTime> invoicedates = new Map<Id, DateTime>();
		List<Fall__c> faelle = new List<Fall__c>();
		List<Id> fallidstonull = new List<Id>();
		
		// erst holen wir uns alle faelle
		// wir brauchen alle faelle, da wir ueberall aenderungen machen werden
		System.debug('PARX updateFieldLastInvoice SOQL 1');
		for (Fall__c f: [SELECT Id, Letzte_Rechnung__c FROM Fall__c WHERE Id IN :fallids]) {
			faelle.add(f);
		}
		
		try {
			// alle zugehoerigen Rechnungen
			System.debug('PARX updateFieldLastInvoice SOQL 2');
			for (Debitoren_Rechnung__c r: [SELECT Id, Fall__c, CreatedDate FROM Debitoren_Rechnung__c WHERE Fall__c IN :fallids]) {
				// finden wir die juengste Rechnung je fall, oder merken uns, dass es keine gibt
				if (!invoicedates.containsKey(r.Fall__c)) {
					// wir hatten bisher zu diesem Fall noch keine Rechung ...
					invoicedates.put(r.Fall__c, r.CreatedDate);
				} else {
					// wir aendern nur etwas, wenn das neue Datum groesser ist,
					// als das, was wir bereits in der Map haben
					if (r.CreatedDate>invoicedates.get(r.Fall__c)) {
						invoicedates.remove(r.Fall__c);
						invoicedates.put(r.Fall__c,r.CreatedDate);
					}
				}
			}
		} catch (System.QueryException e) {
			// es gibt gar keine Rechnung zu keinem Fall
			System.debug('PARX QueryException updateFieldLastInvoice (keine Rechnung mehr zum Fall) ' + e.getMessage());
		}
		
		// wenn wir keine invoicedates und keine fallidstonull haben, ist ALLES zu nullen
		if (invoicedates.isEmpty() && fallidstonull.isEmpty()) fallidstonull=fallids.clone();
		
		// Methode, die die Null in die Felder schreibt
		if (!fallidstonull.isEmpty()) {
			faelle=writeNullsInFaelle(faelle,fallidstonull);
		}
		
		// Methode, die die Zeitstempel in die Felder schreibt
		if (!invoicedates.isEmpty()) {
			faelle=writeDateTimeInFaelle(faelle, invoicedates);
		}
		
		// update
		if (!faelle.isEmpty()) {
			try {
				System.debug('PARX updateFieldLastInvoice DML 1');
				update faelle;
			} catch (System.DmlException e) {
				System.debug('PARX update Fehler bei faelle: ' + e.getMessage());
			}
		}
		
		System.debug('PARX updateFieldLastInvoice ENDE');
	}
	
	/*
	* Hilfsmethode fuer updateFieldLastInvoice
	* Aktualisiert das Feld "Letzte_Rechnung__c" im Fall mit den Wert null
	*/
	public static List<Fall__c> writeNullsInFaelle(List<Fall__c> faelle, List<Id> fallids) {
		System.debug('PARX writeNullsInFaelle START');
		List<Fall__c> faellereturn = new List<Fall__c>();
		Map<Id, Id> fallidmap = new Map<Id, Id>();
		if (!fallids.isEmpty()) {
			// mit einer Map gehts leichter
			for (Id fid: fallids) {
				if (!fallidmap.containsKey(fid)) fallidmap.put(fid, fid);
			}
			for (Fall__c f: faelle) {
				if (fallidmap.containsKey(f.id)) f.Letzte_Rechnung__c=null;
				faellereturn.add(f);
			}
		}
		
		System.debug('PARX writeNullsInFaelle ENDE');
		return faellereturn;
	}
	
	/*
	* Hilfsmethode fuer updateFieldLastInvoice
	* Aktualisiert das Feld "Letzte_Rechnung__c" im Fall anhand einer Map mit
	* DateTimes
	*/
	public static List<Fall__c> writeDateTimeInFaelle(List<Fall__c> faelle, Map<Id, DateTime> invoicedates) {
		System.debug('PARX writeDateTimeInFaelle START');
		List<Fall__c> faellereturn = new List<Fall__c>();
		if (!faelle.isEmpty() && !invoicedates.isEmpty()) {
			for (Fall__c f: faelle) {
				if (invoicedates.containsKey(f.id)) f.Letzte_Rechnung__c=invoicedates.get(f.id);
				faellereturn.add(f);
			}
		}
		System.debug('PARX writeDateTimeInFaelle ENDE');
		return faellereturn;
	}

	public static void updateKlientAdressField(list<Debitoren_Rechnung__c> listRechnung, list<Id> listEmpfaengerId){
		list<Account> listAccount = [select Id, PersonMailingPostalCode, PersonMailingStreet, Adresszusatz_Kontakt__pc,
										PersonMailingCity, PersonMailingCountry from Account where Id in: listEmpfaengerId];

		for(Integer i=0; i<listRechnung.size(); i++){
				for(Account oAccount: listAccount){
					if(listRechnung.get(i).Rechnungsempfaenger__c == oAccount.Id){
							listRechnung.get(i).Klient_PLZ__c = oAccount.PersonMailingPostalCode;
							listRechnung.get(i).Klient_Strasse__c = oAccount.PersonMailingStreet;
							listRechnung.get(i).Klient_Ort__c = oAccount.PersonMailingCity;
							listRechnung.get(i).Klient_Land__c = oAccount.PersonMailingCountry;
							listRechnung.get(i).Klient_Adresszusatz__c=oAccount.Adresszusatz_Kontakt__pc;
					}	
				}
		}
	}
	
	public static map<id, boolean> isPersonaccount (list<Id> listAccountId){
		list<Account> listKlient = [select Id, IsPersonAccount from Account where Id in :listAccountId];
		map<id, boolean> mapIsKlient = new map<id, boolean>();
		for(Account oAccount : listKlient) {
				if(oAccount.IsPersonAccount){
						mapIsKlient.put(oAccount.Id, true);	
				}		
		}
		return mapIsKlient;

	}
}