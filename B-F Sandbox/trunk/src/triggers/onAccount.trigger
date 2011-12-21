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
	 * @date    30.11.2011
	 * @author  Christophe Vidal
    */
	list<Id> AccountIds = new list<Id>();
    for(Account acc:trigger.new) {
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
}