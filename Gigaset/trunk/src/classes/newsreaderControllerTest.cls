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
private class newsreaderControllerTest {

    static testmethod void newsreadertest1() {
    	testData.initData mytestData = new testData.initData('de',false);
    	
    	test.setCurrentPage(Page.page);
    	ApexPages.currentPage().getParameters().put('pageid',System_Settings.newsreaderpageid);
	 	
	 	System.runAs(mytestData.testuser) {
	 	newsreader ctrl = new newsreader();
		ctrl.openNews();
		ctrl.goHome();
	 	}
	 }
	 
	 static testmethod void newsreadertestWithNews1() {
    	testData.initData mytestData = new testData.initData('de',false);
    	ContentItem__c ci=new ContentItem__c();
    	ci.Portal__c='de';
    	ci.IsActive__c=true;
    	ci.IsPro__c=false;
    	ci.Release_Date__c=System.today().addDays(-30);
    	ci.Text__c='text';
    	ci.TopNews__c=true;
    	ci.Title__c='TestTitle';
    	insert ci;
    	test.setCurrentPage(Page.page);
    	ApexPages.currentPage().getParameters().put('pageid',System_Settings.newsreaderpageid);
	 	
	 	System.runAs(mytestData.testuser) {
	 	newsreader ctrl = new newsreader();
		ctrl.openNews();
		ctrl.goHome();
	 	}
	 }
	 
	 static testmethod void newsreadertestWithNews2() {
    	testData.initData mytestData = new testData.initData('de',false);
    	ContentItem__c ci=new ContentItem__c();
    	ci.Portal__c='de';
    	ci.IsActive__c=true;
    	ci.IsPro__c=false;
    	ci.Release_Date__c=System.today().addDays(-30);
    	ci.Text__c='text';
    	ci.TopNews__c=true;
    	ci.Title__c='TestTitle';
    	insert ci;
    	test.setCurrentPage(Page.page);
    	ApexPages.currentPage().getParameters().put('pageid',System_Settings.newsreaderpageid);
	 	ApexPages.currentPage().getParameters().put('newsid',ci.id);
	 	System.runAs(mytestData.testuser) {
	 	newsreader ctrl = new newsreader();
		ctrl.openNews();
		ctrl.goHome();
	 	}
	 }
}