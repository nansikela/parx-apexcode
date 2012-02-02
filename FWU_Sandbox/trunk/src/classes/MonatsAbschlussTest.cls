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
private class MonatsAbschlussTest {

    static testmethod void MonatsAbschlussBatchStartTest() {
    	MonatsAbschlussAccount.runTest=true;
		MonatsAbschlussArtikel.runTest=true;
		MonatsAbschlussBatchStart.start();
	}
	
	static testmethod void MonatsAbschlussTest() {
		MonatsAbschlussAccount.runTest=true;
		MonatsAbschlussArtikel.runTest=true;
		list<sobject> acc=new list<sobject>();
		MonatsAbschluss.MonatsAbschlussAccountRun(acc);
		list<sobject> prod=new list<sobject>();
		MonatsAbschluss.MonatsAbschlussArtikelRun(prod);
	}
	
	static testmethod void MonatsAbschlussAccountTest() {
		MonatsAbschlussAccount.runTest=true;
		MonatsAbschlussArtikel.runTest=true;
		map<Id, Account> accs=new map<Id, Account>();
		testData.testOpportunity mt=new testData.testOpportunity();
		accs.put(mt.a.id, mt.a);
		//for (Account a: [SELECT Id, UMLJ02__c, UM1V02__c, UM2V02__c, UM3V02__c, UM4V02__c, BillingCountry FROM Account limit 10]) {
		//	if (a.BillingCountry==null || a.BillingCountry!='DE') a.BillingCountry='DE';
		//	accs.put(a.id, a);
		//}
		MonatsAbschlussAccount.run(accs);
	}
	
	static testmethod void MonatsAbschlussArtikelTest() {
		MonatsAbschlussAccount.runTest=true;
		MonatsAbschlussArtikel.runTest=true;
		map<Id, Product2> prods=new map<Id, Product2>();
		testData.testSammelnummer mt=new testData.testSammelnummer();
		prods=mt.pmap.deepClone();
		MonatsAbschlussArtikel.run(prods);
	}
	
	static testmethod void MonatsAbschlussAccountBatchTest() {
		MonatsAbschlussAccount.runTest=true;
		MonatsAbschlussArtikel.runTest=true;
		map<Id, Account> accs=new map<Id, Account>();
		testData.testOpportunity mt=new testData.testOpportunity();
		accs.put(mt.a.id, mt.a);
		MonatsAbschlussBatchStart.start();
	}
	
	static testmethod void MonatsabschlussPageTest() {
		MonatsAbschlussPage ctrl = new MonatsAbschlussPage();
		ctrl.confirmed();
		ctrl.getCurrentMonth();
		ctrl.init();
		ctrl.noaction();
	}
	
}