/*************************************************************
*Name : Test_BF_UsersMustFollowManagerJob
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Purpose : Tests EverythingElseController (controller for quick link)
****************************************************************/
@isTest
private class Test_EverythingElseController {

    static testMethod void myUnitTest() {
    	  
        Test.startTest();
        Quick_Link__c quickLink1 = new Quick_Link__c(
        Image_Link__c = 'http://www.google.com',
        Link_Location__c = 'http://www.google.com',
        Name__c = 'test',
        Category__c = 'Google'
        );
        insert quickLink1;
        Quick_Link__c quickLink2 = new Quick_Link__c(
        Image_Link__c = 'http://www.google.com',
        Link_Location__c = 'http://www.google.com',
        Name__c = 'test',
        Category__c = 'Google'
        );        
        insert quickLink2;
        UserQuickLink__c userLink = new UserQuickLink__c(UserId__c = UserInfo.getUserId() ,Quick_Link_ID__c = quickLink2.Id); 
        insert userLink;
        EverythingElseController everyThing = new EverythingElseController();
        everyThing.getItems();
        everyThing.setCategory('All');        
        system.assertEquals('All',everyThing.getCategory());
        everyThing.selectedLink = quickLink1.Id;
        everyThing.createUserLinks();
        List<UserQuickLink__c> lstUserLink = [select id from UserQuickLink__c where Quick_Link_ID__c = :quickLink1.Id And UserId__c = :UserInfo.getUserId()];
        system.assert(lstUserLink.size() > 0);
        everyThing.showFavourites();
        everyThing.selectedLink = quickLink1.Id;
        everyThing.deleteFavourites();  
        everyThing.changeCategory();
        Test.stopTest();
    }
}