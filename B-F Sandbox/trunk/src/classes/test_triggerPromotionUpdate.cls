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
private class test_triggerPromotionUpdate {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
//Getting Profile Details
 Profile testProfile = [select id from profile where name='CHN-Sales Rep']; 
 
 //Getting Market Details
 market__c testMarket = [select id from market__c where name='China'];
 
 //Outlet Class Details (A & China)
Outlet_Class__c testOutletClass = [select id from Outlet_Class__c where name='A' and market__c=:testMarket.Id];
 
//RecordType for (Promotion)
RecordType promoRtype = [Select Id From RecordType where Sobjecttype = 'promotion__c' and name = 'Sales Promotion']; 

//RecordType for (Promotion Goals)
RecordType promo_goalRtype = [Select Id From RecordType where Sobjecttype = 'promotion_goal__c' and name = 'Sales Promotion']; 

//Product (JD 750ml)
Product2 testProduct = [Select Id From Product2 where name = 'JD 750ml']; 
 
 
 //Creating a Test User
 User testUser = new User(alias = 'myTest', email='myTest@b-f.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = testProfile.id, 
            timezonesidkey='America/Los_Angeles', username='myTest@b-f.com@b-f.com',market__c = 'China');
 
//Run as        
 System.runAs(testUser) {
           // The following code runs as user 'testUser' 
           System.debug('Current User: ' + UserInfo.getUserName());
           System.debug('Current Profile: ' + UserInfo.getProfileId()); }
           // Run some code that checks record sharing
        
        
        
//Creating a Test Account       
Account testAccount = new Account(name='testPromo',market__c=testMarket.id,Outlet_Class__c=testOutletClass.Id);
     insert testAccount;
     
     string s_AccountId = testAccount.id;     

//Creating a Promotion for the new Account
promotion__c testPromo = new Promotion__c(account__c=s_AccountId,RecordTypeId=promoRtype.Id,
                                          Promotion_Goal_Lock__c=true,name='testPromo',
                                          Approval_Status__c='Approved');
     insert testPromo;      
     
     
//Creating the Promotion Goals for the Promotion
promotion_goal__c testPromoGoal = new promotion_goal__c(Plan_Bottle_Quantity__c=1,RecordTypeId=promo_goalRtype.id,
                                                        promotion__c =testPromo.Id,Product__c=testProduct.id );    
                                                        
      insert testPromoGoal;                                                                                 
        
    }
}