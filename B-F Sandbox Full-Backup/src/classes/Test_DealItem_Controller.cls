/* Class Name : Test_DealItem_Controller
* Description: Test class to test the deal item controller
* Created By : Tass Tsakiridis
* Created On : 2nd May 2012
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
*/ 
@isTest
private class Test_DealItem_Controller {
	static testMethod void unitTest1() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        Profile[] p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];
        //Profile[] p1 = [SELECT Id FROM Profile WHERE Name = 'AUD-Customer Service (Platform)'];        
        u1.ProfileID = p1[0].id;      
        u1.Market__c = 'Australia';
        insert u1;		
        
		// SOQL Query for Order & Order_Item Record Type Data
		RecordType p_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE r.Name = 'Outlet Deal' AND SObjectType = 'Group_Promotions__c'];       
        RecordType o_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE  r.Name = 'Group Deal' AND SObjectType = 'Group_Promotions__c'];
        
        
		// Test Data for Market
		List<Market__c> markets = [SELECT Id FROM Market__c WHERE Name = 'Australia'];

		List<Reference_Material_Group__c> pList = new List<Reference_Material_Group__c>();
		
		for(integer x = 0; x < 3; x++) {
			Reference_Material_Group__c p = new Reference_Material_Group__c();
			p.Name = 'TestOrderProduct_' + x;
			p.Is_Active__c = true;
			p.Legacy_Code__c = 'LEG00' + x;
			p.Reference_Material_Group_Number__c = 'mat00' + x;
			pList.add(p);
		}
		insert pList;
		
        
        system.runas(u1) {
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

        	 
        	 Group_Promotions__c deal = new Group_Promotions__c();
        	 deal.Account__c = a.Id;
        	 deal.RecordTypeId = p_rt.Id;
        	 deal.Wholesaler__c = w.Id;
        	 deal.Account_Wholesaler__c = aw.Id;
        	 deal.Activity_Code__c = 'Catalogue';
        	 deal.Application__c = 'On Retailers Invoice - Rate per Case On';
        	 deal.Deal_Channel__c = 'ON';
        	 deal.Deal_Method__c = 'Rate Per Case';
        	 deal.Activity_Comment__c = 'test controller';
        	 deal.Buy_Period_Start_Date__c = Date.today();
        	 deal.Buy_Period_End_Date__c = Date.today();
        	 insert deal;
        	 
        	 Group_Promotion_Item__c oi1 = new Group_Promotion_Item__c();
        	 oi1.Group_Promotion__c = deal.Id;
        	 oi1.Reference_Material_Group__c = pList[0].Id;
        	 oi1.Discount_Amount__c = 1.5;
        	 insert oi1;
        	 
        	 
        	 ApexPages.currentPage().getParameters().put('Id', deal.Id);
        	 test.startTest();
        	 
        	 ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(deal);
        	 DealItem_Controller controller = new DealItem_Controller(sc);
        	 controller.myDeal = deal;
        	 
			 
			 // Test lineItemWrapper class
			 DealItem_Controller.lineItemWrapper liw = new DealItem_Controller.lineItemWrapper();
			 
			 controller.addLine();
			 System.debug('[test_oictrl] myorderitems.size: ' + controller.myDealItems.size());
			 
			 //System.assert(controller.myOrderItems.size() == 1);
			 
			 //controller.filterAction();
			 controller.BuildLineItems();
			 //System.assert(controller.myOrderItems.size() == 11);

			 controller.myDealItems.clear();
			 
			 //OrderItem_Controller.lineItemWrapper liw2 = new OrderItem_Controller.lineItemWrapper(deal, null, pList[1]);
			 //controller.myDealItems.add(liw2);
			 
			 //liw1.selected = true;
			 //controller.myDealItems.add(liw1);

			 controller.removeDealItems();
			 	//System.assert(controller.myOrderItems.size() == 9);			 	

			 controller.saveAction();
			 if (ApexPages.getMessages().size() > 0) {
			 	System.debug('Error saving order ' + deal.Id + ' [' + deal.Name + ']');
			 } else {
			 } 

			 
			 controller.myDeal = deal;
	   		 controller.BuildLineItems();
	   		 	 
			 controller.close();
			 controller.saveAndClose();
        	 test.stopTest();
        }
	}
}