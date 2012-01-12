/*************************************************************
*Name : BF_UsersMustFollowManager
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Modified Date: 10/24/2011 by Raj Rao
*Purpose : To force users to follow thier managers
*Pseudo Code : Check if an EntitySubscription object exists for a user and their manager
               If not create it, else do nothing       
****************************************************************/
public without sharing class BF_UsersMustFollowManager {
  
  //=====================================================================//
  //collects the updated users , forms a map of users and pass it to followManager method
  // to create subscription and to update user
  //====================================================================//
//  @future
  public static void followManager(List<Id> lstUserId) {
    Map<Id,User> mpUser = new Map<Id,User>();
    for(User user : [SELECT ManagerId,DefaultGroupNotificationFrequency,NextLevelManagers__c 
                                     FROM User 
                                     WHERE id IN :lstUserId AND ManagerId != null AND Manager.IsActive = true AND IsActive = true]) {
      mpUser.put(user.Id,user); 
    }
    followManager(mpUser);   
  }
  
  //=====================================================================//
  //Collect Manager IDs in a set,so that it can set for querying.
  //====================================================================//
  private static Set<Id> CollectManagerIds(Map<Id,User> mpUser) {
    Set<Id> setManagerID = new Set<Id>();

    for(User user :mpUser.values()) {
      if(user.ManagerID != null) {
        setManagerID.add(user.ManagerID);
      }  
    }
    return setManagerID;
  }
  
    //----------------------------------------------------------//
  //to find if entry corresponding to user and its managers exists ,
  // and insert record if no record exists in entity subscription  
  //----------------------------------------------------------//
  public static void followManager(Map<Id,User> mpUser) {
    Set<Id> followerIds = new Set<Id>();
    Set<Id> managerID = CollectManagerIDs(mpUser);

//NEW CODE BY RAj RAO 
    List<String> nextLevelMgrID = new List<String>();
    Boolean isFollower;
    List<EntitySubscription> lstNextLevelManagerNewSubscription = new List<EntitySubscription>(); 
 
//Query existing subscription objects for records
    for(EntitySubscription entitySubscription : [SELECT ParentId,SubscriberId,Subscriber.Name FROM EntitySubscription 
                                                 WHERE SubscriberId in :mpUser.values() AND ParentId IN :managerID]) {
      
      if(entitySubscription.ParentId == mpUser.get(entitySubscription.SubscriberId).ManagerId) { 
        followerIds.add(entitySubscription.SubscriberId);
      }
    }
    
    //Iterate over all users, and check if their is a record present

    List<EntitySubscription> lstNewSubscription = new List<EntitySubscription>(); 
    for(User user : mpUser.values()) {
      if(user.ManagerId == null) 
        continue;
        
      if(!followerIds.contains(user.Id)) {
        user.DefaultGroupNotificationFrequency = 'N';
        lstNewSubscription.add(new EntitySubscription(ParentId = user.ManagerId,Subscriberid = user.Id));
      }
    }
    
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
 
    //NextLevelManagers Code block
        
    for(EntitySubscription entitySubscription : [SELECT ParentId,SubscriberId,Subscriber.Name FROM EntitySubscription 
                                                 WHERE SubscriberId in :mpUser.values() AND ParentId IN :managerID]) {
      if(mpUser.get(entitySubscription.SubscriberId).NextLevelManagers__c!=null){
        nextLevelMgrID = mpUser.get(entitySubscription.SubscriberId).NextLevelManagers__c.split(',');
        for(Integer i=0; i<nextLevelMgrID.size(); i++ ){
          //System.Debug ('NEXT LEVEL MANAGERID ' + nextLevelMgrID[i]);
          if(entitySubscription.ParentId == nextLevelMgrID[i]){
            isFollower = true;
          }else{
            isFollower = false;
            //System.Debug ('NEW ENTITY SUBSCRIPTION FOR PARENT Name:'+ nextLevelMgrID[i] + ' SUBSCRIBER ID:'+mpUser.get(entitySubscription.SubscriberId)+' whose name is '+entitySubscription.Subscriber.Name);
            mpUser.get(entitySubscription.SubscriberId).DefaultGroupNotificationFrequency = 'N';
            if(nextLevelMgrID[i]!= mpUser.get(entitySubscription.SubscriberId).Id){
              lstNextLevelManagerNewSubscription.add(new EntitySubscription(ParentId = nextLevelMgrID[i],Subscriberid = mpUser.get(entitySubscription.SubscriberId).Id));
            }
          }
        }
      }   
    }    
    
    try {  
      insert lstNextLevelManagerNewSubscription; 
    }
    catch(DMLException de) {
      if(!de.getMessage().contains('DUPLICATE_VALUE')) {
        throw de;
      }
      else {
        Database.insert(lstNextLevelManagerNewSubscription,false);
      }
    }
    try {
//   update Users DefaultNotificationFrequency = N
      update mpUser.values();
    }
    catch(DMLException de) {
    
    }
  }
}