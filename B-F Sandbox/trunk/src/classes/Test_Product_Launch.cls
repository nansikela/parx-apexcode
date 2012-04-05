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
private class Test_Product_Launch {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        //Getting Profile Details
 Profile testProfile = [select id from profile where name='Standard User']; 
 
 

 
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
        


//Create an Account

Account testAccount = new Account (name = 'myBar');

insert testAccount;


Product_Launch__c testProductLaunch = new Product_Launch__c (comments__c = 'test', Account__c = testAccount.id);

insert testProductLaunch; 

Product_Launch_detail__c testProductLaunchDetail = [SELECT Id, Counter__c, week__c,Survey_Date__c FROM Product_Launch_Detail__c where Product_Launch__c =:testProductLaunch.id];

system.debug(testProductLaunchDetail);

update testProductLaunchDetail;

Product_Launch_detail__c testProductLaunchDetail2 = new Product_Launch_detail__c(Product_Launch__c = testProductLaunch.id );

insert testProductLaunchDetail2;

delete testProductLaunchDetail;


        
    }
}