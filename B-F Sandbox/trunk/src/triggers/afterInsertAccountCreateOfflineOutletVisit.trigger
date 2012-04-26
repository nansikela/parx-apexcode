trigger afterInsertAccountCreateOfflineOutletVisit on Account (after insert) {
/*
Modification Log:
-------------------------------------------------------------------------------
Developer           Date        Description
-------------------------------------------------------------------------------
Jishad P A (DC)     15-Jun-2011 Modified to add record type check to exclude 
                                 POS Ship-to record type.
-------------------------------------------------------------------------------
*/
    Map<ID,List<Account>> mapOwnerAccount = new Map<ID,List<Account>>();
    Set<ID> setOVtoProcess = new Set<ID>();
    List<Outlet_Visit__c> lstInsertOutletVisits = new List<Outlet_Visit__c>();
    // Get the Account record types by name
    Map<String,Schema.RecordTypeInfo> promoRTMap = 
        Schema.SObjectType.Account.getRecordTypeInfosByName();
    // Id for POS Ship-To record type
    Id posShiptoRecType = null;
    // Get the record type id for POS Ship-To from the record type map
    if(promoRTMap.containsKey('POS Ship-To')){
        posShiptoRecType = promoRTMap.get('POS Ship-To').getRecordTypeId();
    }
    
    for(Account y : Trigger.New) {
        // Execute the login only for record types other than POS Shipto type
        if(y.RecordTypeId!=posShiptoRecType){
            List<Account> temp = mapOwnerAccount.get(y.OwnerId);
            if(temp!=null){
                temp.add(y);
            }else{
                temp = new List<Account>();   
                temp.add(y);
            }                                       
            mapOwnerAccount.put(y.OwnerId,temp);
        }
    }
    Map<ID,User> mapUsers = new  Map<ID,User>([Select u.UserPermissionsOfflineUser From User u where u.Id =: mapOwnerAccount.keyset()]);   
    for(string x : mapOwnerAccount.keyset()){
        //if the OwnerId is mobile, then create an Outlet Visit, then process OfflineOVI.
        if(mapUsers.get(x)!=null && (mapUsers.get(x).UserPermissionsOfflineUser)){
            for(Account a: mapOwnerAccount.get(x)){
                Outlet_Visit__c ov = new Outlet_Visit__c(Create_Offline_OVIs__c=true, OwnerId = a.OwnerId, Account__c = a.Id, Visit_Date__c = date.today().addmonths(-1), Status__c = 'New');
                lstInsertOutletVisits.add(ov);
            }           
        }   
    }
    if(!lstInsertOutletVisits.isEmpty()){
        insert lstInsertOutletVisits;
    }
    for(Outlet_Visit__c f : lstInsertOutletVisits){
        setOVtoProcess.add(f.Id);   
    }
    if(!setOVtoProcess.isempty())
        offlineOutletVisit.processDatedOOVIsIDS();
}