public class ContactAddressEnricher{

    private String REFERENCEDATA_CITY_TYPE = SystemSettings.REFERENCEDATA_CITY_TYPE;
    
    private String LANGUAGE_FRENCH = SystemSettings.LANGUAGE_FRENCH;
    private String STATUS_COMPLETED = SystemSettings.TASK_STATUS;
    private Map<String,String> countryMap = new Map<String,String>();
    
    public ContactAddressEnricher(){
    }
    
    public void enrich(Contact c){          	
    	TriggerContext.setIsBatchjob();
    	
    	 //country map (french, english)
        List<Reference_Data__c> countryList = [Select r.Country_Francais__c, r.Country_English__c from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE];   
        
        for(Reference_Data__c r : countryList) {
            countryMap.put(r.Country_Francais__c,r.Country_English__c);
        }
        
        List<Reference_Data__c> cityList; 
        
        c.UpdatedBySpecialUser__c = false;
       
       String country = c.Country_Preferred__c.toUpperCase();
       if(countryMap.containsKey(country)) {          
            //might have french country
            if(c.Country_Preferred__c != countryMap.get(country)){
                c.Country_Preferred__c = countryMap.get(country);
            }        
        }
        
        //only check if is country that must be validated
        if(SystemSettings.COUNTRYVALIDATIONLIST.contains(c.Country_Preferred__c.toUpperCase())) {
            if(c.City_English__c != null && c.ZIP_Code_Preferred__c !=  null){
                //has zip code
                cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c = :c.ZIP_Code_Preferred__c and ( r.City_English__c = :c.City_English__c or r.City_Francais__c = :c.City_English__c) and (r.City_Country__r.Country_Code__c = :c.Country_Preferred__c or r.City_Country__r.Country_Francais__c = :c.Country_Preferred__c or  r.City_Country__r.Country_English__c = :c.Country_Preferred__c)];
            }else if(c.City_English__c != null){
                //has no zip but city
                cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_CITY_TYPE and ( r.City_English__c = :c.City_English__c or r.City_Francais__c = :c.City_English__c) and (r.City_Country__r.Country_Code__c = :c.Country_Preferred__c or r.City_Country__r.Country_Francais__c = :c.Country_Preferred__c or  r.City_Country__r.Country_English__c = :c.Country_Preferred__c)];
            }else if(c.ZIP_Code_Preferred__c != null){
                //has only zip
                cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c = :c.ZIP_Code_Preferred__c and (r.City_Country__r.Country_Code__c = :c.Country_Preferred__c or r.City_Country__r.Country_Francais__c = :c.Country_Preferred__c or  r.City_Country__r.Country_English__c = :c.Country_Preferred__c)];
            }
            
            System.debug('**** cityList size: ' +cityList.size());
            
            if(cityList.isEmpty()){            
                List<Task> taskExistList = [Select t.Id from Task t where t.WhoId = :c.Id and t.OwnerId = :c.OwnerId and t.Status != :STATUS_COMPLETED];
                
                if(taskExistList.isEmpty()){
                    Task t = new Task();
                    t.WhoId = c.Id;
                    t.OwnerId = c.OwnerId;
                    t.ActivityDate = Date.today();
                    t.Subject = 'Data Cleansing Batch';
                    t.Topic__c = 'Contact with invalid address';
                    t.Description = 'There is a contact with an invalid address. Please update this contact address accordingly.\n\nHelp:\nhttps://emea.salesforce.com/50120000000SFtp';
                    insert t;
                }
            }
        } //if country empty
        
        update c;
        
    } //end method
}