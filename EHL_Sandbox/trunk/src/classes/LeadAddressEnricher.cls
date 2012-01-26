public class LeadAddressEnricher{
	
    private Map<String,String> countryMap = new Map<String,String>();
    
    public LeadAddressEnricher(){
    }
    
    
    
    public void enrich(Lead l){
    	
    	TriggerContext.setIsBatchjob();
    	    
    	     	//country map (french, english)
        List<Reference_Data__c> countryList = [Select r.Country_Francais__c, r.Country_English__c from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE];   
        for(Reference_Data__c r : countryList) {
        	countryMap.put(r.Country_Francais__c,r.Country_English__c);
        }
        
		//reset flag
		l.UpdatedBySpecialUser__c = false;	
		
       	String country = l.Country__c.toUpperCase();
       
        
        System.debug('*** does contain country in map: '+ countryMap.containsKey(country));
		if(countryMap.containsKey(country)) {			
		 	//might have french country
		 	if(l.Country__c != countryMap.get(country)){
		 		l.Country__c = countryMap.get(country);
        		System.debug('*** set english country: '+ l.Country__c);
		 	}		 
		}
		
        List<Reference_Data__c> cityList;
        
        //only check if is country that must be validated
        
        System.debug('*** does contain country in list: '+ SystemSettings.COUNTRYVALIDATIONLIST.contains(l.Country__c.toUpperCase()));	
        if(SystemSettings.COUNTRYVALIDATIONLIST.contains(l.Country__c.toUpperCase())) {
	        if(l.City_English__c != null && l.ZIP_Code__c !=  null){
	            //has zip code
	            cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c = :l.ZIP_Code__c and ( r.City_English__c = :l.City_English__c or r.City_Francais__c = :l.City_English__c) and (r.City_Country__r.Country_Code__c = :l.Country__c or r.City_Country__r.Country_Francais__c = :l.Country__c or  r.City_Country__r.Country_English__c = :l.Country__c)];
	        }else if(l.City_English__c != null){
	            //has no zip
	            cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and ( r.City_English__c = :l.City_English__c or r.City_Francais__c = :l.City_English__c) and (r.City_Country__r.Country_Code__c = :l.Country__c or r.City_Country__r.Country_Francais__c = :l.Country__c or  r.City_Country__r.Country_English__c = :l.Country__c)];
	        }else if(l.ZIP_Code__c != null){
	        	//has only zip
	        	cityList = [Select r.ZIP_Code__c, r.State_Canton__c, r.Id, r.City_Francais__c, r.City_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Country__r.Country_English__c, r.City_Country__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c = :l.ZIP_Code__c and (r.City_Country__r.Country_Code__c = :l.Country__c or r.City_Country__r.Country_Francais__c = :l.Country__c or  r.City_Country__r.Country_English__c = :l.Country__c)];
	        }
	        
	        System.debug('**** cityList size: ' +cityList.size());
	        
	        if(cityList.isEmpty()){            
	        	List<Task> taskExistList = [Select t.WhoId, t.Id from Task t where t.WhoId = :l.Id and t.OwnerId = :l.OwnerId and t.Status != :SystemSettings.TASK_STATUS];
				
				if(taskExistList.isEmpty()){
		            Task t = new Task();
		            t.WhoId = l.Id;
		            t.OwnerId = l.OwnerId;
	                t.ActivityDate = Date.today();
		            t.Subject = SystemSettings.TASK_STATUS;
		            t.Topic__c = SystemSettings.TASK_TOPIC_LEAD;
		            t.Status = SystemSettings.TASK_STATUS;
		            t.Description = 'There is a prospect with an invalid address. Please update this prospect address accordingly.\n\nHelp:\nhttps://emea.salesforce.com/50120000000SFtp';
		            insert t;
				}
	        }
        }
        
        System.debug('*** start update lead: '+ l.id);		
        update l;
        System.debug('*** end update lead: '+ l.Id);		
    }
}