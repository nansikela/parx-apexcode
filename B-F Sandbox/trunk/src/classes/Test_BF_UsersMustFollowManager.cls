/*************************************************************
*Name : Test_BF_UsersMustFollowManager
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Modified Date : October 24,2011 
*Purpose : Tests BF_UsersMustFollowManagerJob & BF_UsersMustFollowManagerTrigger
****************************************************************/
@isTest
private class Test_BF_UsersMustFollowManager {
  
  static testMethod void myUnitTestBatch() {
    Test.startTest();
    // Creation Of user
    User testuser1 = [select id,managerId,NextLevelManagers__c from User where id = :UserInfo.getUserId()];
    List<User> testuser2 = [select id,managerId, NextLevelManagers__c from user where id != :UserInfo.getUserId() AND isActive = true];       

//Getting Profile Details        
  Profile testProfile = [select id from profile where name='Default One App'];         
  //Creating a Test User        
  User testuser3 = new User(alias = 'myTest', email='myTest@b-f.com',emailencodingkey='UTF-8', 
  lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = testProfile.id,
  timezonesidkey='America/Los_Angeles', username='myTest@b-f.com@b-f.com', ManagerId=testuser2[0].id);   

    if(testuser2.size() == 0) {
      return;
    }
    
    
    // Updating Manager of user
    testuser1.NextLevelManagers__c = testuser2[0].Id;
    update testuser1;
    testuser1.NextLevelManagers__c = testuser2[0].Id +','+ testuser2[0].Id;
    testuser1.ManagerId = testuser2[0].id; 
    update testuser1;
    
    testuser1.NextLevelManagers__c = null;
    insert testuser3;
    
    List<EntitySubscription> lstNewSubscription = new List<EntitySubscription>(); 
    lstNewSubscription.add(new EntitySubscription(ParentId = testuser3.ManagerId,Subscriberid = testuser3.id));
    try {  
      insert lstNewSubscription;
    }
    catch(DMLException de) {
      if(!de.getMessage().contains('DUPLICATE_VALUE')) {
        throw de;
      }
      else {
        Database.insert(lstNewSubscription,false);
      }
    }
// Update testuser3    
    
    //delete existing Entity Subscription created due to trigger
    delete [select id from EntitySubscription where Subscriberid = :testuser3.Id and parentID = :testuser2[0].Id];   
    
     List<Id> lstUserId = new List<Id>();
     lstUserId.add(testuser1.Id);
     lstUserId.add(testuser2[0].Id);
     lstUserId.add(testuser3.Id);
     Database.executeBatch(new BF_UsersMustFollowManagerJob(null));     
     Test.stopTest();
   
    EntitySubscription entitySubscription = [select id,ParentId,Subscriberid from EntitySubscription where Subscriberid = :testuser1.Id AND ParentId = :testuser2[0].Id];   
    system.assert(entitySubscription.id != null);
  }
}