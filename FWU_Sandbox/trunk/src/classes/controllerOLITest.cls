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
private class controllerOLITest {

    static testMethod void myUnitTest() {
        String AccId = testData.creationAccount();
          
        Opportunity opp = new Opportunity(Name='Test', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), REAR2A__c = 0, Lizenznummer__c = '10206');
        insert opp;
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(opp);
        
        Medienart__c medien = new Medienart__c(Name = '46', MALTXT__c = 'qwertzu');
        insert medien;
        Product2 prod = new Product2(Name='Test', RECH01__c = '0', MEDA01__c = medien.Id);
        insert prod;
      //  String ArtikelName = [Select Name From ArtikelLizenz__c where LZN015__c='10206' AND SPK015__c = false AND medienart__c != null limit 1].Name;
     //   ArtikelName = ArtikelName.split('10206')[0];
      ArtikelLizenz__c AL = new ArtikelLizenz__c(LZN015__c = '10206', VPR015__c = 50, SPK015__c = false, MNG015__c = 1, Name = '0', Artikel__c = prod.Id);
      insert AL;
      
      String ArtikelName = [Select Name From ArtikelLizenz__c where Id =: AL.Id].Name;
        ArtikelName = ArtikelName.split('10206')[0];
        
      controllerOLI controller = new controllerOLI(stdcontroller);
      for(controllerOLI.myterm term:controller.Terms) {
             term.Quantity = '100';
             term.Name = ArtikelName;
             term.Anzahl_Schulen = '10';
             term.Kopien_Rabatt= null;
        }
        system.debug('ARTIKEL !!!! ' + ArtikelName);
        controller.getTerms();
        controller.updateline();
      controller.checkline();
      controller.saveIt(); 
      controller.savecontinue();
      try{
      controller.del(); 
      }catch(exception e) {}
      controller.initCheck();
      controller.cancel();
        
       for(controllerOLI.myterm term:controller.Terms) {
             term.Quantity = 'qwe';
             term.Name = 'qwwd';
             term.Anzahl_Schulen = 'wqwqe';
        }
      controller.checkline();

    }
}