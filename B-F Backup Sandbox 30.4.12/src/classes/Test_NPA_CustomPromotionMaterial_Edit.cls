/******************************************************************************
Name			: Test_NPA_CustomPromotionMaterial_Edit
Description		: This is the test class for NPA_CustomPromotionMaterial_Edit

Modification Log:
-------------------------------------------------------------------------------
Developer			Date		Description
-------------------------------------------------------------------------------
Jishad P A (DC)	20-Jun-2011 Created
******************************************************************************/
@istest
private class Test_NPA_CustomPromotionMaterial_Edit{
    static testMethod void test(){
    	//Create test users
        Profile userProfile = [SELECT Id,Name FROM Profile Where Name like 'System Administrator' limit 1];
        UserRole role = [Select Name From UserRole Where Name = 'Global Administrator' Limit 1];
        List<User> userListOne = new List<User>{
        	new User(alias = 'test1', email='testuser1@b-f.com',
	            emailencodingkey='UTF-8', lastname='Test1', Market__c='Alaska;China',
	            languagelocalekey='en_US',localesidkey='en_US', 
	            profileid = userProfile.Id,timezonesidkey='America/Los_Angeles',
	            username='testuser1@b-f.com', UserRoleId=role.Id
            )};
        insert userListOne;

        System.runAs(userListOne[0]){
            // Create markets
            List<Market__c> marketList = new List<Market__c>{
                new Market__c(Name='Alaska'),new Market__c(Name='Alabama'),
                new Market__c(Name='Illinois'),new Market__c(Name='Kentucky')};
            insert marketList;
    
            // Create accounts
            Map<String,Schema.RecordTypeInfo> shiptoRTMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
            Id shiptoRecType=null;
            if(shiptoRTMapByName.containsKey('POS Ship-To')){
                shiptoRecType = shiptoRTMapByName.get('POS Ship-To').getRecordTypeId();
            }
            
            List<ID> accIdList = new List<ID>();
            List<Account> accountList = new List<Account>{
                new Account(Name='Account1', Market__c=marketList[0].Id, RecordTypeId=shiptoRecType,
                    PAS_Relevant__c='Yes',Legacy_Id__c='ww1',ShippingStreet='street',ShippingCity='city',ShippingState='state'),
                new Account(Name='Account2', Market__c=marketList[0].Id, RecordTypeId=shiptoRecType,
                    PAS_Relevant__c='Yes',Legacy_Id__c='xx1',ShippingStreet='street',ShippingCity='city',ShippingState='state'),
                new Account(Name='Account2', Market__c=marketList[0].Id, RecordTypeId=shiptoRecType,
                    PAS_Relevant__c='Yes',Legacy_Id__c='yy1',ShippingStreet='street',ShippingCity='city',ShippingState='state'),
                new Account(Name='Account4', Market__c=marketList[0].Id, RecordTypeId=shiptoRecType,
                    PAS_Relevant__c='Yes',Legacy_Id__c='zz1',ShippingStreet='street',ShippingCity='city',ShippingState='state')};
            insert accountList;
            for(account acc : accountList){
                accIdList.add(acc.Id);
            }
            
            //Create B-F Contacts
            List<B_F_Contact__c> contactList = new List<B_F_Contact__c>{
                new B_F_Contact__c(Account__c=accountList[0].Id, User__c=userListOne[0].Id),
                new B_F_Contact__c(Account__c=accountList[1].Id, User__c=userListOne[0].Id),
                new B_F_Contact__c(Account__c=accountList[2].Id, User__c=userListOne[0].Id),
                new B_F_Contact__c(Account__c=accountList[3].Id, User__c=userListOne[0].Id)};
            insert contactList;
            
            //Create Supplier
            Supplier__c supp = new Supplier__c(Name='B-F');
            insert supp;
            
            // Create brands
            List<Brand__c> brandList = new List<Brand__c>{
                new Brand__c(Name='Brand1',Supplier__c=supp.Id),new Brand__c(Name='Brand2',Supplier__c=supp.Id)};
            insert brandList;
            
            //Create internal orders
            List<Internal_Order__c> ioList = new List<Internal_Order__c>{
                new Internal_Order__c(Name='IO1',Description__c='IO1',Internal_Order_Number__c='IO1'),
                new Internal_Order__c(Name='IO2',Description__c='IO2',Internal_Order_Number__c='IO2')};
            insert ioList;
            
            //Create products
            Id productRecTypeId=null;
            Map<String,Schema.RecordTypeInfo> productRTMapByName = Schema.SObjectType.Product__c.getRecordTypeInfosByName();
            if(productRTMapByName.containsKey('POS - US')){
                productRecTypeId = productRTMapByName.get('POS - US').getRecordTypeId();
            }
            List<Product__c> productList = new List<Product__c>{
                new Product__c(Name='Product1',RecordTypeId=productRecTypeId,Planned_Cost__c=10),
                new Product__c(Name='Product2',RecordTypeId=productRecTypeId,Planned_Cost__c=10),
                new Product__c(Name='Product3',RecordTypeId=productRecTypeId,Planned_Cost__c=10),
                new Product__c(Name='Product4',RecordTypeId=productRecTypeId,Planned_Cost__c=10)};
            insert productList;
            
            //Create promotions
            Id promotionRecTypeId=null;
            Map<String,Schema.RecordTypeInfo> promoRTMapByName = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
            if(promoRTMapByName.containsKey('National Promotion - US')){
                promotionRecTypeId = promoRTMapByName.get('National Promotion - US').getRecordTypeId();
            }
            Date dt = system.today()+1;
            Date futureDt = system.today()+1;
            
            List<Promotion__c> promoList = new List<Promotion__c>{
                new Promotion__c(RecordTypeId=promotionRecTypeId,Promotion_Start_Date__c=dt,Brand_NPA__c=brandList[0].Id,
                Promotion_End_Date__c=dt,Freeze_Date__c=futureDt, Internal_Order__c=ioList[0].Id,Promotion_Status__c='Active',
                Promotion_Premise__c='On Premise'),
                new Promotion__c(RecordTypeId=promotionRecTypeId,Promotion_Start_Date__c=dt,Brand_NPA__c=brandList[0].Id,
                Promotion_End_Date__c=dt,Freeze_Date__c=futureDt, Internal_Order__c=ioList[1].Id,Promotion_Status__c='Active',
                Promotion_Premise__c='On Premise')};
            insert promoList;
    
            List<Promotion__c> dummyPromos = promoList;
            promolist = new List<Promotion__c>();
            
            // Get the promotions from database with formula fields
            promoList = [Select RecordTypeId,Tertile__c,Promotion_End_Date__c,Freeze_Date__c,Promotion_Start_Date__c,Fiscal_Year__c,
                                Internal_Order__r.Internal_Order_number__c,Promotion_Status__c,Brand_NPA__c,Has_Line_Items__c 
                                from promotion__c where Id in :dummyPromos];
            for(Promotion__c promo : promolist){
                promo.Promotion_Status__c = 'Active';
            }
            update promolist;
            
            // Create Promotion Material Items
            List<Promotion_Material_Item__c> pmiList = new List<Promotion_Material_Item__c>{
                new Promotion_Material_Item__c(Promotion__c=promoList[0].Id, Product_Custom__c=productList[0].Id,Status__c='0'),
                new Promotion_Material_Item__c(Promotion__c=promoList[0].Id, Product_Custom__c=productList[1].Id,Status__c='0'),
                new Promotion_Material_Item__c(Promotion__c=promoList[1].Id, Product_Custom__c=productList[0].Id,Status__c='0'),
                new Promotion_Material_Item__c(Promotion__c=promoList[1].Id, Product_Custom__c=productList[1].Id,Status__c='0')};
            insert pmiList;
    		
    		Test.startTest();
		    //Initialize the page
		    PageReference pageRefOne = Page.NPA_promotionMaterialCustomEdit;
		    Test.setCurrentPage(pageRefOne);
		    ApexPages.currentPage().getParameters().put('promotion', promolist[0].id);
		    Promotion_Material_Item__c pmi = new Promotion_Material_Item__c();
		    ApexPages.standardController stdController = new ApexPages.Standardcontroller(pmi);
		    NPA_CustomPromotionMaterial_Edit conExt = new NPA_CustomPromotionMaterial_Edit(stdController);
		    //Call controller methods
		    conExt.save();
		    conExt.cancel();
		    
		    Test.stopTest();
        }
    }
}