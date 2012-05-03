@isTest
private class Test_DealItem_Redirect_Controller {
	static testMethod void unitTest1() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;      
        insert u1;		
        		
		RecordType p_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE r.Name = 'Outlet Deal' AND SObjectType = 'Group_Promotions__c'];       
        RecordType o_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE  r.Name = 'Group Deal' AND SObjectType = 'Group_Promotions__c'];

		List<Market__c> markets = [SELECT Id FROM Market__c WHERE Name = 'Australia'];
	
		Account a = new Account();
		a.Name = 'test account';
		a.Market__c = markets[0].Id;
		insert a;
		
		Contact c = new Contact();
		c.AccountId = a.Id;
		c.FirstName = 'test';
		c.LastName = 'contact';
		insert c;
		
		Wholesaler__c wsaler = new Wholesaler__c();
		wsaler.Name = 'test Wholesaler';
		wsaler.Account__c = a.Id;
		wsaler.Is_Active__c = true;
		wsaler.Market__c = markets[0].Id;
		insert wsaler;
		
		Account_Wholesaler__c aw = new Account_Wholesaler__c();
		aw.Account__c = a.Id;
		aw.Wholesaler__c = wsaler.Id;
		insert aw; 
						
		Reference_Material_Group__c m1 = new Reference_Material_Group__c();
		m1.Is_Active__c = true;
		m1.Legacy_Code__c = 'LEG001';
		m1.Reference_Material_Group_Number__c = 'mat001';
		insert m1;
		
		Reference_Material_Group__c m2 = new Reference_Material_Group__c();
		m2.Is_Active__c = true;
		m2.Legacy_Code__c = 'LEG002';
		m2.Reference_Material_Group_Number__c = 'mat002';
		insert m2;

		System.runAs(u1) {
			Group_Promotions__c o = new Group_Promotions__c();
			o.Account__c = a.Id;
			o.Wholesaler__c = wsaler.Id;
			o.RecordTypeId = o_rt.Id;
			insert o;
			
			Group_Promotion_Item__c oi1 = new Group_Promotion_Item__c();
			oi1.Group_Promotion__c = o.Id;
			oi1.Reference_Material_Group__c = m1.Id;
			oi1.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Outlet Deal Item' AND SObjectType = 'Group_Promotion_Item__c'][0].Id;
			oi1.Discount_Amount__c = 1.5;
			insert oi1;
			
		    PageReference pageRef = Page.dealItem;
		    Test.SetCurrentpage(pageRef);
		    ApexPages.StandardController stdCon = new ApexPages.StandardController(oi1);
		    DealItem_Redirect_Controller oictrl = new DealItem_Redirect_Controller(stdCon);
		    oictrl.Redirect();
		    
		    stdCon = new ApexPages.StandardController(oi1);
		    oictrl = new DealItem_Redirect_Controller(stdCon);
		    oictrl.Redirect();
		}
	}

}