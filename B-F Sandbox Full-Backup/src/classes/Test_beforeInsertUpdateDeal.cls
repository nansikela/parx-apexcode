/* Class Name : Test_OrderItem_Controller
* Description: Test class to test the order item controller
* Created By : Tass Tsakiridis
* Created On : 17th April 2012
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
*/ 
@isTest
private class Test_beforeInsertUpdateDeal {
	static testMethod void UnitTest1() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        Profile[] p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];
        //Profile[] p1 = [SELECT Id FROM Profile WHERE Name = 'AUD-Customer Service (Platform)'];        
        u1.ProfileID = p1[0].id;      
        u1.Market__c = 'Australia';
        insert u1;		
        
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name = 'Outlet Deal' AND SObjectType = 'Group_Promotions__c']; 
		// Test Data for Market
		List<Market__c> markets = [SELECT Id FROM Market__c WHERE Name = 'Australia'];
	
        System.runas(u1) {
        	Account a = new Account();
        	a.Name = 'Test Account';
        	a.Market__c = markets[0].Id;
        	insert a;
        	
        	Wholesaler__c w = new Wholesaler__c();
        	w.Name = 'Test Wholesaler';
        	w.Account__c = a.Id;
        	w.SAP_Number__c = 'ECC1234';
        	w.Is_Active__c = true;
        	insert w;
        	
        	Account_Wholesaler__c aw = new Account_Wholesaler__c();
        	aw.Account__c = a.Id;
        	aw.Wholesaler__c = w.Id;
        	aw.Wholesaler_Account_Number__c = 'WAN-1234';
        	aw.Wholesaler_Account_Name__c = 'Test Account for Test W/Saler';
        	insert aw;

			Banner_Groups__c bg = new Banner_Groups__c();
			bg.Name = 'Test Banner Group';
			insert bg;
			         	
        	Group_Promotions__c deal = new Group_Promotions__c();
        	if (recordTypes.size() > 0) {
        		deal.RecordTypeId = recordTypes[0].Id;        		
        	}
 			deal.Account__c = a.Id;
 			deal.Wholesaler__c = w.Id;       	
 			deal.Account_Wholesaler__c = aw.Id;
 			deal.Buy_Period_Start_Date__c = Date.today();
 			deal.Buy_Period_End_Date__c = Date.today();
        	deal.Deal_Channel__c = 'ON';
        	deal.Deal_Method__c = 'Rate Per Case';
        	deal.Application__c = 'On Retailers Invoce - Rate per Case On';
        	deal.Activity_Code__c = 'Price Support';
        	deal.Activity_Comment__c = 'test trigger';
        	insert deal;
        	
        }
	}
}