/*************************************************************
*Name : BF_UsersMustFollowManagerJob
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Purpose : Batch Job thst runs at night to force users to follow their managers if they unfollow them. 
****************************************************************/
global class BF_UsersMustFollowManagerJob implements Database.Batchable<SObject>{
   global String Query;
   Id userID;
      
   global BF_UsersMustFollowManagerJob(Id subscriberID) {
     userID = subscriberID;
   } 
  
   //--------------------------------------------// 
   //method to retrieve jobs to be processed
   //--------------------------------------------//   
  global Database.queryLocator start(Database.BatchableContext ctx){
    //Retrieve only those users, who are active and their managers are active
    if(Test.isRunningTest()) {
      query = 'SELECT ManagerId,NextLevelManagers__c,DefaultGroupNotificationFrequency '+
            ' FROM User WHERE Id = :userId AND ManagerId != null AND Manager.IsActive = true AND IsActive = true';
      return Database.getQueryLocator(query);
    }
    else {
      query = 'SELECT ManagerId,NextLevelManagers__c,DefaultGroupNotificationFrequency '+
            ' FROM User WHERE ManagerId != null AND Manager.IsActive = true AND IsActive = true';
      return Database.getQueryLocator(query);
    }
  } 
  //--------------------------------------------// 
  //method to process records
  //--------------------------------------------// 
  global void execute(Database.BatchableContext ctx, List<Sobject> scope) {    
    Map<Id,User> mpUser = new Map<Id,User>();
    for(User user : (List<User>)scope) {
      mpUser.put(user.Id,user);
    } 
    BF_UsersMustFollowManager.followManager(mpUser); 
  }
  
 
  //--------------------------------------------// 
  // finish method of interface,nothings needs to be done
  // no notification etc needs to be send
  //--------------------------------------------// 
  global void finish(Database.BatchableContext ctx){} 
}