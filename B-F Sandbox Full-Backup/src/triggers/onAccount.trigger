trigger onAccount on Account (after update) {
	/**
	 * we run the trigger on Outlet Visit Item to update the brand depletion actuals.
	 *Conditions: 
	 *  +Account RecordType: EUR_Outlets (or "DEU_Outlets")
	 *  +onUpdate, Brand or Facing or Channel (Account) has changed
	 *
	 * On delete, we have to get the event from the on Outlet Visit trigger because there is no event in the outlet Visit Item
	 * We refresh always all the records of the account to make sure everything is fine for every event.
	 * If the Channel is on, then Depletion actuals is 1 else it's the sum of the facing grouped by brand.
	 * If the brand does not exist, it has to be created, else it has to be updated (the Depletion Actual).
	 *          
	 * @date    		30.11.2011
	 * @author  		Christophe Vidal
	 * @modification	Michael Mickiewicz - 04/24/2012 (Substitution Concept)
    */
	list<Id> AccountIds = new list<Id>();
	//PARX - Substitution Concept - Part 1 --------------------------------------------------
    map<ID, ID> accs4Sharing = new map<ID, ID>();
	//PARX END ------------------------------------------------------------------------------
		
    for(Account acc:trigger.new) {
    	//PARX - Substitution Concept - Part 2 ----------------------------------------------
    	accs4Sharing.put(acc.ID, acc.Substitution__c);
    	//PARX END --------------------------------------------------------------------------
    	if(acc.Channel__c != trigger.oldMap.get(acc.Id).Channel__c) {
    	   AccountIds.add(acc.Id);
    	}
    }
    if(!AccountIds.isEmpty()) {
    	list<Id> RTIds = new list<Id>();
    	for(RecordType rt:[select id from RecordType where sObjectType = 'Account' AND (developerName = 'EUR_Outlets' OR developerName = 'DEU_Outlets')]) {
    		RTIds.add(rt.Id);
    	}
    	Outlet_Visit_Item_Helper.runIt = true;
    	list<Outlet_Visit_Item__c> OVI_List = new list<Outlet_Visit_Item__c>([select id from Outlet_Visit_Item__c where Outlet_Visit__r.Account__c IN: AccountIds AND Outlet_Visit__r.Account__r.RecordTypeId IN: RTIds]);
    	update OVI_List;
    }
    
    //PARX - Substitution Concept - Part 3 ---------------------------------------------------	       
    map<ID, ID> accs_DeleteSharing = new map<ID, ID>();
    map<ID, ID> accs_InsertSharing = new map<ID, ID>();
    
    for(Account acc : trigger.old) {
       	//Make a distribution of the values dependend on the situation
       	if(accs4Sharing.get(acc.ID) == acc.Substitution__c)
    		accs4Sharing.remove(acc.ID); //If the old value and the new value are the same, we do not make any changes! Regardless if values are null!
    	else if(accs4Sharing.get(acc.ID) == null && acc.Substitution__c != null)
    		accs_DeleteSharing.put(acc.ID, acc.Substitution__c); //If the old subsumption was set and the new one is empty, the sharing rule needs to be removed! ==> No subsumption anymore needed!
    	else if(Accs4Sharing.get(acc.ID) != null && acc.Substitution__c == null)
    		accs_InsertSharing.put(acc.ID, accs4Sharing.remove(acc.ID)); //If the old subsumption was empty, but the new one was set, a sharing rule must be created! ==> A person was set for subsumption!
    }
    
    //First delete all obsolate sharing rules!
    set<ID> ovIDs = new set<ID>();
    for(Outlet_Visit__c ov : [Select ID From Outlet_Visit__c Where Account__c IN: accs_DeleteSharing.keySet()])
    	if(!ovIDs.contains(ov.ID))
    		ovIDs.add(ov.ID);
    		
    system.debug('Outlet Visit amount: '+ovIDs.size());		
    system.debug(accs_DeleteSharing.values());
    list<Outlet_Visit__Share> sharingRules = [Select ID From Outlet_Visit__Share Where UserOrGroupID IN :accs_DeleteSharing.values() AND ParentId IN: ovIDs AND RowCause = :Schema.Outlet_Visit__Share.rowCause.Substitution__c];
    system.debug(sharingRules);
    list<AccountShare> accSharingRules = [Select ID From AccountShare Where UserOrGroupID IN :accs_DeleteSharing.values() AND AccountId IN: accs_DeleteSharing.keySet()];
    
    if(sharingRules.size() > 0)
    	delete sharingRules;
    if(accSharingRules.size() > 0)
    	delete accSharingRules;
    	
    
    //Then clear the list and fill it with the newly created rules!
    sharingRules.clear();
    accSharingRules.clear();
    
    map<ID, ID> accIdWithOvIds = new map<ID, ID>();
    for(Outlet_Visit__c ov : [Select ID, Account__c From Outlet_Visit__c Where Last_Visit__c = true AND Account__c IN: accs_InsertSharing.keySet()])
 		accIdWithOvIds.put(ov.Account__c, ov.ID);
 		   		
    for(String accID : accs_InsertSharing.keySet()) {
    	Outlet_Visit__Share ovShr  = new Outlet_Visit__Share(RowCause = Schema.Outlet_Visit__Share.RowCause.Substitution__c);
    	ovShr.ParentId = accIdWithOvIds.get(accID);
 	    ovShr.UserOrGroupId = accs_InsertSharing.get(accID);
      	ovShr.AccessLevel = 'Read';
		sharingRules.add(ovShr);

    	AccountShare AccShare = new AccountShare(AccountId = accID, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'None', CaseAccessLevel = 'None', UserOrGroupId = accs_InsertSharing.get(accID));
    	accSharingRules.add(AccShare);
    }
    
    insert accSharingRules;
    insert sharingRules;
    //PARX END -------------------------------------------------------------------------------
}