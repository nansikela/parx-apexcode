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
private class Application_beforeInsertBeforeUpdateTEST {

    static testMethod void myUnitTest() {
    	
    	String PRODUCT_RT 	= '012200000004y0dAAA'; //Product RT
    	String OPP_RT 		= '012200000004nPAAAY'; // Record type of Opp
    	String OPP_STAGE 	= 'In Progress';
    	String PRODUCT_TYPE = 'Diploma Programs';
    	String LANGUAGE 	= 'E';
    	STRING PB_ID		= '01s200000001DbQAAU'; // Pricebook ID
        
        
	    // Create account
	    Account myAccount 	= new Account();
	    myAccount.name 		= 'ACME';
	    insert myAccount;
	    
	    
	    // Create contact
	    Contact myContact 	= new Contact();
	    myContact.FirstName 	= 'Peter';
	    myContact.LastName	= 'Müller';
	    insert myContact;
        
        
        // create opportunity
		Opportunity testOpportunity = new Opportunity();
		testOpportunity.Name = 'testopportunity A';
		testOpportunity.RecordTypeId = OPP_RT;
		testOpportunity.Contact_Student__c = myContact.Id; 
		testOpportunity.AccountId = myAccount.Id;
		testOpportunity.StageName = OPP_STAGE;
		testOpportunity.CloseDate = Date.newInstance(2010, 1, 30);
		testOpportunity.CurrencyIsoCode = 'USD';
        insert testOpportunity;
        
        
        // create product, set start/end date and language
		Product2 testProduct = new Product2();
		testProduct.Name = 'xmas seminar';
		testProduct.RecordTypeId = PRODUCT_RT;
		testProduct.Start_Date__c = Date.newInstance(2009,12,24);
		testProduct.End_Date__c = Date.newInstance(2009,12,25);
		testProduct.Product_Language__c = LANGUAGE;
		testProduct.CurrencyIsoCode = 'USD';
		insert testProduct;  
        
        
        // create pricebookentry
        PricebookEntry myPricebookEntry = new PricebookEntry();
        myPricebookEntry.Product2Id = testProduct.id;
        myPricebookEntry.Pricebook2Id = PB_ID;
        myPricebookEntry.UnitPrice = 100;
        myPricebookEntry.UseStandardPrice = false;
        myPricebookEntry.CurrencyIsoCode = 'USD';
        myPricebookEntry.IsActive = true; 
        insert myPricebookEntry;
        
        
        // add opportunitylineitem
        OpportunityLineItem opplineitem = new OpportunityLineItem();
        opplineitem.PricebookEntryId = myPricebookEntry.id;
        opplineitem.OpportunityId = testOpportunity.id;
		insert opplineitem;
		
		
        // create application
	    Application__c myApplication 	= new Application__c();
	    insert myApplication;
	    
	    system.assert(myApplication.Product_Start_Date__c == null);
        system.assert(myApplication.Product_End_Date__c == null);
        system.assert(myApplication.Product_Language__c == null);
        
        // update application and check if product data was correctly copied
        myApplication.Predicted_GPA__c = 'abc';
        myApplication.Opportunity__c 	= testOpportunity.id;
        update myApplication;
        
        List<Application__c> appList = [Select Product_Start_Date__c, Product_Language__c, Product_End_Date__c From Application__c WHERE id=:myApplication.Id ];
        Application__c currentApp = appList.get(0);
        
        system.assert(currentApp.Product_Language__c == LANGUAGE);
        system.assert(currentApp.Product_Start_Date__c == Date.newInstance(2009,12,24));
        system.assert(currentApp.Product_End_Date__c == Date.newInstance(2009,12,25));
        
    }
}