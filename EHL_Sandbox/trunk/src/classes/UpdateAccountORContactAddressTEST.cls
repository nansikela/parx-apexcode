public class UpdateAccountORContactAddressTEST {
    
    
    static testMethod void updateAllContactFromAccountTestmethod(){
        
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS;
        
        String ACCOUNT_BILLING_ADDRESS = SystemSettings.ACCOUNT_BILLING_ADDRESS; //PICKLIST VALUE        
        
        String REFERENCEDATA_CITY_TYPE = SystemSettings.REFERENCEDATA_CITY_TYPE;
        String REFERENCEDATA_COUNTRY_TYPE = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
        String CITY_F = 'parxF20101119';
        String CITY_E = 'parxE20101119';       
        
        String LANGUAGE_FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        
        try{
        	 //create city
	        List<Reference_Data__c> tempList = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'SWITZERLAND' limit 1];
		    Reference_Data__c countryPARX;
		    if(tempList.isEmpty()) {
		        	countryPARX = new Reference_Data__c();
			        countryPARX.Name = 'SWITZERLAND';
			        countryPARX.RecordTypeId = REFERENCEDATA_COUNTRY_TYPE;
			        countryPARX.Country_Francais__c = 'SUISSE';
			        countryPARX.Country_English__c = 'SWITZERLAND';
			        countryPARX.Country_Code__c = 'CH';
		        	insert countryPARX;
		
			        System.debug('**** countryPARX ' + countryPARX);
		     } else {
	            countryPARX = tempList[0];
	            System.debug('**** countryPARX else ' + countryPARX);
		            
		   	}
	        
	        Reference_Data__c cityParx = new Reference_Data__c();
	        cityParx.Name = CITY_E;
	        cityParx.RecordTypeId = REFERENCEDATA_CITY_TYPE;
	        cityParx.City_Francais__c = CITY_F;
	        cityParx.City_English__c = CITY_E;
	        cityParx.City_Country__c = countryPARX.Id;
	        cityParx.ZIP_Code__c = '3000';
	        insert cityParx;   
	        
	        Reference_Data__c cityParx2 = new Reference_Data__c();
	        cityParx2.Name = 'Zurich';
	        cityParx2.RecordTypeId = REFERENCEDATA_CITY_TYPE;
	        cityParx2.City_Francais__c = 'Zurich';
	        cityParx2.City_English__c = 'Zurich';
	        cityParx2.City_Country__c = countryPARX.Id;
	        cityParx2.ZIP_Code__c = '8045';
	        insert cityParx2;   
	        
	        Reference_Data__c cityParx3 = new Reference_Data__c();
	        cityParx3.Name = CITY_E;
	        cityParx3.RecordTypeId = REFERENCEDATA_CITY_TYPE;
	        cityParx3.City_Francais__c = CITY_F;
	        cityParx3.City_English__c = CITY_E;
	        cityParx3.City_Country__c = countryPARX.Id;
	        cityParx3.ZIP_Code__c = '3500';
	        insert cityParx3;   
		        
		        
            Account a = new Account(Name = 'Test Firma', City_English__c = 'Los Angeles', ZIP_Code_Preferred__c = '25478', State_Preferred__c = 'CA', Country_Preferred__c = 'UNITED STATES', Address_Type__c = ACCOUNT_BILLING_ADDRESS, Street_Name_Nr_Preferred__c = 'street 56', PO_Box_Preferred__c = 'pp', Address_Line_2_Preferred__c = 'addr 2', Address_Line_3_Preferred__c = 'addr 3');
            insert a;
		    TriggerContext.reset();
            
            
            List<Contact> contactToInsert = new List<Contact>();
            
            Integer numberOfCreatedContact = 17;
            Integer i;
            
            for(i=0; i<numberOfCreatedContact; i++){

                Contact c = new Contact(AccountId = a.Id, Lastname = 'TESTER', Firstname = 'K', ZIP_Code_Preferred__c = '3000', Country_Preferred__c = 'SWITZERLAND', City_English__c = CITY_E, Street_Name_Nr_Preferred__c = 'Streetname', Preferred_Language__c = LANGUAGE_FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_TIMESTUDY_ADDRESS, Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                contactToInsert.add(c);     
            }
           
           	insert contactToInsert;
		    TriggerContext.reset();
             
           
            //overwrite address with account address
            String result = UpdateAccountORContactAddress.updateAllContacts(a.Id);
		    TriggerContext.reset();
            System.debug('**** Method result ' + result);

            
            List<Contact> updatedContactList = [Select c.Country_Preferred__c, c.State_Preferred__c, c.ZIP_Code_Preferred__c, c.PO_Box_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_2_Preferred__c, c.Address_Line_3_Preferred__c, c.Street_Name_Nr_Preferred__c from Contact c where c.Id in :contactToInsert];
            for(Contact con : updatedContactList){
                System.assertEquals(con.Address_Type__c, CONTACT_TIMESTUDY_ADDRESS);
                System.assertEquals(con.City_English__c, CITY_E);
                System.assertEquals(con.Street_Name_Nr_Preferred__c, 'Streetname');
                System.assertEquals(con.Address_Line_2_Preferred__c, 'Line 2');
                System.assertEquals(con.Address_Line_3_Preferred__c, 'Line 3');
                System.assertEquals(con.PO_Box_Preferred__c, 'po box');
                System.assertEquals(con.State_Preferred__c, null);
                System.assertEquals(con.Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(con.ZIP_Code_Preferred__c, '3000');
            }
            
            List<Address__c> addressList = [Select a.Preferred_Address__c, a.Zip_Code__c, a.City_English__c, a.Country__c, a.Address_Line_3__c, a.Address_Line_2__c, a.PO_Box__c, a.Street_Name_Nr__c, a.State__c,a.RecordTypeId from Address__c a where a.RecordTypeId = :ADDRESS_BUSINESS_ADDRESS and a.Contact__c in :contactToInsert];
            
            //check that new address are created (must be twice as much because every contact has two now but only one preferred)
            System.assertEquals(addressList.size(), numberOfCreatedContact);

            for(Address__c ad : addressList){
                if(ad.Preferred_Address__c){
                    //check that preferred address are all the same
                    System.assertEquals(ad.RecordTypeId, ADDRESS_BUSINESS_ADDRESS);
                    System.assertEquals(ad.City_English__c, 'Los Angeles');
                    System.assertEquals(ad.Street_Name_Nr__c, 'street 56');
                    System.assertEquals(ad.Address_Line_2__c, 'addr 2');
                    System.assertEquals(ad.Address_Line_3__c, 'addr 3');
                    System.assertEquals(ad.PO_Box__c, 'pp');
                    System.assertEquals(ad.State__c, 'CA');
                    System.assertEquals(ad.Country__c, 'UNITED STATES');
                    System.assertEquals(ad.ZIP_Code__c, '25478');
                   	System.assertEquals(ad.Preferred_Address__c, false);//perferred address is at the time of study
                }
            }
            
            //*************************
            Account a2 = new Account(Name = 'Test Firma 2', City_English__c = 'Zurich', ZIP_Code_Preferred__c = '8045', State_Preferred__c = 'ZH', Country_Preferred__c = 'SWITZERLAND', Address_Type__c = ACCOUNT_BILLING_ADDRESS, Street_Name_Nr_Preferred__c = 'street 565', PO_Box_Preferred__c = 'po box', Address_Line_2_Preferred__c = 'addr 22', Address_Line_3_Preferred__c = 'addr 33');
            insert a2;
		    TriggerContext.reset();
            
            
           contactToInsert.clear();
                       
            for(i=0; i<numberOfCreatedContact; i++){

                Contact c = new Contact(AccountId = a2.Id, Lastname = 'TESTER', Firstname = 'Peter', ZIP_Code_Preferred__c = '3500', Country_Preferred__c = 'SWITZERLAND', City_English__c = CITY_E, Street_Name_Nr_Preferred__c = 'Streetname', Preferred_Language__c = LANGUAGE_FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                contactToInsert.add(c);     
            }           
            insert contactToInsert;
		    TriggerContext.reset();
            
            //overwrite address with account address
            result = UpdateAccountORContactAddress.updateAllContacts(a2.Id);
		    TriggerContext.reset();
            System.debug('**** Method result ' + result);
            
           	addressList = [Select a.Preferred_Address__c, a.Zip_Code__c, a.City_English__c, a.Country__c, a.Address_Line_3__c, a.Address_Line_2__c, a.PO_Box__c, a.Street_Name_Nr__c, a.State__c,a.RecordTypeId from Address__c a where a.RecordTypeId = :ADDRESS_BUSINESS_ADDRESS and a.Contact__c in :contactToInsert];
            
            //check that new address are updated
            System.assertEquals(addressList.size(), numberOfCreatedContact);

            for(Address__c ad : addressList){
                if(ad.Preferred_Address__c){
                    //check that preferred address are all the same
                    System.assertEquals(ad.RecordTypeId, ADDRESS_BUSINESS_ADDRESS);
                    System.assertEquals(ad.City_English__c, 'Zurich');
                    System.assertEquals(ad.Street_Name_Nr__c, 'street 565');
                    System.assertEquals(ad.Address_Line_2__c, 'addr 22');
                    System.assertEquals(ad.Address_Line_3__c, 'addr 33');
                    System.assertEquals(ad.PO_Box__c, 'po box');
                    System.assertEquals(ad.State__c, 'ZH');
                    System.assertEquals(ad.Country__c, 'SWITZERLAND');
                    System.assertEquals(ad.ZIP_Code__c, '8045');
                   	System.assertEquals(ad.Preferred_Address__c, true);
                }
            }
            
             
       }catch(System.Exception e){
            System.debug('**** Final Exception updateContactTestmethod 1 ' + e);
            System.assert(false);

       }
    }
    
    
    static testMethod void getAddressFromAccountTestmethod(){
        
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS;
        
        String ACCOUNT_BILLING_ADDRESS = SystemSettings.ACCOUNT_BILLING_ADDRESS; //PICKLIST VALUE        
        
        String REFERENCEDATA_CITY_TYPE = SystemSettings.REFERENCEDATA_CITY_TYPE;
        String REFERENCEDATA_COUNTRY_TYPE = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
        String CITY_F = 'parxF20101119';
        String CITY_E = 'parxE20101119';       
        
        String LANGUAGE_FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        try{
        	
        	 //create city
	        List<Reference_Data__c> tempList = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'SWITZERLAND' limit 1];
		    Reference_Data__c countryPARX;
		    if(tempList.isEmpty()) {
		        	countryPARX = new Reference_Data__c();
			        countryPARX.Name = 'SWITZERLAND';
			        countryPARX.RecordTypeId = REFERENCEDATA_COUNTRY_TYPE;
			        countryPARX.Country_Francais__c = 'SUISSE';
			        countryPARX.Country_English__c = 'SWITZERLAND';
			        countryPARX.Country_Code__c = 'CH';
		        	insert countryPARX;
		
			        System.debug('**** countryPARX ' + countryPARX);
		     } else {
	            countryPARX = tempList[0];
	            System.debug('**** countryPARX else ' + countryPARX);
		            
		   	}
	        
	        Reference_Data__c cityParx = new Reference_Data__c();
	        cityParx.Name = CITY_E;
	        cityParx.RecordTypeId = REFERENCEDATA_CITY_TYPE;
	        cityParx.City_Francais__c = CITY_F;
	        cityParx.City_English__c = CITY_E;
	        cityParx.City_Country__c = countryPARX.Id;
	        cityParx.ZIP_Code__c = '3000';
	        insert cityParx;   
	        
	        Reference_Data__c cityParx2 = new Reference_Data__c();
	        cityParx2.Name = CITY_E;
	        cityParx2.RecordTypeId = REFERENCEDATA_CITY_TYPE;
	        cityParx2.City_Francais__c = CITY_F;
	        cityParx2.City_English__c = CITY_E;
	        cityParx2.City_Country__c = countryPARX.Id;
	        cityParx2.ZIP_Code__c = '3001';
	        insert cityParx2;   
	        
            Account a = new Account(Name = 'Test Firma', ZIP_Code_Preferred__c = '25478', State_Preferred__c = 'CA', Country_Preferred__c = 'UNITED STATES', City_English__c = 'Los Angeles', Address_Type__c = ACCOUNT_BILLING_ADDRESS, Street_Name_Nr_Preferred__c = 'street 56', PO_Box_Preferred__c = 'pp', Address_Line_2_Preferred__c = 'addr 2', Address_Line_3_Preferred__c = 'addr 3');
            insert a;
		    TriggerContext.reset();     

            List<Contact> cList = new List<Contact>();
            //has preferred study address
            Contact c = new Contact(AccountId = a.Id, Lastname = 'TESTER', ZIP_Code_Preferred__c = '3000', Country_Preferred__c = 'SWITZERLAND', Firstname = 'K', City_English__c = CITY_E, Street_Name_Nr_Preferred__c = 'Streetname', Preferred_Language__c = LANGUAGE_FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_TIMESTUDY_ADDRESS, Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
            cList.add(c);
            
            //no preferred address
            Contact c1 = new Contact(AccountId = a.Id, Lastname = 'TESTER');
            cList.add(c1);
            
            //has business address
            Contact c2 = new Contact(AccountId = a.Id, Lastname = 'TESTER', ZIP_Code_Preferred__c = '3001', Country_Preferred__c = 'SWITZERLAND', Firstname = 'K', City_English__c = CITY_E, Street_Name_Nr_Preferred__c = 'Streetname2', Preferred_Language__c = LANGUAGE_FRENCH, PO_Box_Preferred__c = 'pobox', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Address_Line_3_Preferred__c = 'Line3', Address_Line_2_Preferred__c  = 'Line2');
            cList.add(c2);
            
            try{
                insert cList;
		    	TriggerContext.reset();
             }catch(System.DMLException e){
                System.debug('**** TEST Exception> ' + e);
                System.assert(false);
             }
           
            //****************** CONTACT
            //create new business address, not preferred
            String result = UpdateAccountORContactAddress.getAddressFromAccount(c.Id);
		    TriggerContext.reset();
            System.debug('**** Method result ' + result);
            
            
            //check that contact is not updated
            List<Contact> updatedContactList = [Select c.Country_Preferred__c, c.State_Preferred__c, c.ZIP_Code_Preferred__c, c.PO_Box_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_2_Preferred__c, c.Address_Line_3_Preferred__c, c.Street_Name_Nr_Preferred__c from Contact c where c.Id = :c.Id];
            List<Address__c> addrList = [Select a.ZIP_Code__c, a.Preferred_Address__c, a.Street_Name_Nr__c, a.State__c, a.RecordTypeId, a.PO_Box__c, a.Country__c, a.City_English__c, a.Address_Line_3__c, a.Address_Line_2__c From Address__c a where a.Contact__c = :c.Id and a.RecordTypeId = :ADDRESS_BUSINESS_ADDRESS];
            if(updatedContactList.isEmpty()){
                 System.assert(false);
            }else{
                //check that contact address not overriden
                Contact con = updatedContactList[0];
                System.assertEquals(con.Address_Type__c, CONTACT_TIMESTUDY_ADDRESS);
                System.assertEquals(con.City_English__c, CITY_E);
                System.assertEquals(con.Street_Name_Nr_Preferred__c, 'Streetname');
                System.assertEquals(con.Address_Line_2_Preferred__c, 'Line 2');
                System.assertEquals(con.Address_Line_3_Preferred__c, 'Line 3');
                System.assertEquals(con.PO_Box_Preferred__c, 'po box');
                System.assertEquals(con.Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(con.ZIP_Code_Preferred__c, '3000');
            }            
            if(addrList.isEmpty()){
                 System.assert(false);
            }else{
                //check that address is created (not preferred)
                Address__c ad = addrList[0];
                System.assertEquals(ad.RecordTypeId, ADDRESS_BUSINESS_ADDRESS);
                System.assertEquals(ad.City_English__c, 'Los Angeles');
                System.assertEquals(ad.Street_Name_Nr__c, 'street 56');
                System.assertEquals(ad.Address_Line_2__c, 'addr 2');
                System.assertEquals(ad.Address_Line_3__c, 'addr 3');
                System.assertEquals(ad.PO_Box__c, 'pp');
                System.assertEquals(ad.State__c, 'CA');
                System.assertEquals(ad.Country__c, 'UNITED STATES');
                System.assertEquals(ad.ZIP_Code__c, '25478');
                System.assertEquals(ad.Preferred_Address__c, false);
            }

            
            //****************** CONTACT 1
            //create new business address,  preferred
            result = UpdateAccountORContactAddress.getAddressFromAccount(c1.Id);
		    TriggerContext.reset();
            System.debug('**** Method result1 ' + result);
            
            
            //check that contact is updated
            updatedContactList = [Select c.Country_Preferred__c, c.State_Preferred__c, c.ZIP_Code_Preferred__c, c.PO_Box_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_2_Preferred__c, c.Address_Line_3_Preferred__c, c.Street_Name_Nr_Preferred__c from Contact c where c.Id = :c1.Id];
            addrList = [Select a.ZIP_Code__c, a.Preferred_Address__c, a.Street_Name_Nr__c, a.State__c, a.RecordTypeId, a.PO_Box__c, a.Country__c, a.City_English__c, a.Address_Line_3__c, a.Address_Line_2__c From Address__c a where a.Contact__c = :c1.Id and a.RecordTypeId = :ADDRESS_BUSINESS_ADDRESS];
            if(updatedContactList.isEmpty()){
                 System.assert(false);
            }else{
                //check that contact address overriden
                Contact con = updatedContactList[0];
                System.assertEquals(con.Address_Type__c, CONTACT_BUSINESS_ADDRESS);
                System.assertEquals(con.City_English__c, 'Los Angeles');
                System.assertEquals(con.Street_Name_Nr_Preferred__c, 'street 56');
                System.assertEquals(con.Address_Line_2_Preferred__c, 'addr 2');
                System.assertEquals(con.Address_Line_3_Preferred__c, 'addr 3');
                System.assertEquals(con.PO_Box_Preferred__c, 'pp');
                System.assertEquals(con.Country_Preferred__c, 'UNITED STATES');
                System.assertEquals(con.ZIP_Code_Preferred__c, '25478');
            }            
            if(addrList.isEmpty()){
                 System.assert(false);
            }else{
                //check that address is created (preferred)
                Address__c ad = addrList[0];
                System.assertEquals(ad.RecordTypeId, ADDRESS_BUSINESS_ADDRESS);
                System.assertEquals(ad.City_English__c, 'Los Angeles');
                System.assertEquals(ad.Street_Name_Nr__c, 'street 56');
                System.assertEquals(ad.Address_Line_2__c, 'addr 2');
                System.assertEquals(ad.Address_Line_3__c, 'addr 3');
                System.assertEquals(ad.PO_Box__c, 'pp');
                System.assertEquals(ad.State__c, 'CA');
                System.assertEquals(ad.Country__c, 'UNITED STATES');
                System.assertEquals(ad.ZIP_Code__c, '25478');
                System.assertEquals(ad.Preferred_Address__c, true);
            }
            
            
            
             //****************** CONTACT 2
            //updaet business address
            result = UpdateAccountORContactAddress.getAddressFromAccount(c2.Id);
		    TriggerContext.reset();
            System.debug('**** Method result2 ' + result);
            
            
            //check that contact is updated
            updatedContactList = [Select c.Country_Preferred__c, c.State_Preferred__c, c.ZIP_Code_Preferred__c, c.PO_Box_Preferred__c, c.Address_Type__c, c.City_English__c, c.Address_Line_2_Preferred__c, c.Address_Line_3_Preferred__c, c.Street_Name_Nr_Preferred__c from Contact c where c.Id = :c2.Id];
            addrList = [Select a.ZIP_Code__c, a.Preferred_Address__c, a.Street_Name_Nr__c, a.State__c, a.RecordTypeId, a.PO_Box__c, a.Country__c, a.City_English__c, a.Address_Line_3__c, a.Address_Line_2__c From Address__c a where a.Contact__c = :c2.Id and a.RecordTypeId = :ADDRESS_BUSINESS_ADDRESS];
            if(updatedContactList.isEmpty()){
                 System.assert(false);
            }else{
                //check that contact address overriden
                Contact con = updatedContactList[0];
                System.assertEquals(con.Address_Type__c, CONTACT_BUSINESS_ADDRESS);
                System.assertEquals(con.City_English__c, 'Los Angeles');
                System.assertEquals(con.Street_Name_Nr_Preferred__c, 'street 56');
                System.assertEquals(con.Address_Line_2_Preferred__c, 'addr 2');
                System.assertEquals(con.Address_Line_3_Preferred__c, 'addr 3');
                System.assertEquals(con.PO_Box_Preferred__c, 'pp');
                System.assertEquals(con.Country_Preferred__c, 'UNITED STATES');
                System.assertEquals(con.ZIP_Code_Preferred__c, '25478');
            }            
            if(addrList.isEmpty()){
                 System.assert(false);
            }else{
                //check that address is updated (preferred)
                Address__c ad = addrList[0];
                System.assertEquals(ad.RecordTypeId, ADDRESS_BUSINESS_ADDRESS);
                System.assertEquals(ad.City_English__c, 'Los Angeles');
                System.assertEquals(ad.Street_Name_Nr__c, 'street 56');
                System.assertEquals(ad.Address_Line_2__c, 'addr 2');
                System.assertEquals(ad.Address_Line_3__c, 'addr 3');
                System.assertEquals(ad.PO_Box__c, 'pp');
                System.assertEquals(ad.State__c, 'CA');
                System.assertEquals(ad.Country__c, 'UNITED STATES');
                System.assertEquals(ad.ZIP_Code__c, '25478');
                System.assertEquals(ad.Preferred_Address__c, true);
            }
             
       }catch(System.Exception e){
            System.debug('**** Final Exception ugetAddressFromAccountTestmethod 1 ' + e);
            System.assert(false);

       }
    }
    

}