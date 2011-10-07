@isTest
private class AfterOnProductTEST {
	
    static testMethod void afterProductTestmethod() {
        
   		String OFFENE_SEMINARE = '012200000004Y3H';
		String PHASE_ANMELDUNG = 'Anmeldung';
		String PHASE_RECHNUNG = 'Rechnung';   
        
        /**************************
         * Create account
         **************************/
        
        Account testAccount = new Account();
        testAccount.name = 'Testfirma';
        insert testAccount;
        
        
        /***********************************************
         * Create contacts with reference to account
         ***********************************************/        
    
    	List<Contact> Kontaktliste = new list<Contact>();
       
        // No E-Mail address set
    	Contact testContactA = new Contact();
    	testContactA.lastname = 'Müller';
    	testContactA.accountid = testAccount.id;
    	
    	// E-Mail address set
    	Contact testContactB = new Contact();
    	testContactB.lastname = 'Meier';
    	testContactB.accountid = testAccount.id;  	
    	testContactB.email = 'meier@test.com';   	
    	
    	KontaktListe.add(testContactA);
    	KontaktListe.add(testContactB);
    	
    	insert KontaktListe;
    	
    	
        /***********************************************
         * Create a product
         ***********************************************/  
    	
		Product2 p = new Product2();
		p.Name = 'Testseminar';
		p.Seminargebuehr__c = 1200; 
		p.Seminarende__c = Date.Today().addDays(10); 
		p.Seminarbeginn__c = Date.Today().addDays(5); 
		p.SeminarCodeID__c = 'Test Code';
		p.MwSt__c = '20';
		insert p;
		
		
        /***********************************************
         * Create opportunities with reference to contacts and product
         ***********************************************/  
             	
    	List<Opportunity> Opportunityliste = new list<Opportunity>();
    	
    	// Opportunity of contact without e-mail address
    	Opportunity testOpportunityA = new Opportunity();
		testOpportunityA.Name = 'Test Seminar Opportunity A';
		testOpportunityA.RecordTypeId = OFFENE_SEMINARE;
		testOpportunityA.Seminarteilnehmer__c = testContactA.Id;
		testOpportunityA.Seminar__c = p.Id;
		testOpportunityA.StageName = PHASE_ANMELDUNG;
		testOpportunityA.CloseDate = Date.Today().addDays(10);
    	
    	Opportunity testOpportunityB = new Opportunity();
		testOpportunityB.Name = 'Test Seminar Opportunity B';
		testOpportunityB.RecordTypeId = OFFENE_SEMINARE;
		testOpportunityB.Seminarteilnehmer__c = testContactB.Id;
		testOpportunityB.Seminar__c = p.Id;
		testOpportunityB.StageName = PHASE_ANMELDUNG;
		testOpportunityB.CloseDate = Date.Today().addDays(10);    	
    	
    	Opportunityliste.add(testOpportunityA);
    	Opportunityliste.add(testOpportunityB);
    	    	
    	insert Opportunityliste;
 
 
        /***********************************************
         * Update product (field that triggers e-mails)
         * Test: No E-Mail sent because of wrong opportunity status
         ***********************************************/     	
         
    	p.Fotoprotokoll_hochgeladen__c = Date.Today();
    	update p;
    	
    	List<task> activitylist = [select id, subject from task where whatid=:testOpportunityB.id];
    	System.assertEquals(activitylist.size(),0);
    	
    	
        /***********************************************
         * Update product (field that triggers e-mails)
         * Test: 1 e-mail sent, 1 e-mail not sent (missing contact email address)
         ***********************************************/     	
        testOpportunityA.StageName = PHASE_RECHNUNG;
        testOpportunityB.StageName = PHASE_RECHNUNG;
        update testOpportunityA;
        update testOpportunityB;
        
    	p.Fotoprotokoll_hochgeladen__c = null;
    	update p;
    	
    	p.Fotoprotokoll_hochgeladen__c = Date.Today();
    	Integer t = Limits.getEmailInvocations();
    	update p;
    	
    	activitylist = [select id, subject from task where whatid=:testOpportunityB.id];
    	System.assertEquals(activitylist.size(),1);
    	
    	Integer t2 = Limits.getEmailInvocations();
    	System.assertEquals(t2,t+1);
    		
    }
    
}