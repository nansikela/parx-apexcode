/*********************************************************************************************************
    Name    : test_CodeCoverage
    Desc    : This is a test class for following classes :
    			1)artPDF_controller
				2)createScheduledApexJobsController
				3)mobileOutletVisit_Controller
				4)promotionHelperClass
				5)updateStockPriceData 
				6)callYahooFinance 
				7)INFW_Stateful 
				8)processDatedOfflineOutletVisits 
    			
    Modification Log :  
--------------------------------------------------------------------------------------------------------
 Developer                                 Date             Description
--------------------------------------------------------------------------------------------------------
Fayas Mansoor(Deloitte Consulting)       30/05/2011          Created  

*********************************************************************************************************/
@isTest
private class test_CodeCoverage {
	
	//Test method for class artPDF_controller
	static testmethod void artPDF_controller_Coverage()
	{
		PageReference pageRef = Page.artPDF;
        Test.setCurrentPage(pageRef);
        Art_Asset__c art_asset=new Art_Asset__c();
        List<Art_Asset__c> artlist= new List<Art_Asset__c>();
        artlist.add(art_asset);
        Database.insert(artlist);
        Attachment att=new Attachment();
        att.ParentId=artlist.get(0).id;
        att.Name='testClass attachment';
        att.Body=Blob.valueof('asdas');
        list<Attachment> attlist= new list<Attachment>();
        attlist.add(att);
        Database.insert(attlist);
        test.startTest();
        ApexPages.standardController stdController = new ApexPages.Standardcontroller(art_asset);
        artPDF_controller obj=new artPDF_controller(stdController);
        test.stopTest();
        
	}
	
	//Test method for class createScheduledApexJobsController 
	static testmethod void createScheduledApexJobsController_Coverage()
	{
		Offline_Outlet_Visit_CRON_Settings__c cust=new Offline_Outlet_Visit_CRON_Settings__c();
		cust.Job_ID__c='testclass';
		Database.insert(new List<Offline_Outlet_Visit_CRON_Settings__c> {cust});
		createScheduledApexJobsController obj =new createScheduledApexJobsController();
		test.startTest();
		obj.startScheduledJobs();
		obj.stopScheduledJobs();
		test.stopTest();
	}
	
	//Test method for class mobileOutletVisit_Controller
	static testmethod void mobileOutletVisit_Controller_Coverage()
	{
		test.startTest();
		mobileOutletVisit_Controller obj=new mobileOutletVisit_Controller();
		List<Outlet_Visit__c> outletlist=obj.getRecentOVs();
		test.stopTest();
	}
	
	//Test method for class promotionHelperClass
	static testmethod void promotionHelperClass_Coverage()
	{
		promotionHelperClass obj=new promotionHelperClass();
		List<Promotion__c> promlist= new List<Promotion__c>();
		Promotion__c prom=new Promotion__c();
		prom.Name='Testclass Promo1';
		promlist.add(prom);
		Database.insert(promlist);
		List<Id> ids=new List<id>();
		for(Promotion__c p:promlist)
		{
			ids.add(p.id);
		}
		Set<id> setids=new Set<id>();
		for(Id i:ids)
		{
			setids.add(i);
		}
		test.startTest();
		promotionHelperClass.setPromotionUserLookups(ids);
		promotionHelperClass.calculateAccountBrandTotals(setids);
		test.stopTest();
	}
	
	//Test method for class promotionMaterialItemRedirect_Controller
/*	static testmethod void promotionMaterialItemRedirect_Controller_Coverage() 
	 {
	 	Promotion_Material_Item__c p=new Promotion_Material_Item__c();
	 	ApexPages.StandardController controller=new ApexPages.StandardController(p);
	 	test.startTest();
	 	promotionMaterialItemRedirect_Controller obj=new promotionMaterialItemRedirect_Controller(controller);
	 	obj.Redirect();
	 	test.stopTest();
	 	
	 }*/
	 
	 //Test method for class updateStockPriceData
	 static testmethod void updateStockPriceData_Coverage() 
	 {
	 	updateStockPriceData obj =new updateStockPriceData();
	 	SchedulableContext sch;
	 	test.startTest();
	 	obj.execute(sch);
	 	test.stopTest();
	 }
	 
	 //Test method for class INFW_Stateful
	 static testmethod void INFW_Stateful_Coverage() 
	 {
	 	test.startTest();
	 	INFW_Stateful.hasAlreadyCreated();
	 	INFW_Stateful.setAlreadyCreated();
	 	INFW_Stateful.cancelAlreadyCreated();
	 	test.stopTest();
	 }
	 
	 
	 static testmethod void callYahooFinance_Coverage() 
	 {
		 	//callYahooFinance obj=new callYahooFinance();
		List<Account> accList=new List<Account>();
		Account acc=new Account();
		RecordType rec=[select id from RecordType where name='PLFC Accounts' and SobjectType='Account' Limit 1].get(0);
		acc.Name='testClass Account1';
		acc.RecordTypeId=rec.Id;
		acc.TickerSymbol='e';
		accList.add(acc);
		acc=new Account();
		acc.Name='testClass Account2';
		acc.RecordTypeId=rec.Id;
		acc.TickerSymbol='l1';
		accList.add(acc);
		Database.insert(accList);
		test.startTest();
		callYahooFinance.getQuotes();
		
		
		test.stopTest();
	 }
	 
}