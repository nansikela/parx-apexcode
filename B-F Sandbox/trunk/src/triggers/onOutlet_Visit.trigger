trigger onOutlet_Visit on Outlet_Visit__c (before delete, after delete, after undelete, after update, after insert) {
/**
 *Trigger on all events
 *Conditions: 
 *	+Account RecordType: EUR_Outlets (or "DEU_Outlets")
 *	+Status__c is 'Complete'
 *
 * We refresh always all the rows of the account to make sure everything is fine for every event.
 * We sort the retrieved records from the Account by Visit_Date__c. The last Visit_Date__c record gets the 
 * Last_Visit__c true. The next gets the field Next_to_Last_Visit__c true and Last_Visit__c to false
 * and all other records are set back to false.
 * 			
 * @date	11/28/2011
 * @author 	Christophe Vidal
 *
 * Modification History:
 * 12/05/2011, Jochen Schrader - Id lists are now sets and the strings are now configureable at the head of the trigger.
**/

	private static final String COMPLETESTATE='Complete';
	private static final String DEU_ACCOUNT_RECORDTYPE='DEU_Outlets';
	private static final String EUR_ACCOUNT_RECORDTYPE='EUR_Outlets';
	
	if(trigger.isAfter) {
		set<Id> AccountIds = new set<Id>();
	
		if((trigger.isInsert || trigger.isUpdate || trigger.isUndelete) && !Outlet_Visit_Helper.hasAlreadyRun) {
			Outlet_Visit_Helper.hasAlreadyRun = true; 
	
			for(Outlet_Visit__c OV:trigger.new) {
				if(OV.Status__c == COMPLETESTATE && OV.Account__c != null) {
					//we have to make the update.
					if (!AccountIds.contains(OV.Account__c)) AccountIds.add(OV.Account__c);
				}  
			}
		}
		
		if((trigger.isDelete) && !Outlet_Visit_Helper.hasAlreadyRun) {
			Outlet_Visit_Helper.hasAlreadyRun = true; 
	
			for(Outlet_Visit__c OV:trigger.old) {
				if(OV.Status__c == COMPLETESTATE && OV.Account__c != null) {
					//we have to make the update.
					if (!AccountIds.contains(OV.Account__c)) AccountIds.add(OV.Account__c);
				}  
			}
		}
		
		Outlet_Visit_Helper.main(AccountIds); 
	}
	
	
	/* we run the trigger on Outlet Visit Item to update the brand depletion actuals. We don't get the event 
	* in the Outlet Visit Item trigger when the outlet visit is deleted.
	*/
	if(trigger.isDelete && trigger.isBefore) {
		set<Id> RTIds = new set<Id>();
        for(RecordType rt:[select id from RecordType where sObjectType = 'Account' AND (developerName = :DEU_ACCOUNT_RECORDTYPE OR developerName = :EUR_ACCOUNT_RECORDTYPE)]) {
            RTIds.add(rt.Id);
        }
		list<Outlet_Visit_Item__c> OVI_List = new list<Outlet_Visit_Item__c>([select id from Outlet_Visit_Item__c where Outlet_Visit__c IN: trigger.old AND Outlet_Visit__r.Account__r.RecordTypeId IN: RTIds]);
		system.debug('delete OVI_List:' + OVI_List);
		delete OVI_List;
	}
}