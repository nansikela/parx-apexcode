/*************************************************************
*Name : Test_BF_UsersMustFollowManagerJob
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Purpose : Tests BF_UsersMustFollowManagerJob & BF_UsersMustFollowManagerTrigger
****************************************************************/
@isTest
private class Test_BF_UsersMustFollowManagerJob {
  
  static testMethod void myUnitTestBatch() {
    Test.startTest();
    // Creation Of user
    User testuser1 = [select id,managerId from User where id = :UserInfo.getUserId()];
    List<User> testuser2 = [select id from user where id != :UserInfo.getUserId() AND isActive = true];       
    if(testuser2.size() == 0) {
      return;
    }
    
    // Updating Manager of user
    testuser1.managerId = testuser2[0].Id;
    update testuser1;
    
    //delete existing Entity Subscription created due to trigger
    delete [select id from EntitySubscription where Subscriberid = :testuser1.Id and parentID = :testuser2[0].Id];   
    
    Database.executeBatch(new BF_UsersMustFollowManagerJob(testuser1.Id)); 
    Test.stopTest();
   
    EntitySubscription entitySubscription = [select id,ParentId,Subscriberid from EntitySubscription where Subscriberid = :testuser1.Id AND ParentId = :testuser2[0].Id];   
    system.assert(entitySubscription.id != null);
  }
}