public class AddressModelAccount {
  
  
    //before insert
    public void addressBeforeInsert(List<Address__c> addrList){
        try{
            Set<Id> accountSet = new Set<Id>();
            for(Address__c ad : addrList){
                accountSet.add(ad.Account__c);
            }
            
            //validation
            List<Reference_Data__c> countryList;
            List<String> cityNameListNoZip = new List<String>();
            List<String> cityNameList = new List<String>();
            List<String> zipList = new List<String>();
            List<Reference_Data__c> cityList;
            List<Reference_Data__c> cityListWithNoZip;
                    
            if(!SystemSettings.API_USERID.contains(UserInfo.getUserId())) {
                //only init if gui user, otherwise not needed
                countryList = [Select r.Id, r.Country_English__c From Reference_Data__c r where country_english__c in :SystemSettings.COUNTRYVALIDATIONLIST and RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE];
            
                for(Address__c a: addrList){ 
                    if(a.Zip_Code__c != null && a.City_English__c!=null){
                        zipList.add(a.Zip_Code__c);
                        cityNameList.add(a.City_English__c);
                    }else if(a.City_English__c!=null){  
                        cityNameListNoZip.add(a.City_English__c);
                    }
                }
                
                cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList or r.City_English__c in :cityNameList) and r.City_Country__c in :countryList];
                cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip or r.City_English__c in :cityNameListNoZip) and r.City_Country__c in :countryList];
            
            }
            System.debug('***** addressBeforeInsert cityNameListNoZip ' + cityNameListNoZip);           
            System.debug('***** addressBeforeInsert cityList ' + cityList.size());
            System.debug('***** addressBeforeInsert cityListWithNoZip ' + cityListWithNoZip.size());
           
            Boolean isValid;
            String error = '';
            //get all accounts
            Map<Id,Account> accountMap = new Map<Id,Account>([Select a.Address_Type__c, a.ZIP_Code_Preferred__c, a.Street_Name_Nr_Preferred__c, a.State_Preferred__c, a.PO_Box_Preferred__c, a.Country_Preferred__c, a.City_English__c, a.Address_Line_3_Preferred__c, a.Address_Line_2_Preferred__c, a.Id, (Select Id From Address__r where Preferred_Address__c = true) From Account a where a.Id in :accountSet]);
            for(Address__c addr : addrList){
                if(addr.Preferred_Address__c && accountMap.containsKey(addr.Account__c) && accountMap.get(addr.Account__c).Address__r.size()>0){
                    //check if account already has preferred address, if yes error
                    addr.Preferred_Address__c.addError(SystemSettings.ERROR_MSG_ACCOUNT);
                    
                } else {
                    //check if valid                    
                    if(addr.Country__c != null && SystemSettings.COUNTRYVALIDATIONLIST.contains(addr.Country__c.toUpperCase()) && !SystemSettings.API_USERID.contains(UserInfo.getUserId())){
                        isValid = false;
                        //******************************** validate city with zip   
                        if(addr.Zip_Code__c != null && addr.City_English__c != null){                                             
                            System.debug('***** addressBeforeInsert a validate city with zip');
                    		error = addr.Zip_Code__c + '+' + addr.City_English__c;   
                            for(Reference_Data__c cityRef : cityList){
                                if(
                                    (addr.Country__c == cityRef.City_Country__r.Country_Francais__c || addr.Country__c == cityRef.City_Country__r.Country_English__c || addr.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                                    (addr.City_English__c.compareTo(cityRef.City_English__c) == 0 || addr.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                                    (addr.Zip_Code__c == cityRef.ZIP_Code__c) 
                                ){
                                    isValid = true;
                                    break;
                                }
                            }
                            System.debug('***** addressBeforeInsert isValid1 ' + isValid);
                        
                        //******************************** validate city without zip      
                        }else if(addr.City_English__c != null){
                            System.debug('***** addressBeforeInsert a validate city without zip');                            
                    		error = addr.City_English__c;   
                             for(Reference_Data__c cityRef : cityListWithNoZip){
                                if(
                                    (addr.Country__c == cityRef.City_Country__r.Country_Francais__c || addr.Country__c == cityRef.City_Country__r.Country_English__c || addr.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                                    (addr.City_English__c.compareTo(cityRef.City_English__c) == 0 || addr.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                                ){
                                    isValid = true;
                                    break;
                                }
                            }
                            System.debug('***** addressBeforeInsert isValid2 ' + isValid);
                        }
                        System.debug('***** addressBeforeInsert isValid3 ' + isValid);
                        
                        if(!isValid){
                        	addr.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                        }
                    } //end if country set
                }     //end else validation   
            } //end for loop
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
     ////////*******************************************************************
    //after insert
    public void addressAfterInsert(List<Address__c> addrList){
        Boolean hasChanged = false;
        try{
            List<Account> accountToUpdate = new List<Account>();
            
            Set<Id> accountSet = new Set<Id>();
            for(Address__c ad : addrList){
                accountSet.add(ad.Account__c);
            }
            
            //get all accounts
            Map<Id,Account> accountMap = new Map<Id,Account>([Select a.Address_Type__c, a.ZIP_Code_Preferred__c, a.Street_Name_Nr_Preferred__c, a.State_Preferred__c, a.PO_Box_Preferred__c, a.Country_Preferred__c, a.City_English__c, a.Address_Line_3_Preferred__c, a.Address_Line_2_Preferred__c, a.Id, (Select Id From Address__r where Preferred_Address__c = true) From Account a where a.Id in :accountSet]);
            for(Address__c addr : addrList){
                if (addr.Preferred_Address__c && accountMap.containsKey(addr.Account__c)){
                    //update account address if is not from trigger
                    Account a = accountMap.get(addr.Account__c);
                    //check if address in account is the same
                    if(a.ZIP_Code_Preferred__c != addr.Zip_Code__c
                    || a.Street_Name_Nr_Preferred__c != addr.Street_Name_Nr__c
                    || a.PO_Box_Preferred__c != addr.PO_Box__c
                    || a.City_English__c != addr.City_English__c
                    || a.Address_Line_3_Preferred__c != addr.Address_Line_3__c
                    || a.Address_Line_2_Preferred__c != addr.Address_Line_2__c
                    || a.Country_Preferred__c != addr.Country__c
                    ){
                        hasChanged = true;  
                    }else{
                        if(addr.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE && a.Address_Type__c != SystemSettings.ACCOUNT_BILLING_ADDRESS){
                            hasChanged = true;
                        }else if (addr.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE && a.Address_Type__c != SystemSettings.ACCOUNT_SHIPPING_ADDRESS){
                            hasChanged = true;
                        }
                    }
                    System.debug('**** AddressModelAccount Account must be changed ' +  hasChanged);
                    if(hasChanged){
                        //update account
                        a.ZIP_Code_Preferred__c = addr.Zip_Code__c;
                        a.Street_Name_Nr_Preferred__c = addr.Street_Name_Nr__c;
                        a.PO_Box_Preferred__c = addr.PO_Box__c;
                        a.City_English__c = addr.City_English__c;
                        a.Address_Line_3_Preferred__c = addr.Address_Line_3__c;
                        a.Address_Line_2_Preferred__c = addr.Address_Line_2__c;
                        a.Country_Preferred__c = addr.Country__c;
                        a.State_Preferred__c = addr.State__c;
                        
                        if(addr.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE){
                            a.Address_Type__c = SystemSettings.ACCOUNT_BILLING_ADDRESS;
                        }else{
                            a.Address_Type__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
                        }
                        accountToUpdate.add(a); 
                    }
                }
            }
            
            System.debug('**** AddressModelAccount Account to update ' +  accountToUpdate.size());
            update accountToUpdate;
            
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
    
     ////////*******************************************************************
    
    //before update
    public void addressBeforeUpdate(List<Address__c> addrList, Map<Id,Address__c> oldAddrMap){
        try{           
           //validation
            List<Reference_Data__c> countryList;
            List<String> cityNameListNoZip = new List<String>();
            List<String> cityNameList = new List<String>();
            List<String> zipList = new List<String>();
            List<Reference_Data__c> cityList;
            List<Reference_Data__c> cityListWithNoZip;
            
            List<Address__c> addressListChanged = new List<Address__c>();  
            
            Set<Id> accountSet = new Set<Id>();
            for(Address__c ad : addrList){
                accountSet.add(ad.Account__c);
            }
            
            Map<Id,Account> accountMap = new Map<Id,Account>([Select a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.Address_Line_2_Preferred__c, a.Address_Line_3_Preferred__c, a.City_English__c, a.PO_Box_Preferred__c, a.Street_Name_Nr_Preferred__c, a.Id, (Select Id From Address__r where Preferred_Address__c = true) From Account a where a.Id in :accountSet]);
                
            //check that not more than one preferred       
            for(Address__c addr : addrList){
                if(addr.Preferred_Address__c && !oldAddrMap.get(addr.Id).Preferred_Address__c  && accountMap.containsKey(addr.Account__c) && accountMap.get(addr.Account__c).Address__r.size()>0){
                    addr.Preferred_Address__c.addError(SystemSettings.ERROR_MSG_ACCOUNT);
                    
                }
            }
            
            if(!SystemSettings.API_USERID.contains(UserInfo.getUserId())) {
                //only init if gui user, otherwise not needed
                countryList = [Select r.Id, r.Country_English__c From Reference_Data__c r where country_english__c in :SystemSettings.COUNTRYVALIDATIONLIST and RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE];
            
                for(Address__c a: addrList){ 
                    Address__c oldAdd = oldAddrMap.get(a.Id);
          
                    //check if data has changed
                    if( a.City_English__c != oldAdd.City_English__c
                        || a.Country__c != oldAdd.Country__c
                        || a.ZIP_Code__c != oldAdd.ZIP_Code__c        
                    )
                    {
                        if(SystemSettings.COUNTRYVALIDATIONLIST.contains(a.Country__c.toUpperCase())){
                            addressListChanged.add(a);
                            if(a.Zip_Code__c != null && a.City_English__c!=null){
                                zipList.add(a.Zip_Code__c);
                                cityNameList.add(a.City_English__c);
                            }else if(a.City_English__c!=null){  
                                cityNameListNoZip.add(a.City_English__c);
                            }
                        }               
                    }
                }
                
                cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList or r.City_English__c in :cityNameList) and r.City_Country__c in :countryList];
                cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip or r.City_English__c in :cityNameListNoZip) and r.City_Country__c in :countryList];
                
                System.debug('***** addressBeforeUpdate cityList ' + cityList.size());
                System.debug('***** addressBeforeUpdate cityListWithNoZip ' + cityListWithNoZip.size());
                
                //check if new data is valid
                Boolean isValid;      
                String error = '';  
                for(Address__c addr : addressListChanged){
                    isValid = false;
                    //******************************** validate city with zip   
                    if(addr.Zip_Code__c != null && addr.City_English__c != null){ 
                    	error = addr.Zip_Code__c + '+' + addr.City_English__c;                                
                        System.debug('***** addressBeforeInsert a validate city with zip');
                        for(Reference_Data__c cityRef : cityList){
                            if(
                                (addr.Country__c == cityRef.City_Country__r.Country_Francais__c || addr.Country__c == cityRef.City_Country__r.Country_English__c || addr.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                                (addr.City_English__c.compareTo(cityRef.City_English__c) == 0 || addr.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                                (addr.Zip_Code__c == cityRef.ZIP_Code__c) 
                            ){
                                isValid = true;
                                break;
                            }
                        }
                        System.debug('***** addressBeforeInsert isValid1 ' + isValid);
                    
                    //******************************** validate city without zip      
                    }else if(addr.City_English__c != null){
                        System.debug('***** addressBeforeInsert a validate city without zip');
                    	error = addr.City_English__c;   
                         for(Reference_Data__c cityRef : cityListWithNoZip){
                            if(
                                (addr.Country__c == cityRef.City_Country__r.Country_Francais__c || addr.Country__c == cityRef.City_Country__r.Country_English__c || addr.Country__c == cityRef.City_Country__r.Country_Code__c) &&
                                (addr.City_English__c.compareTo(cityRef.City_English__c) == 0 || addr.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                            ){
                                isValid = true;
                                break;
                            }
                        }
                        System.debug('***** addressBeforeInsert isValid2 ' + isValid);
                    }
                    System.debug('***** addressBeforeInsert isValid3 ' + isValid);
                    
                    if(!isValid){
                        addr.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                    }
                    
                }//end for loop 
            } //end if not API_USERID
           
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
     ////////*******************************************************************
     
     //after update
    public void addressAfterUpdate(List<Address__c> addrList, Map<Id,Address__c> oldAddrMap){
        try{            
            List<Account> accountToUpdate = new List<Account>();

            Set<Id> accountIdSet = new Set<Id>();

            for(Address__c ad : addrList){
                accountIdSet.add(ad.Account__c);
            }
           
            //get all parent accounts
            Map<Id,Account> accountMap = new Map<Id,Account>([Select a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.Address_Line_2_Preferred__c, a.Address_Line_3_Preferred__c, a.City_English__c, a.PO_Box_Preferred__c, a.Street_Name_Nr_Preferred__c, a.Id From Account a where a.Id in :accountIdSet]);
                        
            for(Address__c addr : addrList){
               if(accountMap.containsKey(addr.Account__c)){
                    //use preferred and unpreferred --> if unpreferred delete address data
                    Account thisAcc = accountMap.get(addr.Account__c);
                    
                    if(!addr.Preferred_Address__c && addr.Preferred_Address__c != oldAddrMap.get(addr.Id).Preferred_Address__c){
                        //preferred has changed, is not preferred anymore, delete addressdata in account
                        thisAcc.Zip_Code_Preferred__c = null;
                        thisAcc.Street_Name_Nr_Preferred__c = null;
                        thisAcc.PO_Box_Preferred__c = null;
                        thisAcc.City_English__c = null;
                        thisAcc.Address_Line_3_Preferred__c = null;
                        thisAcc.Address_Line_2_Preferred__c = null;
                        thisAcc.Country_Preferred__c = null;                        
                        thisAcc.Address_Type__c = null;
                        thisAcc.State_Preferred__c = null;
                        accountToUpdate.add(thisAcc);
                    
                    }else if(addr.Preferred_Address__c &&
                            (thisAcc.Zip_Code_Preferred__c != addr.Zip_Code__c
                                || thisAcc.Street_Name_Nr_Preferred__c != addr.Street_Name_Nr__c
                                || thisAcc.PO_Box_Preferred__c != addr.PO_Box__c
                                || thisAcc.City_English__c != addr.City_English__c
                                || thisAcc.Address_Line_3_Preferred__c != addr.Address_Line_3__c
                                || thisAcc.Address_Line_2_Preferred__c != addr.Address_Line_2__c
                                || thisAcc.Country_Preferred__c != addr.Country__c
                                || thisAcc.State_Preferred__c != addr.State__c
                                || oldAddrMap.get(addr.Id).RecordTypeId != addr.RecordTypeId
                           ))
                    {
                            //update address in account
                            System.debug('***** AddressModelAccount update date in account');
                     
                            thisAcc.Zip_Code_Preferred__c = addr.Zip_Code__c;
                            thisAcc.Street_Name_Nr_Preferred__c = addr.Street_Name_Nr__c;
                            thisAcc.PO_Box_Preferred__c = addr.PO_Box__c;
                            thisAcc.City_English__c = addr.City_English__c;
                            thisAcc.Address_Line_3_Preferred__c = addr.Address_Line_3__c;
                            thisAcc.Address_Line_2_Preferred__c = addr.Address_Line_2__c;
                            thisAcc.Country_Preferred__c = addr.Country__c;
                            thisAcc.State_Preferred__c = addr.State__c;
                            if(addr.RecordTypeId == SystemSettings.ACCOUNT_ADDRESS_BILLING_RECORDTYPE){
                                thisAcc.Address_Type__c = SystemSettings.ACCOUNT_BILLING_ADDRESS;
                            }else{
                                thisAcc.Address_Type__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
                            }
                            accountToUpdate.add(thisAcc);                        
                    }
                   
               } 
           }
           
           //update account if changed
           System.debug('***** AddressModelAccount Account to update: ' + accountToUpdate.size());
           update accountToUpdate;
           
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
     ////////*******************************************************************
    
    //delete address in account if it was preferred
    //after delete
    public void addressAfterDelete(List<Address__c> addrList){
        Set<Id> accountIdSet = new Set<Id>();
        List<Account> accountToUpdate = new List<Account>();
        for(Address__c a : addrList){
            accountIdSet.add(a.Account__c); 
        }
        
        try{
            Map<Id,Account> accountMap = new Map<Id,Account>([Select a.Address_Type__c, a.ZIP_Code_Preferred__c, a.Street_Name_Nr_Preferred__c, a.State_Preferred__c, a.PO_Box_Preferred__c, a.Country_Preferred__c, a.City_English__c, a.Address_Line_3_Preferred__c, a.Address_Line_2_Preferred__c from Account a where a.Id in :accountIdSet]);
            
            for(Address__c addr : addrList){
                if(addr.Preferred_Address__c && accountMap.containsKey(addr.Account__c)){
                    Account a = accountMap.get(addr.Account__c);
                    a.ZIP_Code_Preferred__c = null;
                    a.Street_Name_Nr_Preferred__c = null;
                    a.PO_Box_Preferred__c = null;
                    a.City_English__c = null;
                    a.Address_Line_3_Preferred__c = null;
                    a.Address_Line_2_Preferred__c = null;
                    a.Country_Preferred__c = null;                
                    a.Address_Type__c = null;
                    a.State_Preferred__c = null;
                    
                    accountToUpdate.add(a);
                }
            }
            
            update accountToUpdate;
            
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }

}