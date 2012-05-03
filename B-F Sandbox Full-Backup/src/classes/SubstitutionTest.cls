/**
  * Unit test
  *
  * If a sales rep. must be temporarily replaced, the represenatative
  * needs read permission on the last outlet visit, to continue the
  * recording of further outlet visits till the appropriate field is 
  * not clear. 
  *      
  * @date    04/24/2012
  * @author  Michael Mickiewicz
  **/
@isTest
private class SubstitutionTest {

    static testMethod void myUnitTest() {
    	Account acc;
    	Contact con;
    	
        Profile p = [Select ID From Profile Where Name = 'DEU_LEVEL_TWO' limit 1];
        User u = [Select ID From User Where ProfileID =: p.ID AND ID <> :UserInfo.getUserId() AND isActive = true limit 1];
        User u1 = [Select ID From User Where ProfileID =: p.ID AND ID <> :UserInfo.getUserId() AND isActive = true AND ID <> :u.ID limit 1];
        
        Date visit_date = Date.newInstance( system.today().year(), system.today().month()-2, system.today().day());
        Outlet_Visit__c outlet;
        
        test.startTest();
	        system.runas(u) {
	        	RecordType RT = [select id from RecordType where sObjectType = 'Account' AND developerName = 'EUR_Outlets' limit 1];
    			Market__c market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '1', On_Channel__c = '1');
        		insert market;
        		acc = new Account(Name = 'PARX', Market__c = market.Id, RecordTypeId = RT.Id, Channel__c = 'On', BillingCountry = 'DE');
        		insert acc;
        		con = new Contact(LastName = 'Roger', AccountId = acc.Id);
        		insert con;
	        	
	        	outlet = new Outlet_Visit__c(Visit_Date__c = visit_date);
	        	outlet.Account__c = acc.Id;
	        	outlet.Met_With__c = con.Id;
	        	insert outlet;
	        	system.assertEquals(false, outlet.Last_Visit__c);
	        	system.assertEquals(false, outlet.Next_to_Last_Visit__c);
	        	
	        	Outlet_Visit_Helper.hasAlreadyRun = false;
	        	outlet.Status__c = 'Complete';
	        	update outlet;
	        	outlet = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet.Id];
	        	system.assertEquals(true, outlet.Last_Visit__c);
	        	system.assertEquals(false, outlet.Next_to_Last_Visit__c);
	        	
	        	acc.substitution__c = u.ID;
        		update acc;
	        }
	        
        	system.runas(u1) {
	        	system.debug('BEFORE: '+visit_date);
	        	visit_date = Date.newInstance( system.today().year(), system.today().month()-1, system.today().day());
	        	system.debug('AFTER: '+visit_date);
	        	Outlet_Visit_Helper.hasAlreadyRun = false;
	        	Outlet_Visit__c outlet2 = new Outlet_Visit__c(Visit_Date__c = visit_date, Account__c = acc.Id, Met_With__c = con.Id);
	        	outlet2.Status__c = 'Complete';
	        	insert outlet2;
	        	outlet = [select Last_Visit__c, Next_to_Last_Visit__c, Visit_Date__c from Outlet_Visit__c where Id =: outlet.Id];
	        	outlet2 = [select Last_Visit__c, Next_to_Last_Visit__c, Visit_Date__c from Outlet_Visit__c where Id =: outlet2.Id];
	        	system.debug(outlet.ID+': '+outlet.Visit_Date__c);
	        	system.debug(outlet2.ID+': '+outlet2.Visit_Date__c);
	        	system.assertEquals(false, outlet.Last_Visit__c);
	        	system.assertEquals(true, outlet.Next_to_Last_Visit__c);
	        	system.assertEquals(true, outlet2.Last_Visit__c);
	        	system.assertEquals(false, outlet2.Next_to_Last_Visit__c);
        	}
        		
        	system.runas(u1) {
	        	system.debug('BEFORE: '+visit_date);
	        	visit_date = Date.newInstance( system.today().year(), system.today().month()-1, system.today().day());
	        	system.debug('AFTER: '+visit_date);
	        	Outlet_Visit_Helper.hasAlreadyRun = false;
	        	Outlet_Visit__c outlet3 = new Outlet_Visit__c(Visit_Date__c = visit_date, Account__c = acc.Id, Met_With__c = con.Id);
	        	outlet3.Status__c = 'Complete';
	        	insert outlet3;
	        	
	        	acc.substitution__c = null;
        		update acc;
        	}	
        	
        	system.runas(u) {
	        	system.debug('BEFORE: '+visit_date);
	        	visit_date = Date.newInstance( system.today().year(), system.today().month()-1, system.today().day());
	        	system.debug('AFTER: '+visit_date);
	        	Outlet_Visit_Helper.hasAlreadyRun = false;
	        	Outlet_Visit__c outlet4 = new Outlet_Visit__c(Visit_Date__c = visit_date, Account__c = acc.Id, Met_With__c = con.Id);
	        	outlet4.Status__c = 'Complete';
	        	insert outlet4;
        	}	
        test.stopTest();
    }
}