public without sharing class updateAccountBrandAsynch {

	@future (callout=true) 
	public static void updateAccountBrandAsynch(Set<ID> myIDS)
	{
		updateAccountBrand(myIDS);
	}
	public static void updateAccountBrandSynch(Set<ID> myIDS)
	{
		updateAccountBrand(myIDS);
	}	

	public static void updateAccountBrand(Set<ID> myIDS)
	{
		Map<string,Map<string,Account_Brand__c>> myABs = new Map<string,Map<string,Account_Brand__c>>();
		List<Account_Brand__c> myUpdates = new List<Account_Brand__c>();
		for(Account_Brand__c a : [Select a.Fiscal_Year__c, a.FY_Start__c, a.FY_End__c, a.Depletion_Actuals__c, a.Brand__c, a.Account__c From Account_Brand__c a where a.Account__c in: myIDS order by a.FY_Start__c])
		{
            system.debug(a);
            if(a.FY_Start__c!=null && a.FY_End__c!=null)
            {
	            a.Depletion_Actuals__c=0;
	            Map<string,Account_Brand__c> temp = myABs.get(a.Account__c+'~'+a.Brand__c);
	            if(temp==null)
	            {
	                temp = new Map<string,Account_Brand__c>(); 
	            }
	            temp.put(a.FY_Start__c.format()+'~'+a.FY_End__c.format(),a);
	            myABs.put(a.Account__c+'~'+a.Brand__c,temp);	
            }		
		}
    	List<sObject> Totals;	
    	//code updated for product remediation added custom setting to enable and disable custom product code.
    	
    	 	Totals = [Select d.Account__c Account, d.Custom_Product__r.Brand__c Brand, d.Month_Of_Date__c Month, SUM(d.Bottles__c) Amount From Depletion__c d where d.Account__c in: myIDS GROUP BY CUBE(d.Account__c, d.Custom_Product__r.Brand__c, d.Month_Of_Date__c) order by d.Month_Of_Date__c];
        for(sObject y : Totals)
        {               
            system.debug(y);
            if(
                ((string)y.get('Account')!=null && (string)y.get('Brand')!=null && (date)y.get('Month')!=null ) //need distinct list of months 
            )
            {               
                Map<string,Account_Brand__c> temp = myABs.get((string)y.get('Account')+'~'+(string)y.get('Brand'));
                if(temp==null)
                {
                    //do NOTHING 
                    continue;
                }
                //loop thru the keys and find the matching date range
                boolean foundFlag=false;
                for(string z : temp.keyset())
                {
                	string[] myDates = z.split('~');
                	if((date)y.get('Month')>=date.parse(myDates[0]) && (date)y.get('Month')<=date.parse(myDates[1]))
                	{ 
                		Account_Brand__c myVal = temp.get(z);
                		system.debug(myVal);
                		myVal.Depletion_Actuals__c = myVal.Depletion_Actuals__c+(decimal)y.get('Amount');
                		temp.put(z,myVal);
                		myABs.put((string)y.get('Account')+'~'+(string)y.get('Brand'),temp);
                		foundFlag=true;
                		break;
                	}
                }          
            }   
		} 
        for(Map<string,Account_Brand__c> t :myABs.values() )
        {
        	myUpdates.addall(t.values());
        }
    	update myUpdates;
    }

}