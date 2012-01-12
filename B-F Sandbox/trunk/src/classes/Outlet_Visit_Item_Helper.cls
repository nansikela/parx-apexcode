public with sharing class Outlet_Visit_Item_Helper {
	private static final String DEU_ACCOUNT_RECORDTYPE='DEU_Outlets';
	private static final String EUR_ACCOUNT_RECORDTYPE='EUR_Outlets';
	
	public static boolean runIt = false;
    
    public static void map_to_Account_Products(list<Id> ovi_Ids, list<Id> deletedIds) {
    	   /**
		     * we run the trigger on Outlet Visit Item to update the account products.
		     *Conditions: 
		     *  + Outlet Visit Items have to been created already
		     *
		     * We want to map all necessary information from the selected outlet visit item to a account product 
		     * (custom object) for more refined product information.
		     * If the account product does not exist, it has to be created, else it has to be updated with information
		     * from the outlet visit item.
		     * 
		     * @date    21.12.2011
		     * @author  Michael Mickiewicz
		    */
		
		if(deletedIds.size() > 0) {
			list<Outlet_Visit_Item__c> items = [Select ID, Outlet_Visit__c From Outlet_Visit_Item__c Where ID IN: deletedIds];
			if(items.size() > 0) {
				Set<ID> ovIDs = new Set<ID>();
				for(Outlet_Visit_Item__c ovi : items)
					if(!ovIDs.contains(ovi.Outlet_Visit__c))
						ovIDs.add(ovi.Outlet_Visit__c);
				
				list<Account_Product__c> toDelete = [Select ID From Account_Product__c Where Last_Outlet_Visit_Number__c IN: ovIDs];
        		if(toDelete.size() > 0) {
        			delete toDelete;
        		}
			}
		}
		
        if(ovi_Ids.size() > 0) {
	        map<ID, Outlet_Visit_Item__c> ovi_Map = new map<Id, Outlet_Visit_Item__c>([select Available__c, Bottle_Price__c, Bottle_Price_Special__c, Brand__c, Double_Price__c, Double_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Facing__c, Custom_Product__c, Product__c, Shelf__c, Outlet_Visit__r.Account__c, Outlet_Visit__r.Name, Outlet_Visit__r.Last_Visit_Date__c from Outlet_Visit_Item__c where ID IN: ovi_Ids AND Id NOT IN: deletedIds]);
	        set<ID> accountIDs = new set<ID>();
	        
	        for(Outlet_Visit_Item__c ovi : ovi_Map.values()) {
	        	if(!accountIDs.contains(ovi.Outlet_Visit__r.Account__c))
	        		accountIDs.add(ovi.Outlet_Visit__r.Account__c);
	        }
	        
	        delete [Select ID From Account_Product__c Where Account__c IN: accountIDs];
	        
	        //Request all existing account products to complete the lefting records
	        //map<ID, Account_Product__c> ac_Map = new map<ID, Account_Product__c>([Select Available__c, Bottle_Price__c, Bottle_Price_Special__c, Brand__c, Double_Price__c, Double_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Facings__c, Product__c, Shelf__c, Account__c, 	Last_Outlet_Visit_Number__c, Last_Outlet_Visit_Date__c From Account_Product__c Where Account__c IN: accountIDs]);
	        
	        //Iterate and map all outlet visit items to account products 
	        list<Account_Product__c> newAccountProducts = new list<Account_Product__c>();
	        for(Outlet_Visit_Item__c ovi : ovi_Map.values()) {
	        	/*
	        	Boolean isMapped = false;
				for(Account_Product__c ac : ac_Map.values()) {
					if(ovi.Custom_Product__c == ac.Product__c) {
						system.debug('MATCHED: '+ ac.Product__c);  
	        			ac.Available__c = ovi.Available__c;
						ac.Bottle_Price__c = ovi.Bottle_Price__c;
						ac.Bottle_Price_Special__c = ovi.Bottle_Price_Special__c;
						ac.Brand__c = ovi.Brand__c;
						ac.Double_Price__c = ovi.Double_Price__c;
						ac.Double_Price_Special__c = ovi.Double_Price_Special__c;
						ac.Drink_Price__c = ovi.Drink_Price__c;
						ac.Drink_Price_Special__c = ovi.Drink_Price_Special__c;
						//ac.Facings_Delta__c=ovi.Facing__c-ac.Facings__c;
						ac.Facings__c = ovi.Facing__c;
						ac.Last_Outlet_Visit_Number__c = ovi.Outlet_Visit__c;
						ac.Last_Outlet_Visit_Date__c = ovi.Outlet_Visit__r.Last_Visit_Date__c;
						ac.Shelf__c = ovi.Shelf__c;
	            		//ac.Account__c = ovi.Outlet_Visit__r.Account__c;	
						isMapped = true;
					}
				}
				
				//If a account product is not mapped, it do not exists. So create it and map all values.
				if(!isMapped) {
				*/
					Account_Product__c ac = new Account_Product__c();
					ac.Available__c = ovi.Available__c;
					ac.Bottle_Price__c = ovi.Bottle_Price__c;
					ac.Bottle_Price_Special__c = ovi.Bottle_Price_Special__c;
					ac.Brand__c = ovi.Brand__c;
					ac.Double_Price__c = ovi.Double_Price__c;
					ac.Double_Price_Special__c = ovi.Double_Price_Special__c;
					ac.Drink_Price__c = ovi.Drink_Price__c;
					ac.Drink_Price_Special__c = ovi.Drink_Price_Special__c;
					ac.Facings__c = ovi.Facing__c;
					ac.Last_Outlet_Visit_Number__c = ovi.Outlet_Visit__c;
					ac.Last_Outlet_Visit_Date__c = ovi.Outlet_Visit__r.Last_Visit_Date__c;
					ac.Product__c = ovi.Custom_Product__c;
					ac.Shelf__c = ovi.Shelf__c;
	            	ac.Account__c = ovi.Outlet_Visit__r.Account__c;	
	            	newAccountProducts.add(ac);
				//}
	        }
	        
	        //if(!ac_Map.values().isEmpty()) {
	        //    upsert ac_Map.values();
	        //}
	        if(newAccountProducts.size() > 0){
	        	insert newAccountProducts;
	        }
        }
        
    }
}