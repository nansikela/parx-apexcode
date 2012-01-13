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
        	// now we want only the available ones
	        map<ID, Outlet_Visit_Item__c> ovi_Map = new map<Id, Outlet_Visit_Item__c>();
	        set<ID> accountIDs = new set<ID>();
	        
	        for(Outlet_Visit_Item__c ovi : [select Id, Available__c, Bottle_Price__c, Bottle_Price_Special__c, Brand__c, Double_Price__c, Double_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Facing__c, Custom_Product__c, Product__c, Shelf__c, Outlet_Visit__r.Account__c, Outlet_Visit__r.Name, Outlet_Visit__r.Last_Visit_Date__c from Outlet_Visit_Item__c where ID IN: ovi_Ids AND Id NOT IN: deletedIds AND Outlet_Visit__r.Last_Visit__c=true]) {
	        	if (ovi.Available__c && !ovi_Map.containsKey(ovi.id))
	        		ovi_Map.put(ovi.id, ovi);
	        	if(!accountIDs.contains(ovi.Outlet_Visit__r.Account__c))
	        		accountIDs.add(ovi.Outlet_Visit__r.Account__c);
	        }
	        
	        
	        
	        // get existing Account Products to calculate the differences
	        // the sting key is the combination of account id and product id, because each product can only exists once for each account
	        map<String, Account_Product__c> oldAccountProducts = new map<String, Account_Product__c>();
	        for (Account_Product__c ap: [SELECT Id
	        			, Account__c
	        			, Product__c
	        			, Available__c
	        			, Facings__c
	        			, Shelf__c
	        			, Facings_Delta__c
	        			, Facings_Delta_Indicator__c
	        			, New_Listing__c
	        			, New_Listing_Date__c
	        			, Shelf_Move__c
	        			, Shelf_Move_Indicator__c
	        			FROM Account_Product__c 
	        			WHERE Account__c IN: accountIds
	        		]) {
	        	String foreignkey=String.valueOf(ap.Account__c) + String.valueOf(ap.Product__c);
	        	if (!oldAccountProducts.containsKey(foreignkey)) oldAccountProducts.put(foreignkey,ap);				
	        }
	        
	        //Iterate and map all outlet visit items to account products 
	        list<Account_Product__c> newAccountProducts = new list<Account_Product__c>();
	        for(Outlet_Visit_Item__c ovi : ovi_Map.values()) {
	        	
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
	            	ac.New_Listing__c=true;
	            	ac.New_Listing_Date__c=ovi.Outlet_Visit__r.Last_Visit_Date__c;
	            	
	            	// we have an old value
	            	String foreignkey=String.valueOf(ovi.Outlet_Visit__r.Account__c) + String.valueOf(ovi.Custom_Product__c);
	            	if (oldAccountProducts.containsKey(foreignkey)) {
	            		Account_Product__c oldAccountProduct = oldAccountProducts.get(foreignkey);
	            		// facing delta and indicator
	            		ac.Facings_Delta__c=0;
	            		if (ovi.Facing__c!=null) {
	            			ac.Facings_Delta__c=ovi.Facing__c-(oldAccountProduct.Facings__c==null?0:oldAccountProduct.Facings__c);	
	            		} else if (ovi.Facing__c==null && oldAccountProduct.Facings__c!=null) {
	            			ac.Facings_Delta__c=0-oldAccountProduct.Facings__c;
	            		}
	            		ac.Facings_Delta_Indicator__c=ac.Facings_Delta__c!=0?true:false;
	            		
	            		// shelf move and shelf move indicator
            			Double recentShelf;
            			try {
            				recentShelf=Double.valueOf(ovi.Shelf__c.substring(0,1));
            			} catch (System.Exception e) {
            				System.debug('Wrong Decimal in Shelf value');
            			}
            			Double previousShelf;
            			try {
            				previousShelf=Double.valueOf(String.valueOf(oldAccountProduct.Shelf__c==null?ovi.Shelf__c:oldAccountProduct.Shelf__c).substring(0,1));
            			} catch (System.Exception e) {
            				System.debug('Wrong Decimal in Shelf value');
            			}
            			ac.Shelf_Move__c=0;
	            		if (recentShelf!=null) {	
	            			ac.Shelf_Move__c=recentShelf-(previousShelf==null?0:previousShelf);
	            		} else if (recentShelf==null && previousShelf!=null) {
	            			ac.Shelf_Move__c=0-previousShelf;
	            		}
	            		ac.Shelf_Move_Indicator__c=ac.Shelf_Move__c!=0?true:false;
	            		// new listing will be false!
	            		ac.New_Listing__c=false;
	            		ac.New_Listing_Date__c=null;
	            	}
	            	newAccountProducts.add(ac);
	        }
	        

	        if (!oldAccountProducts.isEmpty()) {
	        	delete oldAccountProducts.values();
	        }
	        if(newAccountProducts.size() > 0){
	        	insert newAccountProducts;
	        }
        }
        
    }
}