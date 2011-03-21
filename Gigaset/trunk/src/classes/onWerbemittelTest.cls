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
private class onWerbemittelTest {

    static testMethod void myUnitTest() {
        Werbemittel__c Wtest = new Werbemittel__c();
        Wtest.Artikelnummer__c = '111';
        Wtest.Titel__c = 'blabla';
        Wtest.Beschreibung__c = 'blabla';
        Wtest.Verpackungseinheit__c = 'stck';
        Wtest.Portal__c = 'DE';
        insert Wtest;
        
        Werbemittel_Bestellung__c WBtest = new Werbemittel_Bestellung__c();
        Contact ctct = new Contact();
        ctct = [select id from Contact limit 1];
        
        //Werbemittel_Bestellung__c WB_temp = [select id, Besteller__c from Werbemittel_Bestellung__c limit 1];
        //WBtest.Besteller__c = WB_temp.Besteller__c;  
        WBtest.Besteller__c = ctct.Id;
        insert WBtest;
        
        //WBtest =  new Werbemittel_Bestellung__c ([select id,Name from Werbemittel_Bestellung__c limit 1]);
        Werbemittel__c Wtest2 = new Werbemittel__c();
       Wtest2=  [select id from Werbemittel__c limit 1];
        Werbemittel_Posten__c WPtest = new Werbemittel_Posten__c();
        WPtest.Bestellung__c = WBtest.Id;
        WPtest.Werbemittel__c = Wtest2.Id;
        WPtest.Menge__c = 10;
        
        
        insert WPtest;
        
        DEwerbemittelController bla = new DEwerbemittelController();
        bla.firstPage();
        bla.secondPage();
        bla.thirdPage();
        
        bla.getTerms();
        bla.setbestellungTemp();
        bla.getbestellungTemp();
        bla.getTerms2();
        bla.getctrl();
        
        Wtest.Beschreibung__c = 'Rofl';
        update Wtest;
        
        WPtest.Menge__c = 2;
        update WPtest;
    }
}