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
private class onVorhabenKostenTest {

    static testMethod void myUnitTest() {
    	
    	Account lieferant1 =new Account(Name='Lieferant1',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	Account lieferant2 =new Account(Name='Lieferant2',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	list<Account> accounts =new list<Account>();
    	accounts.add(lieferant1);
    	accounts.add(lieferant2);
    	insert accounts;
    	
    	Vorhaben__c vh = new Vorhaben__c(Name = '0');
    	insert vh;
    	  
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;  
        VorhabenBewegung__c v1 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v1;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v2 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v2;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v3 = new VorhabenBewegung__c(DORGB9__c = 04, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v3;
    }
    
    static testMethod void deleteTest1() {
    	Account lieferant1 =new Account(Name='Lieferant1',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	Account lieferant2 =new Account(Name='Lieferant2',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	list<Account> accounts =new list<Account>();
    	accounts.add(lieferant1);
    	accounts.add(lieferant2);
    	insert accounts;
    	
    	 Vorhaben__c vh = new Vorhaben__c(Name = '0');
    	 insert vh;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;  
        VorhabenBewegung__c v1 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v1;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v2 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v2;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v3 = new VorhabenBewegung__c(DORGB9__c = 04, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v3;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v2;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v3;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v1;
    }
    
    static testMethod void deleteTest2() {
    	VorhabenKostenart__c vhka1=new VorhabenKostenart__c(Name='899');
    	VorhabenKostenart__c vhka2=new VorhabenKostenart__c(Name='999');
    	list<VorhabenKostenart__c> vhka=new list<VorhabenKostenart__c>();
    	vhka.add(vhka1);
    	vhka.add(vhka2);
    	insert vhka;
    	
    	Account lieferant1 =new Account(Name='Lieferant1',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	Account lieferant2 =new Account(Name='Lieferant2',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	list<Account> accounts =new list<Account>();
    	accounts.add(lieferant1);
    	accounts.add(lieferant2);
    	insert accounts;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
    	Vorhaben__c vh = new Vorhaben__c(Name = '0');
    	insert vh;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;  
        VorhabenBewegung__c v1 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, KSTAK9__c=vhka.get(0).id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v1;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v2 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v2;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v3 = new VorhabenBewegung__c(DORGB9__c = 04, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v3;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v2;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v3;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v1;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
    }
    
    static testMethod void deleteTest3() {
    	VorhabenKostenart__c vhka1=new VorhabenKostenart__c(Name='899');
    	VorhabenKostenart__c vhka2=new VorhabenKostenart__c(Name='999');
    	list<VorhabenKostenart__c> vhka=new list<VorhabenKostenart__c>();
    	vhka.add(vhka1);
    	vhka.add(vhka2);
    	insert vhka;
    	
    	Account lieferant1 =new Account(Name='Lieferant1',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	Account lieferant2 =new Account(Name='Lieferant2',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	list<Account> accounts =new list<Account>();
    	accounts.add(lieferant1);
    	accounts.add(lieferant2);
    	insert accounts;
    	
    	 Vorhaben__c vh = new Vorhaben__c(Name = '0');
    	 insert vh;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;  
        VorhabenBewegung__c v1 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, KSTAK9__c=vhka.get(0).id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v1;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v2 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, KSTAK9__c=vhka.get(0).id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v2;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v3 = new VorhabenBewegung__c(DORGB9__c = 04, VORHB9__c = vh.id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v3;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v2;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v3;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        delete v1;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
    }
    
    static testMethod void changeTest() {
    	VorhabenKostenart__c vhka1=new VorhabenKostenart__c(Name='899');
    	VorhabenKostenart__c vhka2=new VorhabenKostenart__c(Name='999');
    	list<VorhabenKostenart__c> vhka=new list<VorhabenKostenart__c>();
    	vhka.add(vhka1);
    	vhka.add(vhka2);
    	insert vhka;
    	
    	Account lieferant1 =new Account(Name='Lieferant1',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	Account lieferant2 =new Account(Name='Lieferant2',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	list<Account> accounts =new list<Account>();
    	accounts.add(lieferant1);
    	accounts.add(lieferant2);
    	insert accounts;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
    	Vorhaben__c vh = new Vorhaben__c(Name = '0');
    	insert vh;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;  
        VorhabenBewegung__c v1 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, KSTAK9__c=vhka.get(0).id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v1;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v2 = new VorhabenBewegung__c(DORGB9__c = 04, BTRGB9__c = 50, VORHB9__c = vh.id, KSTAK9__c=vhka.get(0).id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v2;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        v1.VTDIB9__c=System.today()+1;
        v1.BTRGB9__c=49;
        update v1;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        v1.KSTAK9__c=vhka.get(1).id;
        update v1;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        v1.KSTAK9__c=vhka.get(0).id;
        update v1;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        v1.GKTOK9__c=accounts.get(1).id;
        update v1;
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        v2.GKTOK9__c=accounts.get(1).id;
        update v2;
        System.assertEquals(0,[SELECT count() FROM VorhabenBewegung__c WHERE GKTOK9__c=:accounts.get(0).id]);
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
    }
    
    static testMethod void cloneTest() {
    	VorhabenKostenart__c vhka1=new VorhabenKostenart__c(Name='898');
    	VorhabenKostenart__c vhka2=new VorhabenKostenart__c(Name='999');
    	list<VorhabenKostenart__c> vhka=new list<VorhabenKostenart__c>();
    	vhka.add(vhka1);
    	vhka.add(vhka2);
    	insert vhka;
    	
    	Account lieferant1 =new Account(Name='Lieferant1',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	Account lieferant2 =new Account(Name='Lieferant2',BillingStreet='BC',BillingCity='BC',BillingCountry='DE',BillingPostalCode='12345',RecordTypeId=[SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Lieferant'].Id);
    	list<Account> accounts =new list<Account>();
    	accounts.add(lieferant1);
    	accounts.add(lieferant2);
    	insert accounts;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
    	 Vorhaben__c vh = new Vorhaben__c(Name = '0');
    	 insert vh;
    	
    	onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;  
        VorhabenBewegung__c v1 = new VorhabenBewegung__c(DORGB9__c = 01, BTRGB9__c = 50, VORHB9__c = vh.id, KSTAK9__c=vhka.get(0).id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today()+1);
        insert v1;
        
        onVorhabenKosten.inFutureContext = False;
        onVorhabenKosten.alreadyInUpdate=false;
        VorhabenBewegung__c v2 = new VorhabenBewegung__c(DORGB9__c = 01, BTRGB9__c = 50, VORHB9__c = vh.id, KSTAK9__c=vhka.get(0).id, GKTOK9__c=accounts.get(0).id, VTDIB9__c=System.today());
        insert v2;
        // falls das zum Fehler führt, funktioniert das klonen nicht richtig!
        VorhabenBewegung__c clone = [SELECT Id FROM VorhabenBewegung__c WHERE DORGB9__c = 2 AND BTRGB9__c = 50 AND VORHB9__c = :vh.id AND KSTAK9__c= :vhka.get(0).id AND GKTOK9__c= :accounts.get(0).id AND VTDIB9__c=:System.today() limit 1];
       
    }
}