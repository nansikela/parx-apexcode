/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TimecardTriggerHelperTest {

	static testMethod void timecardKeineManuelePauschaleTest() {
		Date selectedDate = System.today();
    	Datetime selectedDatetime = System.now();
		// Account erstellen 
		Account a = new Account();
		a.Name = 'Test Parx Account FallTriggerHelper';
		a.BillingStreet='Test';
		a.BillingCity='Test';
		a.BillingCountry='Test';
		a.BillingPostalCode='Test';
		a.Type = 'Klient';
		insert a;			
		
		Contact c = new Contact();
		c.AccountId = a.Id;
		c.FirstName = 'Parx Contact name FallTriggerHelper';
		c.LastName = 'Parx Contact Lastname FallTriggerHelper';
		c.MailingStreet='TEST';
		c.MailingCity='TEST';
		c.MailingCountry='TEST';
		c.MailingPostalCode='TEST';
		insert c;
		Fall__c f = new Fall__c();
		f.Status__c='Erstkontakt erfolgt';
		f.Klient__c=c.id;
		f.Coach__c=UserInfo.getUserId();
		f.Kostentraeger__c='Versicherung';
		f.Fallkategorie__c='Seminar Pauschale';
		f.Coaching_Center_neu__c='Wil';
		f.Betrag_Pauschale__c=1;
		insert f;
		// jetzt neue TC als Pauschale anlegen
		Timecard__c tc_v = new Timecard__c();
		tc_v.Fall__c=f.id;
		tc_v.Aktivitaet__c='Seminar Pauschale';
		tc_v.von__c=selectedDatetime.addHours(4);
		tc_v.bis__c=selectedDatetime.addHours(8);
		tc_v.Coach__c=UserInfo.getUserId();
		tc_v.verrechenbar__c=false;
		tc_v.berechnet__c=false;
		try {
			test.startTest();
			insert tc_v;
			test.stopTest();
		} catch (System.DmlException e) {
			System.assert(e.getMessage().contains(System.label.KeineManuellePauschale));
		}
		
	}

    static testMethod void timecardInsertTest() {
    	Date selectedDate = System.today();
    	Datetime selectedDatetime = Datetime.newInstance(selectedDate.year(), selectedDate.month(), selectedDate.day());
		// Account erstellen 
		Account a = new Account();
		a.Name = 'Test Parx Account FallTriggerHelper';
		a.BillingStreet='Test';
		a.BillingCity='Test';
		a.BillingCountry='Test';
		a.BillingPostalCode='Test';
		a.Type = 'Klient';
		insert a;			
		
		Contact c = new Contact();
		c.AccountId = a.Id;
		c.FirstName = 'Parx Contact name FallTriggerHelper';
		c.LastName = 'Parx Contact Lastname FallTriggerHelper';
		c.MailingStreet='TEST';
		c.MailingCity='TEST';
		c.MailingCountry='TEST';
		c.MailingPostalCode='TEST';
		insert c;
		Fall__c f = new Fall__c();
		f.Status__c='Erstkontakt erfolgt';
		f.Klient__c=c.id;
		f.Coach__c=UserInfo.getUserId();
		f.Kostentraeger__c='Versicherung';
		f.Fallkategorie__c='Seminar Pauschale';
		f.Coaching_Center_neu__c='Wil';
		f.Betrag_Pauschale__c=1;
		insert f;
		list<Id> fallids = new list<Id>();
		fallids.add(f.id);
		// eine Pauschale wurde angelegt!
		list<Timecard__c> tcs = [SELECT Aktivitaet__c, von__c, bis__c, Coach__c, Fall__c, verrechenbar__c, berechnet__c, createdByTrigger__c FROM Timecard__c WHERE Fall__c IN: fallids ];
		
		System.assertEquals(1,tcs.size());
		for (Timecard__c tc: tcs) {
			// nur pauschalen wurden angelegt!
			System.assertEquals(true, tc.verrechenbar__c);
		}
		
		// jetzt neue TC als Coaching anlegen
		Timecard__c tc_v = new Timecard__c();
		tc_v.Fall__c=f.id;
		tc_v.Aktivitaet__c='Coaching';
		tc_v.von__c=selectedDatetime.addHours(24+13);
		tc_v.bis__c=selectedDatetime.addHours(24+14);
		tc_v.Coach__c=UserInfo.getUserId();
		tc_v.verrechenbar__c=false;
		tc_v.berechnet__c=false;
		insert tc_v;
		
		// wir holen uns alle tcs;
		tcs.clear();
		tcs = [SELECT Aktivitaet__c, von__c, bis__c, Coach__c, Fall__c, verrechenbar__c, berechnet__c, createdByTrigger__c FROM Timecard__c WHERE Fall__c IN: fallids ];
		System.assertEquals(2, tcs.size());
		// ok, die TCs wurden angelegt
		// stimmen sie denn auch
		for (Timecard__c tc: tcs) {
			if (tc.Aktivitaet__c=='Seminar Pauschale') {
				System.assertEquals(true, tc.verrechenbar__c);
				//System.assertEquals(true, tc.createdByTrigger__c);
			} else {
				System.assertEquals(false, tc.verrechenbar__c);
			}
			System.assertEquals(UserInfo.getUserId(), tc.Coach__c);
			System.assertEquals(f.id, tc.Fall__c);
			System.assertEquals(false, tc.berechnet__c);
		}
		
		f.Datum_Fallkategorie_Aenderung__c=selectedDate-1;
		f.Fallkategorie__c='Coaching Pauschale';
		f.Betrag_Pauschale__c=1;
		update f;
		
		tcs.clear();
		tcs = [SELECT Aktivitaet__c, von__c, bis__c, Coach__c, Fall__c, verrechenbar__c, berechnet__c, createdByTrigger__c FROM Timecard__c WHERE Fall__c IN: fallids ];
		System.assertEquals(2, tcs.size());
		// ok, die TC wurde geloescht
		// stimmet die Pauschale denn auch
		for (Timecard__c tc: tcs) {
			if (tc.Aktivitaet__c=='Seminar Pauschale') {
				System.assertEquals(true, tc.verrechenbar__c);
				//System.assertEquals(true, tc.createdByTrigger__c);
			} else if (tc.Aktivitaet__c=='Coaching Pauschale') {
				System.assertEquals(true, tc.verrechenbar__c);
				//System.assertEquals(true, tc.createdByTrigger__c);
			} else {
				System.assertEquals(false, tc.verrechenbar__c);
			}
			System.assertEquals(UserInfo.getUserId(), tc.Coach__c);
			System.assertEquals(f.id, tc.Fall__c);
			System.assertEquals(false, tc.berechnet__c);
		}
	}
	
	static testMethod void timecardUpdateTest() {
    	Date selectedDate = System.today().toStartOfMonth();
    	Datetime selectedDatetime = Datetime.newInstance(selectedDate.year(),selectedDate.month(),selectedDate.day(),0,0,0);
		// Account erstellen 
		Account a = new Account();
		a.Name = 'Test Parx Account FallTriggerHelper';
		a.BillingStreet='Test';
		a.BillingCity='Test';
		a.BillingCountry='Test';
		a.BillingPostalCode='Test';
		a.Type = 'Klient';
		insert a;			
		
		Contact c = new Contact();
		c.AccountId = a.Id;
		c.FirstName = 'Parx Contact name FallTriggerHelper';
		c.LastName = 'Parx Contact Lastname FallTriggerHelper';
		c.MailingStreet='TEST';
		c.MailingCity='TEST';
		c.MailingCountry='TEST';
		c.MailingPostalCode='TEST';
		insert c;
		Fall__c f = new Fall__c();
		f.Status__c='Erstkontakt erfolgt';
		f.Klient__c=c.id;
		f.Coach__c=UserInfo.getUserId();
		f.Kostentraeger__c='Versicherung';
		f.Fallkategorie__c='Seminar Pauschale';
		f.Coaching_Center_neu__c='Wil';
		f.Betrag_Pauschale__c=1;
		insert f;
		list<Id> fallids = new list<Id>();
		fallids.add(f.id);
		// keine Pauschale wurde angelegt!
		list<Timecard__c> tcs = [SELECT Aktivitaet__c, von__c, bis__c, Coach__c, Fall__c, verrechenbar__c, berechnet__c, createdByTrigger__c FROM Timecard__c WHERE Fall__c IN: fallids ];
		
		System.assertEquals(1,tcs.size());
		
		
		// jetzt neue TC als Coaching anlegen
		Timecard__c tc_v1 = new Timecard__c();
		tc_v1.Fall__c=f.id;
		tc_v1.Aktivitaet__c='Coaching';
		tc_v1.von__c=selectedDatetime.addHours(26);
		tc_v1.bis__c=selectedDatetime.addHours(28);
		tc_v1.Coach__c=UserInfo.getUserId();
		tc_v1.verrechenbar__c=true;
		tc_v1.berechnet__c=false;
		insert tc_v1;
		// jetzt neue TC als Coaching anlegen
		Timecard__c tc_v2 = new Timecard__c();
		tc_v2.Fall__c=f.id;
		tc_v2.Aktivitaet__c='Coaching';
		tc_v2.von__c=selectedDatetime.addHours(26);
		tc_v2.bis__c=selectedDatetime.addHours(28);
		tc_v2.Coach__c=UserInfo.getUserId();
		tc_v2.verrechenbar__c=true;
		tc_v2.berechnet__c=false;
		insert tc_v2;
		
		FallTriggerHelper.alreadyRun=false;
		
		// update fall
		f.Datum_Fallkategorie_Aenderung__c=System.today().toStartOfMonth();
		f.Fallkategorie__c='Abklärung Pauschal';
		update f;
		
		// wir holen uns alle tcs;
		tcs.clear();
		tcs = [SELECT Aktivitaet__c, von__c, bis__c, Coach__c, Fall__c, verrechenbar__c, berechnet__c, createdByTrigger__c FROM Timecard__c WHERE Fall__c IN: fallids ];
		System.assertEquals(3, tcs.size());
		// ok, die TCs wurden angelegt
		// stimmen sie denn auch
		for (Timecard__c tc: tcs) {
			if (tc.Aktivitaet__c=='Abklärung Pauschal') {
				System.assertEquals(true, tc.verrechenbar__c);
				//System.assertEquals(true, tc.createdByTrigger__c);
			} else {
				System.assertEquals(false, tc.verrechenbar__c);
			}
			System.assertEquals(UserInfo.getUserId(), tc.Coach__c);
			System.assertEquals(f.id, tc.Fall__c);
			System.assertEquals(false, tc.berechnet__c);
		}
		
		// test des loesschens
		delete tc_v1;
		delete tc_v2;
		tcs.clear();
		tcs = [SELECT Aktivitaet__c, von__c, bis__c, Coach__c, Fall__c, verrechenbar__c, berechnet__c, createdByTrigger__c FROM Timecard__c WHERE Fall__c IN: fallids ];
		System.assertEquals(1, tcs.size());
		// ok, die TC wurde geloescht
		// stimmet die Pauschale denn auch
		for (Timecard__c tc: tcs) {
			if (tc.Aktivitaet__c=='Abklärung Pauschal') {
				System.assertEquals(true, tc.verrechenbar__c); // nicht ganz korrekt!
				//System.assertEquals(true, tc.createdByTrigger__c);
			} else {
				System.assertEquals(false, tc.verrechenbar__c);
			}
			System.assertEquals(UserInfo.getUserId(), tc.Coach__c);
			System.assertEquals(f.id, tc.Fall__c);
			System.assertEquals(false, tc.berechnet__c);
		}
	}
}