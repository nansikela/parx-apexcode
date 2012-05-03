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
private class Test_wombat_Graveyard {
	public final static Integer twoBillion = 2000000000;

    static testMethod void Test_getGraveyardData() {
              
        
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
		User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='wombatTestUser@b-f.com');
		System.debug('USER ID'+u1.Id);

		DateTime lastSyncDate = Datetime.now();
       	String ownerId = String.valueOf(u1.Id);
        //string sessionId = 'a20Q0000000DTbY';
		wombat_Sync_Session__c wss = new wombat_Sync_Session__c();
		wss.InProgress__c = true;
		wss.App_Version__c = '1.1';
		wss.IP_Address__c = '1.1.1.1';
		wss.Model__c = 'TestMethod';
		wss.User__c = u1.Id;
		insert wss;
		
		String sessionId = wss.Id;
       	
       	
       	System.runAs(u1){
			test.startTest();
       		//Testing Wombat_graveyard
	       	
	      	Asset_Type__c a = new Asset_Type__c();
	      	a.Name = 'Test_Asset Type';
	      	insert a;
	      	
	       	wombat_graveyard.getGraveyardItems(null, String.valueOf(u1.Id), lastSyncDate.format());
	       	
	       	delete a;
	       	wombat_graveyard.getGraveyardItems('Asset_Type__c', String.valueOf(u1.Id), lastSyncDate.format());
	       	wombat_graveyard.getGraveyardItems('Account', String.valueOf(u1.Id), null);
	       	
			//Testing Wombat_graveyard_item
			wombat_graveyard_item wgi = new wombat_graveyard_item();
			
			//Testing wombat_UpdateSessionStatus
			wombat_UpdateSessionStatus wuss = new wombat_UpdateSessionStatus();
			
			test.stopTest();
       	}
    }
}