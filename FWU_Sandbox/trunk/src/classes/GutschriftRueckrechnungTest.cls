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
private class GutschriftRueckrechnungTest {

    static testMethod void myUnitTest() {
        String AccId = testData.creationAccount();
    	  
        Opportunity opp = new Opportunity(Name='Test', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), REAR2A__c = 0, Lizenznummer__c = '10206');
        insert opp;
         
       Rechnung__c rechnung = new Rechnung__c(Name='Anyway1', AUN211__c = opp.id);
    	  insert rechnung;
    	  
    	 list<String> Ids = new list<String>();
    	 Ids.add(rechnung.id);
	 GutschriftRueckrechnung.init(Ids, 'true');
	 
	
    }
}