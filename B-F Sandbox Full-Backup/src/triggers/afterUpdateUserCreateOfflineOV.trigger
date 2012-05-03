trigger afterUpdateUserCreateOfflineOV on User (before update) {
	Set<ID> setIds = new Set<ID>();
    for(User u : Trigger.new){
    	if(u.Create_Offline_Outlet_Visit_Records__c){
    		setIds.add(u.Id);
    		u.Create_Offline_Outlet_Visit_Records__c = false;
    	}
    }
	Set<ID> setIds2 = new Set<ID>();
    for(User u : [Select Id, UserPermissionsOfflineUser, UserPermissionsMobileUser from User where Id in: setIds]){
    	if(u.UserPermissionsOfflineUser || u.UserPermissionsMobileUser)
    		setIds2.add(u.Id);
    }
    system.debug(setIds2);
    List<Outlet_Visit__c> lstInsertOutletVisits = new List<Outlet_Visit__c>();
	for(Account a : [Select Id, OwnerId, (Select Id From Outlet_Visits__r where Status__c = 'New') from Account where OwnerId in: setIds2]){	
		if(a.Outlet_Visits__r.isempty()){
			Outlet_Visit__c ov = new Outlet_Visit__c(Create_Offline_OVIs__c=true, OwnerId = a.OwnerId,Account__c = a.Id, Visit_Date__c = date.today().addmonths(-1), Status__c = 'New');
			lstInsertOutletVisits.add(ov);
		}
	}
	if(!lstInsertOutletVisits.isempty()){
    	insert lstInsertOutletVisits;    
    	offlineOutletVisit.processDatedOOVIsIDS();
	}    	
}