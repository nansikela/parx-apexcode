public class LeadAddressHandler {
    
    //before insert
    public void insertValidationCity(List<Lead> leadList){
        try{
            List<String> cityNameListNoZip = new List<String>();
            List<String> cityNameList = new List<String>();
            List<String> zipList = new List<String>();
            
            
            List<Lead> leadListForBatchJob = new List<Lead>();
            List<Lead> leadListToValidate = new List<Lead>();
            
            System.debug('***** isBatchJob ' + TriggerContext.getIsBatchjob());
                
            for(Lead l : leadList){
            	if(!SystemSettings.API_USERID.contains(UserInfo.getUserId()) && SystemSettings.COUNTRYVALIDATIONLIST.contains(l.Country__c.toUpperCase())) {
	            	if(l.ZIP_Code__c != null){
	                    zipList.add(l.ZIP_Code__c);
	                    cityNameList.add(l.City_English__c);
	                } else{  
	                    cityNameListNoZip.add(l.City_English__c);
	                }
	                leadListToValidate.add(l);
            	} else if(SystemSettings.API_USERID.contains(UserInfo.getUserId()) && !TriggerContext.getIsBatchjob()) {
            		//only set flag if not in batch context
            		leadListForBatchJob.add(l);
            	}
            }

            List<Reference_Data__c> cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList or r.City_English__c in :cityNameList) and r.City_Country__r.Country_English__c in :SystemSettings.COUNTRYVALIDATIONLIST];
            List<Reference_Data__c> cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip or r.City_English__c in :cityNameListNoZip) and r.City_Country__r.Country_English__c in :SystemSettings.COUNTRYVALIDATIONLIST];
            System.debug('***** cityList ' + cityList.size());
            System.debug('***** cityListWithNoZip ' + cityListWithNoZip.size());
            
            Boolean isValid;
            String error = '';
            for(Lead l : leadListToValidate){
                //validate city / zip
                System.debug('***** current Lead ' + l.Id);
                isValid = false;
                if(l.ZIP_Code__c != null){
                    // compare zip code                    
                    error = l.ZIP_Code__c + '+' + l.City_English__c;  
                    for(Reference_Data__c cityRef : cityList){
                        if((l.Country__c == cityRef.City_Country__r.Country_Francais__c || l.Country__c == cityRef.City_Country__r.Country_English__c || l.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                            (l.City_English__c.compareTo(cityRef.City_English__c) == 0 || l.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                            (l.ZIP_Code__c == cityRef.ZIP_Code__c) 
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }else{
                    //nozip code provided
                    error = l.City_English__c; 
                    for(Reference_Data__c cityRef : cityListWithNoZip){
                        if(
                                (l.Country__c == cityRef.City_Country__r.Country_Francais__c || l.Country__c == cityRef.City_Country__r.Country_English__c || l.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                                (l.City_English__c.compareTo(cityRef.City_English__c) == 0 || l.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }
                //End For city
                
                if(!isValid){
                  //not valid and GUI user, show error
                  l.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                }
            }
            
            
            //set  UpdatedBySpecialUser__c
            for(Lead l : leadListForBatchJob) {
            	l.UpdatedBySpecialUser__c = true;
            }
                    
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
    //before update
    //checks that city is valid
    public void updateValidationCity(List<Lead> leadList, Map<Id,Lead> oldLeadMap){       
        try{
            List<String> cityNameListNoZip = new List<String>();
            List<String> cityNameList = new List<String>();
            List<String> zipList = new List<String>();
            
            List<Lead> leadListForBatchJob = new List<Lead>();
            List<Lead> leadListToValidate = new List<Lead>();
            
            System.debug('***** contains userId ' + SystemSettings.API_USERID.contains(UserInfo.getUserId()));
            System.debug('***** list ' + SystemSettings.API_USERID);
            System.debug('***** contains UserInfo ' + UserInfo.getUserId());
            System.debug('***** isBatchJob ' + TriggerContext.getIsBatchjob());
            
            for(Lead l : leadList){
            	if(!SystemSettings.API_USERID.contains(UserInfo.getUserId()) && SystemSettings.COUNTRYVALIDATIONLIST.contains(l.Country__c.toUpperCase())) {
	            	if(l.ZIP_Code__c != null){
	                    zipList.add(l.ZIP_Code__c);
	                    cityNameList.add(l.City_English__c);
	                } else{  
	                    cityNameListNoZip.add(l.City_English__c);
	                }
	                leadListToValidate.add(l);
            	} else if(SystemSettings.API_USERID.contains(UserInfo.getUserId()) && !TriggerContext.getIsBatchjob()) {
            		//only set flag if not in batch context
            		leadListForBatchJob.add(l);
            	}
            }
            
			List<Reference_Data__c> cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList Or r.City_English__c in :cityNameList) And r.City_Country__r.Country_English__c in :SystemSettings.COUNTRYVALIDATIONLIST];
            List<Reference_Data__c> cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip Or r.City_English__c in :cityNameListNoZip) And r.City_Country__r.Country_English__c in :SystemSettings.COUNTRYVALIDATIONLIST];
            System.debug('***** cityList ' + cityList.size());
            System.debug('***** cityListWithNoZip ' + cityListWithNoZip.size());
           
            Boolean isValid;
            String error = '';
            for(Lead l : leadListToValidate){
                //validate city / zip
                Lead oldLead =  oldLeadMap.get(l.Id);
                if( l.City_English__c != oldLead.City_English__c || l.Country__c != oldLead.Country__c || l.ZIP_Code__c != oldLead.ZIP_Code__c){
                    System.debug('***** update have to validate');
                    //validate lead address
                    isValid = false;
                    
                    if(l.ZIP_Code__c != null){
                    // compare zip code
                    	error = l.ZIP_Code__c+ '+' + l.City_English__c; 
                        for(Reference_Data__c cityRef : cityList){
                            if((l.Country__c == cityRef.City_Country__r.Country_Francais__c || l.Country__c == cityRef.City_Country__r.Country_English__c || l.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                                (l.City_English__c.compareTo(cityRef.City_English__c) == 0 || l.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                                (l.ZIP_Code__c == cityRef.ZIP_Code__c) 
                            ){
                                isValid = true;
                                break;
                            }
                        }
                    }else{
                        //nozip code provided                         
                        error = l.City_English__c; 
                        for(Reference_Data__c cityRef : cityListWithNoZip){
                            if(
                                (l.Country__c == cityRef.City_Country__r.Country_Francais__c || l.Country__c == cityRef.City_Country__r.Country_English__c || l.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                                (l.City_English__c.compareTo(cityRef.City_English__c) == 0 || l.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                            ){
                                isValid = true;
                                break;
                            }
                        }
                    }                    
                    if(!isValid){
	                  //not valid and GUI user, show error
                    	l.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                	}                    
                }
            }
            
            
            //set  UpdatedBySpecialUser__c
            for(Lead l : leadListForBatchJob) {
            	l.UpdatedBySpecialUser__c = true;
            }
            
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
   
}