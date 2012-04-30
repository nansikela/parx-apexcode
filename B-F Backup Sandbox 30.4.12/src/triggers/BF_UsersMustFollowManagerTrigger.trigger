/*************************************************************
*Name : BF_UsersMustFollowManagerTrigger
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Purpose : trigger to force users to follow their managers on user insert/update
           Check if the manager has been changed or updated.
****************************************************************/

trigger BF_UsersMustFollowManagerTrigger on User (after insert, after update) {
      
  List<Id> lstUpdatedUsers = new List<Id>(); 
  for(User user :Trigger.New) {
    if(isManagerUpdated(user)) {
      lstUpdatedUsers.add(user.Id);
    }
  }
  
  if(lstUpdatedUsers.size() > 0 ) { 
    BF_UsersMustFollowManager.followManager(lstUpdatedUsers); 
  }
  
  //-----------------------------------------//
  // Returns true if the manager of the user is changed in case of update
  // and in case of insert if manager is not  blank 
  //-----------------------------------------//
  private Boolean IsManagerUpdated(User user) {
    if(Trigger.isInsert) {
      return (user.ManagerId != null);
    }
    
    User oldUser = Trigger.oldMap.get(user.Id);
    if(!oldUser.isActive && user.IsActive && user.ManagerId != null)
      return true;
     
    if(oldUser.ManagerId != user.ManagerId && user.ManagerID != null) {
      return true;
    }
    return false;
  } 
    
  
  
}