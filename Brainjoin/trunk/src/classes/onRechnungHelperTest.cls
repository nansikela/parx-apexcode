@isTest
private class onRechnungHelperTest {

	/*
	* Testet das Anlegen der Rechnung bzw. Gutschrift in der Klasse onRechnungHelper und RechnungGutschrift
	*/
	/*
	static testMethod void testonRechnungHelperCreateInvoice() {
		onRechnungHelper.setAlreadyRun();
		onRechnungHelper.hasAlreadyRun();
		onRechnungHelper.resetAlreadyRun();
		
		// Account erstellen 
		Account account = new Account();
		account.Name = 'Test Parx Account';
		account.Type = 'Klient';
		insert account;			
		
		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.FirstName = 'Parx Contact name';
		contact.LastName = 'Parx Contact Lastname';
		insert contact;
		
		//Fall erstellen  Account Id = 001R0000006hEdiIAE
		Fall__c fall = new Fall__c();
		fall.Fallkategorie__c = 'Nach Aufwand';
		//fall.Coach__c  = '00520000000lauPAAQ';
		fall.Klient__c = contact.Id;
		
		fall.Status__c = 'Coach zugeordnet';
		fall.Rechnungsempfaenger__c = account.Id;
		fall.Kostentraeger__c = 'Klient';
		//fall.Coaching_Center__c = account.Id;
		insert fall;
		
		//Falldokumentation erstellen 
		Timecard__c falldokumenatation = new Timecard__c();
		falldokumenatation.Fall__c = fall.Id;
		falldokumenatation.Aktivitaet__c = 'Coaching';
		falldokumenatation.von__c = Datetime.newInstance(2007, 01, 25, 11, 11, 11);
		falldokumenatation.Dauer_min__c = 60;
		falldokumenatation.verrechenbar__c = true; 
		insert falldokumenatation;
		
		
		//Falldokumentation erstellen 
		Timecard__c falldokumenatation2 = new Timecard__c();
		falldokumenatation2.Fall__c = fall.Id;
		falldokumenatation2.Aktivitaet__c = 'Coaching';
		falldokumenatation2.von__c = Datetime.newInstance(2007, 01, 25, 11, 11, 11);
		falldokumenatation2.Dauer_min__c = 60;
		falldokumenatation2.verrechenbar__c = true; 
		insert falldokumenatation2;
		
		String rechnungsId  = RechnungGutschrift.createRechnung(fall.Id);
		
		
		Debitoren_Rechnung__c  rechnung = [select Id, Fall__c, Klient__c, Betrag_brutto__c, Betrag_Gutschrift__c from Debitoren_Rechnung__c where Id =:rechnungsId limit 1];
		System.assert(rechnung.Fall__c == fall.Id);
		//System.assert(rechnung.Betrag_brutto__c == 547.40);
		//System.assert(rechnung.Betrag_Gutschrift__c == 547.40);
		
		Id rechId = rechnungsId; 
		Id gutschriftId = (Id) RechnungGutschrift.createGutschrift(rechId);
		
		Posten__c postenRechnung = [select Id, Anzahl__c, Betrag__c, Falldokumentation__c, Rechnung__c from Posten__c where Rechnung__c =:rechnung.Id limit 1];
		System.assert(postenRechnung.Betrag__c == 230.00);
		//System.assert(postenRechnung.Anzahl__c == 1);
		System.assert(postenRechnung.Falldokumentation__c == falldokumenatation.Id);
		System.assert(postenRechnung.Rechnung__c == rechnung.Id);
		
		Posten__c postenRechnung2 = [select Id, Anzahl__c, Betrag__c, Falldokumentation__c, Rechnung__c from Posten__c where Rechnung__c =:rechnung.Id limit 1];
		System.assert(postenRechnung2.Betrag__c == 230.00);
		//System.assert(postenRechnung2.Anzahl__c == 1);
		System.assert(postenRechnung2.Falldokumentation__c == falldokumenatation.Id);
		System.assert(postenRechnung2.Rechnung__c == rechnung.Id);
		
		Debitoren_Rechnung__c  gutschrift = [select Id, Fall__c, Klient__c, Betrag_brutto__c, Betrag_Gutschrift__c from Debitoren_Rechnung__c where Id =:gutschriftId limit 1];
		System.assert(gutschrift.Fall__c == fall.Id);
		//System.assert(gutschrift.Betrag_brutto__c == 547.40);
		
		Posten__c postenGutschrift = [select Id, Anzahl__c, Betrag__c, Falldokumentation__c, Rechnung__c from Posten__c where Rechnung__c =:gutschrift.Id limit 1];
		//System.assert(postenGutschrift.Betrag__c == 230.00);
		//System.assert(postenGutschrift.Anzahl__c == 60);
		//System.assert(postenGutschrift.Falldokumentation__c == falldokumenatation.Id);
		System.assert(postenGutschrift.Rechnung__c == gutschrift.Id);
		
		Posten__c postenGutschrift2 = [select Id, Anzahl__c, Betrag__c, Falldokumentation__c, Rechnung__c from Posten__c where Rechnung__c =:gutschrift.Id limit 1];
		//System.assert(postenGutschrift2.Betrag__c == 230.00);
		//System.assert(postenGutschrift2.Anzahl__c == 60);
		//System.assert(postenGutschrift2.Falldokumentation__c == falldokumenatation.Id);
		System.assert(postenGutschrift2.Rechnung__c == gutschrift.Id);
		
		Debitoren_Rechnung__c  rechnung2 = [select Id, Fall__c, Klient__c, Betrag_brutto__c, Betrag_Gutschrift__c, Gutschriftbetrag__c from Debitoren_Rechnung__c where Id =:rechnungsId limit 1];
		
		//System.assert(rechnung2.Betrag_Gutschrift__c == 0.0);
		//System.assert(rechnung2.Betrag_brutto__c == 547.40);
		//System.assert(rechnung2.Gutschriftbetrag__c == 547.40);
		System.assert(rechnung2.Fall__c == fall.Id);
		
		
		// Noch eine Rechnung im selben Monate darf nicht erstellt werden 
		String errorMessage = RechnungGutschrift.createRechnung(fall.Id);
		System.assert(errorMessage != 'false');      //ERKAN 
		
		
		//Fall erstellen  Account Id = 001R0000006hEdiIAE
		Fall__c fall2 = new Fall__c();
		fall2.Fallkategorie__c = 'Nach Aufwand';
		fall2.Coach__c  = '00520000000lauPAAQ';
		fall2.Klient__c = contact.Id;
		fall2.Status__c = 'Coach zugeordnet';
		fall2.Rechnungsempfaenger__c = account.Id;
		fall2.Kostentraeger__c = 'Klient';
		//fall2.Coaching_Center__c = account.Id;
		insert fall2;
		
		//Falldokumentation erstellen 
		Timecard__c falldokumentation3 = new Timecard__c();
		falldokumentation3.Fall__c = fall.Id;
		falldokumentation3.Aktivitaet__c = 'Coaching';
		falldokumentation3.von__c = Datetime.newInstance(2007, 01, 25, 11, 11, 11);
		falldokumentation3.Dauer_min__c = 60;
		falldokumentation3.berechnet__c = true;   
		falldokumentation3.verrechenbar__c = true; 
		insert falldokumentation3;
		
		//Es darf keine Rechnung erstellt werden, da fallDoku schon berechnet auf dem Status berechnet ist. 
		String errorMessage2 = RechnungGutschrift.createRechnung(fall2.Id);
		System.assert(errorMessage2 == 'false'); 
		
		
		
		//Fuer den Pauschal Fall
		//Fall erstellen  Account Id = 001R0000006hEdiIAE
		Fall__c fallPauschal = new Fall__c();
		fallPauschal.Fallkategorie__c = 'Pauschale A';
		fallPauschal.Coach__c  = '00520000000lauPAAQ';
		fallPauschal.Klient__c = contact.Id;
		
		fallPauschal.Status__c = 'Coach zugeordnet';
		fallPauschal.Rechnungsempfaenger__c = account.Id;
		fallPauschal.Kostentraeger__c = 'Klient';
		//fallPauschal.Coaching_Center__c = account.Id;
		
		insert fallPauschal;
		
		//Falldokumentation erstellen 
		Timecard__c falldokumentationPauschal = new Timecard__c();
		falldokumentationPauschal.Fall__c = fall.Id;
		falldokumentationPauschal.Aktivitaet__c = 'Coaching';
		falldokumentationPauschal.von__c = Datetime.newInstance(2007, 01, 25, 11, 11, 11);
		falldokumentationPauschal.Dauer_min__c = 60;
		falldokumentationPauschal.verrechenbar__c = false; 
		insert falldokumentationPauschal;
		
		String rechnungsIdPauschal  = RechnungGutschrift.createRechnung(fallPauschal.Id);		
	}
	*/
	
	/*
	* Testet das Loeschen von Rechnungen in onRechnungHelper
	*/
	
	static testMethod void testonRechnungHelperDeleteInvoice() {
		// Account erstellen 
		Account account = new Account();
		account.Name = 'Test Parx Account FallTriggerHelper';
		account.BillingStreet='Test';
		account.BillingCity='Test';
		account.BillingCountry='Test';
		account.BillingPostalCode='Test';
		account.Type = 'Klient';
		insert account;			
		
		Contact contact = new Contact();
		contact.AccountId = account.Id;
		contact.FirstName = 'Parx Contact name FallTriggerHelper';
		contact.LastName = 'Parx Contact Lastname FallTriggerHelper';
		contact.MailingStreet='TEST';
		contact.MailingCity='TEST';
		contact.MailingCountry='TEST';
		contact.MailingPostalCode='TEST';
		insert contact;
		
		//Fall erstellen  Account Id = 001R0000006hEdiIAE
		Fall__c fall = new Fall__c();
		fall.Fallkategorie__c = 'Pauschale A';
		//fall.Coach__c  = '00520000000lauPAAQ';
		fall.Klient__c = contact.Id;
		
		fall.Status__c = 'Coach zugeordnet';
		fall.Rechnungsempfaenger__c = account.Id;
		fall.Kostentraeger__c = 'Klient';
		//fall.Coaching_Center__c = account.Id;
		insert fall;
		
		//Falldokumentation erstellen 
		Timecard__c falldokumenatation = new Timecard__c();
		falldokumenatation.Fall__c = fall.Id;
		falldokumenatation.Aktivitaet__c = 'Pauschale B';
		falldokumenatation.von__c = Datetime.newInstance(2007, 01, 25, 11, 11, 11);
		//falldokumenatation.bis__c = Datetime.newInstance(2007, 01, 31, 11, 11, 11);
		//falldokumenatation.Dauer_min__c = 60;
		falldokumenatation.verrechenbar__c = true;
		falldokumenatation.createdByTrigger__c = true;
		insert falldokumenatation;
		
		
		String rechnungsId  = createRechnung.createRechnung(fall.Id);
		
		Debitoren_Rechnung__c  rechnung = [select Id, Fall__c, Klient__c, Betrag_brutto__c, Betrag_Gutschrift__c from Debitoren_Rechnung__c where Id =:rechnungsId limit 1];
		System.assert(rechnung.Fall__c == fall.Id);
		
		//Falldokumentation erstellen 
		Timecard__c falldokumenatation2 = new Timecard__c();
		falldokumenatation2.Fall__c = fall.Id;
		falldokumenatation2.Aktivitaet__c = 'Pauschale A';
		falldokumenatation2.von__c = Datetime.newInstance(2007, 01, 25, 11, 11, 11);
		//falldokumenatation2.bis__c = Datetime.newInstance(2007, 01, 31, 11, 11, 11);
		//falldokumenatation2.Dauer_min__c = 60;
		falldokumenatation2.verrechenbar__c = true;
		falldokumenatation2.createdByTrigger__c = true;
		insert falldokumenatation2;
		
		fall.Letzte_Rechnung__c=null;
		update fall;
		
		rechnungsId  = createRechnung.createRechnung(fall.Id);
		Debitoren_Rechnung__c  rechnung2 = [select Id, Fall__c, Klient__c, Betrag_brutto__c, Betrag_Gutschrift__c from Debitoren_Rechnung__c where Id =:rechnungsId limit 1];
		System.assert(rechnung2.Fall__c == fall.Id);
		
		// testen wir den Trigger:
		delete rechnung2;
		delete rechnung;
		
	}
	
}