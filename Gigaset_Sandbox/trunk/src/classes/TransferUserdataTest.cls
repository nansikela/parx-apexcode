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
private class TransferUserdataTest {

    static testMethod void initTest() {
        User u=[SELECT Id, Lastname, Firstname, Title_Kontakt__c,
        	MobilePhone_Kontakt__c, Salutation_Kontakt__c,
        	Fax_Kontakt__c,
        	Email, 
        	Funktion__c,
        	Info_per_Email__c, Info_per_Post__c,
        	Interne_Abteilungsbezeichnung__c, Status__c,
        	Telefon_Kontakt__c, 
        	Abteilung_Auswahl__c, MailingCity_Kontakt__c,
        	MailingStreet_Kontakt__c, 
        	MailingCountry_Kontakt__c,
        	MailingState_Kontakt__c, MailingPostalCode_Kontakt__c,
        	ContactId
        	FROM USER WHERE IsActive=true AND ContactId!=null LIMIT 1];
        u.Fax_Kontakt__c='+498954';
        u.Telefon_Kontakt__c='+4989809';
        u.MobilePhone_Kontakt__c='+49891234';
        u.Email='test@test.test';
        u.Info_per_Email__c=true;
        u.Handelskanal__c='test';
        test.startTest();
        System.runAs(u) {
        	update u;
        }
        test.stopTest();
        Contact c=[SELECT Id, Fax, Email, AccountId FROM Contact WHERE Id=:u.ContactId];
        System.assertEquals(u.Email,c.Email);
        Account a=[SELECT Id, Handelskanal__c FROM Account WHERE Id=:c.AccountId];
        System.assertEquals(u.Handelskanal__c,a.Handelskanal__c);
    }
}