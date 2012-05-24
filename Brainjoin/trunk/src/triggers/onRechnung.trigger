trigger onRechnung on Debitoren_Rechnung__c (after insert, after update, after delete, 
after undelete, before update, before insert) {
	System.debug('PARX trigger onRechnung START');
	map<id, Double> invoiceCreditNoteAmount = new map<id, Double>();
	List<Id> fallids = new List<Id>();
	list<Debitoren_Rechnung__c> listRechnungen = new list<Debitoren_Rechnung__c>();
	list<Id> listEmpfaengerId = new list<Id>();
	list<Id> listCheckEmpfaenger = new list<Id>();
	map<id, boolean> mapIsPersonAccount = new map<id, boolean>();
	System.debug('PARX trigger onRechnung SQOL 1');
	//RechnungGutschrift.setDatensatzTyp('Rechnung');
	String DSRechnungId=[SELECT ID FROM RecordType WHERE Name='Rechnung' AND SobjectType='Debitoren_Rechnung__c' limit 1].Id;
	boolean bUpdateKlientAdress = false;
	
	
	//hier wird geprüft, ob der Rechnugsempfänger ein Klient ist. Wenn ja wird die Operation ausgeführt
	if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert)){
		for (Integer i=0; i<trigger.size; i++) {
				if(trigger.new[i].Rechnungsempfaenger__c != null) {
					listCheckEmpfaenger.add(trigger.new[i].Rechnungsempfaenger__c);
				}
		}
		if(!listCheckEmpfaenger.isEmpty()){
				mapIsPersonAccount = onRechnungHelper.isPersonaccount(listCheckEmpfaenger);
				bUpdateKlientAdress = true;
		}
	}
	// ein wechsel in der Referenz zur Rechnung ist nicht vorgesehen
	// aktuell verhindert durch den Schreibschutz auf dem Seitenlayout
	for (Integer i=0; i<trigger.size; i++) {
		System.debug('PARX nur nach Update ausfuehren');
		if (trigger.isAfter) {
			System.debug('PARX nur nach Delete ausfuehren');
			if (trigger.isDelete) {
				invoiceCreditNoteAmount.put(trigger.old[i].Rechnung__c, trigger.old[i].Betrag_brutto__c*(-1));
				// nur fuer Rechnungen
				if (Trigger.old[i].RecordTypeId==DSRechnungId) fallids.add(Trigger.old[i].Fall__c);
			} else {
				// ein Rechnungsbezug definiert eine gutschrift
				// wir koennten auch ueber den DS Typ gehen
				// das verlangt aber ein SOQL Statement
				if (trigger.new[i].Rechnung__c!=null) {
					if (trigger.isInsert) {
						invoiceCreditNoteAmount.put(trigger.new[i].Rechnung__c, trigger.new[i].Betrag_brutto__c);
					}
					if (trigger.isUpdate && 
						trigger.old[i].Betrag_brutto__c!=trigger.new[i].Betrag_brutto__c) {
							invoiceCreditNoteAmount.put(trigger.new[i].Rechnung__c, trigger.new[i].Betrag_brutto__c-trigger.old[i].Betrag_brutto__c);
					}
					// virtuelles loeschen
					if (trigger.isUpdate &&
						trigger.old[i].Status__c != trigger.new[i].Status__c &&
						trigger.new[i].Status__c=='storniert') {
						invoiceCreditNoteAmount.put(trigger.new[i].Rechnung__c, trigger.new[i].Betrag_brutto__c*(-1));
					}
					
					// virtuelles loeschen
					if (trigger.isUpdate &&
						trigger.old[i].Status__c != trigger.new[i].Status__c &&
						trigger.old[i].Status__c=='storniert') {
						invoiceCreditNoteAmount.put(trigger.new[i].Rechnung__c, trigger.new[i].Betrag_brutto__c);
					}
					if (trigger.isUndelete) {
						invoiceCreditNoteAmount.put(trigger.new[i].Rechnung__c, trigger.new[i].Betrag_brutto__c);
					}
				}
			}
		}
		if(bUpdateKlientAdress) {
			if(trigger.new[i].Rechnungsempfaenger__c != null) {
				if(mapIsPersonAccount.containsKey(trigger.new[i].Rechnungsempfaenger__c)){			
					listRechnungen.add(trigger.new[i]);
					listEmpfaengerId.add(trigger.new[i].Rechnungsempfaenger__c);		
				}
			}
		}
	}
	System.debug('PARX size of invoiceCreditNoteAmount ' + invoiceCreditNoteAmount.size());
	
	if (!invoiceCreditNoteAmount.isEmpty()
		&& !onRechnungHelper.hasAlreadyRun() 
		) {
		System.debug('PARX value of first entry of invoiceCreditNoteAmount  ' + invoiceCreditNoteAmount.values().get(0));
		onRechnungHelper.updateInvoices(invoiceCreditNoteAmount);
	}
	
	System.debug('PARX size of fallids ' + fallids.size());
	if (!fallids.isEmpty()) {
		onRechnungHelper.updateFieldLastInvoice(fallids);
	}
	
	if(!listRechnungen.isEmpty()) onRechnungHelper.updateKlientAdressField(listRechnungen, listEmpfaengerId);
	
	System.debug('PARX trigger onRechnung ENDE');
}