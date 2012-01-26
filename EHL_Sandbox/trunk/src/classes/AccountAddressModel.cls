public class AccountAddressModel {
    
    private String error = 'There is already a preferred address for this account.';
    private List<Reference_Data__c> countryList;
    
    public AccountAddressModel(){         
        countryList = [Select r.Id, r.Country_English__c From Reference_Data__c r where country_english__c in :SystemSettings.COUNTRYVALIDATIONLIST and RecordTypeId = '01220000000HFKm'];
        System.debug('***** countryList ' + countryList.size());
    }
    
    
    
   
   //before insert
    public void accountBeforeInsert(List<Account> accList){
        System.debug('**** AccountAddressModel accountBeforeInsert, accountsize> ' + accList.size());
        List<String> cityNameListNoZip = new List<String>();
        List<String> cityNameList = new List<String>();
        List<String> zipList = new List<String>();
        
        List<Account> accountListForBatchJob = new List<Account>();
                
        for(Account a: accList){        
            if(!SystemSettings.API_USERID.contains(UserInfo.getUserId())  && SystemSettings.COUNTRYVALIDATIONLIST.contains(a.Country_Preferred__c.toUpperCase())) {
                //only init if gui user, otherwise not needed
                System.debug('***** account to add accountBeforeInsert' + a.Zip_Code_Preferred__c + ', ' + a.City_English__c);
                if(a.Zip_Code_Preferred__c != null && a.City_English__c!=null){
                    zipList.add(a.Zip_Code_Preferred__c);
                    cityNameList.add(a.City_English__c);
                }else if(a.City_English__c!=null){  
                    cityNameListNoZip.add(a.City_English__c);
                }
            } else if (SystemSettings.API_USERID.contains(UserInfo.getUserId()) && !TriggerContext.getIsBatchjob()) {
            	//only set flag if not in batch context
                accountListForBatchJob.add(a);
            }
        }
        
        System.debug('***** accountBeforeInsert cityNameListNoZip ' + cityNameListNoZip);
        
        List<Reference_Data__c> cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList or r.City_English__c in :cityNameList) and r.City_Country__c in :countryList];
        List<Reference_Data__c> cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip or r.City_English__c in :cityNameListNoZip) and r.City_Country__c in :countryList];
        System.debug('***** accountBeforeInsert cityList ' + cityList.size());
        System.debug('***** accountBeforeInsert cityListWithNoZip ' + cityListWithNoZip.size());
       
        Boolean isValid;
        String error = '';
        try{
            for(Account a : accList){
                System.debug('***** accountBeforeInsert a ' + a.Country_Preferred__c);
                isValid = false;
                if(a.Country_Preferred__c != null && SystemSettings.COUNTRYVALIDATIONLIST.contains(a.Country_Preferred__c.toUpperCase()) && !SystemSettings.API_USERID.contains(UserInfo.getUserId())){
                    //check if valid
                    
                    //******************************** validate city with zip   
                    if(a.Zip_Code_Preferred__c != null && a.City_English__c != null){                                             
                        System.debug('***** accountBeforeInsert a validate city with zip');
                        error = a.Zip_Code_Preferred__c + '+' + a.City_English__c;
                        for(Reference_Data__c cityRef : cityList){
                            if(
                                (a.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                                (a.City_English__c.compareTo(cityRef.City_English__c) == 0 || a.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                                (a.Zip_Code_Preferred__c == cityRef.ZIP_Code__c) 
                            ){
                                isValid = true;
                                break;
                            }
                        }
                        System.debug('***** accountBeforeInsert isValid1 ' + isValid);
                    
                    //******************************** validate city without zip      
                    }else if(a.City_English__c != null){
                        System.debug('***** accountBeforeInsert a validate city without zip');
                        error = a.City_English__c;
                         for(Reference_Data__c cityRef : cityListWithNoZip){
                            if(
                                (a.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                                (a.City_English__c.compareTo(cityRef.City_English__c) == 0 || a.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                            ){
                                isValid = true;
                                break;
                            }
                        }
                        System.debug('***** accountBeforeInsert isValid2 ' + isValid);
                    }
                    System.debug('***** accountBeforeInsert isValid3 ' + isValid);
                    
                    if(!isValid){
                        a.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                    }
                } //end if in countrylist
            } //end for
            
            //set  UpdatedBySpecialUser__c
            for(Account a : accountListForBatchJob) {
                a.UpdatedBySpecialUser__c = true;
            }
            
        }catch(System.Exception e){
            System.debug('***** Exception occured accountBeforeInsert: ' + e);
        }
    }
    
    
    
    ////////*******************************************************************
    
    
    
    //after insert
    public void accountAfterInsert(List<Account> accList){
        System.debug('**** accountAfterInsert AccountAddressModel, accountsize> ' + accList.size());
        try{
            for(List<Account> accounts : [Select a.OwnerId, a.Id, a.Zip_Code_Preferred__c, a.Street_Name_Nr_Preferred__c, a.State_Preferred__c, a.PO_Box_Preferred__c, a.Country_Preferred__c, a.City_English__c, a.Address_Line_3_Preferred__c, a.Address_Line_2_Preferred__c, a.Address_Type__c from Account a where a.Id in :accList]){
               List<Address__c> addressList = new List<Address__c>();
               for(Account a : accounts){
                     //create address (only if at least city, zip or street is provided)
                    if(a.Address_Type__c != null && (a.Zip_Code_Preferred__c != null || a.Street_Name_Nr_Preferred__c != null || a.City_English__c != null)){
                        //if type of address not provided, do nothing
                        String recordId = SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE;
                        if(a.Address_Type__c == SystemSettings.ACCOUNT_BILLING_ADDRESS){
                            recordId = SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE;
                        }
                        
                        Address__c addr = new Address__c();
                        addr.Account__c = a.Id;
                        addr.Zip_Code__c = a.Zip_Code_Preferred__c; 
                        addr.Street_Name_Nr__c = a.Street_Name_Nr_Preferred__c; 
                        addr.State__c = a.State_Preferred__c;
                        addr.RecordTypeId = recordId; 
                        addr.Preferred_Address__c = true;
                        addr.PO_Box__c = a.PO_Box_Preferred__c;
                        addr.Country__c = a.Country_Preferred__c; 
                        addr.City_English__c = a.City_English__c; 
                        addr.Address_Line_3__c = a.Address_Line_3_Preferred__c; 
                        addr.Address_Line_2__c = a.Address_Line_2_Preferred__c;
                        
                        System.debug('***** accountAfterInsert AccountAddressModel Account: ' + addr.Account__c);
                        addressList.add(addr);
                    }
                   
                }  
                //insert task and address
                System.debug('**** accountAfterInsert AccountAddressModel Insert address> ' +addressList.size());               
                insert addressList;   
            }

        }catch(System.Exception e){
            System.debug('***** accountAfterInsert Exception occured: ' + e);
        }
    }
    
    
    ////////*******************************************************************
    
    
    
    //before update
    public void accountBeforeUpdate(List<Account> accList, Map<Id,Account> oldAccMap){    
        List<String> cityNameListNoZip = new List<String>();
        List<String> cityNameList = new List<String>();
        List<String> zipList = new List<String>();
      
        List<Account> accountListChanged = new List<Account>();  
        List<Account> accountListForBatchJob = new List<Account>();    
            
        try{
            for(Account a : accList){
                //if city has changed, update state and country
                Account oldAcc = oldAccMap.get(a.Id);
          
                //check if data has changed
                if( a.City_English__c != oldAcc.City_English__c
                    || a.Country_Preferred__c != oldAcc.Country_Preferred__c
                    || a.ZIP_Code_Preferred__c != oldAcc.ZIP_Code_Preferred__c        
                )
                {
                    if(!SystemSettings.API_USERID.contains(UserInfo.getUserId()) && SystemSettings.COUNTRYVALIDATIONLIST.contains(a.Country_Preferred__c.toUpperCase())){
                        accountListChanged.add(a);
                        if(a.Zip_Code_Preferred__c != null){
                            zipList.add(a.Zip_Code_Preferred__c);
                            cityNameList.add(a.City_English__c);
                        }else{
                            cityNameListNoZip.add(a.City_English__c);   
                        }
                    } else if (SystemSettings.API_USERID.contains(UserInfo.getUserId()) && !TriggerContext.getIsBatchjob()) {
            			//only set flag if not in batch context
                        accountListForBatchJob.add(a);
                    }             
                } 
            }
           
            List<Reference_Data__c> cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList or r.City_English__c in :cityNameList) and r.City_Country__c in :countryList];
            List<Reference_Data__c> cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip or r.City_English__c in :cityNameListNoZip) and r.City_Country__c in :countryList];
           
            System.debug('***** cityList ' + cityList.size());
            System.debug('***** cityListWithNoZip ' + cityListWithNoZip.size());
           
            Boolean isValid;
            String error = '';
            
            for(Account a : accountListChanged){
                //******************  validate address
                isValid = false;                          
                
                if(a.Zip_Code_Preferred__c != null && a.City_English__c != null){
                    //validate city with zip
                    error = a.Zip_Code_Preferred__c + '+' + a.City_English__c;
                    for(Reference_Data__c cityRef : cityList){
                        if(
                            (a.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                            (a.City_English__c.compareTo(cityRef.City_English__c) == 0 || a.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                            (a.Zip_Code_Preferred__c == cityRef.ZIP_Code__c) 
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }else if(a.City_English__c != null){
                     //validate city without zip
                     error = a.City_English__c;
                     for(Reference_Data__c cityRef : cityListWithNoZip){
                        if(
                            (a.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || a.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                            (a.City_English__c.compareTo(cityRef.City_English__c) == 0 || a.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }
                
                if(!isValid){
                     a.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                }
            }//end for
            
            //set  UpdatedBySpecialUser__c
            for(Account a : accountListForBatchJob) {
                a.UpdatedBySpecialUser__c = true;
            }
            
        }catch(System.Exception e){
            System.debug('***** Exception accountBeforeUpdate occured: ' + e);
        }
    }
    
    
    ////////*******************************************************************
   
   //after update
    public void accountAfterUpdate(List<Account> accList, Map<Id,Account> oldAccMap){
        //if it is in after update, we already know that city is valid, no validation nedded
        
        Boolean hasChanged = false;
        try{
            Map<Id,Account> accMap = new Map<Id,Account>(accList);
            
            List<Account> accSetToInactiveList = new List<Account>();
            List<Account> accWithChangedAddress = new List<Account>();

            for(Account a : accList){
                //if city has changed, update state and country
                Account oldAcc = oldAccMap.get(a.Id);
          
                if( a.City_English__c != oldAcc.City_English__c
                    || a.Country_Preferred__c != oldAcc.Country_Preferred__c
                    || a.ZIP_Code_Preferred__c != oldAcc.ZIP_Code_Preferred__c
                    || a.State_Preferred__c != oldAcc.State_Preferred__c
                    || a.Status__c != oldAcc.Status__c  
                    || a.Address_Type__c != oldAcc.Address_Type__c
                    || a.Street_Name_Nr_Preferred__c != oldAcc.Street_Name_Nr_Preferred__c
                    || a.PO_Box_Preferred__c != oldAcc.PO_Box_Preferred__c
                    || a.Address_Line_3_Preferred__c != oldAcc.Address_Line_3_Preferred__c
                    || a.Address_Line_2_Preferred__c != oldAcc.Address_Line_2_Preferred__c
                )
                {
                    accWithChangedAddress.add(a);          
                }
                
                if(a.Status__c == SystemSettings.STATUS_INACTIVE && (a.Status__c != oldAcc.Status__c)){
                    accSetToInactiveList.add(a);
                }
           }
           
           
            
            //get preferred address
            List<Address__c> addrList = [Select a.Account__c, a.Zip_Code__c, a.Street_Name_Nr__c, a.RecordTypeId, a.Preferred_Address__c, a.PO_Box__c, a.Country__c, a.Address_Line_3__c, a.Address_Line_2__c, a.City_English__c From Address__c a where a.Preferred_Address__c = true and a.Account__c in :accWithChangedAddress];
            Map<Id,Address__c> addrMap = new Map<Id,Address__c>();
            for(Address__c addr : addrList){
                addrMap.put(addr.Account__c, addr);
            }
            
            //get all address (needed if account is set to inactive)
            List<Address__c> addrListAll = [Select a.Account__c, a.Status__c From Address__c a where a.Account__c in :accSetToInactiveList];
           

            List<Address__c> addressList = new List<Address__c>();
            List<Address__c> addressListToInsert = new List<Address__c>();
            List<Address__c> addressListInactive = new List<Address__c>();
            
            
            //process inactive --> set address to inactive
            for(Address__c addr : addrListAll){
                if(addr.Status__c != SystemSettings.STATUS_INACTIVE){
                    addr.Status__c = SystemSettings.STATUS_INACTIVE;
                    addressListInactive.add(addr);
                }
            } 
                
                
            for(Account a : accWithChangedAddress){
                
                Account oldAccount = oldAccMap.get(a.Id);    
                
                //******************  update address
                if(addrMap.containsKey(a.Id)){
                    //address has changed, update address
                    String recordId = SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE;
                    Address__c newAddr = addrMap.get(a.Id);
                    
                    //change recordtype if address type has changed
                    if(a.Address_Type__c != oldAccount.Address_Type__c){
                        if(a.Address_Type__c == SystemSettings.ACCOUNT_BILLING_ADDRESS){
                            recordId = SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE;
                        }                        
                        newAddr.RecordTypeId = recordId;
                    }
                    
                    newAddr.Zip_Code__c = a.Zip_Code_Preferred__c; 
                    newAddr.Street_Name_Nr__c = a.Street_Name_Nr_Preferred__c; 
                    newAddr.State__c = a.State_Preferred__c;
                    newAddr.Preferred_Address__c = true;
                    newAddr.PO_Box__c = a.PO_Box_Preferred__c;
                    newAddr.Country__c = a.Country_Preferred__c;
                    newAddr.City_English__c = a.City_English__c; 
                    newAddr.Address_Line_3__c = a.Address_Line_3_Preferred__c; 
                    newAddr.Address_Line_2__c = a.Address_Line_2_Preferred__c;
                    newAddr.Country__c = a.Country_Preferred__c;
                    
                    addressList.add(newAddr);
                }else{
                    //no address, insert
                    if(a.Address_Type__c != null && (a.Zip_Code_Preferred__c != null || a.Street_Name_Nr_Preferred__c != null || a.City_English__c != null)){
                        //if type of address not provided, do nothing
                        String recordId = SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE;
                        if(a.Address_Type__c == SystemSettings.ACCOUNT_BILLING_ADDRESS){
                            recordId = SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE;
                        }
                        
                        Address__c addr = new Address__c();
                        addr.Account__c = a.Id;
                        addr.Zip_Code__c = a.Zip_Code_Preferred__c; 
                        addr.Street_Name_Nr__c = a.Street_Name_Nr_Preferred__c; 
                        addr.State__c = a.State_Preferred__c;
                        addr.RecordTypeId = recordId; 
                        addr.Preferred_Address__c = true;
                        addr.PO_Box__c = a.PO_Box_Preferred__c;
                        addr.Country__c = a.Country_Preferred__c; 
                        addr.City_English__c = a.City_English__c; 
                        addr.Address_Line_3__c = a.Address_Line_3_Preferred__c; 
                        addr.Address_Line_2__c = a.Address_Line_2_Preferred__c;
                        addressListToInsert.add(addr);
                    }
                }//end address 
                             
            }//end for
            
            System.debug('***** AccountAddressModel address to update: ' + addressList.size());
            System.debug('***** AccountAddressModel addressListInactive to update: ' + addressListInactive.size());
            update addressList;
            update addressListInactive;
            insert addressListToInsert;
            
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
    ////////*******************************************************************
    
    
    //returns true if an exception occured
    //delete all address objects
    //before delete
    public Boolean accountBeforeDelete(Map<Id,Account> accountMap){
        Boolean hasError = false;   
        try{
            List<Address__c> addressList= [Select a.Id from Address__c a where a.Account__c in :accountMap.keySet()];
            if(!addressList.isEmpty()){
                System.debug('***** AccountAddressModel address to delete: ' + addressList.size());
                delete addressList;
            }
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
            hasError = true;
        }
        return hasError;
    } 
    
    
}