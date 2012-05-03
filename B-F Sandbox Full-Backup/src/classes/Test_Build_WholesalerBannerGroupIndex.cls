/* Class Name : Test_Build_WholesalerBannerGroupIndex
* Description: Test class to test the Build_RepWholesalerBannerGroup_Index class
* Created By : Tass Tsakiridis
* Created On : 27th April 2012
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
*/ 
@isTest
private class Test_Build_WholesalerBannerGroupIndex {
	static testMethod void unitTest1() {
		INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        Profile[] p1 = [select id from Profile where Name = 'System Administrator' LIMIT 1];
        //Profile[] p1 = [SELECT Id FROM Profile WHERE Name = 'AUD-Customer Service (Platform)'];        
        u1.ProfileID = p1[0].id;      
        u1.Market__c = 'Australia';
        insert u1;		
		
		System.runAs(u1) {
			Build_Rep_WholesalerBannerGroup_Index o = new Build_Rep_WholesalerBannerGroup_Index();
			o.BuildIndex('');
		}
	}
}