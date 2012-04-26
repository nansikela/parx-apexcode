@isTest
private class Test_OrderItem_Redirect_Controller {
	static testMethod void unitTest1() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;      
        insert u1;		
        		
		RecordType p_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE r.Name = 'Wet Goods' AND SObjectType = 'Product__c'];       
        RecordType o_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE  r.Name = 'New' AND SObjectType = 'Order__c'];
        RecordType oi_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE r.Name = 'New' AND SObjectType = 'Order_Item__c'];

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
				
        // Test Data for Supplier
        Supplier__c s = new Supplier__c();
        s.Name = 'test Supplier';
        s.Is_B_F_Brand__c = true;
        insert s;
        
        // Test Data for Brand
        Brand__c b = new Brand__c();
        b.Supplier__c = s.Id;
        b.Spirit_Type__c = 'Bourbon';
        b.Name = 'Jazza Daniels';
        insert b;

		Product__c p = new Product__c();
		p.Name = 'test Product1';
		p.IsActive__c = true;
		p.RecordTypeId = p_rt.Id;
		p.Market__c = markets[0].Id;
		p.Brand__c = b.Id;
		p.Description__c = p.Name;
		p.ProductCode__c = 'LEG-1';
		
		
		System.runAs(u1) {
			Order__c o = new Order__c();
			o.Account__c = a.Id;
			o.Contact__c = c.Id;
			o.Wholesalers__c = aw.Id;
			o.RecordTypeId = o_rt.Id;
			insert o;
			
			Order_Item__c oi1 = new Order_Item__c();
			oi1.Order__c = o.Id;
			oi1.Product__c = p.Id;
			oi1.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New' AND SObjectType = 'Order_Item__c'][0].Id;
			oi1.Carton__c = 1;
			insert oi1;
			
		    PageReference pageRef = Page.orderItem;
		    Test.SetCurrentpage(pageRef);
		    ApexPages.StandardController stdCon = new ApexPages.StandardController(oi1);
		    OrderItem_Redirect_Controller oictrl = new OrderItem_Redirect_Controller(stdCon);
		    oictrl.Redirect();
		    
		    stdCon = new ApexPages.StandardController(oi1);
		    oictrl = new OrderItem_Redirect_Controller(stdCon);
		    oictrl.Redirect();
		}
	}
}