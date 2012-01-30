@isTest
private class Test_promotionMaterialItem_Controller {

      //Assume that products and Brands are already setup.
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
        for(Integer x = 0; x<10; x++) {
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
        for(Integer x = 0; x<10; x++)   {
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
        system.runas(u1)  {   
            
// Account Creation             
            a.Name = 'Test Account';
            a.Market__c = m.Id;
            insert a;
            
// Creating Contact            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.FirstName = 'Info';
            c.LastName = 'Welders';
            insert c;
           
            recordtype[] rtype = [Select Id From RecordType where Name = 'Sales Promotion' and SobjectType = 'Promotion__c'];
   
 // Creating Promotion           
            Promotion__c prom = new Promotion__c();
            prom.Name = 'test123';
            prom.Account__c = a.id;
            prom.RecordTypeid = rtype[0].id;
            insert prom;

            ApexPages.currentPage().getParameters().put('Id', prom.Id);     
            test.startTest();
                promotionMaterialItem_Controller constructor = new promotionMaterialItem_Controller();        
                constructor.myLimit = 100; 
    
                List<SelectOption> myRecordTypeList = constructor.getrecordTypeList();
                List<SelectOption> myBrandsList = constructor.getBFBrandsList();
                Promotion_Material_Item__c PMI = new Promotion_Material_Item__c(Promotion__c = prom.Id, Product_Custom__c = pList.get(0).Id);
                insert PMI;

                promotionMaterialItem_Controller.buildProdSelection2('Jack', 'ALL', 'ALL', null);
                list<promotionMaterialItem_Controller.wrapperRemote> NewProducts = new list<promotionMaterialItem_Controller.wrapperRemote>();
                promotionMaterialItem_Controller.wrapperRemote NewProduct = new promotionMaterialItem_Controller.wrapperRemote();
                NewProduct.productid = pList.get(0).Id;
                NewProduct.promoid = PMI.Id;
                NewProducts.add(NewProduct);
                promotionMaterialItem_Controller.AddNewProduct(NewProducts, 'Agreement', prom.Id);
                promotionMaterialItem_Controller.RemoveLine(PMI.Id);
            test.stopTest();
             
        }     
    }
}