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
private class test_beforeInsertUpdateVendor {

    static testMethod void myUnitTest() {
             
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
        

//Creating a test Vendor (Block1)  
Vendor__c testVendor = new Vendor__c(Copy_Business_Address_to_Payment_Address__c = true,
                                     Company_Code__c = '1000-Brown Forman Corparation', Purchasing_Org__c = '5590',
                                     Country_LAND1__c = 'US-USA', Business_Name_NAME1__c = 'Dicks Crab Shack',
                                     Business_Address_STRAS__c = '123 anywhere', Business_City_ORT01__c = 'Seaside',
                                     Business_Region__c = 'NJ',Business_Postal_Code_PSTLZ__c = '08816',
                                     time_zone__c = 'EST', Business_Phone_TELF1__c = '999-999-9999',
                                     currency__c = 'USD', Method_of_Payment__c = 'Check',
                                     Payment_Terms__c = 'N45', Accepts_Credit_Card__c = 'true',
                                     Evaluated_Receipt_Settlement__c = 'true',Business_Type__c = 'US - Tax Exempt',
                                     Tax_Withholding_Code__c = 'US-1-Rents',Minority_Indicator__c = 'Levites',
                                     Purchase_or_Service__c = 'Service', your_name__c = 'Mike Levites',
                                     your_manager_s_name__c = 'Marc baldwin',X1099_Business_Legal_Name__c = 'Dicks Crab Shack',
                                     Payment_Address_STRAS__c = '123 anywhere',Payment_City_ORT01__c = 'Anywhere',
                                     Payment_Postal_Code_PSTLZ__c = '08816',SSN_Encrypted__c = '999-99-9999',
                                     Tax_City_ORT01__c = 'Anywhere',Tax_Postal_Code_PSTLZ__c ='08816',
                                     Tax_Address_STRAS__c = '123 anywhere');

     insert testVendor;
  
  
  //Block 2   Copy_Business_Name_to_Business_Legal__c == true
     Vendor__c testVendor2 = new Vendor__c(Copy_Business_Name_to_Business_Legal__c = true,
                                     Company_Code__c = '1000-Brown Forman Corparation', Purchasing_Org__c = '5590',
                                     Country_LAND1__c = 'US-USA', Business_Name_NAME1__c = 'Dicks Crab Shack',
                                     Business_Address_STRAS__c = '123 anywhere', Business_City_ORT01__c = 'Seaside',
                                     Business_Region__c = 'NJ',Business_Postal_Code_PSTLZ__c = '08816',
                                     time_zone__c = 'EST', Business_Phone_TELF1__c = '999-999-9999',
                                     currency__c = 'USD', Method_of_Payment__c = 'Check',
                                     Payment_Terms__c = 'N45', Accepts_Credit_Card__c = 'true',
                                     Evaluated_Receipt_Settlement__c = 'true',Business_Type__c = 'US - Tax Exempt',
                                     Tax_Withholding_Code__c = 'US-1-Rents',Minority_Indicator__c = 'Levites',
                                     Purchase_or_Service__c = 'Service', your_name__c = 'Mike Levites',
                                     your_manager_s_name__c = 'Marc baldwin',X1099_Business_Legal_Name__c = 'Dicks Crab Shack',
                                     Payment_Address_STRAS__c = '123 anywhere',Payment_City_ORT01__c = 'Anywhere',
                                     Payment_Postal_Code_PSTLZ__c = '08816',SSN_Encrypted__c = '999-99-9999',
                                     Tax_City_ORT01__c = 'Anywhere',Tax_Postal_Code_PSTLZ__c ='08816',
                                     Tax_Address_STRAS__c = '123 anywhere');

     insert testVendor2;
     
     
      //Block 3   Copy_Business_Address_to_Tax_Address__c == true
     Vendor__c testVendor3 = new Vendor__c(Copy_Business_Address_to_Tax_Address__c = true,
                                     Company_Code__c = '1000-Brown Forman Corparation', Purchasing_Org__c = '5590',
                                     Country_LAND1__c = 'US-USA', Business_Name_NAME1__c = 'Dicks Crab Shack',
                                     Business_Address_STRAS__c = '123 anywhere', Business_City_ORT01__c = 'Seaside',
                                     Business_Region__c = 'NJ',Business_Postal_Code_PSTLZ__c = '08816',
                                     time_zone__c = 'EST', Business_Phone_TELF1__c = '999-999-9999',
                                     currency__c = 'USD', Method_of_Payment__c = 'Check',
                                     Payment_Terms__c = 'N45', Accepts_Credit_Card__c = 'true',
                                     Evaluated_Receipt_Settlement__c = 'true',Business_Type__c = 'US - Tax Exempt',
                                     Tax_Withholding_Code__c = 'US-1-Rents',Minority_Indicator__c = 'Levites',
                                     Purchase_or_Service__c = 'Service', your_name__c = 'Mike Levites',
                                     your_manager_s_name__c = 'Marc baldwin',X1099_Business_Legal_Name__c = 'Dicks Crab Shack',
                                     Payment_Address_STRAS__c = '123 anywhere',Payment_City_ORT01__c = 'Anywhere',
                                     Payment_Postal_Code_PSTLZ__c = '08816',SSN_Encrypted__c = '999-99-9999',
                                     Tax_City_ORT01__c = 'Anywhere',Tax_Postal_Code_PSTLZ__c ='08816',
                                     Tax_Address_STRAS__c = '123 anywhere');

     insert testVendor3;
     
     
     
                                                                        
        
    }
}