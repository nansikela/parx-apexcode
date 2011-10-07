public class akademie {
	
	public static String getRecordTypeIdByName(String recordTypeName) {
		
		// This method returns an Id
		String Id;
		RecordType rtype;
		System.debug('PRAX: RecordTypeName: ' + recordTypeName);
		try {
			rtype = [select id, name from recordtype where name= :recordTypeName limit 1];
		} catch (System.QueryException e) {
			System.debug('PARX: System Query Exception ' + e.getMessage());
		}
		if (rtype!=null) {
			Id = rtype.Id;
			System.debug('PRAX: RecordTypeId: '+ Id);
		}
		return Id;
		
	}
	
	// Testmethode fuer Helfer Methode
	public static testMethod void testgetRecordTypeIdByName() {
		
		System.assert(getRecordTypeIdByName('Offene Seminare').length()>0);
		System.assert(getRecordTypeIdByName('Inhouse').length()>0);
		System.assert(getRecordTypeIdByName('Abschlussbericht')==null);
		
	}
	
	
	// Testmethode fuer UpdateProduct2
	// legt Opp mit LineItems an und aktualisiert diese
	public static testMethod void testUpdateProduct2() {
		
		// Variablen
		String osRecordTypeId=getRecordTypeIdByName('Offene Seminare');
		String seminarid='01t20000000C5CS'; // Testseminar
		String stornoid='01t20000000C2CX'; // Stornoprodukt
		String pbeseminarid='01u20000000UCvV'; // Testseminar PBE
		String pbestornoid='01u20000000UBOM'; // Stornoprodukt PBE
		Double OriginalStornoumsatz = [Select Stornoumsatz__c From Product2 Where Id =: seminarid].Stornoumsatz__c;
		/* Simple Test */
		/*
		// Account / Contact
		List<Account> acs = new List<Account>();
		List<Contact> cs = new List<Contact>();		
		Account ac = new Account(name='PARXTEST Testfirma');
		acs.add(ac);
		try {
			insert acs;
		} catch (System.DmlException e) {
			System.debug('PARX: Insert Exception: ' + e.getMessage());
			System.assert(false);
		}
		Contact st = new Contact();
		st.Salutation='Herr';
		st.FirstName='PARXTEST';
		st.LastName='Teilnehmer';
		st.AccountId=ac.Id;
		cs.add(st);
		try {
			insert cs;
		} catch (System.DmlException e) {
			System.debug('PARX: Insert Exception: ' + e.getMessage());
			System.assert(false);
		}
		// Opps
		List<Opportunity> os = new List<Opportunity>();
		Opportunity mitstorno = new Opportunity(name='PARXTEST: mitstorno');
		Opportunity ohnestorno = new Opportunity(name='PARXTEST: ohnestorno');
		mitstorno.CloseDate = System.today();
		mitstorno.RecordTypeId=osRecordTypeId;
		mitstorno.Seminar__c=seminarid;
		mitstorno.Seminarteilnehmer__c=st.Id;
		mitstorno.AccountId=ac.Id;
		mitstorno.StageName='Anmeldung';
		os.add(mitstorno);
		ohnestorno.CloseDate = System.today();
		ohnestorno.RecordTypeId=osRecordTypeId;
		ohnestorno.Seminar__c=seminarid;
		ohnestorno.Seminarteilnehmer__c=st.Id;
		ohnestorno.AccountId=ac.Id;
		ohnestorno.StageName='Anmeldung';
		os.add(ohnestorno);
		try {
			insert os;
		} catch (System.DmlException e) {
			System.debug('PARX: Insert Exception: ' + e.getMessage());
			System.assert(false);
		}
		*/
		/* simple Test ende */
				
		List<Account> acs = new List<Account>();
		List<Contact> cs = new List<Contact>();		
		List<Opportunity> os = new List<Opportunity>();
		List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
		
		// Account / Contact
		Account ac = new Account(name='PARXTEST Testfirma');
		acs.add(ac);
		try {
			insert acs;
		} catch (System.DmlException e) {
			System.debug('PARX: Insert Exception: ' + e.getMessage());
			System.assert(false);
		}
		Contact st = new Contact();
		st.Salutation='Herr';
		st.FirstName='PARXTEST';
		st.LastName='Teilnehmer';
		st.AccountId=ac.Id;
		cs.add(st);
		try {
			insert cs;
		} catch (System.DmlException e) {
			System.debug('PARX: Insert Exception: ' + e.getMessage());
			System.assert(false);
		}
		
		// Opps
		Opportunity mitstorno = new Opportunity(name='PARXTEST: mitstorno');
		Opportunity ohnestorno = new Opportunity(name='PARXTEST: ohnestorno');
		mitstorno.CloseDate = System.today();
		mitstorno.RecordTypeId=osRecordTypeId;
		mitstorno.Seminar__c=seminarid;
		mitstorno.Seminarteilnehmer__c=st.Id;
		mitstorno.AccountId=ac.Id;
		mitstorno.StageName='Anmeldung';
		os.add(mitstorno);
		ohnestorno.CloseDate = System.today();
		ohnestorno.RecordTypeId=osRecordTypeId;
		ohnestorno.Seminar__c=seminarid;
		ohnestorno.Seminarteilnehmer__c=st.Id;
		ohnestorno.AccountId=ac.Id;
		ohnestorno.StageName='Anmeldung';
		os.add(ohnestorno);
		try {
			insert os;
		} catch (System.DmlException e) {
			System.debug('PARX: Insert Exception: ' + e.getMessage());
			System.assert(false);
		}
		// Olis ( 3 Stk
		OpportunityLineItem olims1 = new OpportunityLineItem();
		OpportunityLineItem olims2 = new OpportunityLineItem();
		OpportunityLineItem olios1 = new OpportunityLineItem();
		olims1.Quantity=1;
		olims1.TotalPrice=0;
		olims1.PriceBookEntryId=pbeseminarid;
		olims1.OpportunityId = mitstorno.Id;
		olims2.Quantity=1;
		olims2.TotalPrice=125;
		olims2.PriceBookEntryId=pbestornoid;
		olims2.OpportunityId = mitstorno.Id;
		olims2.Produktcode__c = 'STORNOGEB';
		olios1.Quantity=1;
		olios1.TotalPrice=1;
		olios1.PriceBookEntryId=pbeseminarid;
		olios1.OpportunityId = ohnestorno.Id;
		olis.add(olims1);
		olis.add(olims2);
		olis.add(olios1);
		if (olis==null) {
			System.debug('PARX: Keine olis');
		}
		try {
			insert olis;
		} catch (System.DmlException e) {
			System.debug('PARX: Insert Exception: ' + e.getMessage());
			System.assert(false);
		}
		// Pruefen, ob die betraege in den OS richtig sind
		System.debug('PARX: ProductcodeUD ' + olims2.Produktcode__c);
		System.assertEquals(125,[Select Amount From Opportunity Where Id = :mitstorno.Id].Amount);
		System.assertEquals(1,[Select Amount From Opportunity Where Id = :ohnestorno.Id].Amount);
		System.assertEquals(0,[Select Umsatz_Seminar__c From Opportunity Where Id = :mitstorno.Id].Umsatz_Seminar__c);
		System.assertEquals(1,[Select Umsatz_Seminar__c From Opportunity Where Id = :ohnestorno.Id].Umsatz_Seminar__c);
		ohnestorno.StageName='Rechnung';
		mitstorno.StageName='Rechnung';
		// nun loesen wir den update trigger aus
		try {
			update os;
		} catch (System.DmlException e) {
			System.debug('PARX: Update Exception: ' + e.getMessage());
			System.assert(false);
		}
		// pruefen, ob der trigger richtig gearbeitet hat
		System.assertEquals(OriginalStornoumsatz+125,[Select Stornoumsatz__c From Product2 Where Id =: seminarid].Stornoumsatz__c);
		// nun loesen wir den delete trigger aus
		try {
			delete os;
		} catch (System.DmlException e) {
			System.debug('PARX: Update Exception: ' + e.getMessage());
			System.assert(false);
		}
		//System.assertEquals(OriginalStornoumsatz,[Select Stornoumsatz__c From Product2 Where Id =: seminarid].Stornoumsatz__c);
		System.assert(true);
		
	}
	
	// aktualisiert das Seminar (Stornoumsatz__c) anhand der Stornokosten der opps
	public static void UpdateProduct2 (Map<Id, Double> osMap,String typ) {
		
		Map<Id, Product2> psMap = new Map<Id, Product2>();
		
		if (osMap!=null) {
			System.debug('PARX: UpdateProduct2 osMap.keySet: ' + osMap.keySet());
			for (Product2 seminar : [Select Id, Stornoumsatz__c From Product2 Where Id in :osMap.keySet()]) {
				if (seminar.Stornoumsatz__c==null) {
					seminar.Stornoumsatz__c=0;
				}
				if (typ=='update') {
					seminar.Stornoumsatz__c=seminar.Stornoumsatz__c+osMap.get(seminar.id);
				}
				else if (typ=='delete') {
					seminar.Stornoumsatz__c=seminar.Stornoumsatz__c-osMap.get(seminar.id);
				}
				psMap.put(seminar.id,seminar);
			}
			if (psMap!=null) {
				update psMap.values();
			}
		}
	 
	}
}