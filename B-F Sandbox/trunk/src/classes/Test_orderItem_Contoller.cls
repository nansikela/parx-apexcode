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
private class Test_orderItem_Contoller {
	static testMethod void orderItem_Controller_Coverage() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        Profile[] p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];
        //Profile[] p1 = [SELECT Id FROM Profile WHERE Name = 'AUD-Customer Service (Platform)'];        
        u1.ProfileID = p1[0].id;      
        u1.Market__c = 'Australia';
        insert u1;		
        
		// SOQL Query for Order & Order_Item Record Type Data
		RecordType p_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE r.Name = 'Wet Goods' AND SObjectType = 'Product__c'];       
        RecordType o_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE  r.Name = 'New' AND SObjectType = 'Order__c'];
        RecordType oi_rt = [SELECT r.Name, r.Id FROM RecordType r WHERE r.Name = 'New' AND SObjectType = 'Order_Item__c'];
        
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
        
		// Test Data for Market
		List<Market__c> markets = [SELECT Id FROM Market__c WHERE Name = 'Australia'];

	
		List<Product__c> pList = new List<Product__c>();
		
		for(integer x = 0; x < 3; x++) {
			Product__c p = new Product__c();
			p.Name = 'TestOrderProduct_' + x;
			p.IsActive__c = true;
			p.RecordTypeId = p_rt.Id;
			p.Market__c = markets[0].Id;
			p.Brand__c = b.Id;
			p.Description__c = p.Name;
			p.ProductCode__c = 'LEG-' + x;
			p.Pricing_Reference_Material__c = 'prm0001';
			pList.add(p);
		}
		insert pList;
		
        
        system.runas(u1) {
	        Account a = new Account();
        	a.Name = 'Test Account';
        	a.Market__c = markets[0].Id;
        	System.debug('[testOrderItemController] market: ' + a.Market__c);
        	insert a;
        	 
        	 Contact c = new Contact();
        	 c.AccountId = a.Id;
        	 c.FirstName = 'Test';
        	 c.LastName = 'Contact';
        	 insert c;
        	 
        	 Wholesaler__c w = new Wholesaler__c();
        	 w.Name = 'Test Wholesaler';
        	 w.Account__c = a.Id;
        	 w.SAP_Number__c = 'ECC1234';
        	 w.Is_Active__c = true;
        	 insert w;
        	 
        	 Price_Tolerance__c pt = new Price_Tolerance__c();
        	 pt.Max_PA_Per_Case__c = 10;
        	 pt.PRM_Units_Per_Case__c = 12;
        	 pt.Price_Ref_Material__c = 'prm0001';
        	 pt.Banner_Partner__c = 'bp001';
        	 insert pt;
        	 
        	 Account_Wholesaler__c aw = new Account_Wholesaler__c();
        	 aw.Account__c = a.Id;
        	 aw.Wholesaler__c = w.Id;
        	 aw.Wholesaler_Account_Number__c = 'WAN-1234';
        	 aw.Wholesaler_Account_Name__c = 'Test Account for Test W/Saler';
        	 aw.Banner_Partner__c = pt.Banner_Partner__c;
        	 insert aw;

        	 Wholesaler_Product__c wp1 = new Wholesaler_Product__c();
        	 wp1.Name = 'wp_Product_0';
        	 wp1.SAP_Material_Number__c = 'SAPMN001';
        	 wp1.Wholesaler__c = w.Id;
        	 wp1.Product__c = pList[0].Id;
        	 insert wp1;
        	 
        	 Wholesaler_Product__c wp2 = new Wholesaler_Product__c();
        	 wp2.Name = 'wp_Product_2';
        	 wp2.SAP_Material_Number__c = '';
        	 wp2.Wholesaler__c = w.Id;
        	 wp2.Product__c = plist[2].Id;
        	 insert wp2;
        	 
        	 Order__c ord = new Order__c();
        	 ord.Account__c = a.Id;
        	 ord.RecordTypeId = o_rt.Id;
        	 ord.Contact__c = c.Id;
        	 ord.Order_Type__c = 'In-Direct';
        	 ord.Status__c = 'New';
        	 ord.Wholesalers__c = aw.Id;
        	 insert ord;
        	 
        	 Order_Item__c oi1 = new Order_Item__c();
        	 oi1.Order__c = ord.Id;
        	 oi1.Product__c = pList[0].Id;
        	 oi1.Carton__c = 1;
        	 insert oi1;
        	 
        	 
        	 ApexPages.currentPage().getParameters().put('Id', ord.Id);
        	 test.startTest();
        	 
        	 ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ord);
        	 OrderItem_Controller controller = new OrderItem_Controller(sc);
        	 controller.myOrder = ord;
        	 
        	 List<SelectOption> myBrandsList = controller.getBFBrandsList();
        	 System.debug('number of brands in list: ' + myBrandsList.size());
        	 
			 controller.bfBrandValue = b.Id;
			 controller.filterAction();
			 System.debug('prodselection.size; ' + controller.ProdSelection.size());
			 //System.assert(controller.ProdSelection.size() == 10);			
			 
			 controller.ProductNameTextValue = 'TestOrderProduct';
			 controller.filterAction();
			 
			 controller.ProductCodeTextValue = 'LEG';
			 controller.filterAction();
			 
			 controller.DescriptionTextValue = 'TestOrder';
			 controller.filterAction();
			 
			 controller.bfBrandTextValue = 'Jazza';
			 controller.filterAction();
			 //System.assert(controller.ProdSelection.size() == 10);
			 
			 // Test lineItemWrapper class
			 OrderItem_Controller.lineItemWrapper liw = new OrderItem_Controller.lineItemWrapper();
			 OrderItem_Controller.lineItemWrapper liw1 = new OrderItem_Controller.lineItemWrapper(ord, null, pList[0]);
			 System.assert(liw1.carton == 0);
			 System.assert(liw1.unit == 0);
			 System.assert(liw1.discount == 0);
			 System.assert(liw1.bonusCarton == 0);
			 System.assert(liw1.bonusUnit == 0);
			 
			 controller.ProdSelection.clear();
			 List<OrderItem_Controller.productWrapper> pwList = new List<OrderItem_Controller.productWrapper>();
		     OrderItem_Controller.productWrapper pw = new OrderItem_Controller.productWrapper(pList[0]);
		     OrderItem_Controller.productWrapper pw1 = new OrderItem_Controller.productWrapper(pList[1]);
		     pwList.add(pw);
		     
		     controller.ProdSelection.add(pw);
		     controller.ProdSelection.add(pw1);
			 controller.addProducts();
			 System.debug('[test_oictrl] myorderitems.size: ' + controller.myOrderItems.size());
			 
			 //System.assert(controller.myOrderItems.size() == 1);
			 
			 //controller.filterAction();
			 controller.BuildLineItems();
			 //System.assert(controller.myOrderItems.size() == 11);

			 controller.myOrderItems.clear();
			 
			 OrderItem_Controller.lineItemWrapper liw2 = new OrderItem_Controller.lineItemWrapper(ord, null, pList[1]);
			 controller.myOrderItems.add(liw2);
			 
			 liw1.selected = true;
			 liw1.orderItem.Wholesaler_Product__c = wp1.Id;
			 controller.myOrderItems.add(liw1);

			 controller.removeOrderItems();
			 	//System.assert(controller.myOrderItems.size() == 9);			 	

			 liw.orderItem.Carton__c = 1;			 
			 controller.saveAction();
			 if (ApexPages.getMessages().size() > 0) {
			 	System.debug('Error saving order ' + ord.Id + ' [' + ord.Name + ']');
			 } else {
			 	//List<Order_Item__c> items = [SELECT Id FROM Order_Item__c WHERE Order__c = :ord.Id];
			 	//System.assert(items.size() == controller.myOrderItems.size());
			 } 

			 plist[2].Pricing_Reference_Material__c = 'prm002';
			 OrderItem_Controller.lineItemWrapper liw3 = new OrderItem_Controller.lineItemWrapper(ord, null, plist[2]);		
			 controller.myOrderItems.add(liw3);
			 controller.saveAction();
			 
			 //liw.orderItem.Carton__c = 1;
			 //liw.orderItem.Unit__c = 1;
			 //liw.orderItem.Carton_Bonus__c = 1;
			 //controller.myOrderItems.clear();
			 //controller.myOrderItems.add(liw);
			 //controller.saveAction();
			 
			 controller.myOrder = ord;
	   		 controller.BuildLineItems();
	   		 	 
	   	     
	   		 	 
			 controller.close();
			 controller.saveAndClose();
        	 test.stopTest();
        }
	}
}