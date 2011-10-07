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
private class WebAnmeldungControllerTest {
/*
    static testMethod void myUnitTest() {
    	WebAnmeldungController w;
    	ApexPages.currentPage().getParameters().put('seminarCode', 'FO120');
        w = new WebAnmeldungController();
        
        w.save0();
        w.teilnehmer1.LastName = 'Test';
        w.teilnehmer1.FirstName = 'Test';
        Product2 p = [SELECT id FROM Product2 p WHERE p.Portfolio__r.name = 'FO120' AND p.Seminarbeginn__c > 2010-01-01 LIMIT 1];
        w.bestellung.Seminar__c = p.id;
        w.save1();
        ID id = w.bestellung.id;
        ApexPages.currentPage().getParameters().put('bid', id);
        w = new WebAnmeldungController();
        w.save2();
        w.save3();
        w.save4();
        w.bestellung.eMail__c = 'Test@test.de';
        w.bestellung.Telefon__c = '123454664756235';
        w.bestellung.Ansprechpartner__c = 'Test';
        w.bestellung.Strasse__c = 'Test';
        w.bestellung.PLZ__c = '81478';
        w.bestellung.Ort__c = 'test';
        w.save3();
        w.bestellung.AGB_akzeptiert__c = true;
        w.save4();
    } */
}