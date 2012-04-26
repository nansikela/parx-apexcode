public class Outlet_Visit_Helper {
    public static boolean hasAlreadyRun = false;
    
    public static void main(set<Id> AccountIds) {
        /**
         *Trigger on all events
         *Conditions: 
         *  +Account RecordType: EUR_Outlets (or "DEU_Outlets")
         *  +Status__c is 'Complete'
         *
         * We refresh always all the rows of the account to make sure everything is fine for every event.
         * We sort the retrieved records from the Account by Visit_Date__c. The last Visit_Date__c record gets the 
         * Last_Visit__c true. The next gets the field Next_to_Last_Visit__c true and Last_Visit__c to false
         * and all other records are set back to false.
         *          
         * @date    28.11.2011
         * @author  Christophe Vidal
        **/
        map<Id, list<Outlet_Visit__c>> Outlets_Visit = new map<Id, list<Outlet_Visit__c>>();
		system.debug('Account IDs: '+AccountIds);
// Commented by Sandeep Gadicherla 2/13 - 	for(Outlet_Visit__c OV:[select Account__c, Last_Visit__c, Next_to_Last_Visit__c from Outlet_Visit__c where Status__c = 'Complete' AND Account__c IN: AccountIds AND (Account__r.RecordType.developerName = 'EUR_Outlets' OR Account__r.RecordType.developerName = 'DEU_Outlets' OR Account__r.RecordType.developerName = 'CAD_Outlets') order by Visit_Date__c desc]) {
        for(Outlet_Visit__c OV:[select Account__c, Last_Visit__c, Next_to_Last_Visit__c, Visit_Date__c from Outlet_Visit__c where Status__c = 'Complete' AND Account__c IN: AccountIds AND (Account__r.RecordType.developerName = 'EUR_Outlets' OR Account__r.RecordType.developerName = 'DEU_Outlets' OR Account__r.RecordType.developerName = 'CAD_Outlets') order by Visit_Date__c desc]) {    
            if(!Outlets_Visit.containsKey(OV.Account__c))
                Outlets_Visit.put(OV.Account__c, new list<Outlet_Visit__c>());
            Outlets_Visit.get(OV.Account__c).add(OV);
        }
        system.debug('outlets visits for last visit: ' + Outlets_Visit);
        
        if(!Outlets_Visit.isEmpty()) {
            Integer i = 0;
            for(Id AccountId:Outlets_Visit.keySet()) {
            //  if(Outlets_Visit.containsKey(OV.Account__c)) {
                    i = 0;
                    system.debug('------------ BEFORE: Account '+AccountID+' has following items: '+Outlets_Visit.get(AccountId));
                    for(Outlet_Visit__c OVHelper:Outlets_Visit.get(AccountId)) {
                        if(i == 0) {
                            //first element
                            OVHelper.Last_Visit__c = true;
                            OVHelper.Next_to_Last_Visit__c = false;
                        }
                        else if(i == 1) {
                            //second element
                            OVHelper.Last_Visit__c = false;
                            OVHelper.Next_to_Last_Visit__c = true;
                        }
                        else {
                            //for the other elements, we set all checkboxes to false 
                            OVHelper.Last_Visit__c = false;
                            OVHelper.Next_to_Last_Visit__c = false;
                        }
                        i++;
                    }
                    system.debug('------------ AFTER: Account '+AccountID+' has following items: '+Outlets_Visit.get(AccountId));
            //  } 
            }
            list<Outlet_Visit__c> Outlets_Visit_2_Update = new list<Outlet_Visit__c>();
            for(list<Outlet_Visit__c> OV:Outlets_Visit.values()) {
                Outlets_Visit_2_Update.addAll(OV);
            }
            if(!Outlets_Visit_2_Update.isEmpty()) {
                update Outlets_Visit_2_Update;
            }
        }
    }

}