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
private class Test_AccountFactsheet {

    static testMethod void myUnitTest() {
    	Account Acc = new Account(Name = 'test');
    	insert Acc;
    	
    	Account Acc1 = new Account(Name = 'test1', Channel__c = 'on');
    	insert Acc1;
    	
    	Account Acc2 = new Account(Name = 'test2', Channel__c = 'off');
    	insert Acc2;
    	
        ApexPages.currentPage().getParameters().put('AccountId', acc.Id);
        Promotion_Activity__c pa = new Promotion_Activity__c(Name = 'x Secondary Placement x', Active__c = true);
        insert pa;
        
        Promotion__c promo = new Promotion__c (Account__c = acc.Id, Promotion_Activity__c = pa.ID);
        insert promo;
        
        Brand__c b = new Brand__c(Name = 'JDB');
        insert b;
        
        Product__c cp = new Product__c(Name = 'JD',Brand__c =  b.ID);
        insert cp;
        
        Mandatory_Products__c mp = new Mandatory_Products__c(Account__c = Acc.ID, Custom_Product__c = cp.ID); 
       	insert mp;
       	
       	Product__c cp1 = new Product__c(Name = 'JD',Brand__c =  b.ID);
        insert cp1;
        
        Mandatory_Products__c mp1 = new Mandatory_Products__c(Account__c = Acc.ID, Custom_Product__c = cp1.ID); 
       	insert mp1;
       	
       	Account_Product__c ap = new Account_Product__c(Account__c = Acc.ID ,Product__c=cp.ID);
       	insert ap;
       	
       	Account_Product__c ap1 = new Account_Product__c(Account__c = Acc.ID, Product__c=cp1.ID);
       	insert ap1;
       	
        AccountFactsheet af = new AccountFactsheet ();
        
        ApexPages.currentPage().getParameters().put('AccountId', acc1.Id);
        af = new AccountFactsheet ();
        
        ApexPages.currentPage().getParameters().put('AccountId', acc2.Id);
        af = new AccountFactsheet ();
    }
}