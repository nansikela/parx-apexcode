public with sharing class MandatoryVisitController {
	
    public class DataElement {

        public String name { get; set; }
        public Integer value { get; set; }

        public DataElement(String name, Integer value) {
            this.name = name;
            this.value = value;
        }
    }
    
    private final ID userID;
	private final ID recordID;
	public Outlet_Visit__c record {get;set;}
	
	Set<ID> accountIDs {get;set;}
	list<Time_Tracking__c> timecards {get;set;} 
	public Integer outletVisitAmount {get;set;}
	
	public Double maxDays {get;set;}
	public Date startingDate {get;set;}
	public Date endingDate {get;set;}
	public Integer visitsPerDay {get;set;}
	
	
	public MandatoryVisitController(ApexPages.StandardController ctrl) {
		maxDays = 0;
		visitsPerDay = 8;
		Integer actualMonth = Date.today().month();
		Integer actualYear = Date.today().year();
		
		startingDate = Date.newInstance(actualYear, actualMonth, 1);
		endingDate = Date.newInstance(actualYear, actualMonth+1, 1);
		
		recordID = ctrl.getRecord().Id;

		userID = System.Userinfo.getUserId();
		accountIDs = new set<ID>(); 
			
		for(Account a : [Select Id, Name From Account Where OwnerID =: userID])
			if(!accountIDs.contains(a.ID))
				accountIDs.add(a.ID);
			 
		for(Time_Tracking__c tt : [Select Working_Days_left__c From Time_Tracking__c Where Staff_Account__c IN: accountIDs AND StartDate__c >=: startingDate AND StartDate__c <: endingDate]){
			maxDays += tt.Working_Days_left__c;
		} 
		
		outletVisitAmount = [Select Id From Outlet_Visit__c Where Account__c IN: accountIDs AND Last_Visit_Date__c >=: startingDate AND Last_Visit_Date__c <: endingDate].size();
	}
	
}