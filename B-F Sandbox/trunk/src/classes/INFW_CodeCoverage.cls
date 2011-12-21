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
private class INFW_CodeCoverage {
/*
    //Assume that products and Brands are already setup.
    static testMethod void promotionProductSelection_Controller_Coverage() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;        
        insert u1;

            Market__c m = new Market__c();
            m.Name = 'Test Market'; 
            insert m;
            
            Supplier__c s = new Supplier__c();
            s.Name='BF';
            s.Is_B_F_Brand__c=true; 
            insert s;
            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;

            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;              
            
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
            
            List<Product__c> pList = new List<Product__c>();
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                //p.Supplier__c = s.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b1.id;
                pList.add(p);
            }
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b.id;
                pList.add(p);
            }           
            insert pList;
            
        Account a = new Account();          
        system.runas(u1)
        {   
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            //a.Outlet_Class__c = o.id;
            insert a;
            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'Info';
            c.LastName = 'Welders';
            insert c;
            
            Promotion__c prom = new Promotion__c();
            prom.Name = 'test123';
            prom.Account__c = a.id;
            //prom.Brand__c = b.id;
            insert prom;
            
            //PageReference pageRef = new PageReference('/apex/outletVisit');
            //Test.setCurrentPage(pageRef);
           // sObject so = new Outlet_Visit__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(prom);
            promotionProductSelection_Controller constructor = new promotionProductSelection_Controller(sc);        
             
            //constructor.ov.Account__c = a.id;
            List<SelectOption> myRecordTypeList = constructor.getrecordTypeList();
            List<SelectOption> myBrandsList = constructor.getBFBrandsList();
            system.assert(myBrandsList.size()>0);
            
            string myval = constructor.RecordTypeValue;
            constructor.RecordTypeValue = myval;
            
            myval = constructor.bfBrandValue;
            constructor.bfBrandValue = myBrandsList[0].getvalue();
            
            myval = constructor.ProductNameTextValue;
            List<Product__c> myval2 = constructor.ProdSelection;
            myval = constructor.RecordTypeValue;
            myval = constructor.bfBrandValue;
            myval = constructor.ProductNameTextValue;
            myval = constructor.productID;
            myval = constructor.productName;

            constructor.filterAction();
            
            system.debug(Apexpages.getmessages());          
            system.assert(Apexpages.getmessages().size()==0);
        }       
    }
        */     
  /*  //Assume that products and Brands are already setup.
    static testMethod void promotionMaterialItem_Controller_Coverage() {
    	
  //....6/15 Levites Helper Class has User data
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;      
        insert u1;
//....6/15 End Levites 

// Test Data for Market
            Market__c m = new Market__c();
            m.Name = 'Test Market'; 
            insert m;
 
// Test Data for Suppiler            
            Supplier__c s = new Supplier__c();
            s.Name='BF';
            s.Is_B_F_Brand__c=true; 
            insert s;

// Test Data for a New Supplier            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
            
// Test Data for "BF" Brand                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;
            
// Test Data for "Other" Brand
            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;    
                      
// SOQL Query for Record Type Data       
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
   
// Creating "Product" List object           
            List<Product__c> pList = new List<Product__c>();
            
// Purpose of the For Loop is to create 10 Dummy BF Material's for Test Data         
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                //p.Supplier__c = s.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b1.id;
                pList.add(p);
            }
            
// Purpose of the For Loop is to create 10 Dummy Non-BF Material's for Test Data              
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b.id;
                pList.add(p);
            }           
            insert pList;
            
 // New Account Object        
        Account a = new Account();     
        
// Running as the created Test User             
        system.runas(u1)
        {   
        	
// Account Creation         	
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            //a.Outlet_Class__c = o.id;
            insert a;
// Creating Contact            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'Info';
            c.LastName = 'Welders';
            insert c;
//            
//Recordtypeid[] rtypeId = [Select Id From RecordType r where Name = 'Sales Promotion' and SobjectType = 'Promotion__c'];            
recordtype[] rtype = [Select Id From RecordType where Name = 'Sales Promotion' and SobjectType = 'Promotion__c'];
   
 // Creating Promotion           
            Promotion__c prom = new Promotion__c();
            prom.Name = 'test123';
            prom.Account__c = a.id;
            prom.RecordTypeid = rtype[0].id;
system.debug(rtype[0].id)    ;        
//The Fix create promotion with record type            
            //prom.Brand__c = b.id;
            insert prom;
            
 //OLD// PageReference pageRef = new PageReference('/apex/outletVisit');
 //OLD// Test.setCurrentPage(pageRef);
 //OLD// sObject so = new Outlet_Visit__c();
 
// "prom" = Newly Created Promotion
       //     ApexPages.StandardController sc = new ApexPages.StandardController(prom);
// "sc" = ApexPages.StandardController     
            ApexPages.currentPage().getParameters().put('Id', prom.Id);     
            promotionMaterialItem_Controller constructor = new promotionMaterialItem_Controller();        
            constructor.myLimit = 100; 
 //OLD// constructor.ov.Account__c = a.id;
 
 //Creating List for Records Types from promotionMaterialItem_Controller-->>promotionProductHelper
            List<SelectOption> myRecordTypeList = constructor.getrecordTypeList();
            
 //Creating List for Brands from promotionMaterialItem_Controller-->>promotionProductHelper           
            List<SelectOption> myBrandsList = constructor.getBFBrandsList();
            system.debug(myBrandsList);
            system.debug(myRecordTypeList);
            system.assert(myBrandsList.size()>0);

// Declaring myval (Record Type) Type String            
            string myval = constructor.RecordTypeValue;
// Assigning myval (Record Type)               
            constructor.RecordTypeValue = myval;
            
// Declaring myval (Brand)             
            myval = constructor.bfBrandValue;
// Assigning myval (Brand)             
            constructor.bfBrandValue = myBrandsList[0].getvalue();
 
//            
            myval = constructor.ProductNameTextValue; 
            myval = constructor.bfBrandValue;
            
//Create List Object--Reference             

//          
            List<promotionMaterialItem_Controller.wrapper> mySelected = constructor.myPromMatItems;
            system.debug(mySelected);
            system.assert(mySelected.size()==2); //Was An Issue

            //constructor.saveAction();
            //system.debug(Apexpages.getmessages());          
            //system.assert(Apexpages.getmessages().size()==1);
            
            system.debug('about to save');
            mySelected = constructor.myPromMatItems;
            //mySelected[0].selected=true; //Was An Issue
            //mySelected[0].PromMatItem.Quantity__c=1; //Was An Issue
            mySelected[0].PromMatItem.Approval_Status__c = 'New';

            system.debug(Apexpages.getmessages());          
            system.assert(Apexpages.getmessages().size()==1);
                        
            mySelected = constructor.myPromMatItems; 

            system.debug(Apexpages.getmessages());          
            system.assert(Apexpages.getmessages().size()==1);           
            
            mySelected = constructor.myPromMatItems;    
            system.debug(mySelected);
            system.assert(mySelected.size()==2);  //Was An Issue  
             
        }     
          
    }*/
           
           /* 
    //Assume that products and Brands are already setup.
    static testMethod void outletVisit_Controller_Coverage() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;        
        u1.UserPermissionsMobileUser=true; //to test OFFLINE OVIs    
        insert u1;

            Market__c m = new Market__c();
            m.Name = 'Test Market'; 
            insert m;
            
            Supplier__c s = new Supplier__c();
            s.Name='B-F';
            s.Is_B_F_Brand__c=true; 
            insert s;
            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;

            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;  
            
            Outlet_Class__c o = new Outlet_Class__c();
            o.Market__c = m.Id;
            o.Name = 'Outlet';
            insert o;
            
            Key_Task_Template__c k = new Key_Task_Template__c();
            k.Outlet_Class__c=o.id;
            k.Name='Test KT';
            k.Market__c=m.id;
            insert k;
            
            
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
            
            List<Product__c> pList = new List<Product__c>();
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                //p.Supplier__r = s.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b1.id;
                pList.add(p);
            }

       		//Inactive Product
       		Product__c pInactive = new Product__c();
            pInactive.Name = 'myInactiveProduct';
            //p.Supplier__r = s.id;
            pInactive.IsActive__c=false;
            pInactive.RecordTypeId = r.Id;
            pInactive.ProductCode__c = 'myInactiveProduct';
            pInactive.Market__c = m.id; 
            pInactive.Competes_On_Brand__c = b.id; 
            pInactive.Brand__c = b1.id;
            pList.add(pInactive);
                            
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b.id;         
                pList.add(p);
            }           
            insert pList;
            
            Account_Brand__c ab = new Account_Brand__c();
        Account a = new Account();          
        system.runas(u1)
        {   
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            a.Outlet_Class__c = o.id;
            insert a;
            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'Info';
            c.LastName = 'Welders';
            insert c;
            
            //add logic to test Account_Brand
            ab.Account__c =a.id;
            ab.FY_Start__c = date.today().addMonths(-2);
            ab.FY_End__c = date.today().addMonths(10);
            ab.Brand__c = b.id;
            insert ab;
            
            PageReference pageRef = new PageReference('/apex/outletVisit');
            Test.setCurrentPage(pageRef);
            sObject so = new Outlet_Visit__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(so);
            outletVisit_Controller constructor = new outletVisit_Controller(sc);        
            
            constructor.nullAction();
            constructor.refresh();
            
            constructor.ov.Account__c = a.id;
            List<SelectOption> myContacts = constructor.getContacts();
            system.debug(myContacts);
            system.assert(myContacts.size()==1);
            
            constructor.ov.Met_With__c=myContacts[0].getValue();
            constructor.next();
            system.debug(Apexpages.getmessages());          
            system.assert(Apexpages.getmessages().size()==0);
            
            List<SelectOption> myTypeList = constructor.getspiritTypeList();
            List<SelectOption> myBrandsList = constructor.getBFBrandsList();
            List<SelectOption> myCompBrandsList = constructor.getCompBrandsList();

           
            List<outletVisit_Controller.wrapper> myBF = constructor.myBFOvi; 
            system.debug(myBF);
            myBF[0].ovi.Drink_Price__c = 1; 
            myBF[0].ovi.Bottle_Price__c = 10;
            myBF[0].dep1.Bottles__c = 100; 
            List<outletVisit_Controller.wrapper> myCompOvi = constructor.myCompOvi;
            system.debug(myCompOvi);
            myCompOvi[0].ovi.Drink_Price__c = 1; 
            myCompOvi[0].ovi.Bottle_Price__c = 10;
            myBF[0].dep1.Bottles__c = 100;              
            
            List<outletVisit_Controller.wrapperKT> myKTs = constructor.myKTs;
            myKTs[0].selected=true;
            myKTs[0].kt.Met_With__c = c.id;
test.starttest();               
            constructor.saveCommit();
test.stoptest();                
            List<Key_Task__c> myCompletedKTs = constructor.myCompletedKTs;
            system.debug(myCompletedKTs);
            system.assert(myCompletedKTs.size()==1);
            
            constructor.productLookup = myBF[0].ovi.Product__c;
            List<Outlet_Visit_Item__c> myPH = constructor.getmyPHs();
            system.debug(myPH);
            system.assert(myPH.size()==1);
            outletVisit_Controller.wrapperDPHeader myDP = constructor.getmyDPs();
            system.debug(myDP);
            
            string myPstring = constructor.productLookupName; 

            pageRef = new PageReference('/apex/outletVisit?id=' +constructor.ov.id );
            Test.setCurrentPage(pageRef);
            so = new Outlet_Visit__c(id=constructor.ov.id,Account__c=constructor.ov.Account__c,Visit_Date__c = constructor.ov.Visit_Date__c);
            sc = new ApexPages.StandardController(so);
            constructor = new outletVisit_Controller(sc);        

            constructor.cancelKT();
            constructor.spiritType = 'Bourbon';
            constructor.compBrand = 'Bob Beam';
            constructor.nullAction();
                                
        }       

        system.assertequals(100,[Select a.Depletion_Actuals__c from Account_Brand__c a where a.Id =: ab.id].Depletion_Actuals__c);
        Depletion__c d = new Depletion__c();
        d.Account__c = a.id;
        d.Product__c = pList[0].id;
        d.Month_Of_Date__c = date.today();
        d.Bottles__c = 100;
        insert d;
        delete d;
//Now, verify that the processDateOVIs (which is ran because of insert of Accoutn) pulls in KeyTasks and OfflineOVIs records.        
	for(Outlet_Visit__c lstOVs : [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, 
        	(Select Id, Name, Outlet_Visit__c, Bottle_Price_Special__c, Bottle_Price__c, Drink_Price_Special__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Product__c, Available__c, Facing__c, Shelf__c, Space_Placement__c, Double_Price__c, Double_Price_Special__c From Outlet_Visit_Items__r), 
        	(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_Last_Month_Date__c, Depletions_This_Month__c, Depletions_This_Month_Date__c, Depletions_Next_Month__c, Depletions_Next_Month_Date__c From Offline_Outlet_Visit_Items__r),
 			(Select Id, Name, CurrencyIsoCode, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r)         	 
        	From Outlet_Visit__c o where o.Account__c =: a.Id and o.Status__c = 'New' order by Visit_Date__c]){
		//system.assertequals(1,lstOVs.size());
		system.assertequals(0,lstOVs.Outlet_Visit_Items__r.size());
		system.assertequals(20,lstOVs.Offline_Outlet_Visit_Items__r.size());
		system.assertequals(1,lstOVs.Key_Tasks__r.size());        		
     }
               
    }
    */
        
    static testMethod void beforeInsertUpdatePromotion_Coverage() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        insert u1;

        User u2 = helper.createUser();
        u2.Username = 'info2@welders.com';
        u2.Email = 'info2@welders.com';
        u2.Alias = 'infw2';
        u2.CommunityNickname = 'infw98212';
        insert u2;
                
        List<Promotion__c> pList = new List<Promotion__c>();
        Set<ID> pSet = new Set<ID>();
        Test.starttest(); 
            system.runas(u1)
            {             
                Market__c m = new Market__c();
                m.Name = 'Test Market'; 
                insert m;
                            
                Account a = new Account();
                a.Name = 'Test Account';
                a.Market__c = m.Id;
                insert a;
                
                
                
                for(Integer x = 0; x<98; x++)
                {
                    Promotion__c p = new Promotion__c();
                    p.Account__c = a.id;
                    pList.add(p);
                }
                insert pList;
                
                for(Promotion__c p : pList){
                    pSet.add(p.Id);
                    System.debug('The content of promotion is'+p);
                }
            }
            // Get the Promotion record types by name
 			Map<String,Schema.RecordTypeInfo> promoRTMap = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
            // Id for National Promotions US record type
			Id natPromoUSRecType = null;
			// Get the record type id for National Promotions US from the record type map
		 	if(promoRTMap.containsKey('National Promotion - US')){
		 		natPromoUSRecType = promoRTMap.get('National Promotion - US').getRecordTypeId();
		 	}
			List<Internal_Order__c> ioList = new List<Internal_Order__c>{
                new Internal_Order__c(Name='IO1',Description__c='IO1',Internal_Order_Number__c='IO1'),
                new Internal_Order__c(Name='IO2',Description__c='IO2',Internal_Order_Number__c='IO2')};
            insert ioList;
            Promotion__c pro = new Promotion__c(RecordTypeId=natPromoUSRecType,Name='Test',Internal_Order__c=ioList[0].Id);
            insert pro;
            pro.Promotion_Status__c = 'Active';
            update pro;
            try{
            	delete pro;
            }catch(Exception e){}
            
        Test.stoptest(); 

        system.assertequals(pSet.size(),[Select count() from Promotion__c where Brand_Manager__c=:userinfo.getUserId() and Id in: pSet]);
    }

    static testMethod void beforeInsertUpdatePromotion_Coverage2() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        insert u1;

        User u2 = helper.createUser();
        u2.Username = 'info2@welders.com';
        u2.Email = 'info2@welders.com';
        u2.Alias = 'infw2';
        u2.CommunityNickname = 'infw98212';
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u2.ProfileID = p1[0].id;        
        insert u2;
                
        List<Promotion__c> pList = new List<Promotion__c>();
        Set<ID> pSet = new Set<ID>();
        Test.starttest(); 
            system.runas(u1)
            {             
                Market__c m = new Market__c();
                m.Name = 'Test Market'; 
                insert m;
                
                Account a = new Account();
                a.Market__c = m.Id;
                a.Name = 'Test Account';
                insert a;
                
                for(Integer x = 0; x<49; x++)
                {
                    Promotion__c p = new Promotion__c();
                    p.Account__c = a.id;
                    pList.add(p);
                }
                insert pList;
                for(Promotion__c p : pList)
                {
                    p.OwnerId = u2.id;
                    pSet.add(p.Id);
                }
                update pList;               
            }
        Test.stoptest(); 
      //  system.assertequals(0,[Select count() from Promotion__c where Brand_Manager__c=:userinfo.getUserId() and Id in: pSet]);     
    }


    //Assume that products and Brands are already setup.
    static testMethod void offlineOutletVisit_Coverage() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.UserPermissionsMobileUser = true;
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;        
        insert u1;

            Market__c m = new Market__c();
            m.On_Channel__c = '1';
            m.Name = 'Test Market'; 
            insert m;
            
            Supplier__c s = new Supplier__c();
            s.Name='BF';
            s.Is_B_F_Brand__c=true; 
            insert s;
            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;

            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;  
            
            Outlet_Class__c o = new Outlet_Class__c();
            o.Market__c = m.Id;
            o.Name = 'Outlet';
            insert o;
            
            Key_Task_Template__c k = new Key_Task_Template__c();
            k.Outlet_Class__c=o.id;
            k.Name='Test KT';
            k.Market__c=m.id;
            insert k;
            
            
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
            
            List<Product__c> pList = new List<Product__c>();
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                //p.Supplier__c = s.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b1.id;
                pList.add(p);
            }
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b.id;
                pList.add(p);
            }           
            insert pList;
            
        Account_Brand__c ab = new Account_Brand__c();
        Account a = new Account();  
        List<Depletion__c> dList = new List<Depletion__c>();
        Outlet_Visit__c ov;             
        system.runas(u1)
        {   
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            a.Outlet_Class__c = o.id;
            a.Channel__c = 'On';
            insert a;
            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'Info';
            c.LastName = 'Welders';
            insert c;
            
            //add logic to test Account_Brand
            ab.Account__c =a.id;
            ab.FY_Start__c = date.today().addMonths(-2);
            ab.FY_End__c = date.today().addMonths(10);
            ab.Brand__c = b.id;
            insert ab;
            
            Depletion__c d = new Depletion__c();
            d.Custom_Product__c = pList[0].Id;
            d.Month_Of_Date__c = date.today();
            d.Bottles__c = 123;
            d.Account__c = a.id;
            dList.add(d);
            
            d = new Depletion__c();
            d.Custom_Product__c = pList[0].Id;
            d.Month_Of_Date__c = date.today().addmonths(-1);
            d.Bottles__c = 123;
            d.Account__c = a.id;
            dList.add(d);

            d = new Depletion__c();
            d.Custom_Product__c = pList[0].Id;
            d.Month_Of_Date__c = date.today().addmonths(1);
            d.Bottles__c = 123;
            d.Account__c = a.id;
            dList.add(d);
            insert dList;
                   
            Outlet_Visit__c ovOld1 = new Outlet_Visit__c(Account__c = a.id,Visit_Date__c=date.today()-1,Status__c = 'Complete',Offline_Use__c = true);
            insert ovOld1;
            
            Outlet_Visit__c ovOld2 = new Outlet_Visit__c(Account__c = a.id,Visit_Date__c=date.today()-2,Status__c = 'Complete',Offline_Use__c = true);
            insert ovOld2;
                        
            ov = new Outlet_Visit__c(Account__c = a.id,Visit_Date__c=date.today(),Status__c = 'New',Offline_Use__c = true);
            insert ov;
            Offline_Outlet_Visit_Items__c ovi = new Offline_Outlet_Visit_Items__c(Outlet_Visit__c=ov.id);
            ovi.Product_ID__c = pList[0].Id;
            ovi.Drink_Price__c = 11;
            ovi.Depletions_Last_Month__c = 1;
            ovi.Depletions_This_Month__c = 2;
            ovi.Depletions_Next_Month__c = 3;
            insert ovi;
            ovi = new Offline_Outlet_Visit_Items__c(Outlet_Visit__c=ov.id);
            ovi.Product_ID__c = pList[1].Id;
            ovi.Drink_Price__c = 11;
            ovi.Depletions_Last_Month__c = 1;
            ovi.Depletions_This_Month__c = 2;
            ovi.Depletions_Next_Month__c = 3;
            insert ovi;         
            ov.Status__c = 'Complete';
            update ov;
    test.starttest();   
            update ovi;
    test.stoptest();                                
        }       

        system.assertequals(4,[Select count() from Outlet_Visit__c where Account__c =: a.id]);
        system.assertequals(2,[Select count() from Outlet_Visit_Item__c where Outlet_Visit__c =: ov.id]);
        system.assertequals(2,[Select Bottles__c from Depletion__c where Id =: dList[0].id].Bottles__c);
        
        //processDatedOOVIs coverage
        Outlet_Visit__c newOv = [Select ID from Outlet_Visit__c where Account__c =: a.id order by Visit_Date__c desc LIMIT 1];
        newOv.Status__c = 'New';
        newOv.Visit_Date__c = date.today().addmonths(-1);
        update newOv;
        offlineOutletVisit.processDatedOOVIs(); //runs asynchronously; didn't do assertions here; would need a new test

		Set<ID> setTest = new Set<ID>();
		setTest.add(newOv.Id);
        batchableProcessDatedOfflineOutletVisits batch2 = new batchableProcessDatedOfflineOutletVisits('',1,offlineOutletVisit.swapStringForCollection(setTest));
  
        batch2.query = 'Select Id from Account where Id = \'' + a.Id + '\'';        
    	Database.BatchableContext BC;
        Database.QueryLocator ql = batch2.start(BC);
        batch2.execute(BC, 
        		new Map<ID, Account>(
                 [Select p.Id From Account p where p.Id =: a.Id]).values());        
             
    }
 
  /*       
    //Assume that products and Brands are already setup.
    static testMethod void outletVisit_Controller_Coverage2() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;        
        //u1.UserPermissionsMobileUser=true; //to test OFFLINE OVIs    
        insert u1;

            Market__c m = new Market__c();
            m.Name = 'Test Market'; 
            insert m;
            
            Supplier__c s = new Supplier__c();
            s.Name='B-F';
            s.Is_B_F_Brand__c=true; 
            insert s;
            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;

            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;  
            
            Outlet_Class__c o = new Outlet_Class__c();
            o.Market__c = m.Id;
            o.Name = 'Outlet';
            insert o;
            
            Key_Task_Template__c k = new Key_Task_Template__c();
            k.Outlet_Class__c=o.id;
            k.Name='Test KT';
            k.Market__c=m.id;
            insert k;
                               
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
            
            List<Product__c> pList = new List<Product__c>();
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                //p.Supplier__c = s.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b1.id;         	 
                pList.add(p);
            }
            
            Product__c pI = new Product__c();
            pI.Name = 'myInvalidProduct';
            //p.Supplier__c = s.id;
            pI.IsActive__c=true;
            pI.RecordTypeId = r.Id;
            pI.ProductCode__c = 'myInvalidProduct';
            pI.Market__c = m.id; 
            pI.Competes_On_Brand__c = b.id; 
            pI.Brand__c = b1.id;         	 
            pList.add(pI);
                            
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b.id;
                pList.add(p);
            }           
            insert pList;
            

            
            
            Account_Brand__c ab = new Account_Brand__c();
        Account a = new Account();          
        system.runas(u1)
        {   
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            a.Outlet_Class__c = o.id;
            insert a;
            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'Info';
            c.LastName = 'Welders';
            insert c;
            
            //add logic to test Account_Brand
            ab.Account__c =a.id;
            ab.FY_Start__c = date.today().addMonths(-2);
            ab.FY_End__c = date.today().addMonths(10);
            ab.Brand__c = b.id;
            insert ab;
        
        	u1.UserPermissionsMobileUser=true; //to test OFFLINE OVIs    
        	update u1;            
            PageReference pageRef = new PageReference('/apex/outletVisit');
            Test.setCurrentPage(pageRef);
            sObject so = new Outlet_Visit__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(so);
            outletVisit_Controller constructor = new outletVisit_Controller(sc);        
            
            constructor.ov.Account__c = a.id;
            List<SelectOption> myContacts = constructor.getContacts();
            system.debug(myContacts);
            system.assert(myContacts.size()==1);
            
            constructor.ov.Met_With__c=myContacts[0].getValue();
            constructor.next();
            system.debug(Apexpages.getmessages());          
            system.assert(Apexpages.getmessages().size()==0);
            
            List<SelectOption> myTypeList = constructor.getspiritTypeList();
            List<SelectOption> myBrandsList = constructor.getBFBrandsList();
            List<SelectOption> myCompBrandsList = constructor.getCompBrandsList();
            
            List<outletVisit_Controller.wrapper> myBF = constructor.myBFOvi; 
            system.debug('MYBF: ' + myBF);
            myBF[0].ovi.Drink_Price__c = 1; 
            myBF[0].ovi.Bottle_Price__c = 10;
            myBF[0].dep1.Bottles__c = 100; 
            
            List<outletVisit_Controller.wrapper> myCompOvi = constructor.myCompOvi;
            system.debug(myCompOvi);
            myCompOvi[0].ovi.Drink_Price__c = 1; 
            myCompOvi[0].ovi.Bottle_Price__c = 10;
            myBF[0].dep1.Bottles__c = 100;              
            
            List<outletVisit_Controller.wrapperKT> myKTs = constructor.myKTs;
            myKTs[0].selected=true;
            myKTs[0].kt.Met_With__c = c.id;
                       
test.starttest();               
            constructor.saveCommit();
test.stoptest();                                      
        }       

//Now, verify that the processOVI (which is ran because of update to existing COmpleted OV) updates the OfflineRecords with pricing & depletion values.        
	for(Outlet_Visit__c lstOVs : [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, 
        	(Select Id, Name, Outlet_Visit__c, Bottle_Price_Special__c, Bottle_Price__c, Drink_Price_Special__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Product__c, Available__c, Facing__c, Shelf__c, Space_Placement__c, Double_Price__c, Double_Price_Special__c From Outlet_Visit_Items__r), 
        	(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_Last_Month_Date__c, Depletions_This_Month__c, Depletions_This_Month_Date__c, Depletions_Next_Month__c, Depletions_Next_Month_Date__c From Offline_Outlet_Visit_Items__r where Bottle_Price__c=10 or Bottle_Price__c=100), // where Bottle_Price__c=10 or Bottle_Price__c=100
 			(Select Id, Name, CurrencyIsoCode, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r)         	 
        	From Outlet_Visit__c o where o.Account__c =: a.Id and o.Status__c = 'New' order by Visit_Date__c]){
		//system.assertequals(1,lstOVs.size());
		system.assertequals(0,lstOVs.Outlet_Visit_Items__r.size());
		for(Offline_Outlet_Visit_Items__c y : lstOVs.Offline_Outlet_Visit_Items__r)
			system.debug(y);
		system.assertequals(2,lstOVs.Offline_Outlet_Visit_Items__r.size());		
		system.debug(lstOVs.Key_Tasks__r);        		
		system.assertequals(1,lstOVs.Key_Tasks__r.size());		
     }
               
    }
 *//*
     //Assume that products and Brands are already setup.
    static testMethod void afterUpdateUserCreateOfflineOV_Coverage() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;            
        insert u1;

            Market__c m = new Market__c();
            m.Name = 'Test Market'; 
            insert m;
            
            Supplier__c s = new Supplier__c();
            s.Name='BF';
            s.Is_B_F_Brand__c=true; 
            insert s;
            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;

            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;  
            
            Outlet_Class__c o = new Outlet_Class__c();
            o.Market__c = m.Id;
            o.Name = 'Outlet';
            insert o;
            
            Key_Task_Template__c k = new Key_Task_Template__c();
            k.Outlet_Class__c=o.id;
            k.Name='Test KT';
            k.Market__c=m.id;
            insert k;
            
            
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
            
            List<Product__c> pList = new List<Product__c>();
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                //p.Supplier__c = s.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b1.id;
                pList.add(p);
            }
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b.id;
                pList.add(p);
            }           
            insert pList;

        Account a = new Account();          
        system.runas(u1)
        {   
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            a.Outlet_Class__c = o.id;
            insert a;
        }    
        u1.UserPermissionsMobileUser=true; //have to set before we run the test because of salesforce bug.
        update u1;       
       test.starttest();
	        u1.Create_Offline_Outlet_Visit_Records__c=true; //to test OFFLINE OVIs    
	        update u1;
		test.stoptest();	

//Now, verify that the processDateOVIs (which is ran because of insert of Accoutn) pulls in KeyTasks and OfflineOVIs records.        
	Outlet_Visit__c[] lstOVs = [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, 
        	(Select Id, Name, Outlet_Visit__c, Bottle_Price_Special__c, Bottle_Price__c, Drink_Price_Special__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Custom_Product__c, Available__c, Facing__c, Shelf__c, Space_Placement__c, Double_Price__c, Double_Price_Special__c From Outlet_Visit_Items__r), 
        	(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_Last_Month_Date__c, Depletions_This_Month__c, Depletions_This_Month_Date__c, Depletions_Next_Month__c, Depletions_Next_Month_Date__c From Offline_Outlet_Visit_Items__r),
 			(Select Id, Name, CurrencyIsoCode, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r)         	 
        	From Outlet_Visit__c o where o.Account__c =: a.Id and o.Status__c = 'New' order by Visit_Date__c];
		system.assertequals(1,lstOVs.size());
	
		delete lstOVs;
		u1.Create_Offline_Outlet_Visit_Records__c=true; //to test OFFLINE OVIs    
	    update u1;
    }     
    
    static testMethod void outletVisit_Controller_Coverage() {
       INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;        
        //u1.UserPermissionsMobileUser=true; //to test OFFLINE OVIs    
        insert u1;

        Market__c m = new Market__c();
        m.Name = 'Test Market'; 
        insert m;
            
        Supplier__c s = new Supplier__c();
        s.Name='B-F';
        s.Is_B_F_Brand__c=true; 
        insert s;
            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;

            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;  
            
            Outlet_Class__c o = new Outlet_Class__c();
            o.Market__c = m.Id;
            o.Name = 'Outlet';
            insert o;
            
            Key_Task_Template__c k = new Key_Task_Template__c();
            k.Outlet_Class__c=o.id;
            k.Name='Test KT';
            k.Market__c=m.id;
            insert k;
                               
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
            
            List<Product__c> pList = new List<Product__c>();
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b.id;         	 
                pList.add(p);
            }
            
            Product__c pI = new Product__c();
            pI.Name = 'myInvalidProduct';
            //p.Supplier__c = s.id;
            pI.IsActive__c=true;
            pI.RecordTypeId = r.Id;
            pI.ProductCode__c = 'myInvalidProduct';
            pI.Market__c = m.id; 
            pI.Competes_On_Brand__c = b.id; 
            pI.Brand__c = b1.id;         	 
            pList.add(pI);
                            
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b1.id;
                pList.add(p);
            }           
            insert pList;
            
            Account_Brand__c ab = new Account_Brand__c();
	        Account a = new Account();          
	        system.runas(u1)
	        {   
	            a.Name = 'Test Account';
	            a.Market__c = m.Id;
	            a.Outlet_Class__c = o.id;
	            insert a;
	            
	            Contact c = new Contact();
	            c.AccountId = a.Id;
	            c.FirstName = 'Info';
	            c.LastName = 'Welders';
	            insert c;
	            
	            //add logic to test Account_Brand
	            ab.Account__c =a.id;
	            ab.FY_Start__c = date.today().addMonths(-2);
	            ab.FY_End__c = date.today().addMonths(10);
	            ab.Brand__c = b.id;
	            insert ab;
	        
	        	u1.UserPermissionsMobileUser=true; //to test OFFLINE OVIs    
	        	u1.UserPermissionsOfflineUser=true;
	        	update u1;         
	        	
			for(Integer x = 0; x<2; x++) {		        	   
	            PageReference pageRef = new PageReference('/apex/outletVisit');
	            Test.setCurrentPage(pageRef);
	            sObject so = new Outlet_Visit__c();
	            ApexPages.StandardController sc = new ApexPages.StandardController(so);
	            outletVisit_Controller constructor = new outletVisit_Controller(sc);        
	            
	            constructor.ov.Account__c = a.id;
	            List<SelectOption> myContacts = constructor.getContacts();
	            system.debug(myContacts);
	            system.assert(myContacts.size()==1);
	            
	            constructor.ov.Met_With__c=myContacts[0].getValue();
	            constructor.next();
	            system.debug(Apexpages.getmessages());          
	            system.assert(Apexpages.getmessages().size()==x);
	         	constructor.refresh();
	         	
	            List<SelectOption> myTypeList = constructor.getspiritTypeList();
	            List<SelectOption> myBrandsList = constructor.getBFBrandsList();
	            List<SelectOption> myCompBrandsList = constructor.getCompBrandsList();
	            
	            List<outletVisit_Controller.wrapper> myBF = constructor.myBFOvi; 
	            system.debug('MYBF: ' + myBF);
	            myBF[0].ovi.Drink_Price__c = 1; 
	            myBF[0].ovi.Bottle_Price__c = 10;
	            myBF[0].dep1.Bottles__c = 100; 
	            
	            List<outletVisit_Controller.wrapper> myCompOvi = constructor.myCompOvi;
	            system.debug(myCompOvi);
	            myCompOvi[0].ovi.Drink_Price__c = 1; 
	            myCompOvi[0].ovi.Bottle_Price__c = 10;
	            myBF[0].dep1.Bottles__c = 100;              
	            
	            List<outletVisit_Controller.wrapperKT> myKTs = constructor.myKTs;
	            myKTs[0].selected=true;
	            myKTs[0].kt.Met_With__c = c.id;
	                       
				if (x==0) {       
	            	constructor.saveCommit();
				} else {
					constructor.retURL='/' + a.id;
					constructor.saveCommitClose();
				}   
			}                                   
	     }       

		//Now, verify that the processOVI (which is ran because of update to existing COmpleted OV) updates the OfflineRecords with pricing & depletion values.        
			for(Outlet_Visit__c lstOVs : [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, 
		        	(Select Id, Name, Outlet_Visit__c, Bottle_Price_Special__c, Bottle_Price__c, Drink_Price_Special__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Custom_Product__c, Available__c, Facing__c, Shelf__c, Space_Placement__c, Double_Price__c, Double_Price_Special__c From Outlet_Visit_Items__r), 
		        	(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_Last_Month_Date__c, Depletions_This_Month__c, Depletions_This_Month_Date__c, Depletions_Next_Month__c, Depletions_Next_Month_Date__c From Offline_Outlet_Visit_Items__r where Bottle_Price__c=10 or Bottle_Price__c=100), // where Bottle_Price__c=10 or Bottle_Price__c=100
		 			(Select Id, Name, CurrencyIsoCode, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r)         	 
		        	From Outlet_Visit__c o where o.Account__c =: a.Id and o.Status__c = 'New' order by Visit_Date__c]){
				//system.assertequals(1,lstOVs.size());
				system.assertequals(0,lstOVs.Outlet_Visit_Items__r.size());
				for(Offline_Outlet_Visit_Items__c y : lstOVs.Offline_Outlet_Visit_Items__r)
					system.debug(y);
				//system.assertequals(2,lstOVs.Offline_Outlet_Visit_Items__r.size());				
				system.assertequals(0,lstOVs.Offline_Outlet_Visit_Items__r.size());		
				system.debug(lstOVs.Key_Tasks__r);        		
				//system.assertequals(1,lstOVs.Key_Tasks__r.size());		
				system.assertequals(0,lstOVs.Key_Tasks__r.size());				
		     }
   	}
   	
   	
 	static testMethod void deactive_trigger_Coverage() {
      	INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        u1.UserPermissionsMobileUser = true;
        u1.Sales_Manager__c=userinfo.getUserId();
        u1.Finance_Manager__c=userinfo.getUserId(); 
        u1.Brand_Manager__c=userinfo.getUserId();
        Profile []p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];        
        u1.ProfileID = p1[0].id;        
        insert u1;

            Market__c m = new Market__c();
            m.On_Channel__c = '1';
            m.Name = 'Test Market'; 
            insert m;
            
            Supplier__c s = new Supplier__c();
            s.Name='BF';
            s.Is_B_F_Brand__c=true; 
            insert s;
            
            Supplier__c s1 = new Supplier__c();
            s1.Name='myComp';
            s1.Is_B_F_Brand__c=false; 
            insert s1;
                        
            Brand__c b = new Brand__c();
            b.Supplier__c=s.id;
            b.Spirit_Type__c='Bourbon'; 
            b.Name='John Daniels';
            insert b;

            Brand__c b1 = new Brand__c();
            b1.Supplier__c=s1.id;
            b1.Spirit_Type__c='Bourbon'; 
            b1.Name='Bob Beam';
            insert b1;  
            
            Outlet_Class__c o = new Outlet_Class__c();
            o.Market__c = m.Id;
            o.Name = 'Outlet';
            insert o;
            
            Key_Task_Template__c k = new Key_Task_Template__c();
            k.Outlet_Class__c=o.id;
            k.Name='Test KT';
            k.Market__c=m.id;
            insert k;
            
            
            RecordType r = [Select r.Name, r.Id From RecordType r where  r.Name = 'Wet Goods' and SobjectType = 'Product__c'];
            
            List<Product__c> pList = new List<Product__c>();
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myProduct'+x;
                //p.Supplier__c = s.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b.id; 
                p.Brand__c = b1.id;
                pList.add(p);
            }
            for(Integer x = 0; x<10; x++)
            {
                Product__c p = new Product__c();
                p.Name = 'myCompProduct'+x;
                //p.Supplier__c = s1.id;
                p.IsActive__c=true;
                p.RecordTypeId = r.Id;
                p.ProductCode__c = 'myCompProduct'+x;
                p.Market__c = m.id; 
                p.Competes_On_Brand__c = b1.id; 
                p.Brand__c = b.id;
                pList.add(p);
            }           
            insert pList;
            
        Account_Brand__c ab = new Account_Brand__c();
        Account a = new Account();  
        List<Depletion__c> dList = new List<Depletion__c>();
        Outlet_Visit__c ov;             
        system.runas(u1)
        {   
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            a.Outlet_Class__c = o.id;
            a.Channel__c = 'On';
            insert a;
            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'Info';
            c.LastName = 'Welders';
            insert c;
            
            //add logic to test Account_Brand
            ab.Account__c =a.id;
            ab.FY_Start__c = date.today().addMonths(-2);
            ab.FY_End__c = date.today().addMonths(10);
            ab.Brand__c = b.id;
            insert ab;
            
            Depletion__c d = new Depletion__c();
            d.Custom_Product__c = pList[0].Id;
            d.Month_Of_Date__c = date.today();
            d.Bottles__c = 123;
            d.Account__c = a.id;
            dList.add(d);
            
            d = new Depletion__c();
            d.Custom_Product__c = pList[0].Id;
            d.Month_Of_Date__c = date.today().addmonths(-1);
            d.Bottles__c = 123;
            d.Account__c = a.id;
            dList.add(d);
            d = new Depletion__c();
            d.Custom_Product__c = pList[0].Id;
            d.Month_Of_Date__c = date.today().addmonths(1);
            d.Bottles__c = 123;
            d.Account__c = a.id;
            dList.add(d);
            insert dList;
 			Set<ID> myIDS = new Set<ID>();
 			for(Integer x = 0; x<dList.size(); x++)
 			{
 				myIDS.add(dList[x].Account__c);
 			}
 			try{
 				updateAccountBrandAsynch.updateAccountBrandAsynch(myIDS);
 			}catch(AsyncException e)
 			{
 				updateAccountBrandAsynch.updateAccountBrandSynch(myIDS);
 			}
            ov = new Outlet_Visit__c(Account__c = a.id,Visit_Date__c=date.today(),Status__c = 'New');
            insert ov;
            Offline_Outlet_Visit_Items__c ovi = new Offline_Outlet_Visit_Items__c(Outlet_Visit__c=ov.id);
            ovi.Product_ID__c = pList[0].Id;
            ovi.Drink_Price__c = 11;
            ovi.Depletions_Last_Month__c = 1;
            ovi.Depletions_This_Month__c = 2;
            ovi.Depletions_Next_Month__c = 3;
            insert ovi;
            ovi = new Offline_Outlet_Visit_Items__c(Outlet_Visit__c=ov.id);
            ovi.Product_ID__c = pList[1].Id;
            ovi.Drink_Price__c = 11;
            ovi.Depletions_Last_Month__c = 1;
            ovi.Depletions_This_Month__c = 2;
            ovi.Depletions_Next_Month__c = 3;
            insert ovi;         
            ov.Status__c = 'Complete';
            update ov;
		    test.starttest();   
            update ovi;
               if(INFW_Stateful.hasAlreadyCreated()){return;}
    			User u = [Select u.UserPermissionsOfflineUser, u.UserPermissionsMobileUser From User u where u.Id =: UserInfo.getuserId()];
    			Set<ID> myIds2 = new Set<ID>();
    			myIds2.add(ov.Id);
    			if(!myIds2.isempty() && (u.UserPermissionsOfflineUser || u.UserPermissionsMobileUser))
        			offlineOutletVisit.processOVI(myIds2,false,false);
    			test.stoptest();                                
        }       
        system.assertequals(2,[Select count() from Outlet_Visit__c where Account__c =: a.id]);
        system.assertequals(2,[Select count() from Outlet_Visit_Item__c where Outlet_Visit__c =: ov.id]);
        system.assertequals(2,[Select Bottles__c from Depletion__c where Id =: dList[0].id].Bottles__c);
        //processDatedOOVIs coverage
        Outlet_Visit__c newOv = [Select ID from Outlet_Visit__c where Account__c =: a.id order by Visit_Date__c desc LIMIT 1];
        newOv.Status__c = 'New';
        newOv.Visit_Date__c = date.today().addmonths(-1);
        update newOv;
        offlineOutletVisit.processDatedOOVIs(); //runs asynchronously; didn't do assertions here; would need a new test
		Set<ID> setTest = new Set<ID>();
		setTest.add(newOv.Id);
        batchableProcessDatedOfflineOutletVisits batch2 = new batchableProcessDatedOfflineOutletVisits('',1,offlineOutletVisit.swapStringForCollection(setTest));
        batch2.query = 'Select Id from Account where Id = \'' + a.Id + '\'';        
    	Database.BatchableContext BC;
        Database.QueryLocator ql = batch2.start(BC);
        batch2.execute(BC, 
        		new Map<ID, Account>(
                 [Select p.Id From Account p where p.Id =: a.Id]).values());        
 	}*/
}