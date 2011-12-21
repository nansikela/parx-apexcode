@isTest
private class Test_Outlet_Visit_Item_Helper {
    /**
     * we run the trigger on Outlet Visit Item to update the brand depletion actuals.
     *Conditions: 
     *  +Account RecordType: EUR_Outlets (or "DEU_Outlets")
     *  +onUpdate, Brand or Facing or Channel (Account) has changed
     *
     * On delete, we have to get the event from the on Outlet Visit trigger because there is no event in the outlet Visit Item
     * We refresh always all the records of the account to make sure everything is fine for every event.
     * If the Channel is on, then Depletion actuals is 1 else it's the sum of the facing grouped by brand.
     * If the brand does not exist, it has to be created, else it has to be updated (the Depletion Actual).
     *   
     * @date    30.11.2011
     * @author  Christophe Vidal
    */
    static testMethod void myUnitTest() {
        RecordType RT = [select id from RecordType where sObjectType = 'Account' AND developerName = 'EUR_Outlets' limit 1];
        Market__c market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '1', On_Channel__c = '1');
        insert market;
        Account acc = new Account(Name = 'PARX', Market__c = market.Id, RecordTypeId = RT.Id, Channel__c = 'Off', BillingCountry = 'DE');
        insert acc;
        Contact con = new Contact(LastName = 'Roger', AccountId = acc.Id);
        insert con;
        
        Outlet_Visit__c outlet = new Outlet_Visit__c(Visit_Date__c = system.today());
        outlet.Account__c = acc.Id;
        outlet.Met_With__c = con.Id;
        insert outlet;
        
        //brand: we choose an already existing brand: Jack Daniel's
        Product__c Product = [select id from Product__c where Brand__r.Name = 'Jack Daniel\'s' limit 1];
        Product__c Product2 = [select id from Product__c where Brand__r.Name = 'Herradura' limit 1];
        
        test.startTest();
            Outlet_Visit_Item__c OVI = new Outlet_Visit_Item__c();
            OVI.Outlet_Visit__c = outlet.Id;
            OVI.Facing__c = 10;
            OVI.Custom_Product__c = Product.Id;
            insert OVI;
            list<Account_Brand__c> AccountBrand = new list<Account_Brand__c>([select id, Depletion_Actuals__c from Account_Brand__c where Account__c =: acc.Id AND Brand__r.Name = 'Jack Daniel\'s']);
            system.assertEquals(10, AccountBrand.get(0).Depletion_Actuals__c);
            
            AccountBrand.get(0).Depletion_Actuals__c = null;
            update AccountBrand;
            Outlet_Visit_Item__c OVI2 = new Outlet_Visit_Item__c();
            OVI2.Outlet_Visit__c = outlet.Id;
            OVI2.Facing__c = 20;
            OVI2.Custom_Product__c = Product.Id;
            insert OVI2;
            AccountBrand = new list<Account_Brand__c>([select id, Depletion_Actuals__c from Account_Brand__c where Account__c =: acc.Id AND Brand__r.Name = 'Jack Daniel\'s']);
            system.assertEquals(30, AccountBrand.get(0).Depletion_Actuals__c);
            
            acc.Channel__c = 'On';
            update acc;
            
            AccountBrand.get(0).Depletion_Actuals__c = null;
            update AccountBrand;
            Outlet_Visit_Item__c OVI3 = new Outlet_Visit_Item__c();
            OVI3.Outlet_Visit__c = outlet.Id;
            OVI3.Facing__c = 20;
            OVI3.Custom_Product__c = Product2.Id;
            insert OVI3;
            AccountBrand = new list<Account_Brand__c>([select id, Depletion_Actuals__c from Account_Brand__c where Account__c =: acc.Id AND Brand__r.Name = 'Jack Daniel\'s']);
            system.assertEquals(1, AccountBrand.get(0).Depletion_Actuals__c);
            AccountBrand = new list<Account_Brand__c>([select id, Depletion_Actuals__c from Account_Brand__c where Account__c =: acc.Id AND Brand__r.Name = 'Herradura']);
            system.assertEquals(1, AccountBrand.get(0).Depletion_Actuals__c);
            
            
            AccountBrand = new list<Account_Brand__c>([select id, Depletion_Actuals__c from Account_Brand__c where Account__c =: acc.Id AND Brand__r.Name = 'Jack Daniel\'s']);
            system.assertEquals(1, AccountBrand.get(0).Depletion_Actuals__c);
            delete outlet;
            AccountBrand = new list<Account_Brand__c>([select id, Depletion_Actuals__c from Account_Brand__c where Account__c =: acc.Id AND Brand__r.Name = 'Jack Daniel\'s']);
            system.assertEquals(0, AccountBrand.get(0).Depletion_Actuals__c);
        test.stopTest();
    }
}