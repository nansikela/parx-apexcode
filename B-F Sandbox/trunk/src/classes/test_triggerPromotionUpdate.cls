@isTest
private class test_triggerPromotionUpdate {

    static testMethod void myUnitTest() {
        
//Getting Profile Details
 Profile testProfile = [select id from profile where name='CHN-Sales Rep']; 
 UserRole testRole = [select id from UserRole where name='CHN-Brand Manager'];
 
 //Getting Market Details
 market__c testMarket = [select id from market__c where name='China'];
 
 //Outlet Class Details (A & China)
Outlet_Class__c testOutletClass = [select id from Outlet_Class__c where name='A' and market__c=:testMarket.Id];
 
//RecordType for (Promotion)
RecordType promoRtype = [Select Id From RecordType where Sobjecttype = 'promotion__c' and name = 'Sales Promotion'];

//RecordType for (Product)
RecordType productRtype = [Select Id From RecordType where Sobjecttype = 'product__c' and name = 'Wet Goods'];  

//RecordType for (Promotion Goals)
RecordType promo_goalRtype = [Select Id From RecordType where Sobjecttype = 'promotion_goal__c' and name = 'Sales Promotion']; 

//Product (JD 750ml)
//Product__c testProduct = [Select Id From Product__c where name = 'JD 750ml' and market__c = :testMarket.id]; 
 
 
 //Creating a Test User
 User testUser = new User(alias = 'myTest', email='myTest@b-f.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = testProfile.id, userroleid = testRole.id,
            timezonesidkey='America/Los_Angeles', username='myTest@b-f.com@b-f.com',market__c = 'China');
 
//Run as        
 System.runAs(testUser) {
           // The following code runs as user 'testUser' 
           System.debug('Current User: ' + UserInfo.getUserName());
           System.debug('Current Profile: ' + UserInfo.getProfileId()); 
           // Run some code that checks record sharing
        
//Create a Test Product        
Product__c testProduct = new Product__c(name='JD 750ml',RecordTypeID=productRtype.Id, market__c=testMarket.id,IsActive__c=true);
     insert testProduct;
        
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
                                                        promotion__c =testPromo.Id,Custom_Product__c=testProduct.id );    
                                                        
      insert testPromoGoal;                                                                                 
 }
    }
}