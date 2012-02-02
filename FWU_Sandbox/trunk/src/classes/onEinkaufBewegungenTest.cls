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
private class onEinkaufBewegungenTest {

    static testMethod void myUnitTest() {
        Product2 p = new Product2(Name='Test',IsActive=true, PDKZ01__c=2, EPKZ01__c='A', EKPR01__c=40 );
	  Medienart__c m1=new Medienart__c(Name='88',MALTXT__c='VHS');
	  insert m1;
	  p.MEDA01__c = m1.Id;
	  p.Auslieferung_geplant__c = system.today();

        insert p;
        EinkaufBestellung__c EB = new EinkaufBestellung__c ();
        insert EB;
        list<Einkauf__c> listE = new list<Einkauf__c>();
        
        Einkauf__c e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '03';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '04';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '05';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '06';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '08';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '13';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '14';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '15';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '16';
        listE.add(e);
        
        e = new Einkauf__c(Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, Bestellung__c = EB.Id);
        e.BWSL22__c = '18';
        listE.add(e);
       
	  insert listE;        
    }
}