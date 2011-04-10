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
private class FNA_MapConTest {

    	 static testMethod void myUnitTest() {
    	 	// create some accounts
    	 	list<Account> accs =new list<Account>();
    	 	for (Integer i=0; i<5; i++) {
    	 		Account a=new Account();
    	 		a.Name='Parx GmbH ' + i;
    	 		a.BillingCity='München';
    	 		a.BillingCountry='Deutschland';
    	 		a.BillingPostalCode='80337';
    	 		a.BillingStreet='Waltherstr. 29' + i;
    	 		accs.add(a);
    	 	}
    	 	insert accs;
    	 	accs=[SELECT Id, Name, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Phone, FN__Lat__c, FN__Lon__c, FN__Mapping_Status__c, Type, Distance__c, FN__Which_Address__c FROM Account WHERE Name like 'Parx GmbH %'];
    	 	test.startTest();
    	 	FNA_MapCon.getBrowserName();
    	 	test.setCurrentPage(Page.FindNearbyAccountsMap);
    	 	ApexPages.currentPage().getParameters().put('Lang','de');
    	 	ApexPages.currentPage().getParameters().put('Portal','de');
    	 	ApexPages.currentPage().getParameters().put('Pro','true');
    	 	ApexPages.currentPage().getParameters().put('city1','München');
    	 	FNA_MapCon ctrl=new FNA_MapCon();
    	 	ctrl.mainAccount=accs.get(0);
    	 	test.setCurrentPage(Page.FindNearbyAccountsMap);
    	 	ApexPages.currentPage().getParameters().put('Lang','de');
    	 	ApexPages.currentPage().getParameters().put('Portal','de');
    	 	ApexPages.currentPage().getParameters().put('Pro','true');
    	 	ApexPages.currentPage().getParameters().put('city1','München');
    	 	ctrl.latStart=1;
    	 	ctrl.City='München';
    	 	ctrl.error=false;
    	 	ctrl.Lands='Deutschland';
    	 	ctrl.LatMax=1;
    	 	ctrl.LatMin=1;
    	 	ctrl.LonMax=1;
    	 	ctrl.LonMin=1;
    	 	ctrl.lonStart=1;
    	 	ctrl.msg='';
    	 	ctrl.msg2='';
    	 	ctrl.Param_Lang='de';
    	 	ctrl.Param_Portal='de';
    	 	ctrl.Param_Pro=false;
    	 	ctrl.Rmax=1;
    	 	ctrl.showTable=true;
    	 	
    	 	ctrl.getParams();
    	 	ctrl.findMax();
    	 	ctrl.getError();
    	 	ctrl.getItems();
    	 	ctrl.getLocations();
    	 	ctrl.getmainAccount();
    	 	ctrl.getMsg();
    	 	ctrl.getMsg2();
    	 	ctrl.goBack();
    	 	ctrl.goBackMap();
    	 	//ctrl.googleRequest();
    	 	ctrl.isSourceAccountGood();
    	 	ctrl.makeList();
    	 	ctrl.makeQuery();
    	 	//ctrl.Search();
    	 	//ctrl.init();
    	 	test.stopTest();
    	 }
}