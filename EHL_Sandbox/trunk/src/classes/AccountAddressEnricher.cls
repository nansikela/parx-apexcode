public class AccountAddressEnricher{
	
    private Map<String,String> countryMap = new Map<String,String>();
        
    public AccountAddressEnricher(){
    }
    
    
    public void enrich(Account a){
    	
    	TriggerContext.setIsBatchjob();
    	
    	//country map (french, english)
        List<Reference_Data__c> countryList = [Select r.Country_Francais__c, r.Country_English__c from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE];   
        for(Reference_Data__c r : countryList) {
            countryMap.put(r.Country_Francais__c,r.Country_English__c);
        }
        
        
       List<Reference_Data__c> cityList;
        
       a.UpdatedBySpecialUser__c = false;
       
       String country = a.Country_Preferred__c.toUpperCase();
       
       if(countryMap.containsKey(country)) {          
            //might have french country
            if(a.Country_Preferred__c != countryMap.get(country)){
                a.Country_Preferred__c = countryMap.get(country);
            }        
        }
        
        //only check if is country that must be validated
        if(SystemSettings.COUNTRYVALIDATIONLIST.contains(a.Country_Preferred__c.toUpperCase())) {           
            
            //validate     
            if(a.City_English__c != null && a.ZIP_Code_Preferred__c != null){
                //has zip code
                cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c = :a.ZIP_Code_Preferred__c and ( r.City_English__c = :a.City_English__c or r.City_Francais__c = :a.City_English__c) and (r.City_Country__r.Country_Code__c = :a.Country_Preferred__c or r.City_Country__r.Country_Francais__c = :a.Country_Preferred__c or  r.City_Country__r.Country_English__c = :a.Country_Preferred__c)];
            }else if(a.City_English__c != null){
                //has no zip but city
                cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and ( r.City_English__c = :a.City_English__c or r.City_Francais__c = :a.City_English__c) and (r.City_Country__r.Country_Code__c = :a.Country_Preferred__c or r.City_Country__r.Country_Francais__c = :a.Country_Preferred__c or  r.City_Country__r.Country_English__c = :a.Country_Preferred__c)];
            }
            else if(a.ZIP_Code_Preferred__c != null){
                //has only zip
                cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c = :a.ZIP_Code_Preferred__c and (r.City_Country__r.Country_Code__c = :a.Country_Preferred__c or r.City_Country__r.Country_Francais__c = :a.Country_Preferred__c or  r.City_Country__r.Country_English__c = :a.Country_Preferred__c)];
            }
            
            System.debug('**** cityList size: ' +cityList.size());   
            
            if(cityList.isEmpty()){
                List<Task> taskExistList = [Select t.Id from Task t where t.WhatId = :a.Id and t.OwnerId = :a.OwnerId and t.Status != :SystemSettings.TASK_STATUS];
                
                if(taskExistList.isEmpty()){
                    Task t = new Task();
                    t.WhatId = a.Id;
                    t.OwnerId = a.OwnerId;
                    t.ActivityDate = Date.today();
                    t.Subject = SystemSettings.TASK_SUBJECT;
                    t.Topic__c = SystemSettings.TASK_TOPIC_ACCOUNT;
                    t.Description = 'There is an account with an invalid address. Please update this account address accordingly.\n\nHelp:\nhttps://emea.salesforce.com/50120000000SFtp';
                    insert t;
                }
            }
        } //end if country found
        
        update a;
        
    } // end method
}