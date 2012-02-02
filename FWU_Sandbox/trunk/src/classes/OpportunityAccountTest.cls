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
private class OpportunityAccountTest {

    static testMethod void myUnitTest() {
        String AccId = testData.creationAccount();
    	  
        Opportunity opp = new Opportunity(Name='Test', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), Rabatt__c = 10, REAR2A__c = 0,Lizenznummer__c = '10206', Anzahl_Schulen__c  = 5, VKPG2A__c = 'KO');
        insert opp;
       
        Product2 p = new Product2(Name='Test',IsActive=true);
	  Medienart__c m1=new Medienart__c(Name='46',MALTXT__c='VHS');
	  insert m1;
	  p.MEDA01__c = m1.Id;
	  p.RecordTypeId = [select id from recordType where Name = 'Signatur'].Id;
        insert p;
        	
        Pricebook2 standardpricebook = [select id from Pricebook2 where Name = 'Standard Price Book' limit 1];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardpricebook.id,Product2Id=p.id,UnitPrice=5,IsActive=true);
        try{
        	insert pbe;
        }
        catch (exception e) {
        	pbe = [select id from PricebookEntry where Pricebook2Id=:standardpricebook.id AND Product2Id=:p.id AND IsActive=true limit 1];
        }
        ArtikelLizenz__c Lizenz = new ArtikelLizenz__c(LZN015__c = '10206', Name= '0', Artikel__c = p.Id, VPR015__c = 5, SPK015__c=false);
        insert Lizenz;
        
        OpportunityLineItem oppProd = new OpportunityLineItem(OpportunityId=opp.Id, Quantity = 10, UnitPrice = 10, PriceBookEntryId = pbe.id, SCHL2D__c = Lizenz.id 
        	,STAT2D__c = 'Freigabe', Sperrkz__c = false
        	);
        insert oppProd;
        
        
	  onOpportunityLineItem.inFutureContextStoredId = '';
	  opp.StageName = 'Bereit zur Freigabe';
        update opp;
        

        
        Opportunity opp2 = new Opportunity(Name='Test', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), Rabatt__c = 10, REAR2A__c = 0, RecordTypeId = '012200000009lZE');
        onOpportunity.inFutureContextStoredId = '';
        insert opp2;
        OpportunityLineItem oppProd3 = new OpportunityLineItem(OpportunityId=opp2.Id, Quantity = 10, UnitPrice = 10, PriceBookEntryId = pbe.id, SCHL2D__c = Lizenz.id 
        	,STAT2D__c = 'Freigabe', Sperrkz__c = false
        	);
        insert oppProd3;
        
        
        system.debug('help opp debug ' + opp2.StageName + ' ' + oppProd3.Sperrkz__c + ' ' + oppProd3.Fremdvertrieb__c + ' ' + oppProd3.OppRechnungsArt__c + ' ' + opp2.RecordTypeId );
        
        opp2.StageName = 'Bereit zur Freigabe';
        onOpportunity.inFutureContextStoredId = '';
        opp2.Rabatt__c = 5;
        update opp2;
        opp2.Rabatt__c = 10;
        update opp2;
        DuplicateOpportunity.init(opp2.Id);   
	//system.debug('debug opp bla ' + oppProd.Sperrkz__c + ' ' + oppProd.OppRechnungsArt__c + ' ' + oppProd.Fremdvertrieb__c );						
        
       OpportunityLineItem oli = new OpportunityLineItem();
       oli = [select id, Verkaufsprogramm__c, Produkttyp__c, medienart_id__c from OpportunityLineItem where Id =: oppProd.Id limit 1];
        system.debug('oli test ' + oli.Verkaufsprogramm__c + ' ' + oli.Produkttyp__c + ' ' + oli.medienart_id__c );
        
        Product2 p2 = new Product2(Name='Test',IsActive=true);
	  Medienart__c m2=new Medienart__c(Name='55',MALTXT__c='VHS');
	  insert m2;
	  p2.MEDA01__c = m2.Id;
	  onProduct.inFutureContextStoredId = '';
	  onOpportunityLineItem.inFutureContextStoredId = '';
        insert p2;
        ArtikelLizenz__c Lizenz2 = new ArtikelLizenz__c(LZN015__c = '10206', Name= '0', Artikel__c = p2.Id, VPR015__c = 5, SPK015__c=false);
        insert Lizenz2;
	  p.SIG1__c = p2.Id;
	  onProduct.inFutureContextStoredId = '';
	  onOpportunityLineItem.inFutureContextStoredId = '';
	  update p;
	  
	  OpportunityLineItem oppProd2 = new OpportunityLineItem(OpportunityId=opp.Id, Quantity = 10, UnitPrice = 10, PriceBookEntryId = pbe.id, SCHL2D__c = Lizenz.id 
        	,STAT2D__c = 'Freigabe'
        	);
        insert oppProd2;
        
        rabattUpdate.init(opp.Id);

        opp.Rabatt__c = 15;
        opp.StageName = 'Bereit zur Freigabe';
        opp.Anzahl_Schulen__c  = 3;
        opp.Lizenznummer__c = '10206';

	onOpportunity.inFutureContextStoredId = '';
	  opp.Locked__c = false;
        update opp;

        oppProd.STAT2D__c = 'Fakturiert';

	  onOpportunityLineItem.inFutureContextStoredId = '';
        update oppProd;
        oppProd.Quantity = 2;
        oppProd.KreisListe__c = oppProd2.Id;
        Lizenz.MNG015__c = 3;
        update Lizenz;
	  onOpportunityLineItem.inFutureContextStoredId = '';
        update oppProd;
        oppProd.KreisListe__c = null;
        onOpportunityLineItem.inFutureContextStoredId = '';
        update oppProd;
        m1.Name = '46';
        update m1;
    //    p.Typ__c = 'Signatur';
    //    update p;
    //    opp.VKPG2A__c = 'KO';
    	  onOpportunity.inFutureContextStoredId = '';
        update opp;
        
        onOpportunityLineItem.inFutureContextStoredId = '';	
        update oppProd;
           
        onOpportunityLineItem.inFutureContextStoredId = '';
        oppProd.Sperrkz__c = true;
        oppProd.KreisListe__c = oppProd.Id;
        update oppProd;
        
        onOpportunityLineItem.inFutureContextStoredId = '';
        oppProd.Sperrkz__c = false;       
        update oppProd; 
        
        onOpportunityLineItem.inFutureContextStoredId = '';   
        update oppProd; 
        
        onOpportunityLineItem.inFutureContextStoredId = '';
     	  delete oppProd;
   
    	  onOpportunity.inFutureContextStoredId = '';
    	  delete opp;
    	  Database.delete(AccId);        
    }
    
}