global class UpdateAccountORContactAddress {

    /*
    *
    * Copies account address to all contacts
    * Creates new address (business) and set to preferred, set old address object to not preferred
    *	Case 00001581
	*	Here the behavior explanation :
	*	- If there is no Business Address
	*	o Create Business Address
	*	- If there is a Business Address
	*	o Update existing Business Address
	*	- If there is another preferred address
	*	o Keep the existing address as preferred
	*	- If there is no preferred address or Business address is already set as preferred
	*	o Make business address as preferred address    
    */
    webservice static String updateAllContacts(Id accountId){
        String BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE  
        String ADDRESS_BUSINESS_TYPE = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String LANGUAGE_FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        String result = '';
        try{
            List<Address__c> addressListToInsert = new List<Address__c>();
            List<Address__c> addressListToUpdate = new List<Address__c>();
            
            List<Account> accountList = [Select a.ZIP_Code_Preferred__c, a.Country_Preferred__c, a.State_Preferred__c, a.Street_Name_Nr_Preferred__c, a.PO_Box_Preferred__c, a.City_English__c, a.Address_Line_3_Preferred__c, a.Address_Line_2_Preferred__c From Account a where a.Id = :accountId];
            
            if(!accountList.isEmpty()){
                Account account = accountList[0];
                
                List<Contact> contactList = [Select c.Id from Contact c where c.AccountId = :accountId];
                
                
                
                if(!contactList.isEmpty()){
                    //get all preferred address object
                    List<Address__c> businessAddressList = [Select a.Id, a.Contact__c from Address__c a where a.Contact__c in :contactList and a.RecordTypeId = :ADDRESS_BUSINESS_TYPE];
                    List<Address__c> preferredAddressList = [Select a.Id, a.Contact__c from Address__c a where a.Contact__c in :contactList and a.Preferred_Address__c = true];
                    Map<Id, Address__c> businessAddressMap = new Map<Id, Address__c>();
                    Map<Id, Address__c> preferredAddressMap = new Map<Id, Address__c>();
                    
                    for(Address__c addr : businessAddressList){
                        businessAddressMap.put(addr.Contact__c, addr);
                    }
                    
                    for(Address__c addr : preferredAddressList){
                        preferredAddressMap.put(addr.Contact__c, addr);
                    }
                
                    for(Contact c : contactList){
                        if(!businessAddressMap.containsKey(c.Id)){
                            //only create address if not already business exist                          
	                        Address__c newaddr = new Address__c();
	                        newaddr.Contact__c = c.Id; 
	                        newaddr.Street_Name_Nr__c = account.Street_Name_Nr_Preferred__c;
	                        newaddr.RecordTypeId = ADDRESS_BUSINESS_TYPE; 
	                        newaddr.PO_Box__c = account.PO_Box_Preferred__c;
	                        newaddr.City_English__c = account.City_English__c;
	                        newaddr.Address_Line_3__c = account.Address_Line_3_Preferred__c;
	                        newaddr.Address_Line_2__c = account.Address_Line_2_Preferred__c;
	                        newaddr.State__c = account.State_Preferred__c; 
	                        newaddr.ZIP_Code__c = account.ZIP_Code_Preferred__c;
	                        newaddr.Country__c = account.Country_Preferred__c;
	                        if(preferredAddressMap.containsKey(c.Id)){
		            			//already preferred address
		                    	newaddr.Preferred_Address__c = false;    
		            		}else{
		            			newaddr.Preferred_Address__c = true;
		            		}
	                        addressListToInsert.add(newaddr);
                        }else{
                        	//update existing business address
                        	Address__c addToUpdate = businessAddressMap.get(c.Id);                        	
	                        addToUpdate.Street_Name_Nr__c = account.Street_Name_Nr_Preferred__c;
	                        addToUpdate.PO_Box__c = account.PO_Box_Preferred__c;
	                        addToUpdate.City_English__c = account.City_English__c;
	                        addToUpdate.Address_Line_3__c = account.Address_Line_3_Preferred__c;
	                        addToUpdate.Address_Line_2__c = account.Address_Line_2_Preferred__c;
	                        addToUpdate.State__c = account.State_Preferred__c; 
	                        addToUpdate.ZIP_Code__c = account.ZIP_Code_Preferred__c;
	                        addToUpdate.Country__c = account.Country_Preferred__c;
	                        //do not change	preferred                      
	                        addressListToUpdate.add(addToUpdate);
                        }
                        
                        //--> contact will automatically be updated
                    }
                    
                    try{
                        insert addressListToInsert; //create new preferred address.
                        update addressListToUpdate; //update existing business address.
                    }catch(System.DMLException e){
                        result += e.getMessage();   
                    }
                }
            
            }
            
        }catch(System.Exception e){
            result += e.getMessage();   
        }   
        return result;
    }
    
    
    
    /*
    *
    * Copies preferred address from account to this contact
    * Creates new business address object if not already business address exist
    * Set address to preferred if not already preferred exists
    *
    */
    webservice static String getAddressFromAccount(Id contactId){
        String BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE  
        String ADDRESS_BUSINESS_TYPE = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String LANGUAGE_FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        String result = '';
        try{        	
            List<Address__c> businessAddressList = [Select a.Id, a.Preferred_Address__c, a.Contact__c from Address__c a where a.Contact__c = :contactId and a.RecordTypeId = :ADDRESS_BUSINESS_TYPE];

        	List<Contact> cList = [Select c.Id, c.AccountId from Contact c where c.Id = :contactId limit 1];
	        
	        //
	        result = cList.size().format();
	        
	        if(!cList.isEmpty()){
	        	List<Account> accountList = [Select a.ZIP_Code_Preferred__c, a.Country_Preferred__c, a.State_Preferred__c, a.Street_Name_Nr_Preferred__c, a.PO_Box_Preferred__c, a.City_English__c, a.Address_Line_3_Preferred__c, a.Address_Line_2_Preferred__c From Account a where a.Id = :cList[0].AccountId];
	            if(!accountList.isEmpty()){
	            	Account a = accountList[0];
	            	
	            	//
	        result = result + 'businessAddressList ' + businessAddressList.size().format();
	        
		            if(businessAddressList.isEmpty()){
		                //no business address exist, create new one
		                Address__c newaddr = new Address__c();
		                newaddr.Contact__c = cList[0].Id; 
		                newaddr.Street_Name_Nr__c = a.Street_Name_Nr_Preferred__c;
		                newaddr.RecordTypeId = ADDRESS_BUSINESS_TYPE;
		                newaddr.PO_Box__c = a.PO_Box_Preferred__c;
		                newaddr.City_English__c = a.City_English__c;
		                newaddr.Address_Line_3__c = a.Address_Line_3_Preferred__c;
		                newaddr.Address_Line_2__c = a.Address_Line_2_Preferred__c;
		                newaddr.ZIP_Code__c = a.ZIP_Code_Preferred__c;
		                newaddr.Country__c = a.Country_Preferred__c;
		                newaddr.State__c = a.State_Preferred__c;
		                //--> contact will automatically be updated	
						List<Address__c> preferredAddressList = [Select a.Id, a.Preferred_Address__c, a.Contact__c from Address__c a where a.Contact__c = :cList[0].Id and a.Preferred_Address__c = true];
		        		if(preferredAddressList.isEmpty()){
		        			//no preferred address, set thisone to preferred
		                	newaddr.Preferred_Address__c = true;
	        result = result + 'newaddr preferred true';  
		        		}else{
		        			newaddr.Preferred_Address__c = false;
	        result = result + 'newaddr preferred false';  
		        		}
		        		
						insert newaddr;
	        result = result + 'newaddr ' + newaddr.id;
		                
		            }else{		
			            //business address already exist, update existing address
		            	Address__c addToUpdate = businessAddressList[0];
		            	addToUpdate.Street_Name_Nr__c = a.Street_Name_Nr_Preferred__c;
		                addToUpdate.PO_Box__c = a.PO_Box_Preferred__c;
		                addToUpdate.City_English__c = a.City_English__c;
		                addToUpdate.Address_Line_3__c = a.Address_Line_3_Preferred__c;
		                addToUpdate.Address_Line_2__c = a.Address_Line_2_Preferred__c;
		                addToUpdate.State__c = a.State_Preferred__c; 
		                addToUpdate.ZIP_Code__c = a.ZIP_Code_Preferred__c;
		                addToUpdate.Country__c = a.Country_Preferred__c;
		            	
		            	update addToUpdate;	                
		            }    
	            }
        	}	
        }catch(System.Exception e){
            result += e.getMessage();   
        }   
        
        return result;
    }
}