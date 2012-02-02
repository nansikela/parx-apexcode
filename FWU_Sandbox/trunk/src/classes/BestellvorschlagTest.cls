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
private class BestellvorschlagTest {

    static testMethod void myUnitTest() {
          String AccId = testData.creationAccount();
          Account acc = [select id, RecordTypeId from Account where Id =: AccId];
          acc.RecordTypeId = [select id from RecordType where Name = 'Lieferant' AND sObjectType ='Account' limit 1].Id;
          update acc;
        Product2 p = new Product2(Name='Test',IsActive=true, Kreditor__c = AccId, PDKZ01__c=4, EPKZ01__c='A', EKPR01__c=40, BEME01__c = 20, Auslieferung_geplant__c = system.today(), SWFA01__c = '1', DISW01__c=2.0, AZME01__c = 10);
      Medienart__c m1=new Medienart__c(Name='46',MALTXT__c='VHS');
      insert m1;
      p.MEDA01__c = m1.Id;
      p.RecordTypeId = [select id from recordType where Name = 'Signatur'].Id;
        insert p;
        
        Product2 p2 = new Product2(Name='Test',IsActive=true, Kreditor__c = AccId, PDKZ01__c=4, EPKZ01__c='A', EKPR01__c=40, BEME01__c = 20, Auslieferung_geplant__c = system.today()+1, SWFA01__c = '1', DISW01__c=2.0, AZME01__c = 10);
        Medienart__c m2=new Medienart__c(Name='47',MALTXT__c='VHS');
        insert m2;
        p2.MEDA01__c = m2.Id;
        p2.RecordTypeId = [select id from recordType where Name = 'Signatur'].Id;
        insert p2;
        
        Product2 p3 = new Product2(Name='Test',IsActive=true,Neuer_Liefertermin__c = system.today() + 10, Kreditor__c = AccId, PDKZ01__c=4, EPKZ01__c='A', EKPR01__c=40, BEME01__c = 20, Auslieferung_geplant__c = system.today()+1, SWFA01__c = '1', DISW01__c=2.0, AZME01__c = 10);
        p3.MEDA01__c = m2.Id;
        p3.RecordTypeId = [select id from recordType where Name = 'Signatur'].Id;
        insert p3;
        
        Product2 p4 = new Product2(Name='Test',IsActive=true,Neuer_Liefertermin__c = system.today() + 10, Kreditor__c = AccId, PDKZ01__c=4, EPKZ01__c='A', EKPR01__c=40, BEME01__c = 20, Auslieferung_geplant__c = system.today()+1, SWFA01__c = '1', DISW01__c=2.0, AZME01__c = 10, AUSW01__c = 'd');
        p4.MEDA01__c = m2.Id;
        p4.RecordTypeId = [select id from recordType where Name = 'Signatur'].Id;
        insert p4;
        
        Product2 p5 = new Product2(Name='Test',IsActive=true,Neuer_Liefertermin__c = system.today() + 10, Kreditor__c = AccId, PDKZ01__c=4, EPKZ01__c='A', EKPR01__c=40, BEME01__c = 20, Auslieferung_geplant__c = system.today()+1, SWFA01__c = '1', DISW01__c=2.0, AZME01__c = 10, AUSW01__c = 'd', PJKZ01__c='test');
        p5.MEDA01__c = m2.Id;
        p5.RecordTypeId = [select id from recordType where Name = 'Signatur'].Id;
        insert p5;
        
        
        list<String> Ids = new list<String>();
        Ids.add(p.Id);
        Ids.add(p2.Id);
        Ids.add(p3.Id);
        Ids.add(p4.Id);
        Ids.add(p5.Id);
        Bestellvorschlag.init(Ids);
        
 //       p.BEME01__c=20;
 //       update p;
  //      Bestellvorschlag.init(Ids);

    }
}