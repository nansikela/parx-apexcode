trigger afterUpdateOfflineOutletVisitItems on Offline_Outlet_Visit_Items__c (after update) {
	if(INFW_Stateful.hasAlreadyCreated()){return;}
    User u = [Select u.UserPermissionsOfflineUser, u.UserPermissionsMobileUser From User u where u.Id =: UserInfo.getuserId()];
    Set<ID> myIds = new Set<ID>();
    Set<ID> myIds2 = new Set<ID>();
    for(Integer x = 0; x<Trigger.new.size(); x++)
    {
        myIds.add(Trigger.new[x].Outlet_Visit__c);
    }       
    for(Outlet_Visit__c o : [Select Id from Outlet_Visit__c where ID in: myIds and Status__c = 'Complete']){
        myIds2.add(o.Id);
    }
    if(!myIds2.isempty() && (u.UserPermissionsOfflineUser || u.UserPermissionsMobileUser))
        offlineOutletVisit.processOVI(myIds2,false,false);
}