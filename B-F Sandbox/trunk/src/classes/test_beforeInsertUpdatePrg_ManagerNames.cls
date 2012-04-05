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
//Test class for beforeInsertUpdatePrg_ManagerNames Trigger
private class test_beforeInsertUpdatePrg_ManagerNames {

    static testMethod void myUnitTest() {
        
        //Getting Profile Details
        Profile testProfile = [select id from profile where name='Default One App']; 

        //Creating a Test User
        User testUser = new User(alias = 'myTest', email='myTest@b-f.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = testProfile.id, 
        timezonesidkey='America/Los_Angeles', username='myTest@b-f.com@b-f.com');
        
        List<User> users = [SELECT Id FROM User WHERE IsActive = true AND profileid =:testProfile.id LIMIT 2];
        Id User1Id = users[0].Id;
        Id User2Id = users[1].Id;
 
        //Run as        
        System.runAs(testUser) {
        // The following code runs as user 'testUser' 
        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current Profile: ' + UserInfo.getProfileId()); }
        // Run some code that checks record sharing

        //creating a test Degree Declaration
        Degree_Declaration__c testDegreeDeclaration = new Degree_Declaration__c(
        School_To_Be_Attended__c = 'Splading University', 
        School_Address__c = 'Louisville, KY',
        Name = 'MBA',
        Major__c = 'Business Administration',
        Start_date__c = Date.parse('10/04/2011'),
        Approximate_Completion_Date__c = Date.parse('06/30/2013'),
        Number_of_Credit_Hours_Required__c = double.valueOf('48'),
        Current_Cost_per_Credit_Hour__c = double.valueOf('500'),
        Degree_Type__c = 'Graduate',
        HR_Manager__c = user2Id,
        Manager__c = user1Id,
        Reason_You_Wish_To_Pursue_This_Degree__c = 'Career Advancement',
        I_Have_Read_The_Repayment_Agreement__c = True, 
        ProgramAdminStatus__c = 'Closed');
                
        insert testDegreeDeclaration ;

        //creating a test Tuition Refund
        Tuition_Refund__c testTuitionRefund = new Tuition_Refund__c(
        Name = 'Summer 2011', 
        Degree_Declaration__c = testDegreeDeclaration.Id,
        Source_of_Other_Tuition_Assistance__c = 'None');
        
        insert testTuitionRefund ;
  
    }
}