trigger onOutlet_Visit on Outlet_Visit__c (before delete, after delete, after undelete, after update, after insert, before update, before insert) {
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
 * 01/10/2012, Jochen Schrader - Outlet Visits will be connected to their time tracking records (P00002)
 * 02/16/2012, Jochen Schrader - Outlet Visit Date check for offline Clients transfer future Visit Dates to LastModifiedDate 
**/

	private static final String COMPLETESTATE='Complete';
	private static final String DEU_ACCOUNT_RECORDTYPE='DEU_Outlets';
	private static final String EUR_ACCOUNT_RECORDTYPE='EUR_Outlets';
	private static final String CAD_ACCOUNT_RECORDTYPE='CAD_Outlets';	
	
	set<Id> RTIds = new set<Id>();
    for(RecordType rt:[select id from RecordType where sObjectType = 'Account' AND (developerName = :DEU_ACCOUNT_RECORDTYPE OR developerName = :EUR_ACCOUNT_RECORDTYPE OR developerName = :CAD_ACCOUNT_RECORDTYPE)]) {
        RTIds.add(rt.Id);
    }
	
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
			
			/* Outlet Visit Date not in Future for offline Clients of german market */
			if (trigger.isUpdate || trigger.isInsert) {
				list<Outlet_Visit__c> ovlist = new list<Outlet_Visit__c>();

				map<Id, Account> DEUaccounts=new map<Id, Account>([SELECT Id FROM Account WHERE Id IN :AccountIds AND RecordTypeId IN:RTIds]);
				for(Outlet_Visit__c OV:[SELECT Id, LastModifiedDate, Status__c, Account__c, Visit_Date__c FROM Outlet_Visit__c WHERE Id IN :trigger.newMap.keySet()]) {
					if (OV.Status__c == COMPLETESTATE && OV.Account__c != null && DEUaccounts.containsKey(OV.Account__c)) {
						Date ThisLastModifiedDate=Date.newInstance(OV.LastModifiedDate.Year(), OV.LastModifiedDate.Month(), OV.LastModifiedDate.Day());
						if (OV.Visit_Date__c>ThisLastModifiedDate) {
							OV.Visit_Date__c=ThisLastModifiedDate;
							ovlist.add(OV);
						}
					}
				}
				update ovlist;
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
	
	
	/* we run the trigger on Outlet Visit Item to update the product depletion actuals. We don't get the event 
	* in the Outlet Visit Item trigger when the outlet visit is deleted.
	*/
	if(trigger.isDelete && trigger.isBefore) {
		list<Outlet_Visit_Item__c> OVI_List = new list<Outlet_Visit_Item__c>([select id from Outlet_Visit_Item__c where Outlet_Visit__c IN: trigger.old AND Outlet_Visit__r.Account__r.RecordTypeId IN: RTIds]);
		system.debug('delete OVI_List:' + OVI_List);
		delete OVI_List;
	}
	
	/* selecting time tracking records and append the outlet visits to them
		for SOW P00002
	*/
	if ((trigger.isUpdate || trigger.isInsert) && trigger.isBefore) {
		// preparations
		set<String> ownerids = new set<String>();
		set<Integer> monthlist = new set<Integer>();
		map<String, Time_Tracking__c> ttmap=new map<String, Time_Tracking__c>();
		
		for (Outlet_Visit__c ov: trigger.new) {
			if (
				ov.Status__c==COMPLETESTATE && 
				ov.Time_Tracking__c==null
				) {
				if (!ownerids.contains(String.valueOf(ov.OwnerId).substring(0,15))) ownerids.add(String.valueOf(ov.OwnerId).substring(0,15));
				if (!monthlist.contains(ov.Visit_Date__c.month() + ov.Visit_Date__c.year()*100)) monthlist.add(ov.Visit_Date__c.month() + ov.Visit_Date__c.year()*100);
			}
		}

		// now get the time tracking records and connect them to the ov
		if (!ownerids.isEmpty() && !monthlist.isEmpty()) {
			for (Time_Tracking__c tt: [SELECT Id, StartDate__c, OwnerId__c, StartDate_Month__c FROM Time_Tracking__c
										WHERE OwnerId__c IN :ownerids AND StartDate_Month__c IN :monthlist]) {
				if (!ttmap.containsKey(tt.OwnerId__c + String.valueOf(tt.StartDate_Month__c)))
					ttmap.put(tt.OwnerId__c + String.valueOf(tt.StartDate_Month__c),tt);
			}
		}
		// can't avoid this second run ...
		if (!ttmap.isEmpty()) {
			for (Outlet_Visit__c ov: trigger.new) {
				if (ttmap.containsKey(String.valueOf(ov.OwnerId).substring(0,15) + String.valueOf(ov.Visit_Date__c.month()+ ov.Visit_Date__c.Year()*100)))
					ov.Time_Tracking__c=ttmap.get(String.valueOf(ov.OwnerId).substring(0,15) + String.valueOf(ov.Visit_Date__c.month()+ ov.Visit_Date__c.year()*100)).id;
			}
		}
	}
}