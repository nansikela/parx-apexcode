@isTest
private class Test_Outlet_Visit_Item_Helper {
    
     /**
     * we run the trigger on Outlet Visit Item to update the account products.
     *Conditions: 
     *  + outlet visit items have to been created!
     *
     * On delete, we have to get the event from the on Outlet Visit trigger because there is no event in the outlet Visit Item
     * We refresh always all the records of the account to make sure everything is fine for every event.
     * 
     * @date    09.01.2012
     * @author  Michael Mickiewicz
    */
    static testMethod void accountProductTest() {
        UnitTestUtilities mgr = new UnitTestUtilities();
        mgr.init();
        
        Outlet_Visit__c outlet = new Outlet_Visit__c(Visit_Date__c = system.today());
        outlet.Account__c = mgr.contact1.AccountId;
        outlet.Met_With__c = mgr.contact1.Id;
        outlet.Last_Visit__c=true;
        insert outlet; 
         
        system.debug(outlet.Account__c);
        
            Outlet_Visit_Item__c OVI = new Outlet_Visit_Item__c(Available__c = true, Outlet_Visit__c = outlet.Id, Custom_Product__c = mgr.product1.Id);
            OVI.Facing__c = 10;
            insert OVI;
            
            for(Account_Product__c ap : [select id, Brand__c, Product__c, Available__c, Account__c, Last_Outlet_Visit_Number__c  from Account_Product__c where Product__c =: OVI.Custom_Product__c]) {
                system.assertEquals(OVI.Outlet_Visit__c, ap.Last_Outlet_Visit_Number__c);
                system.assertEquals(OVI.Custom_Product__c, ap.Product__c);
                system.assertEquals(OVI.Available__c, ap.Available__c);
            }
            
            OVI.Facing__c = 20;
            OVI.Bottle_Price__c = 15;
            OVI.Shelf__c='3 - shelf';
            update OVI;
            
            for(Account_Product__c ap : [select id, Brand__c, Product__c, Available__c, Account__c, Last_Outlet_Visit_Number__c from Account_Product__c where Last_Outlet_Visit_Number__c =: outlet.Id]) {
                system.assertEquals(OVI.Outlet_Visit__c, ap.Last_Outlet_Visit_Number__c);
                system.assertEquals(OVI.Custom_Product__c, ap.Product__c);
                system.assertEquals(OVI.Available__c, ap.Available__c);
            }
            
            delete OVI;
            
    }
    
    static testMethod void onAccountTest() {
        list<Id> RTIds = new list<Id>();
          for(RecordType rt:[select id from RecordType where sObjectType = 'Account' AND (developerName = 'EUR_Outlets' OR developerName = 'DEU_Outlets')]) {
            RTIds.add(rt.Id);
          }
        // testing channel change
        Market__c market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '2', On_Channel__c = '3');
        
        insert market;
        list<Account> accounts=new list<Account>();
        
        for (Id rtid: RTIds) {
            accounts.add( new Account(Name = 'Test Account 1', Market__c = market.Id, Channel__c = 'Off', BillingCountry = 'DE', RecordTypeId=rtid));
        }
        insert accounts;
        for (Account a:accounts) {
            a.Channel__c='On';
        }
        test.startTest();
        update accounts;
        test.stopTest();
    }
}