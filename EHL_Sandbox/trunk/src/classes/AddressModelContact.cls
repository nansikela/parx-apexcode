public class AddressModelContact {
    
    private String ADDRESS_TIME_OF_STUDY = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
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
    
        
    public AddressModelContact(){
    }
    
    
    //before insert
    public void addressBeforeInsert(List<Address__c> addrList){
        try{
            Boolean hasChanged = false;
            List<Contact> contactToUpdate = new List<Contact>();
            
            Set<Id> contactSet = new Set<Id>();
            for(Address__c c : addrList){
                contactSet.add(c.Contact__c);
            }
           
            //get all contacts
            Map<Id,Contact> contactMap = new Map<Id,Contact>([Select c.ZIP_Code_Preferred__c, c.Street_Name_Nr_Preferred__c, c.State_Preferred__c, c.PO_Box_Preferred__c, c.Country_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_3_Preferred__c, c.Address_Line_2_Preferred__c, c.Id, (Select Id From Address__r where Preferred_Address__c = true) From Contact c where c.Id in :contactSet]);
            
            for(Address__c addr : addrList){
                //check if contact already has preferred addr
                if(addr.Preferred_Address__c && contactMap.containsKey(addr.Contact__c) && contactMap.get(addr.Contact__c).Address__r.size()>0){
                    
                    addr.Preferred_Address__c.addError(SystemSettings.ERROR_MSG_CONTACT);
                        
                }else if(addr.Preferred_Address__c && contactMap.containsKey(addr.Contact__c)){
                    
                    Contact c = contactMap.get(addr.Contact__c);
                    //check if address in contact is the same
                    if(c.Street_Name_Nr_Preferred__c != addr.Street_Name_Nr__c
                    || c.PO_Box_Preferred__c != addr.PO_Box__c
                    || c.City_English__c != addr.City_English__c
                    || c.Address_Line_3_Preferred__c != addr.Address_Line_3__c
                    || c.Address_Line_2_Preferred__c != addr.Address_Line_2__c
                    || c.Country_Preferred__c != addr.Country__c
                    ){
                        hasChanged = true;
                    }
                    if(addr.RecordTypeId == ADDRESS_TIME_OF_STUDY && c.Address_Type__c != CONTACT_TIME_OF_STUDY){
                        c.Address_Type__c = CONTACT_TIME_OF_STUDY;
                        hasChanged = true;
                    }else if (addr.RecordTypeId == ADDRESS_STUDENT_PERMANENT_ADDRESS && c.Address_Type__c != CONTACT_STUDENT_PERMANENT_ADDRESS){
                        c.Address_Type__c = CONTACT_STUDENT_PERMANENT_ADDRESS;
                        hasChanged = true;
                    }else if (addr.RecordTypeId == ADDRESS_BUSINESS_ADDRESS && c.Address_Type__c != CONTACT_BUSINESS_ADDRESS){
                        c.Address_Type__c = CONTACT_BUSINESS_ADDRESS;
                        hasChanged = true;
                    }else if (addr.RecordTypeId == ADDRESS_PRIVATE_ADDRESS && c.Address_Type__c != CONTACT_PRIVATE_ADDRESS){
                        c.Address_Type__c = CONTACT_PRIVATE_ADDRESS;
                        hasChanged = true;
                    }else if (addr.RecordTypeId == ADDRESS_BILLING_ADDRESS && c.Address_Type__c != CONTACT_BILLING_ADDRESS){
                        c.Address_Type__c = CONTACT_BILLING_ADDRESS;
                        hasChanged = true;
                    }else if (addr.RecordTypeId == ADDRESS_CONTACT_PERMANENT_ADDRESS && c.Address_Type__c != CONTACT_CONTACT_PERMANENT_ADDRESS){
                        c.Address_Type__c = CONTACT_CONTACT_PERMANENT_ADDRESS;
                        hasChanged = true;
                    }
                    
                    
                    if(hasChanged){
                        //update contact --> address type already handled
                        c.Zip_Code_Preferred__c = addr.Zip_Code__c;
                        c.Street_Name_Nr_Preferred__c = addr.Street_Name_Nr__c;
                        c.PO_Box_Preferred__c = addr.PO_Box__c;
                        c.City_English__c = addr.City_English__c;
                        c.Address_Line_3_Preferred__c = addr.Address_Line_3__c;
                        c.Address_Line_2_Preferred__c = addr.Address_Line_2__c;
                        c.Country_Preferred__c = addr.Country__c;
                        c.State_Preferred__c = addr.State__c;
                        contactToUpdate.add(c); 
                    }
                }
            }
            
            System.debug('***** AddressModelContact addressBeforeInsert ' + contactToUpdate.size());
            TriggerContext.setContactIsUpdated();
            update contactToUpdate;
            
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
   //after insert
    public void addressAfterInsert(List<Address__c> addrList){
        try{
            Boolean hasChanged = false;
            List<Contact> contactToUpdate = new List<Contact>();
            
            Set<Id> contactSet = new Set<Id>();
            for(Address__c a : addrList){
                if(a.Preferred_Address__c) {
                    contactSet.add(a.Contact__c);
                }
            }
            System.debug('***** addressAfterInsert contactSet ' + contactSet.size());
           
            //get all contacts
            Map<Id,Contact> contactMap = new Map<Id,Contact>([Select c.ZIP_Code_Preferred__c, c.Street_Name_Nr_Preferred__c, c.State_Preferred__c, c.PO_Box_Preferred__c, c.Country_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_3_Preferred__c, c.Address_Line_2_Preferred__c, c.Id From Contact c where c.Id in :contactSet]);
           
            for(Address__c addr : addrList){
                
                System.debug('***** addressAfterInsert Preferred_Address__c ' + addr.Preferred_Address__c);             
                System.debug('***** addressAfterInsert contains ' + contactMap.containsKey(addr.Contact__c));
               if(addr.Preferred_Address__c && contactMap.containsKey(addr.Contact__c)) {
                    Contact thisContact = contactMap.get(addr.Contact__c);
                    thisContact.Zip_Code_Preferred__c = addr.Zip_Code__c;
                    thisContact.Street_Name_Nr_Preferred__c = addr.Street_Name_Nr__c;
                    thisContact.PO_Box_Preferred__c = addr.PO_Box__c;
                    thisContact.City_English__c = addr.City_English__c;
                    thisContact.Address_Line_3_Preferred__c = addr.Address_Line_3__c;
                    thisContact.Address_Line_2_Preferred__c = addr.Address_Line_2__c;
                    thisContact.Country_Preferred__c = addr.Country__c;
                    thisContact.State_Preferred__c = addr.State__c;
                    
                    thisContact.Address_Type__c = SystemSettings.ADDRESS_CONTACTTYPEMAP.get(addr.RecordTypeId);
                    if(thisContact.Address_Type__c == null) {
                        //not found, should not happen
                        thisContact.Address_Type__c = CONTACT_TIME_OF_STUDY;
                    }                    
                    contactToUpdate.add(thisContact);   
               }               
            }
            
            
            System.debug('***** AddressModelContact addressAfterInsert ' + contactToUpdate.size());
            TriggerContext.setContactIsUpdated();
            update contactToUpdate;
            
        }catch(System.Exception e){
            System.debug('***** Exception occured addressAfterInsert: ' + e);
        }
    }
    
    //before update
    public void addressBeforeUpdate(List<Address__c> addrList, Map<Id,Address__c> oldAddrMap){
        try{            
            Set<Id> contactIdSet = new Set<Id>();
            List<Contact> contactToUpdate = new List<Contact>();
                
            for(Address__c c : addrList){
                contactIdSet.add(c.Contact__c);
            }
            //get all parent contact
            Map<Id,Contact> contactMap = new Map<Id,Contact>([Select c.ZIP_Code_Preferred__c, c.Street_Name_Nr_Preferred__c, c.PO_Box_Preferred__c, c.City_English__c, c.Address_Line_3_Preferred__c, c.Address_Line_2_Preferred__c, c.Country_Preferred__c, c.State_Preferred__c, c.Id, (Select Id From Address__r where Preferred_Address__c = true) From Contact c where c.Id in :contactIdSet]);
            
            for(Address__c addr : addrList){
                if(addr.Preferred_Address__c && !oldAddrMap.get(addr.Id).Preferred_Address__c  && contactMap.containsKey(addr.Contact__c) && contactMap.get(addr.Contact__c).Address__r.size()>0){
                    //was not preferred but now is
                    //check if already prefered addr exist, if yes error
                    addr.Preferred_Address__c.addError(SystemSettings.ERROR_MSG_CONTACT);
                    
                }else if(contactMap.containsKey(addr.Contact__c)){     
                    //use preferred and unpreferred --> if unpreferred delete address data
                    Contact thisContact = contactMap.get(addr.Contact__c);
                    if(!addr.Preferred_Address__c && (addr.Preferred_Address__c != oldAddrMap.get(addr.Id).Preferred_Address__c)){
                        //preferred has changed, is not preferred anymore, delete addressdata in contact
                        thisContact.Zip_Code_Preferred__c = null;
                        thisContact.Street_Name_Nr_Preferred__c = null;
                        thisContact.PO_Box_Preferred__c = null;
                        thisContact.City_English__c = null;
                        thisContact.Address_Line_3_Preferred__c = null;
                        thisContact.Address_Line_2_Preferred__c = null;
                        thisContact.Country_Preferred__c = null;
                        thisContact.Address_Type__c = null;
                        thisContact.State_Preferred__c = null;
                        contactToUpdate.add(thisContact);
                    
                    }else if(addr.Preferred_Address__c &&
                        (thisContact.Zip_Code_Preferred__c != addr.Zip_Code__c
                            || thisContact.Street_Name_Nr_Preferred__c != addr.Street_Name_Nr__c
                            || thisContact.PO_Box_Preferred__c != addr.PO_Box__c
                            || thisContact.City_English__c != addr.City_English__c
                            || thisContact.Address_Line_3_Preferred__c != addr.Address_Line_3__c
                            || thisContact.Address_Line_2_Preferred__c != addr.Address_Line_2__c
                            || thisContact.Country_Preferred__c != addr.Country__c
                            || thisContact.State_Preferred__c != addr.State__c
                            || oldAddrMap.get(addr.Id).RecordTypeId != addr.RecordTypeId
                       )
                    ){
                        //update address in contact
                        System.debug('***** AddressModelContact update date in contact');
                        
                        thisContact.Zip_Code_Preferred__c = addr.Zip_Code__c;
                        thisContact.Street_Name_Nr_Preferred__c = addr.Street_Name_Nr__c;
                        thisContact.PO_Box_Preferred__c = addr.PO_Box__c;
                        thisContact.City_English__c = addr.City_English__c;
                        thisContact.Address_Line_3_Preferred__c = addr.Address_Line_3__c;
                        thisContact.Address_Line_2_Preferred__c = addr.Address_Line_2__c;
                        thisContact.Country_Preferred__c = addr.Country__c;
                        thisContact.State_Preferred__c = addr.State__c;
                        
                        thisContact.Address_Type__c = SystemSettings.ADDRESS_CONTACTTYPEMAP.get(addr.RecordTypeId);
                        if(thisContact.Address_Type__c == null) {
                            //not found, should not happen
                            thisContact.Address_Type__c = CONTACT_TIME_OF_STUDY;
                        }
                        
                        contactToUpdate.add(thisContact);   
                    }
                }              
           }
           
           System.debug('***** AddressModelContact addressBeforeUpdate ' + contactToUpdate.size());
           update contactToUpdate;
                
           
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
    //after update
    public void addressAfterUpdate(List<Address__c> addrList, Map<Id,Address__c> oldAddrMap){
        try{            
            Set<Id> contactIdSet = new Set<Id>();
            List<Contact> contactToUpdate = new List<Contact>();
                
            for(Address__c c : addrList){
                contactIdSet.add(c.Contact__c);
            }
            //get all parent contact
            Map<Id,Contact> contactMap = new Map<Id,Contact>([Select c.ZIP_Code_Preferred__c, c.Street_Name_Nr_Preferred__c, c.PO_Box_Preferred__c, c.City_English__c, c.Address_Line_3_Preferred__c, c.Address_Line_2_Preferred__c, c.Country_Preferred__c, c.State_Preferred__c, c.Id, (Select Id From Address__r where Preferred_Address__c = true) From Contact c where c.Id in :contactIdSet]);
            
            for(Address__c addr : addrList){
                if(addr.Preferred_Address__c && !oldAddrMap.get(addr.Id).Preferred_Address__c  && contactMap.containsKey(addr.Contact__c) && contactMap.get(addr.Contact__c).Address__r.size()>0){
                    //was not preferred but now is
                    //check if already prefered addr exist, if yes error
                    addr.Preferred_Address__c.addError(SystemSettings.ERROR_MSG_CONTACT);
                    
                }else if(contactMap.containsKey(addr.Contact__c)){     
                    //use preferred and unpreferred --> if unpreferred delete address data
                    Contact thisContact = contactMap.get(addr.Contact__c);
                    if(!addr.Preferred_Address__c && (addr.Preferred_Address__c != oldAddrMap.get(addr.Id).Preferred_Address__c)){
                        //preferred has changed, is not preferred anymore, delete addressdata in contact
                        thisContact.Zip_Code_Preferred__c = null;
                        thisContact.Street_Name_Nr_Preferred__c = null;
                        thisContact.PO_Box_Preferred__c = null;
                        thisContact.City_English__c = null;
                        thisContact.Address_Line_3_Preferred__c = null;
                        thisContact.Address_Line_2_Preferred__c = null;
                        thisContact.Country_Preferred__c = null;
                        thisContact.Address_Type__c = null;
                        thisContact.State_Preferred__c = null;
                        contactToUpdate.add(thisContact);
                    
                    }else if(addr.Preferred_Address__c &&
                        (thisContact.Zip_Code_Preferred__c != addr.Zip_Code__c
                            || thisContact.Street_Name_Nr_Preferred__c != addr.Street_Name_Nr__c
                            || thisContact.PO_Box_Preferred__c != addr.PO_Box__c
                            || thisContact.City_English__c != addr.City_English__c
                            || thisContact.Address_Line_3_Preferred__c != addr.Address_Line_3__c
                            || thisContact.Address_Line_2_Preferred__c != addr.Address_Line_2__c
                            || thisContact.Country_Preferred__c != addr.Country__c
                            || thisContact.State_Preferred__c != addr.State__c
                            || oldAddrMap.get(addr.Id).RecordTypeId != addr.RecordTypeId
                       )
                    ){
                        //update address in contact
                        System.debug('***** AddressModelContact update date in contact');
                        
                        thisContact.Zip_Code_Preferred__c = addr.Zip_Code__c;
                        thisContact.Street_Name_Nr_Preferred__c = addr.Street_Name_Nr__c;
                        thisContact.PO_Box_Preferred__c = addr.PO_Box__c;
                        thisContact.City_English__c = addr.City_English__c;
                        thisContact.Address_Line_3_Preferred__c = addr.Address_Line_3__c;
                        thisContact.Address_Line_2_Preferred__c = addr.Address_Line_2__c;
                        thisContact.Country_Preferred__c = addr.Country__c;
                        thisContact.State_Preferred__c = addr.State__c;
                        
                        thisContact.Address_Type__c = SystemSettings.ADDRESS_CONTACTTYPEMAP.get(addr.RecordTypeId);
                        if(thisContact.Address_Type__c == null) {
                            //not found, should not happen
                            thisContact.Address_Type__c = CONTACT_TIME_OF_STUDY;
                        }
                        
                        contactToUpdate.add(thisContact);   
                    }
                }              
           }
           
           System.debug('***** AddressModelContact addressAfterUpdate ' + contactToUpdate.size());
           update contactToUpdate;
                
           
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    //delete address in contact if it was preferred
    //after delete
    public void addressAfterDelete(List<Address__c> addrList){
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> contactToUpdate = new List<Contact>();
        for(Address__c c : addrList){
            contactIdSet.add(c.Contact__c); 
        }
        
        try{
            Map<Id,Contact> contactMap = new Map<Id,Contact>([Select c.ZIP_Code_Preferred__c, c.Street_Name_Nr_Preferred__c, c.State_Preferred__c, c.PO_Box_Preferred__c, c.Country_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_3_Preferred__c, c.Address_Line_2_Preferred__c From Contact c where c.Id in :contactIdSet]);
            
            for(Address__c addr : addrList){
                if(addr.Preferred_Address__c && contactMap.containsKey(addr.Contact__c)){
                    Contact c = contactMap.get(addr.Contact__c);
                    c.Zip_Code_Preferred__c = null;
                    c.Street_Name_Nr_Preferred__c = null;
                    c.PO_Box_Preferred__c = null;
                    c.PO_Box_Preferred__c = null;
                    c.City_English__c = null;
                    c.Address_Line_3_Preferred__c = null;
                    c.Address_Line_2_Preferred__c = null;
                    c.Country_Preferred__c = null;
                    c.Address_Type__c = null;
                    c.State_Preferred__c = null;
                    contactToUpdate.add(c);
                }
            }
            
            System.debug('***** AddressModelContact addressAfterDelete ' + contactToUpdate.size());
            update contactToUpdate;
            
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
}