trigger onTimeTracking on Time_Tracking__c (after insert) {
	/**
     * for P00002
     * need the outlet visits connected to the time tracking records
     * to get a nice report to compare the actual visits with the sales rep goal of 8 visits a day
     *
     * @date    1/10/2012
     * @author  Jochen Schrader
    */

	private static final String COMPLETESTATE='Complete';

	map<Id, Time_Tracking__c> ttmap= new map<Id, Time_Tracking__c>();
	set<Integer> monthlist = new set<Integer>();
	
	for (Time_Tracking__c tt: trigger.new) {
		ttmap.put(tt.OwnerId__c, tt);
		monthlist.add(tt.StartDate__c.Year()*100 + tt.StartDate__c.Month());
	}
	
	list<Outlet_Visit__c> outletvisitsToUpdate = new list<Outlet_Visit__c>();
	
	for (Outlet_Visit__c ov:[SELECT Id, Visit_Date__c, Visit_Date_Month__c, OwnerId 
						FROM Outlet_Visit__c 
						WHERE OwnerId IN :ttmap.KeySet() 
							AND Visit_Date_Month__c IN :monthlist
							AND Status__c=:COMPLETESTATE
							]) {
		if (ttmap.containsKey(ov.OwnerId) 
			&& ov.Visit_Date__c.Month()==ttmap.get(ov.OwnerId).StartDate__c.Month()
			&& ov.Visit_Date__c.Year()==ttmap.get(ov.OwnerId).StartDate__c.Year()
			) {
			ov.Time_Tracking__c=ttmap.get(ov.OwnerId).Id;
			outletvisitsToUpdate.add(ov);
		}
	}
	
	if (!outletvisitsToUpdate.isEmpty())
		update outletvisitsToUpdate;
}