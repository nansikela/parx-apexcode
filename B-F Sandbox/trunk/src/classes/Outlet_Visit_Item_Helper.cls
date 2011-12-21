public with sharing class Outlet_Visit_Item_Helper {
	private static final String DEU_ACCOUNT_RECORDTYPE='DEU_Outlets';
	private static final String EUR_ACCOUNT_RECORDTYPE='EUR_Outlets';
	
	public static boolean runIt = false;
    public static void main(list<Id> ovi_Ids, list<Id> deletedIds) {
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
		     * We care also about the mandatory product (Custom Object from the Account): if a Product is mandatory,
		     * then the account brand becomes also mandatory.
		     *
		     * @date    30.11.2011
		     * @author  Christophe Vidal
		    */
		list<Id> RTIds = new list<Id>();
        for(RecordType rt:[select id from RecordType where sObjectType = 'Account' AND (developerName = :EUR_ACCOUNT_RECORDTYPE OR developerName = :DEU_ACCOUNT_RECORDTYPE)]) {
            RTIds.add(rt.Id);
        }
    	map<Id, Outlet_Visit_Item__c> ovi_Map = new map<Id, Outlet_Visit_Item__c>([select Outlet_Visit__r.Account__c from Outlet_Visit_Item__c where Id IN: ovi_Ids AND Outlet_Visit__r.Account__r.RecordTypeId IN: RTIds]);
        list<Id> AccountIds = new list<Id>();
        for(Outlet_Visit_Item__c ovi:ovi_Map.values()) {
            AccountIds.add(ovi.Outlet_Visit__r.Account__c);
        }
        map<Id, map<Id, Account_Brand__c>> AccountBrand_Map = new map<Id, map<Id, Account_Brand__c>>();
        for(Account_Brand__c AB:[select Account__c, Account__r.Channel__c, Brand__c, Depletion_Actuals__c from Account_Brand__c where Account__c IN: AccountIds]) {
            AB.Depletion_Actuals__c = 0;
            AB.Required_Brand__c = false;
            if(!AccountBrand_Map.containsKey(AB.Account__c)) {
                AccountBrand_Map.put(AB.Account__c, new map<Id, Account_Brand__c>());
            }
            if(!AccountBrand_Map.get(AB.Account__c).containsKey(AB.Brand__c)) {
                AccountBrand_Map.get(AB.Account__c).put(AB.Brand__c,AB);
            }
        }
        map<Id, map<Id, Mandatory_Products__c>> MandatoryProduct_Map = new map<Id, map<Id, Mandatory_Products__c>>();
        for(Mandatory_Products__c MP:[select Account__c, Custom_Product__r.Brand__c from Mandatory_Products__c where Account__c IN: AccountIds AND Product_Status__c = 'Mandatory']) {
            if(!MandatoryProduct_Map.containsKey(MP.Account__c)) {
                MandatoryProduct_Map.put(MP.Account__c, new map<Id, Mandatory_Products__c>());
            }
            if(!MandatoryProduct_Map.get(MP.Account__c).containsKey(MP.Custom_Product__c)) {
                MandatoryProduct_Map.get(MP.Account__c).put(MP.Custom_Product__r.Brand__c,MP);
            }
        }
        
        
        //we get the full map of the account without forgetting to remove the deleted ovi.
        ovi_Map = new map<Id, Outlet_Visit_Item__c>([select Custom_Product__r.Brand__c, facing__c, Outlet_Visit__r.Account__c from Outlet_Visit_Item__c where Outlet_Visit__r.Account__c IN: AccountIds AND Id NOT IN: deletedIds]);
        
        for(Outlet_Visit_Item__c ovi:ovi_Map.values()) {
            if(AccountBrand_Map.containsKey(ovi.Outlet_Visit__r.Account__c) && AccountBrand_Map.get(ovi.Outlet_Visit__r.Account__c).containsKey(ovi.Custom_Product__r.Brand__c)) {
                //we have just to update the existing Account Brand.
                Account_Brand__c AB = AccountBrand_Map.get(ovi.Outlet_Visit__r.Account__c).get(ovi.Custom_Product__r.Brand__c);
                if(AB.Account__r.Channel__c == 'on') {
                    AB.Depletion_Actuals__c = 1;
                }
                else {
                    //channel is off
                    if(AB.Depletion_Actuals__c==null)
                        AB.Depletion_Actuals__c = 0;
                    AB.Depletion_Actuals__c += ovi.Facing__c!=null?ovi.Facing__c:0;
                }
                if(MandatoryProduct_Map.containsKey(ovi.Outlet_Visit__r.Account__c) && MandatoryProduct_Map.get(ovi.Outlet_Visit__r.Account__c).containsKey(ovi.Custom_Product__r.Brand__c))
                    AB.Required_Brand__c = true;
                AccountBrand_Map.get(ovi.Outlet_Visit__r.Account__c).put(ovi.Custom_Product__r.Brand__c, AB);
            }
            else {
                //we have to create a new brand
                Account_Brand__c AB = new Account_Brand__c();
                AB.Account__c = ovi.Outlet_Visit__r.Account__c;
                AB.Brand__c = ovi.Custom_Product__r.Brand__c;
                if(AB.Account__r.Channel__c == 'on') {
                    AB.Depletion_Actuals__c = 1;
                }
                else {
                    //channel is off
                    AB.Depletion_Actuals__c = ovi.Facing__c;
                }
                if(!AccountBrand_Map.containsKey(AB.Account__c)) {
                    AccountBrand_Map.put(AB.Account__c, new map<Id, Account_Brand__c>());
                }
                if(MandatoryProduct_Map.containsKey(ovi.Outlet_Visit__r.Account__c) && MandatoryProduct_Map.get(ovi.Outlet_Visit__r.Account__c).containsKey(ovi.Custom_Product__r.Brand__c))
                    AB.Required_Brand__c = true;
                AccountBrand_Map.get(AB.Account__c).put(AB.Brand__c,AB);
            }  
        }
        list<Account_Brand__c> Account_Brands = new list<Account_Brand__c>();
        for(map<Id, Account_Brand__c> helper1:AccountBrand_Map.values()) {
            for(Account_Brand__c AB:helper1.values()) {
                Account_Brands.add(AB);
            }
        }
        if(!Account_Brands.isEmpty()) {
            upsert Account_Brands;
        }
    }
}