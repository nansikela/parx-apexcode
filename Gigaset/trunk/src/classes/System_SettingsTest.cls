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
private class System_SettingsTest {

    static testMethod void System_SettingsTest() {
		testData.initData testData = new testData.initData(System_Settings.portal, System_Settings.isPro);
		test.startTest();
       //System.assertNotEquals(System_Settings.homepageid,null);
       test.setCurrentPageReference(System_Settings.goHome());
       for (Integer i=0;i<testData.Pages.size();i++) {
       	System_Settings.getCurrentNavigationPointLabel(testData.Pages.get(i).id);
       }
       System_Settings.getCurrentUpdatedUser();
       System_Settings.getExternalURL('clcode1');
       System_Settings.getLabel('clcode0');
       System_Settings.goHome();
       System_Settings.init();
       System_Settings.isPortalUser();
       System_Settings.logError('123', '!23', '1233');
       System_Settings.logError('1234', '23454', '234', '234', 'DEBUG');
       System_Settings.redirectToLogin();
       System_Settings.setLanguage();
       System_Settings.showClearing();
       System.assert(System_Settings.showPmLink());
       System_Settings.showPreset();
       System_Settings.showPrivacy();
       System_Settings.showPrivacyAnonymous();
       test.stopTest();
    }
    
    static testMethod void System_SettingsUserTest() {
    	User u;
    	String portal='de';
    	Boolean isPro=false;
    	try {
    		u=[SELECT Id, ContactId FROM User WHERE ContactId!=null AND IsPortalEnabled=true AND isActive=true limit 1];
    		if (u!=null && u.ContactId!=null) {
    			Contact c = [SELECT Id, Gigaset_Extranet__c, Gigaset_Pro__c, Portal__c FROM Contact WHERE Id=:u.contactId];
    			portal=c.Portal__c;
    			isPro=c.Gigaset_Pro__c;
    		}
    	} catch (System.QueryException e) {}
    	System.assertNotEquals(u, null);
    	if (u!=null) {
    		testData.initData testData = new testData.initData(portal, isPro);
    		System.runAs(u) {
    	
		
		test.startTest();
       //System.assertNotEquals(System_Settings.homepageid,null);
       test.setCurrentPageReference(System_Settings.goHome());
       for (Integer i=0;i<testData.Pages.size();i++) {
       	System_Settings.getCurrentNavigationPointLabel(testData.Pages.get(i).id);
       }
       System_Settings.getCurrentUpdatedUser();
       System_Settings.getExternalURL('clcode1');
       System_Settings.getLabel('clcode0');
       System_Settings.goHome();
       System_Settings.init();
       System_Settings.isPortalUser();
       System_Settings.logError('123', '!23', '1233');
       System_Settings.logError('1234', '23454', '234', '234', 'DEBUG');
       System_Settings.redirectToLogin();
       System_Settings.setLanguage();
       System_Settings.showClearing();
       //System.assert(System_Settings.showPmLink());
       System_Settings.showPreset();
       System_Settings.showPrivacy();
       System_Settings.showPrivacyAnonymous();
       test.stopTest();
    		}
    	}
    }
}