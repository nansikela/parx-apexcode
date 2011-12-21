trigger onOutlet_Visit_Item on Outlet_Visit_Item__c (before delete, after insert, after undelete, after update) {
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
    list<Id> ovi_Ids = new list<Id>();
    list<Id> deletedIds = new list<Id>();
    if(trigger.isDelete) {
    	for(Outlet_Visit_Item__c ovi:trigger.old) {
    		ovi_Ids.add(ovi.Id);
    		deletedIds.add(ovi.Id);
    	}
    }
    else {
    	for(Outlet_Visit_Item__c ovi:trigger.new) {
    		if(!(trigger.isUpdate && ovi.Custom_Product__c == trigger.oldMap.get(ovi.Id).Custom_Product__c && ovi.Facing__c == trigger.oldMap.get(ovi.Id).Facing__c && !Outlet_Visit_Item_Helper.runIt))
                ovi_Ids.add(ovi.Id);
        }
    }
    if(!ovi_Ids.isEmpty()) {
	    Outlet_Visit_Item_Helper.main(ovi_Ids, deletedIds);
    }
}