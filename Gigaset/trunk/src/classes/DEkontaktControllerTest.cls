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
private class DEkontaktControllerTest {

    static testMethod void testDEkontaktController() {
    	testData.initData mytestData = new testData.initData('de',false);
    	test.setCurrentPage(Page.page);
        System.runAs(mytestData.testuser) {
        DEkontaktController ctrl=new DEkontaktController();
        ctrl.isAuthenticated=true;
        ApexPages.currentPage().getParameters().put('pageid',SystemSettings.kontaktpageid);
        ApexPages.currentPage().getParameters().put('kontakttyp','Kontakt');
        
	        ctrl.init();
	        ctrl.goHomeUrl='www.google.de';
	        ctrl.saveRequest();
        }
    }
    
    static testMethod void testDEkontaktControllergenerisch() {
    	testData.initData mytestData = new testData.initData('de',false);
    	test.setCurrentPage(Page.page);
        System.runAs(mytestData.testuser) {
        DEkontaktControllergenerisch ctrl=new DEkontaktControllergenerisch();
        ctrl.isAuthenticated=true;
        ApexPages.currentPage().getParameters().put('pageid',SystemSettings.kontaktpageid);
        ApexPages.currentPage().getParameters().put('kontakttyp','Kontakt');
        
	        ctrl.init();
	        ctrl.goHomeUrl='www.google.de';
	        ctrl.saveRequest();
        }
    }
}