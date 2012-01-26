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
private class segmentation_updateContactSegmListTEST {

    static testMethod void myUnitTest() {
        
		String RT_CONTACTAOI	= '0122000000050Kl';
		String RT_CONTACTCAT	= '012200000005007';
		String RT_MARKETPREFS 	= '01220000000500C';
		String RT_MEMBERSHIP	= '01220000000501F';        
        
        // Create Account + contact, and a few segmentations
    	Account myAccount1 = new Account(Name = 'Parx Testaccount');
        insert myAccount1;
        
        Contact myContact1 = new Contact();
        myContact1.Lastname 	= 'Müller';
        myContact1.Firstname 	= 'Peter';
        myContact1.AccountId 	= myAccount1.id;
        insert myContact1;
        
        Segmentation__c mySegmentation1 = new Segmentation__c();
        mySegmentation1.Contact__c = myContact1.id;
        mySegmentation1.RecordTypeId = RT_CONTACTAOI;
        mySegmentation1.Interest_Area__c = 'Golf';
        insert mySegmentation1;
        
        Segmentation__c mySegmentation5 = new Segmentation__c();
        mySegmentation5.Contact__c = myContact1.id;
        mySegmentation5.RecordTypeId = RT_CONTACTAOI;
        mySegmentation5.Interest_Area__c = 'Golf';
        insert mySegmentation5;        
        
        Segmentation__c mySegmentation2 = new Segmentation__c();
        mySegmentation2.Contact__c = myContact1.id;
        mySegmentation2.RecordTypeId = RT_CONTACTCAT;
        mySegmentation2.Type__c = 'Alumni';
        insert mySegmentation2;
        
        Segmentation__c mySegmentation3 = new Segmentation__c();
        mySegmentation3.Contact__c = myContact1.id;
        mySegmentation3.RecordTypeId = RT_MARKETPREFS;
        mySegmentation3.Marketing_Preferences__c = 'Newsletters';
        mySegmentation3.Marketing_Sub_Preferences__c = 'EHL e-Newsletter';
        insert mySegmentation3;
         
        Segmentation__c mySegmentation4 = new Segmentation__c();
        mySegmentation4.Contact__c = myContact1.id;
        mySegmentation4.RecordTypeId = RT_MEMBERSHIP;
        mySegmentation4.Type__c = 'Student Committees';
        //mySegmentation4.Subtype__c = 'EHL Junior';
        insert mySegmentation4;        
        
        // check if lists of segmentations were correctly created
        // on contact 
        List<Contact> conList = [SELECT id, Contacts_Membership__c, Contacts_Marketing_Preferences__c,Contacts_Categories__c,Contacts_Areas_of_Interest__c from contact where id=:myContact1.id];
        Contact myContact1Reloaded = conList.get(0);
        
        System.debug('**** Contacts_Areas_of_Interest__c= ' + myContact1Reloaded.Contacts_Areas_of_Interest__c);
        System.debug('**** Contacts_Categories__c= ' + myContact1Reloaded.Contacts_Categories__c);
        System.debug('**** Contacts_Marketing_Preferences__c= ' + myContact1Reloaded.Contacts_Marketing_Preferences__c);
        System.debug('**** Contacts_Membership__c= ' + myContact1Reloaded.Contacts_Membership__c);
        
        System.assert(myContact1Reloaded.Contacts_Areas_of_Interest__c == 'Golf; Golf');
        System.assert(myContact1Reloaded.Contacts_Categories__c == 'Alumni');
        System.assert(myContact1Reloaded.Contacts_Marketing_Preferences__c == 'Newsletters (EHL e-Newsletter)');
        System.assert(myContact1Reloaded.Contacts_Membership__c == 'Student Committees' );
        
        
        
        
        
        
    }
}