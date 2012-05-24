@isTest
private class RechnungGutschriftTest {

   private static testMethod void test1(){
   		systemHelper.isDebug=true;
        Fall__c fall = createTestobjectForTests('Nach Aufwand', true);
        fall.letzte_Rechnung__c=System.now().addMonths(-2);
        update fall;
        Id fallId = fall.Id;
       	createAnyTimecards(fallId,1);
        test.startTest();
        String sRechnungsNummer = createRechnung.createRechnung(fallId);
        test.stopTest();
        		
		list<Timecard__c> listTimecard = [select id, Fall__c, berechnet__c, Berechenbar__c, von__c, verrechenbar__c from Timecard__c where Fall__c =: fallId];
		list<Posten__c> listPosten = [select id, Rechnung__c from Posten__c where Rechnung__c=: sRechnungsNummer];
		Timecard__c oTimecard = listTimecard.get(0);
		Debitoren_Rechnung__c r = [SELECT Id, Rechnungsempfaenger__c FROM Debitoren_Rechnung__c WHERE Id =:sRechnungsNummer];
		if (r!=null) {
			Account account = new Account();
			account.Name = 'Test Parx Account FallTriggerHelper';
			account.BillingStreet='Test';
			account.BillingCity='Test';
			account.BillingCountry='Test';
			account.BillingPostalCode='Test';
			account.Type = 'Klient';
			insert account;
			r.Rechnungsempfaenger__c=account.id;
			update r;
		}

		System.assertNotEquals('false',sRechnungsNummer);
		System.assertNotEquals(null,sRechnungsNummer);
		System.assert(oTimecard.berechnet__c);
		System.assert(oTimecard.verrechenbar__c);
		System.assertEquals(0,oTimecard.Berechenbar__c);	
		//System.assert(listTimecard.size() == listPosten.size());
		System.assertEquals(listTimecard.size(),listPosten.size());
     }
     
  /* Kategorie=Pauschale B -> es muss ein zusätzlicher Timecard im Fall angelegt werden. Wie gehabt müssen die Berechnebar = true auf Rechnung
   * als Posten kopiert werden
   */
  private static testMethod void test2(){
  	systemHelper.isDebug=true;
        Fall__c fall = createTestobjectForTests('Nach Aufwand', true);
        Id fallId = fall.Id; 
        createCoachingTimecards(fallId,5);
        
        test.startTest();
        String sRechnungsNummer = createRechnung.createRechnung(fallId);
        if (sRechnungsNummer!='false' && sRechnungsNummer.length()==18) {
        	Id reid=[Select id from Debitoren_Rechnung__c where id=:sRechnungsNummer].Id;
        	createGutschrift.createGutschrift(reid);
        }	
       	test.stopTest();
        System.assert(sRechnungsNummer!='false');
        
		list<Timecard__c> listTimecard = [select id, Fall__c, berechnet__c, Berechenbar__c, von__c from Timecard__c where Fall__c =: fallId];
		list<Posten__c> listPosten = [select id, Rechnung__c from Posten__c where Rechnung__c=: sRechnungsNummer];
		Timecard__c oTimecard = listTimecard.get(0);

		//System.assertEquals(7,listTimecard.size());
		//System.assertEquals(5,listPosten.size());
		//System.assert(listTimecard.size() == listPosten.size());
		//System.assert(listTEMPtimecard.size() < listTimecard.size());
     }
        
  /* Kategorie=Pauschale B -> es exisitiert jedoch eine Timecard mit Pauschale die verrechnet worden ist, daher soll keine zusätzliche Timecard angelegt werden. 
   * Wie gehabt müssen die Berechenbar = true auf Rechnung als Posten kopiert werden.
   */   
   private static testMethod void test3(){
   	systemHelper.isDebug=true;
        Fall__c fall = createTestobjectForTests('Seminar Pauschale', false);
        Id fallId = fall.Id; 
        list<Timecard__c> listTEMPtimecard = createAnyTimecards(fallId,0);
        test.startTest(); 
        String sRechnungsNummer = createRechnung.createRechnung(fallId);
        test.stopTest();
        		
		list<Timecard__c> listTimecard = [select id, Fall__c, berechnet__c, Berechenbar__c, von__c from Timecard__c where Fall__c =: fallId];
		list<Posten__c> listPosten = [select id, Rechnung__c from Posten__c where Rechnung__c=: sRechnungsNummer];

		System.assert('false' != sRechnungsNummer);
     }
    
  /* Kategorie = Nach Aufwand -> erstelle wie aus Test 1 einen Fall + Rechnung
   *  eigentliche Test: Wenn alle Timecards abgerechnet worden sind, darf eine Rechnung nicht erstellt werden da keine abzurechnen sind
   */ 
   private static testMethod void test4(){
   	systemHelper.isDebug=true;
        Fall__c fall = createTestobjectForTests('Nach Aufwand', false);
        fall.Coach__c=[SELECT ID FROM User WHERE IsActive=true limit 1].ID;
        Id fallId = fall.Id; 
        createAnyTimecards(fallId,0);
        test.startTest();
        String sRechnungsNummer = createRechnung.createRechnung(fallId);
        test.stopTest();
        		
		list<Timecard__c> listTimecard = [select id, Fall__c, berechnet__c, Berechenbar__c, von__c from Timecard__c where Fall__c =: fallId];
		list<Posten__c> listPosten = [select id, Rechnung__c from Posten__c where Rechnung__c=: sRechnungsNummer];
		Timecard__c oTimecard = listTimecard.get(0);

		System.assert(sRechnungsNummer != 'false');
		System.assert(sRechnungsNummer != null);
		System.assert(oTimecard.berechnet__c);
		System.assertEquals(0,oTimecard.Berechenbar__c);	
		System.assertEquals(listTimecard.size(),listPosten.size());
		
		sRechnungsNummer = createRechnung.createRechnung(fallId);
		//System.assertEquals('Keine Posten für eine Rechnung gefunden, Rechnung wurde nicht erstellt!',sRechnungsNummer);
		
		//fall.letzte_Rechnung__c = null;
		//update fall;
		
		sRechnungsNummer = createRechnung.createRechnung(fallId);
		
		//System.assertEquals('Keine Posten für eine Rechnung gefunden, Rechnung wurde nicht erstellt!',sRechnungsNummer);
		
     } 
     
   private static testMethod void test5(){
   	systemHelper.isDebug=true;
     	Fall__c fall = createTestobjectForTests('Seminar Pauschale', false);	
     	createAnyTimecards(fall.Id, 4);
     	test.startTest();
     	String sRechnungsNummer = createRechnung.createRechnung(fall.Id);
     	test.stopTest();
     	
     	list<Timecard__c> listTimecard = [select id, Fall__c, berechnet__c, Berechenbar__c, von__c from Timecard__c where Fall__c =: fall.Id];
 		list<Posten__c> listPosten = [select id, Rechnung__c from Posten__c where Rechnung__c=: sRechnungsNummer];    
 		Timecard__c oTimecard = [select id, verrechenbar__c from Timecard__c where Aktivitaet__c like '%Coaching%' and Fall__c =: fall.Id limit 1];
 		
 		// 5 Coaching + 4 Pauschale -> es sollte zusätzlich noch 1 vom Trigger Pauschalen angelegt werden, also =10
 		System.assertEquals(14,listTimecard.size());
 		
 		//Timecard muss auf nicht verrechenbar seien, obwohl diese als verrechenebar erzeugt worden ist
 		System.assert(oTimecard.verrechenbar__c);
 			
     }
         
   private static testMethod void test6(){
   	systemHelper.isDebug=true;
     	Fall__c fall = createTestobjectForTests('Coaching Pauschale', true);	//legt den Fall vor 6 Monaten an	
     	list<Timecard__c> listTEMPtc = createAnyTimecards(fall.Id, 4);
     	
     	String sRechnungsNummer = createRechnung.createRechnung(fall.Id);
     	
     	list<Timecard__c> listTimecard = [select id, Fall__c, berechnet__c, Berechenbar__c, von__c,Aktivitaet__c 
     			from Timecard__c where verrechenbar__c = true and Fall__c =: fall.Id];
     	list<Posten__c> listPosten = [select id, Rechnung__c from Posten__c where Rechnung__c=: sRechnungsNummer];  
     	
     	System.assertEquals(10 , listTimecard.size()); 
     	//System.assertEquals(14, listPosten.size());
     	//System.assertEquals(9, listTimecard.size());
     	
     	fall.letzte_Rechnung__c = null;
     	update fall;
     	test.startTest(); 
     	sRechnungsNummer = createRechnung.createRechnung(fall.Id);
     	test.stopTest();
     	System.assert(sRechnungsNummer != 'false');	
     	
     }
     
   private static testMethod void test7(){
   	systemHelper.isDebug=true;
     	Fall__c fall = createTestobjectForTests('Coaching Pauschale', false);
     	Timecard__c oTimecard = [select Id from Timecard__c where Fall__c =:fall.Id limit 1];
     	
     	delete oTimecard;
     	
     	createTimecardLastMonth(fall.Id, -1, true);
     	test.startTest();
     	String sRechnungsNummer = createRechnung.createRechnung(fall.Id);
     	test.stopTest();
     	     	
     	System.assert('false'!= sRechnungsNummer);
     		
     }
     
     private static testmethod void test8() {
     	// test der createRechnung dazu veranlasst, fehlende Pauschalen anzulegen
     	Fall__c fall = createTestobjectForTests('Pauschale C', true);
     	delete [select Id from Timecard__c where Fall__c =:fall.Id];
     	//Timecard__c oTimecard = [select Id from Timecard__c where Fall__c =:fall.Id limit 1];
     	test.startTest();
     	String sRechnungsNummer = createRechnung.createRechnung(fall.Id);
     	test.stopTest();
     }
     	
///////############## Hilfsklassen für Tests  ###############//////////////     
   private static Fall__c createTestobjectForTests(String fallkategorie, boolean bSetTestDate){
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
        fall.Fallkategorie__c = fallkategorie;
        //fall.Coach__c  = '00520000000lauPAAQ';
        fall.Klient__c = contact.Id;   
        fall.Status__c = 'Coach zugeordnet';
        fall.Rechnungsempfaenger__c = account.Id;
        fall.Kostentraeger__c = 'Klient';
        fall.Betrag_Pauschale__c=1;
        if(bSetTestDate) fall.CreatedDate_OnlyForTest__c = System.now().addMonths(-6);
        //fall.Datum_Fallkategorie_Aenderung__c = System.today()+60;
        insert fall;
        
     	return fall;
     }
     
   private static void createTimecardLastMonth(Id fallId, Integer iMonth, Boolean bBerechnet){
     	Datetime jetzt = Datetime.now(); 
     	Timecard__c falldokumenatation = new Timecard__c();
     	falldokumenatation.Aktivitaet__c = 'Seminar Pauschale';
     	falldokumenatation.Fall__c = fallId;
     	falldokumenatation.von__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 0, 0, 0).addMonths(iMonth);
     	//falldokumenatation.bis__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 23, 59, 59).addMonths(iMonth);
     	falldokumenatation.Dauer_min__c = 60;
     	falldokumenatation.verrechenbar__c = true;
     	falldokumenatation.createdByTrigger__c = true;
     	falldokumenatation.berechnet__c  = bBerechnet; 
     	
     	insert falldokumenatation;
     	falldokumenatation = new Timecard__c();
     	falldokumenatation.Aktivitaet__c = 'Erstgespräch';
     	falldokumenatation.Fall__c = fallId;
     	falldokumenatation.von__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 11, 05, 11).addMonths(iMonth);
     	falldokumenatation.bis__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 11, 20, 11).addMonths(iMonth);
     	falldokumenatation.verrechenbar__c = false;
     	falldokumenatation.createdByTrigger__c = false;
     	insert falldokumenatation;
     }
     
   private static list<Timecard__c> createAnyTimecards(Id fallId, Integer iZahlPauschle){
     	//Falldokumentation erstellen 
     	list<Timecard__c> tempList = new list<Timecard__c>();
     	Datetime jetzt = Datetime.now(); 
     	Integer j=13;
     	Integer t=10;
     	Integer c = 10;
     	iZahlPauschle++;
     	for(Integer i=0; i<5; i++){
     		Timecard__c falldokumenatation = new Timecard__c();
     		falldokumenatation.Aktivitaet__c = 'Coaching';
     		falldokumenatation.Fall__c = fallId;
     		falldokumenatation.von__c = Datetime.newInstance(jetzt.year(), jetzt.month()-1, j, 11, 05, 11);	
     		falldokumenatation.bis__c = Datetime.newInstance(jetzt.year(), jetzt.month()-1, j, 11, 05+c, 11);
     		//falldokumenatation.Dauer_min__c = t;
     		falldokumenatation.Dauer_min__c = 60;
     		falldokumenatation.verrechenbar__c = true;
     		falldokumenatation.berechnet__c  = false;
     		t=t+10;
     		c = c+10;
     		j++;
     		tempList.add(falldokumenatation);
     	}
     	for(Integer k=2; k<=iZahlPauschle;k++){
     		Timecard__c falldokumenatation = new Timecard__c();
     		falldokumenatation.Aktivitaet__c = 'Seminar Pauschale';
     		falldokumenatation.Fall__c = fallId;
     		falldokumenatation.von__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 0, 0, 0).addMonths(-k);
     		//falldokumenatation.bis__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 23, 59, 59).addMonths(-k);
     		falldokumenatation.Dauer_min__c = 60;
     		falldokumenatation.verrechenbar__c = true;
     		falldokumenatation.createdByTrigger__c = true;
     		tempList.add(falldokumenatation);
     	}
     	for(Integer k=2; k<=iZahlPauschle;k++){
     		Timecard__c falldokumenatation = new Timecard__c();
     		falldokumenatation.Aktivitaet__c = 'Erstgespräch';
     		falldokumenatation.Fall__c = fallId;
     		falldokumenatation.von__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 11, 05, 11).addMonths(-k);
     		falldokumenatation.Dauer_min__c = 60;
     		//falldokumenatation.bis__c = Datetime.newInstance(jetzt.year(), jetzt.month(), 01, 11, 20, 11).addMonths(-k);
     		falldokumenatation.verrechenbar__c = false;
     		falldokumenatation.createdByTrigger__c = false;
     		tempList.add(falldokumenatation);
     	}
     	insert tempList; 
     	 
     	return tempList;
     }
     
   private static void createCoachingTimecards(Id fallId, Integer iMonth){
   		Datetime dtJetzt = Datetime.now();
   		Integer iTemp = iMonth;
   		list<Timecard__c> tempList = new list<Timecard__c>();
   		for(Integer i=0; i<iMonth; i++){
     		Timecard__c falldokumenatation = new Timecard__c();
     		falldokumenatation.Aktivitaet__c = 'Coaching';
     		falldokumenatation.Fall__c = fallId;
     		falldokumenatation.von__c = Datetime.newInstance(dtJetzt.year(), dtJetzt.month(), dtJetzt.day(), 12, 00, 00).addMonths(-iTemp);	
     		//falldokumenatation.bis__c = Datetime.newInstance(falldokumenatation.von__c.year(), falldokumenatation.von__c.month()-1, 
     										//falldokumenatation.von__c.day(), 15, 00, 00);
     		falldokumenatation.Dauer_min__c = 60;
     		falldokumenatation.verrechenbar__c = false;
     		falldokumenatation.berechnet__c  = false;
     		iTemp--;
     		tempList.add(falldokumenatation);
     	}
     	Timecard__c falldokumenatation = new Timecard__c();
     	falldokumenatation.Aktivitaet__c = 'Erstgespräch';
     	falldokumenatation.Fall__c = fallId;
     	falldokumenatation.von__c = Datetime.newInstance(dtJetzt.year(), dtJetzt.month(), 01, 11, 05, 11).addMonths(iMonth);
     	//falldokumenatation.bis__c = Datetime.newInstance(dtJetzt.year(), dtJetzt.month(), 01, 11, 20, 11).addMonths(iMonth);
     	falldokumenatation.verrechenbar__c = false;
     	falldokumenatation.createdByTrigger__c = false;
     	falldokumenatation.Dauer_min__c = 60;
     	insert falldokumenatation;
     	insert tempList; 
     	   
   }  
/////////////##################### TEST ENDE #####################//////

}