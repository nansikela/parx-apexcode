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
 * @date	28.11.2011
 * @author 	Christophe Vidal
**/
@isTest
private class Test_Outlet_Visit_Helper {

    static testMethod void TestSettingOfLastVisit() {
    	RecordType RT = [select id from RecordType where sObjectType = 'Account' AND developerName = 'EUR_Outlets' limit 1];
    	Market__c market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '1', On_Channel__c = '1');
        insert market;
        Account acc = new Account(Name = 'PARX', Market__c = market.Id, RecordTypeId = RT.Id, Channel__c = 'On', BillingCountry = 'DE');
        insert acc;
        Contact con = new Contact(LastName = 'Roger', AccountId = acc.Id);
        insert con;
        
        test.startTest();
	        Outlet_Visit__c outlet = new Outlet_Visit__c(Visit_Date__c = system.today());
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
	        
	        Outlet_Visit_Helper.hasAlreadyRun = false;
	        Outlet_Visit__c outlet2 = new Outlet_Visit__c(Visit_Date__c = system.today().addMonths(1));
	        outlet2.Account__c = acc.Id;
	        outlet2.Met_With__c = con.Id;
	        outlet2.Status__c = 'Complete';
	        insert outlet2;
	        outlet = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet.Id];
	        outlet2 = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet2.Id];
	        system.assertEquals(false, outlet.Last_Visit__c);
	        system.assertEquals(true, outlet.Next_to_Last_Visit__c);
	        system.assertEquals(true, outlet2.Last_Visit__c);
	        system.assertEquals(false, outlet2.Next_to_Last_Visit__c);
	        
	        Outlet_Visit_Helper.hasAlreadyRun = false;
	        Outlet_Visit__c outlet3 = new Outlet_Visit__c(Visit_Date__c = system.today().addMonths(2));
	        outlet3.Account__c = acc.Id;
	        outlet3.Met_With__c = con.Id;
	        outlet3.Status__c = 'Complete';
	        insert outlet3;
	        outlet = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet.Id];
	        outlet2 = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet2.Id];
	        outlet3 = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet3.Id];
	        system.assertEquals(false, outlet.Last_Visit__c);
	        system.assertEquals(false, outlet.Next_to_Last_Visit__c);
	        system.assertEquals(false, outlet2.Last_Visit__c);
	        system.assertEquals(true, outlet2.Next_to_Last_Visit__c);
	        system.assertEquals(true, outlet3.Last_Visit__c);
	        system.assertEquals(false, outlet3.Next_to_Last_Visit__c);
	        
	        Outlet_Visit_Helper.hasAlreadyRun = false;
	        delete outlet2;
	        outlet = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet.Id];
	        outlet3 = [select Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Id =: outlet3.Id];
	        system.assertEquals(false, outlet.Last_Visit__c);
	        system.assertEquals(true, outlet.Next_to_Last_Visit__c);
	        system.assertEquals(true, outlet3.Last_Visit__c);
	        system.assertEquals(false, outlet3.Next_to_Last_Visit__c);
        test.stopTest();
    }
}