/******************************************************************************
Name            : Test_NPA_AllocationScreenController
Description     : This is the test class for NPA_AllocationScreenController

Modification Log:
-------------------------------------------------------------------------------
Developer           Date        Description
-------------------------------------------------------------------------------
Jishad P A (DC)     25-Jul-2011 Created
Jishad P A (DC)     16-Aug-2011 Updated the role being queried for.
******************************************************************************/
@isTest
private class Test_NPA_AllocationScreenController{
    static testMethod void NPA_AllocationScreenControllerTest(){
        // Ideally create users as given below
        Profile userProfile = [SELECT Id,Name FROM Profile Where Name like 'System Administrator' limit 1];
        UserRole role = [Select Name From UserRole Where Name = 'FDC - US - POS Manager' Limit 1];
        List<User> userListOne = new List<User>{
            new User(alias = 'test1', email='testuser1@b-f.com',
            emailencodingkey='UTF-8', lastname='Test1', Market__c='Alaska;China',
            languagelocalekey='en_US',localesidkey='en_US', 
            profileid = userProfile.Id,timezonesidkey='America/Los_Angeles',
            username='testuser1@b-f.com', UserRoleId=role.Id
            )};
        insert userListOne;
        
        // Execute as test user
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
            
            // Create B-F contacts
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
            
            // Create internal order
            List<Internal_Order__c> ioList = new List<Internal_Order__c>{
                new Internal_Order__c(Name='IO1',Description__c='IO1',Internal_Order_Number__c='IO1'),
                new Internal_Order__c(Name='IO2',Description__c='IO2',Internal_Order_Number__c='IO2')};
            insert ioList;
            
            // Create Products
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
            
            // Create Promotions
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
            
            // Create Allocations
            List<Allocations__c> allocList = new List<Allocations__c>();
            allocList.add(new Allocations__c(Ship_To__c=accountList[0].Id,Promotion__c=promoList[0].Id,
                promotion_material_item__c=pmiList[0].Id,Ship_To_Qty__c=10,Unique_Key__c=String.valueOf(pmiList[0].Id)+String.valueOf(accountList[0].Id)));
            allocList.add(new Allocations__c(Ship_To__c=accountList[1].Id,Promotion__c=promoList[0].Id,
                promotion_material_item__c=pmiList[1].Id,Ship_To_Qty__c=10,Unique_Key__c=String.valueOf(pmiList[1].Id)+String.valueOf(accountList[1].Id)));
            allocList.add(new Allocations__c(Ship_To__c=accountList[2].Id,Promotion__c=promoList[1].Id,
                promotion_material_item__c=pmiList[2].Id,Ship_To_Qty__c=10,Unique_Key__c=String.valueOf(pmiList[2].Id)+String.valueOf(accountList[2].Id)));
            allocList.add(new Allocations__c(Ship_To__c=accountList[3].Id,Promotion__c=promoList[1].Id,
                promotion_material_item__c=pmiList[3].Id,Ship_To_Qty__c=10,Unique_Key__c=String.valueOf(pmiList[3].Id)+String.valueOf(accountList[3].Id)));
            insert allocList;
            
            promoList = [Select Name,Has_Line_Items__c,Promotion_Premise__c,RecordTypeId,Brand_NPA__c,Freeze_Date__c,
                Fiscal_Year__c,Promotion_Status__c,Tertile__c,Promotion_End_Date__c,
                Internal_Order__r.Name,Promotion_Start_Date__c From Promotion__c WHERE Id in :promoList];
            
            Test.startTest();
            // Create allocation for the controller            
            Allocations__c conAlloc = new Allocations__c();
            PageReference pageRefOne = Page.NPA_AllocationScreen;
            Test.setCurrentPage(pageRefOne);
            // Initialize controller
            ApexPages.standardController stdController = new ApexPages.Standardcontroller(conAlloc);
            NPA_AllocationScreenController conExt = new NPA_AllocationScreenController(stdController);
            // Create promotion wrappers to cover lines
            List<NPA_PromotionWrapper.InnerWrapper> inner_wc = new List<NPA_PromotionWrapper.InnerWrapper>();
            inner_wc.add(new NPA_PromotionWrapper.InnerWrapper(pmiList[0],allocList));
            List<NPA_PromotionWrapper> promo_wrapper = new List<NPA_PromotionWrapper>();
            promo_wrapper.add(new NPA_PromotionWrapper(promoList[0],inner_wc));
            PageReference pageRefTwo = Page.NPA_AllocationWorkbook;
            Test.setCurrentPage(pageRefTwo);
            // Call the controller methods
            conExt.next();
            conExt.selectedMarket = 'Alaska';
            System.assertEquals(conExt.selectedMarket, 'Alaska');
            conExt.next();
            conExt.brandInfo();
            conExt.brandName = brandList[0].Id;
            conExt.tertile = promoList[0].Tertile__c;
            conExt.fiscalYear = promolist[0].Fiscal_Year__c;
            conExt.io = ioList[0].Internal_Order_Number__c;
            conExt.promoId = promolist[0].Id;
            conExt.TaskOne = new Task(ActivityDate=dt);
            conExt.TaskTwo = new Task(ActivityDate=futureDt);
            conExt.Premise = 'On Premise';
            conExt.selectedValues = new List<Id>{accountList[2].Id,accountList[0].Id};
            conExt.unSelectedValues = new List<Id>{accountList[3].Id,accountList[1].Id};
            conExt.doselect();
            conExt.selectedValues = new List<Id>{accountList[2].Id,accountList[0].Id};
            conExt.unSelectedValues = new List<Id>{accountList[3].Id,accountList[1].Id};
            conExt.dounselect();
            conExt.selectedValues = new List<Id>{accountList[2].Id,accountList[0].Id};
            conExt.unSelectedValues = new List<Id>{accountList[3].Id,accountList[1].Id};
            
            List<SelectOption> thisMarkets = conExt.markets;
            List<SelectOption> selOptions = conExt.selectedOptions;
            List<SelectOption> unselOptions = conExt.unselectedOptions;
            List<SelectOption> pList = conExt.premiseList;
            
            conExt.displayAll=false;
            conExt.showAllShiptos();
            conExt.displayAll=true;
            conExt.showAllShiptos();
            conExt.selectedMarket = 'China';
            conExt.getShiptos();
            conExt.selectedMarket = 'Alaska';
            conExt.getShiptos();
            conExt.next();
            conExt.brandInfo();
            conExt.getwrapper();
            conExt.getBrands();
            conExt.getAccounts();
            conExt.getDummyAccounts();
            conExt.getselectedbrand();
            conExt.setselectedbrand(conExt.brandName);
            conExt.getTertileValues();
            conExt.hideAllocations();
            conExt.getFiscalValues();
            conExt.saveAllocs();
            conExt.cancel();
            test.stopTest();
        }
    }
}