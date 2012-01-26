public class ContactAddressModel {
    private String ADDRESS_TIME_OF_STUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
    private String ADDRESS_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE;
    private String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
    private String ADDRESS_PRIVATE_ADDRESS = SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE;
    private String ADDRESS_BILLING_ADDRESS = SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE;
    private String ADDRESS_CONTACT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_PERMANENT_RECORDTYPE;
   
    
    private String CONTACT_TIME_OF_STUDY = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
    private String CONTACT_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_STUDENT_PERMANENT_ADDRESS; //PICKLIST VALUE
    private String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE
    private String CONTACT_PRIVATE_ADDRESS = SystemSettings.CONTACT_PRIVATE_ADDRESS; //PICKLIST VALUE
    private String CONTACT_BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
    private String CONTACT_CONTACT_PERMANENT_ADDRESS = SystemSettings.CONTACT_PERMANENT_ADDRESS; //PICKLIST VALUE 
    
    
    private String REFERENCEDATA_CITY_TYPE = SystemSettings.REFERENCEDATA_CITY_TYPE;
    
    private Map<String, String> CONTACT_ADDRESSTYPEMAP = SystemSettings.CONTACT_ADDRESSTYPEMAP;
    
    
    private String SWITZERLAND_RDID;
        
    //************ NETWORK
    private String NEWTORK_RELATION_FROM = SystemSettings.NEWTORK_RELATION_FROM_EMPLOYED;
    private String ACCOUNTCONTACT_ID = SystemSettings.NEWTOWRK_ACCOUNTCONTACT_RECORDTYPE; //network RecordType
    
    
    
    public ContactAddressModel(){
        
        List<Reference_Data__c> tempList = [Select r.Id, r.Country_English__c From Reference_Data__c r where country_english__c = 'SWITZERLAND' and RecordTypeId = '01220000000HFKm' limit 1];
        if(!tempList.isEmpty()) {
            SWITZERLAND_RDID = tempList[0].Id;
        } else {
            SWITZERLAND_RDID = 'a1120000000PBB3AAO';
        }
        
        System.debug('***** SWITZERLAND_RDID ' + SWITZERLAND_RDID);   
   }
    
    
    //****************************************************************
    
    
    
    //before insert
    public void contactBeforeInsert(List<Contact> contactList){
        List<String> cityNameListNoZip = new List<String>();
        List<String> cityNameList = new List<String>();
        List<String> zipList = new List<String>();
        
        List<Contact> contactToProcess =  new List<Contact>();
        List<Contact> contactListForBatchJob =  new List<Contact>();
                
        for(Contact c: contactList){
            if(c.Country_Preferred__c != null && SystemSettings.COUNTRYVALIDATIONLIST.contains(c.Country_Preferred__c.toUpperCase()) && !SystemSettings.API_USERID.contains(UserInfo.getUserId())){
                if(c.Zip_Code_Preferred__c != null && c.City_English__c!= null){
                    zipList.add(c.Zip_Code_Preferred__c);
                    cityNameList.add(c.City_English__c);
                }else if (c.City_English__c != null){  
                    cityNameListNoZip.add(c.City_English__c);
                }
                contactToProcess.add(c);
            } else if (SystemSettings.API_USERID.contains(UserInfo.getUserId()) && !TriggerContext.getIsBatchjob()) {
            	//only set flag if not in batch context
                contactListForBatchJob.add(c);
            }
        }

        List<Reference_Data__c> cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList or r.City_English__c in :cityNameList) and r.City_Country__c = :SWITZERLAND_RDID];
        List<Reference_Data__c> cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip or r.City_English__c in :cityNameListNoZip) and r.City_Country__c = :SWITZERLAND_RDID];
        
        System.debug('***** contactBeforeInsert cityList ' + cityList.size());
        System.debug('***** contactBeforeInsert cityListWithNoZip ' + cityListWithNoZip.size());
        System.debug('***** contactBeforeInsert contactList Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = '+REFERENCEDATA_CITY_TYPE +' and (r.City_Francais__c in  ' +cityNameListNoZip +' or r.City_English__c in '+cityNameListNoZip+' and r.City_Country__c = ' +SWITZERLAND_RDID);
        System.debug('***** contactBeforeInsert contactToProcess ' + contactToProcess.size());

        Boolean isValid;
        String error = '';
        try{
             for(Contact c : contactToProcess){
                isValid = false;   
                
                //validate address                
                if(c.Zip_Code_Preferred__c != null && c.City_English__c != null){
                    //validate city with zip
                    error = c.Zip_Code_Preferred__c + '+' + c.City_English__c;     
                    for(Reference_Data__c cityRef : cityList){
                        System.debug('***** contactBeforeInsert validate with zip');
                        if(
                            (c.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                            (c.City_English__c.compareTo(cityRef.City_English__c) == 0 || c.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                            (c.Zip_Code_Preferred__c == cityRef.ZIP_Code__c) 
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }else if(c.City_English__c != null){
                     //validate city without zip
                     error = c.City_English__c;     
                     for(Reference_Data__c cityRef : cityListWithNoZip){
                        System.debug('***** contactBeforeInsert validate with no zip');
                        if(
                            (c.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                            (c.City_English__c.compareTo(cityRef.City_English__c) == 0 || c.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }
                
                if(!isValid){                    
                     c.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                }                                  
            } //end for

            //set  UpdatedBySpecialUser__c
            for(Contact c : contactListForBatchJob) {
                c.UpdatedBySpecialUser__c = true;
            }
        }catch(System.Exception e){
            System.debug('***** Exception occured contactBeforeInsert: ' + e);
        }
    }
    
    
    
    //****************************************************************
    
    
    //after insert
    public void contactAfterInsert(List<Contact> contactList){
        
        //map with all contact that must be validated
        Map<Id,Contact> contactToProcessMap = new Map<Id,Contact>([Select c.Id from Contact c where c.Id in :contactList and c.Country_Preferred__c in :SystemSettings.COUNTRYVALIDATIONLIST]);
        try{
            for(List<Contact> contacts : [Select c.OwnerId, c.Id, c.ZIP_Code_Preferred__c, c.Street_Name_Nr_Preferred__c, c.State_Preferred__c, c.PO_Box_Preferred__c, c.Country_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_3_Preferred__c, c.Address_Line_2_Preferred__c From Contact c where c.Id in :contactList]){
                //create address (only if at least city, zip or street is provided)
               List<Address__c> addressList = new List<Address__c>();
               for(Contact c : contacts){
                    if(c.Address_Type__c != null && (c.Street_Name_Nr_Preferred__c != null || c.City_English__c != null || c.Zip_Code_Preferred__c != null)){
                        //if type of address not provided, do nothing
                        String recordId = ADDRESS_TIME_OF_STUDY_ADDRESS;
                        if(CONTACT_ADDRESSTYPEMAP.containsKey(c.Address_Type__c)){
                            recordId = CONTACT_ADDRESSTYPEMAP.get(c.Address_Type__c);
                        }
                        
                        System.debug('**** contactAfterInsert ContactAddressModel recordId> ' + recordId);
                        
                        Address__c addr = new Address__c();
                        addr.Contact__c = c.Id;
                        addr.Zip_Code__c = c.Zip_Code_Preferred__c; 
                        addr.Street_Name_Nr__c = c.Street_Name_Nr_Preferred__c; 
                        addr.State__c = c.State_Preferred__c;
                        addr.RecordTypeId = recordId; 
                        addr.Preferred_Address__c = true;   
                        addr.PO_Box__c = c.PO_Box_Preferred__c;
                        addr.Country__c = c.Country_Preferred__c;
                        addr.City_English__c = c.City_English__c;
                        addr.Address_Line_3__c = c.Address_Line_3_Preferred__c;
                        addr.Address_Line_2__c = c.Address_Line_2_Preferred__c;
                        
                        addressList.add(addr);
                    }       
                } //end for
                 
                System.debug('**** contactAfterInsert ContactAddressModel Insert address> ' +addressList.size());
                insert addressList;
            }

        }catch(System.Exception e){
            System.debug('***** Exception occured contactAfterInsert: ' + e);
        }
    }
    
    
    //****************************************************************
    
    
    //before update
    //if account has changed, take address from new account and create new network
    public void contactBeforeUpdate(List<Contact> contactList, Map<Id,Contact> oldContactMap){
        try{
            //VALIDATION      
            List<String> cityNameListNoZip = new List<String>();
            List<String> cityNameList = new List<String>();
            List<String> zipList = new List<String>();
            
            //list of contact that have changed
            List<Contact> contactListChanged = new List<Contact>();
            List<Contact> contactListForBatchJob = new List<Contact>();
            
            
            for(Contact c: contactList){
                Contact oldContact = oldContactMap.get(c.Id);
          
                //check if data has changed
                if( c.City_English__c != oldContact.City_English__c
                    || c.Country_Preferred__c != oldContact.Country_Preferred__c
                    || c.ZIP_Code_Preferred__c != oldContact.ZIP_Code_Preferred__c        
                ) {
                    if(!SystemSettings.API_USERID.contains(UserInfo.getUserId()) && SystemSettings.COUNTRYVALIDATIONLIST.contains(c.Country_Preferred__c.toUpperCase())){
                        if(c.Zip_Code_Preferred__c != null && c.City_English__c != null) {
                            zipList.add(c.Zip_Code_Preferred__c);
                            cityNameList.add(c.City_English__c);
                        }
                        else if(c.City_English__c !=null) {
                            cityNameListNoZip.add(c.City_English__c);
                        }
                        contactListChanged.add(c);
                    } else if (SystemSettings.API_USERID.contains(UserInfo.getUserId()) && !TriggerContext.getIsBatchjob()) {
            			//only set flag if not in batch context
                        contactListForBatchJob.add(c);
                    }            
                } 
            }
            
            List<Reference_Data__c> cityList = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_CITY_TYPE and r.ZIP_Code__c in :zipList and (r.City_Francais__c in :cityNameList or r.City_English__c in :cityNameList) and r.City_Country__c = :SWITZERLAND_RDID];
            List<Reference_Data__c> cityListWithNoZip = [Select r.City_Country__r.Country_English__c, r.City_Country__r.Country_Code__c, r.City_Country__r.Country_Francais__c, r.City_Francais__c, r.City_English__c, r.ZIP_Code__c From Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_CITY_TYPE and (r.City_Francais__c in :cityNameListNoZip or r.City_English__c in :cityNameListNoZip) and r.City_Country__c = :SWITZERLAND_RDID];
           
            System.debug('***** cityList ' + cityList.size());
            System.debug('***** cityListWithNoZip ' + cityListWithNoZip.size());

            Boolean isValid;
            String error = '';
            for(Contact c : contactListChanged){           
                //validate address
                isValid = false;
                //only check for insert task if address has changed
                
                Boolean hasCountryToValidate = false;
                
                if(c.Zip_Code_Preferred__c != null && c.City_English__c != null){
                    //validate city with zip
                    error = c.Zip_Code_Preferred__c + '+' + c.City_English__c;        
                    for(Reference_Data__c cityRef : cityList){
                        if(
                            (c.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                            (c.City_English__c.compareTo(cityRef.City_English__c) == 0 || c.City_English__c.compareTo(cityRef.City_Francais__c) == 0) &&
                            (c.Zip_Code_Preferred__c == cityRef.ZIP_Code__c) 
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }else if(c.City_English__c != null){
                     //validate city without zip
                     error = c.City_English__c;     
                     for(Reference_Data__c cityRef : cityListWithNoZip){
                        if(
                            (c.Country_Preferred__c == cityRef.City_Country__r.Country_Francais__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_English__c || c.Country_Preferred__c == cityRef.City_Country__r.Country_Code__c) &&
                            (c.City_English__c.compareTo(cityRef.City_English__c) == 0 || c.City_English__c.compareTo(cityRef.City_Francais__c) == 0)
                        ){
                            isValid = true;
                            break;
                        }
                    }
                }
                if(!isValid){             
                	c.addError(SystemSettings.ERROR_MSG_PART1 + error + SystemSettings.ERROR_MSG_PART2);
                }
                
            }//for loop
            
            //set  UpdatedBySpecialUser__c
            for(Contact c : contactListForBatchJob) {
                c.UpdatedBySpecialUser__c = true;
            }
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
    public void contactAfterUpdate(List<Contact> contactList, Map<Id,Contact> oldContactMap){  
        try{     
            List<Contact> contactChangedAccountList = new List<Contact>();
            List<Contact> contactAccountNotChangedList = new List<Contact>();
            List<Contact> contactToUpdateList = new List<Contact>();
            
            Set<Id> accountSet = new Set<Id>();
            for(Contact c : contactList){
                //if account changed, create network and take address from account
                if(c.AccountId != oldContactMap.get(c.Id).AccountId){
                    contactChangedAccountList.add(c);
                    accountSet.add(c.AccountId);
                } else {
                    contactAccountNotChangedList.add(c);
                }
              
           }        
            System.debug('**** ContactAddressModel contactAccountNotChangedList ' + contactAccountNotChangedList.size());
            System.debug('**** ContactAddressModel contactChangedAccountList ' + contactChangedAccountList.size());
           
           
           //************************ account change  START ***********************
            List<Network__c> networklist = new List<Network__c>();
            List<Network__c> networklistAlreadyExisting = [Select n.Contact_to__c from Network__c n where n.Valid_till__c = :Date.today() and n.Relation_Type__c = :NEWTORK_RELATION_FROM and n.Contact_to__c in :contactChangedAccountList limit 200];
            Map<Id,Network__c> networkMapAlreadyExisting = new Map<Id,Network__c>();            
            for(Network__c n : networklistAlreadyExisting){
                networkMapAlreadyExisting.put(n.Contact_to__c, n);
            }
                       
            //get account
            Map<Id,Account> accountMap = new Map<Id, Account>([Select a.Zip_Code_Preferred__c, a.Street_Name_Nr_Preferred__c, a.State_Preferred__c, a.PO_Box_Preferred__c, a.Country_Preferred__c, a.City_English__c, a.Address_Line_3_Preferred__c, a.Address_Line_2_Preferred__c from Account a where a.Id in :accountSet]);
            
            
            for(Contact c : contactChangedAccountList){
                //if account changed, create network and take address from account
                //if account has changed, take address from account
                Contact cNew = new Contact(Id=c.Id); //must do this because otherwise c is not writable
                if(accountMap.containsKey(c.AccountId)){
                    Account a = accountMap.get(c.AccountId);
                    cNew.Street_Name_Nr_Preferred__c = a.Street_Name_Nr_Preferred__c;
                    cNew.PO_Box_Preferred__c = a.PO_Box_Preferred__c;
                    cNew.Address_Line_3_Preferred__c = a.Address_Line_3_Preferred__c; 
                    cNew.Address_Line_2_Preferred__c = a.Address_Line_2_Preferred__c;
                    cNew.City_English__c = a.City_English__c; 
                    cNew.Zip_Code_Preferred__c = a.Zip_Code_Preferred__c;
                    cNew.State_Preferred__c = a.State_Preferred__c;
                    cNew.Country_Preferred__c = a.Country_Preferred__c;
                }
                
                //create new Network
                //account has changed, create network with old account --> only if not already created
                if( !networkMapAlreadyExisting.containsKey(c.Id)){
                    Network__c network = new Network__c();
                    network.RecordTypeId = ACCOUNTCONTACT_ID;
                    network.Relation_Type__c = NEWTORK_RELATION_FROM; 
                    network.Contact_to__c = c.Id; 
                    network.Account_from__c = oldContactMap.get(c.Id).AccountId;
                    network.Valid_till__c = Date.today();
                    network.Valid_from__c = oldContactMap.get(c.Id).Belongs_to_this_Account_since__c;
                    networklist.add(network);
                }
                
                //update date
                cNew.Belongs_to_this_Account_since__c = Date.today();
                contactToUpdateList.add(cNew);

           }
            //************************ account change  END ***********************
            
            
            //get changed contact
            List<Contact> contactListChanged = new List<Contact>();
            for(Contact c : contactList) {
                Contact oldContact = oldContactMap.get(c.Id);
                if(c.City_English__c != oldContact.City_English__c 
                            || c.Country_Preferred__c != oldContact.Country_Preferred__c
                            || c.State_Preferred__c != oldContact.State_Preferred__c
                            || c.ZIP_Code_Preferred__c != oldContact.ZIP_Code_Preferred__c
                            || c.Address_Type__c != oldContact.Address_Type__c
                            || c.Street_Name_Nr_Preferred__c != oldContact.Street_Name_Nr_Preferred__c
                            || c.PO_Box_Preferred__c != oldContact.PO_Box_Preferred__c
                            || c.Address_Line_3_Preferred__c != oldContact.Address_Line_3_Preferred__c
                            || c.Address_Line_2_Preferred__c != oldContact.Address_Line_2_Preferred__c
                ){
                    contactListChanged.add(c);
                }
            } 
                   
            //get preferred address
            List<Address__c> addrList = [Select c.Zip_Code__c, c.Street_Name_Nr__c, c.State__c, c.RecordTypeId, c.Preferred_Address__c, c.PO_Box__c, c.Country__c, c.Contact__c, c.City_English__c, c.Address_Line_3__c, c.Address_Line_2__c From Address__c c where c.Preferred_Address__c = true and c.Contact__c in :contactAccountNotChangedList];
            Map<Id,Address__c> addrMap = new Map<Id,Address__c>();
            for(Address__c adr : addrList){
                addrMap.put(adr.Contact__c, adr);
            }
            
            List<Address__c> addressList = new List<Address__c>();
            List<Address__c> addressListToInsert = new List<Address__c>();

            for(Contact c : contactAccountNotChangedList){               
                //check if status changed to inactive
                Contact oldContact = oldContactMap.get(c.Id);  
                if(addrMap.containsKey(c.Id)){
                       //address has changed, update address
                       String recordId = ADDRESS_TIME_OF_STUDY_ADDRESS;
                       Address__c addr = addrMap.get(c.Id);
                        
                        //change recordtype if address type has changed
                       if(c.Address_Type__c != oldContact.Address_Type__c){
                            System.debug('***** ContactAddressModel contactAfterUpdate Type has changed, new: ' + c.Address_Type__c );
                            if(CONTACT_ADDRESSTYPEMAP.containsKey(c.Address_Type__c)){
                                recordId = CONTACT_ADDRESSTYPEMAP.get(c.Address_Type__c);
                            }                  
                            addr.RecordTypeId = recordId;
                        }
                        addr.Zip_Code__c = c.Zip_Code_Preferred__c; 
                        addr.Street_Name_Nr__c = c.Street_Name_Nr_Preferred__c; 
                        addr.State__c = c.State_Preferred__c;
                        addr.Preferred_Address__c = true;   
                        addr.PO_Box__c = c.PO_Box_Preferred__c;
                        addr.Country__c = c.Country_Preferred__c;
                        addr.City_English__c = c.City_English__c; 
                        addr.Address_Line_3__c = c.Address_Line_3_Preferred__c; 
                        addr.Address_Line_2__c = c.Address_Line_2_Preferred__c;
                        addressList.add(addr);
                }else{
                    //no address exist, create and insert
                    if(c.Address_Type__c != null && (c.Street_Name_Nr_Preferred__c != null || c.City_English__c != null || c.Zip_Code_Preferred__c != null)){
                        //if type of address not provided, do nothing
                        String recordId = ADDRESS_TIME_OF_STUDY_ADDRESS;
                        if(CONTACT_ADDRESSTYPEMAP.containsKey(c.Address_Type__c)){
                            recordId = CONTACT_ADDRESSTYPEMAP.get(c.Address_Type__c);
                        }
                        
                        System.debug('**** ContactAddressModel recordId> ' + recordId);
                        
                        Address__c addr = new Address__c();
                        addr.Contact__c = c.Id;
                        addr.Zip_Code__c = c.Zip_Code_Preferred__c; 
                        addr.Street_Name_Nr__c = c.Street_Name_Nr_Preferred__c; 
                        addr.State__c = c.State_Preferred__c;
                        addr.RecordTypeId = recordId; 
                        addr.Preferred_Address__c = true;   
                        addr.PO_Box__c = c.PO_Box_Preferred__c;
                        addr.Country__c = c.Country_Preferred__c;
                        addr.City_English__c = c.City_English__c;
                        addr.Address_Line_3__c = c.Address_Line_3_Preferred__c;
                        addr.Address_Line_2__c = c.Address_Line_2_Preferred__c;
                        
                        addressListToInsert.add(addr);
                    }
                }
            }//for loop
            
            System.debug('***** ContactAddressModel contactAfterUpdate addressList: ' + addressList.size());
            System.debug('***** ContactAddressModel contactAfterUpdate addressListToInsert: ' + addressListToInsert.size());
            update addressList;
            insert addressListToInsert;
            
            System.debug('***** ContactAddressModel contactAfterUpdate networklist: ' + networklist.size());
            System.debug('***** ContactAddressModel contactAfterUpdate contactToUpdateList: ' + contactToUpdateList.size());            
            insert networklist;
            update contactToUpdateList;    
  
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    //****************************************************************
    
    
    //delete all address objects
    //before delete
    public void contactBeforeDelete(Map<Id,Contact> contactMap){
        
        try{
            List<Address__c> addressList= [Select a.Id from Address__c a where a.Contact__c in :ContactMap.keySet()];
            System.debug('***** ContactAddressModel address to delete: ' + addressList.size());
            delete addressList;
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
}