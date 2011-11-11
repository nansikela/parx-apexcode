/******************************************************************************
Name			: Test_NPA_CustomPromotionClone
Description		: This is the test class for NPA_CustomPromotionClone

Modification Log:
-------------------------------------------------------------------------------
Developer			Date		Description
-------------------------------------------------------------------------------
Jishad P A (DC)		20-Jun-2011 Created
******************************************************************************/
@isTest 
private class Test_NPA_CustomPromotionClone{
	static testMethod void NPA_CustomPromotionCloneTest(){
		// Create internal order
		Internal_Order__c io =    new Internal_Order__c();
		io.Name              =    '1234567';
		io.Internal_Order_Number__c=    '1234567';
		io.Description__c              =    '1234567';
		io.CurrencyIsoCode   =    'USD';
		insert io;
		
		//Create brand
		Brand__c b           =    new Brand__c();
		b.Name               =    'Jack Daniels';
		insert b;
		
		//Create product
		Product__c prod              =    new Product__c();
		prod.Name                    =    'Test Product';
		prod.Product__c              =    '123';
		prod.Planned_Cost__c         =    500;
		prod.Brand__c                =    b.Id;
		prod.Status__c               =    'Active';
		insert prod;
		
		//Create promotion
		Promotion__c p       =    new Promotion__c();
		p.Internal_Order__c  =    io.Id;
		p.Name               =    'Test Promotion';
		p.Promotion_Start_Date__c    =    Date.Today();
		p.Promotion_End_Date__c      =    Date.Today() + 5;
		p.Freeze_Date__c             =    Date.Today() + 7;
		p.CurrencyIsoCode            =    'USD';
		p.Promotion_Status__c        =    'Created';
		p.Brand_NPA__c               =    b.Id;
		p.Promotion_Premise__c       =    'Military';
		p.GTM_Channel_Description__c =    'On-Fine';
		insert p;
		
		//Create Promotion Material Item
		Promotion_Material_Item__c pmi    =    new Promotion_Material_Item__c();
		pmi.Product_Custom__c             =    prod.Id;
		pmi.Promotion__c                  =    p.Id;
		pmi.Planned_Cost__c               =    500;
		pmi.Quantity__c                   =    2;
		pmi.Status__c                     =    'Active';
		pmi.Product_Description__c        =    'This is a test product';
		pmi.Unit_of_Measure__c            =    'EA';
		insert pmi;
		
		//Initialize the page
		ApexPages.StandardController controller1 = new ApexPages.StandardController(p);
		ApexPages.currentPage().getParameters().put('id', p.id);
		NPA_CustomPromotionClone cpc1 = new NPA_CustomPromotionClone(controller1);
		PageReference pageRefOne = Page.NPA_PromoMaterialAddSearchPage;
		Test.setCurrentPage(pageRefOne);
		
		//Call controller methods
		PageReference pr    =    cpc1.custom_clone();
		PageReference pr1   =    cpc1.cancel();
		
		//Initialize page again
		ApexPages.StandardController controller2 = new ApexPages.StandardController(p);
		ApexPages.currentPage().getParameters().put('id', p.id);
		NPA_CustomPromotionClone cpc2 = new NPA_CustomPromotionClone(controller2);
		PageReference pageRefTwo = Page.NPA_PromoMaterialAddSearchPage;
		Test.setCurrentPage(pageRefTwo);
		// Call controller method
		PageReference pr2    =    cpc1.custom_clone();
	}
}