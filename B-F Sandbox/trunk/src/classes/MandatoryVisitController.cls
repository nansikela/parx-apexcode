public with sharing class MandatoryVisitController {
	
    private final ID userID;
	public Outlet_Visit__c record {get;set;}
	
	Set<ID> accountIDs {get;set;}
	list<Time_Tracking__c> timecards {get;set;} 
	public Integer outletVisitAmount {get;set;}
	
	public Double maxDays {get;set;}
	public Date startingDate {get;set;}
	public Date endingDate {get;set;}

	
	public MandatoryVisitController() {
		maxDays = 0;
		Integer actualMonth = Date.today().month();
		Integer actualYear = Date.today().year();
		
		startingDate = Date.newInstance(actualYear, actualMonth, 1);
		endingDate = Date.newInstance(actualYear, actualMonth+1, 1).addDays(-1);

		userID = System.Userinfo.getUserId();

		// a user should only be able to see his outlet visits and the visits of his fellows in the role hierachy below him!
		list<Outlet_Visit__c> ovlist=new list<Outlet_Visit__c>([Select Id, OwnerId From Outlet_Visit__c Where Last_Visit_Date__c >=: startingDate AND Last_Visit_Date__c <=: endingDate]);
		outletVisitAmount = ovlist.size();
		
		set<Id> ownerids = new set<Id>();
		for (Outlet_Visit__c ov: ovlist) {
			if (!ownerids.contains(ov.OwnerId)) ownerids.add(ov.OwnerId);
		}
		
		// hope to get the right time tracking informations with this
		for(Time_Tracking__c tt : [Select Number_of_possible_Visits__c From Time_Tracking__c Where Staff_Account__r.OwnerId IN :ownerids AND StartDate__c >=: startingDate AND StartDate__c <=: endingDate]){
			maxDays += tt.Number_of_possible_Visits__c;
		} 
	}
	
	
	public static testMethod void MainTest() {
    	MandatoryVisitController ctrl = new MandatoryVisitController();
    }
}