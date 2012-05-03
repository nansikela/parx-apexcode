/*************************************************************
*Name : BF_UsersMustFollowManager
*Created By : Raj Rao
*Created Date : October,18 2011
*Purpose : To update the NextLevelManagers__c field on the user object
*Pseudo Code : Find the managers manager and so on up the chain and update the NextLevelManagers field
                  
****************************************************************/
public without sharing class BF_UpdateNextLevelManagerNames {
  
  //=====================================================================//
  //collects the updated users , forms a map of users and pass it to updateNextLevelManagerNames method
  // to update NextLevelManagers__c field on the user record
  //====================================================================//
  @future
  public static void callUpdateManagerNames() {
    Map<Id,User> mpUser = new Map<Id,User>();
    for(User user : [SELECT Id, Name, ManagerId,DefaultGroupNotificationFrequency,NextLevelManagers__c  
                                     FROM User WHERE IsActive = true]) {
      mpUser.put(user.Id,user); 
    }
    updateManagerNames(mpUser);   
  }
  
  public static void updateManagerNames(Map<Id,User> mpUser) {
    System.Debug('Map mpUSer Size is '+mpUser.size());
    List<User> updatedUsers = new List<User>();
    User managerUser = new User();    
    String MgrID;
    String NextLevelMgrs = '';
    //Loop thru and get the Manager's Manager till such time that a manager is blank 
    //System.Debug('mpUser size is '+mpUser.size());
    for(User user : mpUser.values()) {
        MgrID = user.ManagerId;
        System.Debug('MgrID is '+MgrID);
        for(Integer i=0; i<7; i++){            
            managerUser = mpUser.get(MgrID);    
            if(managerUser!=null){          
              NextLevelMgrs+= managerUser.id + ',';
              MgrID = managerUser.ManagerId;
              //System.Debug('MgrID inside for loop is '+MgrID);
            }
        }
        //System.debug('User is '+user.Name +' Managers are  :'+ NextLevelMgrs);
        if(NextLevelMgrs.length()>0){
        user.NextLevelManagers__c = NextLevelMgrs.substring(0,NextLevelMgrs.lastIndexOf(',')).trim();
        }
        NextLevelMgrs = '';
           updatedUsers.add(user);
    }        
  
    try{
      update updatedUsers;    
    }catch(DMLException de){
  
    }
  }   
}