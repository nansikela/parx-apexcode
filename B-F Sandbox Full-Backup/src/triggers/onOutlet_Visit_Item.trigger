trigger onOutlet_Visit_Item on Outlet_Visit_Item__c (before delete, after insert, after undelete, after update) {
        /**
	     * we run the trigger on Outlet Visit Item to update the brand depletion actuals.
	     *Conditions: 
	     *  +Account RecordType: EUR_Outlets (or "DEU_Outlets")
	     *  +onUpdate, Brand or Facing or Channel (Account) has changed
	     *
	     * On delete, we have to get the event from the on Outlet Visit trigger because there is no event in the outlet Visit Item
	     * We refresh always all the records of the account to make sure everything is fine for every event..
	     *          
	     * @date    30.11.2011
	     * @author  Christophe Vidal
	     * @author  Michael Mickiewicz
	    */
    list<Id> deletedIds = new list<Id>();
    list<ID> ovi_to_ap_IDs = new list<ID>();
    
    if(trigger.isDelete) {
    	for(Outlet_Visit_Item__c ovi:trigger.old) {
    		deletedIds.add(ovi.Id);
    		ovi_to_ap_IDs.add(ovi.ID);
    	}
    }
    else {
    	for(Outlet_Visit_Item__c ovi:trigger.new) {
    		// we need the ids of available and unavailable ovis
    		ovi_to_ap_IDs.add(ovi.ID);
        }
    }
    if((!ovi_to_ap_IDs.isEmpty() || !deletedIds.isEmpty()) && !Outlet_Visit_Item_Helper.runIt) 
    	Outlet_Visit_Item_Helper.map_to_Account_Products(ovi_to_ap_IDs, deletedIds);
}