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
private class AustauschartikelTest {

    static testMethod void myUnitTest() {
    
        
        String AccId = testData.creationAccount();
          
        Opportunity opp = new Opportunity(Name='Test', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), Rabatt__c = 10, REAR2A__c = 0);
        insert opp;
       
        Product2 p = new Product2(Name='Test',IsActive=true );
      Medienart__c m1=new Medienart__c(Name='46',MALTXT__c='VHS');
      insert m1;
      p.MEDA01__c = m1.Id;
        insert p;
        
        Product2 p2 = new Product2(Name='Test2',IsActive=true,MEDA01__c = m1.Id, Austauschartikel__c = p.Id );
        insert p2;
                
        Pricebook2 standardpricebook = [select id from Pricebook2 where Name = 'Standard Price Book' limit 1];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardpricebook.id,Product2Id=p.id,UnitPrice=5,IsActive=true);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=standardpricebook.id,Product2Id=p2.id,UnitPrice=5,IsActive=true);
        try{
            insert pbe2;
            
        }
        catch (exception e) {
            pbe2 = [select id from PricebookEntry where Pricebook2Id=:standardpricebook.id AND Product2Id=:p2.id AND IsActive=true limit 1];
        }
        try{
            insert pbe;
            
        }
        catch (exception e) {
            pbe = [select id from PricebookEntry where Pricebook2Id=:standardpricebook.id AND Product2Id=:p.id AND IsActive=true limit 1];
        }
        ArtikelLizenz__c Lizenz = new ArtikelLizenz__c(LZN015__c = '10001', Name= 'bla2', Artikel__c = p.Id, VPR015__c = 5, SPK015__c=false);
        onProduct.inFutureContextStoredId = '';
        insert Lizenz;
            
        OpportunityLineItem oppProd = new OpportunityLineItem(OpportunityId=opp.Id, Quantity = 10, UnitPrice = 10, PriceBookEntryId = pbe.id, SCHL2D__c = Lizenz.id 
            
            );
        insert oppProd;
        
        Austauschartikel.init(p.Id, p2.Id);
        Austauschartikel.initMassUnlock(p.Id, p2.Id);
        
        Lizenz = new ArtikelLizenz__c(LZN015__c = '10001', Name= 'bla2', Artikel__c = p2.Id, VPR015__c = 5, SPK015__c=false);
        onProduct.inFutureContextStoredId = '';
        insert Lizenz;
        
        Austauschartikel.init(p.Id, p2.Id);
    }
}