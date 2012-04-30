/**
 * Testing the trigger onTimeTracking
 * goal is to test the selection of outlet visits and the reference to the time tracking record
 *
 * @date	01/11/2012
 * @author 	Jochen Schrader
**/
@isTest
private class Test_onTimeTracking {

    static testMethod void testingTimeTrackingTriggerForConnectingOutletVisits() {
		RecordType RTNS = [select id from RecordType where sObjectType = 'Account' AND developerName = 'Non_Sellable' limit 1];
		RecordType RTEUR = [select id from RecordType where sObjectType = 'Account' AND developerName = 'EUR_Outlets' limit 1];
    	Market__c market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '1', On_Channel__c = '1');
        insert market;
        Account accStaff = new Account(Name = 'PARX Staff account', Market__c = market.Id, RecordTypeId = RTNS.Id, Channel__c = 'On', BillingCountry = 'DE');
        insert accStaff;
        Account accOutlet = new Account(Name = 'PARX Outlet account', Market__c = market.Id, RecordTypeId = RTEUR.Id, Channel__c = 'On', BillingCountry = 'DE');
        insert accOutlet;
        Contact con = new Contact(LastName = 'Roger', AccountId = accOutlet.Id);
        insert con;
        
        Outlet_Visit__c outlet = new Outlet_Visit__c(Visit_Date__c = system.today());
	    outlet.Account__c = accOutlet.Id;
	    outlet.Met_With__c = con.Id;
	    insert outlet;
        
        test.startTest();
	        Time_Tracking__c tt = new Time_Tracking__c();
	        tt.Staff_Account__c=accStaff.id;
	        tt.StartDate__c=system.today();
	        insert tt;
	    test.stopTest();
	    outlet=[SELECT Id, Time_Tracking__c FROM Outlet_Visit__c WHERE id = :outlet.id];
	    system.assertEquals(tt.id,outlet.Time_Tracking__c);
    }
}