trigger afterUpdateOutletVisitStatusChange on Outlet_Visit__c (after insert, after update) {    
/*
Modification Log:
-------------------------------------------------------------------------------
Developer			Date			Description
-------------------------------------------------------------------------------
Mike Shroyer		24-Aug-2011  	Changed the if logic to not process OVI's if the Offline Use is false. 
									This is because I added code in the processOVI job to update this field to false if it's older than the 2nd complete OV
									and future apex cannot call future apex.
-------------------------------------------------------------------------------
*/	
    User u = [Select u.UserPermissionsOfflineUser, u.UserPermissionsMobileUser From User u where u.Id =: UserInfo.getuserId()];
    Set<ID> myIds = new Set<ID>();
    if(Trigger.isUpdate)
    {
        for(Integer x = 0; x<Trigger.new.size(); x++)
        {
            //detect change in Status, or if the outletVisit_Controller is making the change (web form), then also push changes,  but not if Offline_Use is false
            if(Trigger.new[x].Status__c =='Complete' && Trigger.new[x].Offline_Use__c && (INFW_Stateful.hasAlreadyCreated() || (Trigger.new[x].Status__c!=Trigger.old[x].Status__c))){
                myIds.add(Trigger.new[x].ID);
            }
        }
    }else{
        for(Integer x = 0; x<Trigger.new.size(); x++)
        {
            if(Trigger.new[x].Status__c =='Complete'){
                myIds.add(Trigger.new[x].ID);
            }
        }       
    }
    if(!myIds.isempty())// && (u.UserPermissionsOfflineUser || u.UserPermissionsMobileUser))
        offlineOutletVisit.processOVI(myIds,INFW_Stateful.hasAlreadyCreated(),(u.UserPermissionsOfflineUser || u.UserPermissionsMobileUser));
}