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
private class onRechnungTest {

	// TODO
	// bitte mit System.asserts Erfolg pruefen
	// unbedingt auch verschiedene Use Cases testen
	// (z. B. Maximum/Minimum, null in Feldern, ...)
	// versuche 100% Code Abdeckung zu erreichen (nur Code in catch Blöcken muss nicht unbedingt getestet werden)
    static testMethod void myUnitTest() {
    	
    	String AccId = testData.creationAccount();
    	System.assertNotEquals(null,AccId);
      
      Opportunity opp1 = new Opportunity(Name='Test1', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), REAR2A__c = 0);
      insert opp1;
    	System.assertNotEquals(null,opp1.id);
    	
    	Opportunity opp2 = new Opportunity(Name='Test2', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), REAR2A__c = 1);
      insert opp2;
    	System.assertNotEquals(null,opp2.id);
    	
    	Opportunity opp3 = new Opportunity(Name='Test3', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), REAR2A__c = 3);
      insert opp3;
    	System.assertNotEquals(null,opp3.id);
    	
    	Opportunity opp4 = new Opportunity(Name='Test4', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), REAR2A__c = 4);
      insert opp4;
    	System.assertNotEquals(null,opp4.id);
    	
    	list<Nummernkreis__c> NummerKreis;
    	try {
    	NummerKreis = new list<Nummernkreis__c>([Select Id, Nummer__c from Nummernkreis__c]);
    	}
    	catch (system.Queryexception e) {
    		system.debug('Problem by select');
    	}
    	
    	try {
    	delete NummerKreis;
    	}
    	catch (system.DMLexception e) {
    		system.debug('Problem by delete');
    	}
    	
    	
        Rechnung__c rechnung = new Rechnung__c(Name='Anyway1', AUN211__c = opp1.id);
    	  insert rechnung;
    	  system.assertNotEquals(null,rechnung.id);
    	  
    	  Rechnung__c rechnung2 = new Rechnung__c(Name='Anyway2', AUN211__c = opp2.id);
    	  insert rechnung2;
    	  system.assertNotEquals(null,rechnung2.id);
    	  
    	  Rechnung__c rechnung3 = new Rechnung__c(Name='Anyway3', AUN211__c = opp3.id);
    	  insert rechnung3;
    	  system.assertNotEquals(null,rechnung3.id);
    	  
    	  Rechnung__c rechnung4 = new Rechnung__c(Name='Anyway4', AUN211__c = opp4.id);
    	  insert rechnung4;
    	  system.assertNotEquals(null,rechnung4.id);
    }
}