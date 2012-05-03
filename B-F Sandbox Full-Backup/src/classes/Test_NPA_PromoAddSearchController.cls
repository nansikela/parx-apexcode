/******************************************************************************
Name			: Test_NPA_PromoAddSearchController
Description		: This is the test class for NPA_PromoAddSearchController

Modification Log:
-------------------------------------------------------------------------------
Developer			Date		Description
-------------------------------------------------------------------------------
Rohit Gupta (DC)	20-Jun-2011 Created
Achin Suman (DC)	16-Jul-2011	Updated to increase coverage
******************************************************************************/
@isTest 
private class Test_NPA_PromoAddSearchController{
    static testMethod void SearchControllerTest(){
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
            new Product__c(Name='Product1',ProductCode__c='123',RecordTypeId=productRecTypeId,Planned_Cost__c=10,Mark_for_Deletion__c = false,
                           Brand__c=brandList[0].Id,Sales_Org__c='1000'),
            new Product__c(Name='Product2',ProductCode__c='1234',RecordTypeId=productRecTypeId,Planned_Cost__c=10,Mark_for_Deletion__c = false,
                           Brand__c=brandList[0].Id,Sales_Org__c='1000'),
            new Product__c(Name='Product3',ProductCode__c='12345',RecordTypeId=productRecTypeId,Planned_Cost__c=10,Mark_for_Deletion__c = false,
                           Brand__c=brandList[0].Id,Sales_Org__c='1000'),
            new Product__c(Name='Product4',ProductCode__c='123456',RecordTypeId=productRecTypeId,Planned_Cost__c=10,Mark_for_Deletion__c = false,
                           Brand__c=brandList[0].Id,Sales_Org__c='1000')};
        insert productList;
        
        //Create Promotions
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
            Promotion_Premise__c='On Premise',Sales_Org__c='1000'),
            new Promotion__c(RecordTypeId=promotionRecTypeId,Promotion_Start_Date__c=dt,Brand_NPA__c=brandList[0].Id,
            Promotion_End_Date__c=dt,Freeze_Date__c=futureDt, Internal_Order__c=ioList[1].Id,Promotion_Status__c='Active',
            Promotion_Premise__c='On Premise',Sales_Org__c='1000')};
        insert promoList;
        
        //Create Promotion Material Items
        List<Promotion_Material_Item__c> pmiList = new List<Promotion_Material_Item__c>{
            new Promotion_Material_Item__c(Promotion__c=promoList[0].Id, Product_Custom__c=productList[0].Id,Status__c='0'),
            new Promotion_Material_Item__c(Promotion__c=promoList[0].Id, Product_Custom__c=productList[1].Id,Status__c='0'),
            new Promotion_Material_Item__c(Promotion__c=promoList[1].Id, Product_Custom__c=productList[0].Id,Status__c='0'),
            new Promotion_Material_Item__c(Promotion__c=promoList[1].Id, Product_Custom__c=productList[1].Id,Status__c='0')};
        insert pmiList;
        
        //Initialize page
        PageReference pageRefr = Page.NPA_PromoMaterialAddSearchPage;
        Test.setCurrentPage(pageRefr);
        //Set parameters
        ApexPages.currentPage().getParameters().put('id', promoList[0].id);
        ApexPages.currentPage().getParameters().put('SalesOrg', '1000');
        //Initialize controller
        NPA_PromoMaterialAddSearchController conExt = new NPA_PromoMaterialAddSearchController();            
		
		//Assign values to controller variables
        conExt.productNumber = '12345';
        conExt.desc_category = 'Product';
        conExt.prodId = productList[0].id;
        conExt.addedSet = new Set<String>();
        conExt.addedSet.add(productList[0].id);
        conExt.addedSet.add(productList[1].id);
        conExt.addedList = new List<NPA_PromoMaterialAddSearchController.ProductData>();
        conExt.addedList.add(new NPA_PromoMaterialAddSearchController.ProductData(productList[0]));
        conExt.addedList.add(new NPA_PromoMaterialAddSearchController.ProductData(productList[1]));
        conExt.availableList = new List<NPA_PromoMaterialAddSearchController.ProductData>();
        conExt.availableList.add(new NPA_PromoMaterialAddSearchController.ProductData(productList[2]));
        conExt.availableList.add(new NPA_PromoMaterialAddSearchController.ProductData(productList[3]));
        //Select the records in product wrapper
        conExt.availableList[0].isselected = true;
        conExt.availableList[1].isselected = true;
        
        //Call variable getter methods
        String nameStr = conExt.prodid;
        Boolean value =  conExt.limit_to_brand;
        Promotion__c prom = conExt.promotion;
        Set<String> strSet = conExt.addedSet;
        String scrName = conExt.screenname;
        String category = conExt.Id_Category;
        String category1 = conExt.desc_category;
        ApexPages.StandardSetController ssc = conExt.ssc;
        Integer num = conExt.availablelistsize ;
        Integer size = conExt.availablelistsize ;
        Boolean error = conExt.costError;
        Boolean stat = conExt.checkboxstatus;
        Integer listSz = conExt.listSize;
        NPA_PromoMaterialAddSearchController.Direct_Add da = new NPA_PromoMaterialAddSearchController.Direct_Add();
        NPA_PromoMaterialAddSearchController.ProductData pd = new NPA_PromoMaterialAddSearchController.ProductData (productList[0]);
        List < NPA_PromoMaterialAddSearchController.Direct_Add > dar = conExt.directaddrows ;
        
        // Call controller methods
        conExt.getdataGrid();
        conExt.search();
        conExt.hideavailablelist();
        conExt.showavailablelist();
        conExt.clear_directaddrows();
        
        //Call variable getter methods
        String tabl = conExt.tabLeft;
        Boolean listval = conExt.selectledlist_render;
        boolean listRender = conExt.availablelist_render;
        
        // Call controller methods
        conExt.cancel();
        conExt.deleteProduct();
        conExt.addProduct(conExt.prodId);
        conExt.delete_LineItems(conExt.prodId);
        conExt.add_specific_item();
        conExt.prodId = productList[2].id;
        conExt.deselectaddedlist();
        conExt.removeDuplicate(conExt.prodId);
        conExt.getListofProducts();
        conExt.clear();
        conExt.next();
        conExt.previous();
        conExt.setprev_next_true();
        
        //Delete products
        delete productList[3];
		
		//Instantiate controller again
        NPA_PromoMaterialAddSearchController conExt1 = new NPA_PromoMaterialAddSearchController(); 
        //Call controller methods
        conExt1.search();
        conExt1.getListofProducts();
        conExt1.add_specific_item();
        conExt1.getdataGrid();
        conExt.directaddrows = new List < NPA_PromoMaterialAddSearchController.Direct_Add >();
        conExt.directaddrows.add(new NPA_PromoMaterialAddSearchController.Direct_Add());
        conExt.directaddrows.add(new NPA_PromoMaterialAddSearchController.Direct_Add());
        conExt.directaddrows[0].Id_category = productList[0].ProductCode__c;
        conExt.directaddrows[0].desc_category = productList[0].Name;
        conExt.close();
        conExt.lastrecordadd();
        conExt.checkid();
    }
}