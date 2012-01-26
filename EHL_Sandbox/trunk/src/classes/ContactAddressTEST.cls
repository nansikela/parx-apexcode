public class ContactAddressTEST {
    
    static testMethod void contactAddressTestMethod1(){
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String ADDRESS_PRIVATE_ADDRESS = SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE;
        String ADDRESS_BILLING_ADDRESS = SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE;
        
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_STUDENT_PERMANENT_ADDRESS; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE
        String CONTACT_PRIVATE_ADDRESS = SystemSettings.CONTACT_PRIVATE_ADDRESS; //PICKLIST VALUE
        String CONTACT_BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        
        String FRENCH = SystemSettings.LANGUAGE_FRENCH;
        String LANGUAGE_ENGLISH = SystemSettings.LANGUAGE_ENGLISH;
        
        //Account
        String BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        //*****************************
        
        try{
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(guiUser) { 
                String addressType = CONTACT_TIMESTUDY_ADDRESS;
                Account a = new Account(Name = 'Test Firma', City_English__c = 'Berne', Address_Type__c = BILLING_ADDRESS);
                insert a;
                
                
               List<Contact> contactToInsert = new List<Contact>();
                
                Integer numberOfCreatedContact = 50;
                Integer i;
                
                for(i=0; i<numberOfCreatedContact; i++){
                    if(addressType == CONTACT_TIMESTUDY_ADDRESS){
                        addressType = CONTACT_STUDENT_PERMANET_ADDRESS;
                    }else if(addressType == CONTACT_STUDENT_PERMANET_ADDRESS){
                        addressType = CONTACT_BUSINESS_ADDRESS;
                    }else{
                        addressType = CONTACT_TIMESTUDY_ADDRESS;
                    }
                    
                    Contact c = new Contact(AccountId = a.Id, Lastname = 'TESTER', Firstname = 'K', City_English__c = 'Berne', ZIP_Code_Preferred__c = '3001', Street_Name_Nr_Preferred__c = 'Streetname', Preferred_Language__c = LANGUAGE_ENGLISH, PO_Box_Preferred__c = 'po box', Address_Type__c = addressType, Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                    contactToInsert.add(c);     
                }
               
                try{
                    insert contactToInsert;
                    TriggerContext.reset();
                 }catch(System.DMLException e){
                    System.debug('**** TEST Exception> ' + e);
                    System.assert(false);
                 }
               
                
                //check that all addresses are created
                System.assertEquals([Select count() from Address__c c where c.Contact__c in :contactToInsert], numberOfCreatedContact);
                
                 //not set because non gui user
                Contact cc1 = [Select c.UpdatedBySpecialUser__c from Contact c where c.Id in :contactToInsert limit 1];
                System.assert(!cc1.UpdatedBySpecialUser__c);
                
                 //1st contact: try to insert another preferred address, should not work
                Address__c adr1 = new Address__c(City_English__c = 'LA', Street_Name_Nr__c = 'Street Name', RecordTypeId = ADDRESS_TIMESTUDY_ADDRESS, Preferred_Address__c = true, Contact__c = contactToInsert[0].Id);      
                try{
                    insert adr1;
                    System.assert(false);
                 }catch(System.DMLException e){
                    System.debug('**** TEST Exception, should occur ' + e);
                 }
                 TriggerContext.reset();
         
                //edit address and check if contact is changed
                List<Address__c> adr2List = [Select c.Contact__c, c.RecordTypeId, c.City_English__c from Address__c c where c.Contact__c in :contactToInsert and RecordTypeId = :ADDRESS_STUDENT_PERMANENT_ADDRESS limit 1];
                if(adr2List.isEmpty()){
                    System.assert(false);
                }else{
                    Address__c adr2 = adr2List[0];
                    adr2.RecordTypeId = ADDRESS_TIMESTUDY_ADDRESS;
                    adr2.City_English__c = 'LA';
                    update adr2;
                    TriggerContext.reset();
        
                    Contact c2 = [Select c.ZIP_Code_Preferred__c, c.City_English__c, c.Address_Type__c, c.Country_Preferred__c from Contact c where c.Id = :adr2.Contact__c limit 1];
                    System.assertEquals(c2.City_English__c , 'LA');
                    System.assertEquals(c2.Address_Type__c , CONTACT_TIMESTUDY_ADDRESS);
                }                 
               
                 //edit address from businessaddress to current address and check if contact is changed
                 Address__c adr4 = [Select a.Contact__c, a.RecordTypeId, a.City_English__c from Address__c a where a.Contact__c in :contactToInsert and a.RecordTypeId = :ADDRESS_BUSINESS_ADDRESS and a.Preferred_Address__c = true limit 1];
                 adr4.RecordTypeId = ADDRESS_TIMESTUDY_ADDRESS;
                 update adr4;
                 TriggerContext.reset();
                 
                 List<Contact> c4List = [Select c.Address_Type__c from Contact c where c.Id = :adr4.Contact__c limit 1];
                 if(c4List.isEmpty()){
                    System.assert(false);
                 }else{
                    Contact c4 = c4List[0];
                    System.assertEquals(c4.Address_Type__c , CONTACT_TIMESTUDY_ADDRESS);
                 }
             
             }
       }catch(System.Exception e){
            System.debug('**** Final Exception ContactAddressTEST 1 ' + e);
            System.assert(false, e);
       }
    }
    
    
    static testMethod void contactAddressTestMethod2(){
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String ADDRESS_PRIVATE_ADDRESS = SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE;
        String ADDRESS_BILLING_ADDRESS = SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE;
        
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_STUDENT_PERMANENT_ADDRESS; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE
        String CONTACT_PRIVATE_ADDRESS = SystemSettings.CONTACT_PRIVATE_ADDRESS; //PICKLIST VALUE
        String CONTACT_BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        
        String FRENCH = SystemSettings.LANGUAGE_FRENCH;
        String LANGUAGE_ENGLISH = SystemSettings.LANGUAGE_ENGLISH;
        
        //Account
        String BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        //*****************************
        
        try{
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(guiUser) { 
                String addressType = CONTACT_TIMESTUDY_ADDRESS;
                Account a = new Account(Name = 'Test Firma', City_English__c = 'Bern', Address_Type__c = BILLING_ADDRESS);
                insert a;
                
                List<Contact> contactToInsert = new List<Contact>();
                
                Integer numberOfCreatedContact = 50;
                Integer i;
                
                for(i=0; i<numberOfCreatedContact; i++){
                    if(addressType == CONTACT_TIMESTUDY_ADDRESS){
                        addressType = CONTACT_STUDENT_PERMANET_ADDRESS;
                    }else if(addressType == CONTACT_STUDENT_PERMANET_ADDRESS){
                        addressType = CONTACT_BUSINESS_ADDRESS;
                    }else{
                        addressType = CONTACT_TIMESTUDY_ADDRESS;
                    }
                    System.debug('**** AddressHandlerContactTEST addressType:' + addressType);
                    
                    Contact c = new Contact(AccountId = a.Id, Lastname = 'TESTER', Firstname = 'K', City_English__c = 'Bern', Street_Name_Nr_Preferred__c = 'Streetname', Preferred_Language__c = LANGUAGE_ENGLISH, PO_Box_Preferred__c = 'po box', Address_Type__c = addressType, Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                    contactToInsert.add(c);     
                }
               
                try{
                    insert contactToInsert;
                    TriggerContext.reset();
                 }catch(System.DMLException e){
                    System.debug('**** TEST Exception> ' + e);
                    System.assert(false);
                 }
                 
                //check that all communicaton points are created
                System.assertEquals([Select count() from Address__c c where c.Contact__c in :contactToInsert], numberOfCreatedContact);
                
                 
                //edit address to businessaddress and check if contact is changed
                Address__c adr1 = [Select c.Contact__c, c.RecordTypeId from Address__c c where c.Contact__c in :contactToInsert and RecordTypeId = :ADDRESS_TIMESTUDY_ADDRESS and Preferred_Address__c = true limit 1];
                adr1.RecordTypeId = ADDRESS_BUSINESS_ADDRESS;
                adr1.Street_Name_Nr__c = 'NewName';
                update adr1;
                TriggerContext.reset();
                 
                Contact c1;
                List<Contact> c1List = [Select c.Street_Name_Nr_Preferred__c, c.Address_Type__c from Contact c where c.Id = :adr1.Contact__c limit 1];
                if(c1List.isEmpty()){
                    System.assert(false);
                }else{
                    c1 = c1List[0];
                    System.assertEquals(c1.Street_Name_Nr_Preferred__c ,'NewName');
                    System.assertEquals(c1.Address_Type__c , CONTACT_BUSINESS_ADDRESS);
                 }
                 
                 //**********************************
                 
                 //delete contact, check that address also deleted
                 delete c1;
                 TriggerContext.reset();
                 List<Address__c> addrList = [Select a.Id from Address__c a where a.Contact__c = :c1.Id];
                 System.assert(addrList.isEmpty());
            }
          }catch(System.Exception e){
                System.debug('**** Final Exception ContactAddressTEST 2 ' + e);
                System.assert(false);
    
          }
    }
    
    static testMethod void contactAddressTestMethod3(){
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String ADDRESS_PRIVATE_ADDRESS = SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE;
        String ADDRESS_BILLING_ADDRESS = SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE;
        
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_STUDENT_PERMANENT_ADDRESS; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE
        String CONTACT_PRIVATE_ADDRESS = SystemSettings.CONTACT_PRIVATE_ADDRESS; //PICKLIST VALUE
        String CONTACT_BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE        
        
        String FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        //Account
        String BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        //*****************************
        
        try{            
            String addressType = CONTACT_TIMESTUDY_ADDRESS;
            List<Account> accountList = new List<Account>();
            Account a = new Account(Name = 'Test AG', City_English__c = 'Zurich', Address_Type__c = BILLING_ADDRESS);
            accountList.add(a);
            Account a2 = new Account(Name = 'Test AG 2', City_English__c = 'Santa Barbara', Address_Line_3_Preferred__c = 'adr3', Address_Line_2_Preferred__c = 'adr2', Street_Name_Nr_Preferred__c = 'the street', PO_Box_Preferred__c = 'po', Address_Type__c = BILLING_ADDRESS); 
            accountList.add(a2);
            insert accountList;
            TriggerContext.reset();
            
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(guiUser) { 
                List<Contact> contactToInsert = new List<Contact>();
                
                Integer numberOfCreatedContact = 10;
                Integer i;
                
                
                for(i=0; i<numberOfCreatedContact; i++){
                    if(addressType == CONTACT_TIMESTUDY_ADDRESS){
                        addressType = CONTACT_STUDENT_PERMANET_ADDRESS;
                    }else if(addressType == CONTACT_STUDENT_PERMANET_ADDRESS){
                        addressType = CONTACT_BUSINESS_ADDRESS;
                    }else{
                        addressType = CONTACT_TIMESTUDY_ADDRESS;
                    }
                   
                    Contact c = new Contact(AccountId = a.Id, Lastname = 'MUSTER', Firstname = 'Max', Street_Name_Nr_Preferred__c = 'Street', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = addressType, City_English__c = 'Zurich', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                    contactToInsert.add(c);     
                }
                
                try{
                    insert contactToInsert;
                    TriggerContext.reset();
                 }catch(System.DMLException e){
                    System.debug('**** TEST Exception> ' + e);
                    System.assert(false);
                 }
                
                //1st contact> create new address (not preferred)
                Address__c adr1 = new Address__c(City_English__c = 'Santa Barbara', Street_Name_Nr__c = 'StreetName', RecordTypeId = ADDRESS_TIMESTUDY_ADDRESS, Preferred_Address__c = false, PO_Box__c = 'PO', Contact__c = contactToInsert[0].Id, Address_Line_3__c = 'adr3', Address_Line_2__c = 'adr2');
                insert adr1;
                TriggerContext.reset();
    
                
                //2nd contact: try to insert another preferred address, should not work
                Address__c adr2 = new Address__c(City_English__c = 'Santa Barbara', Street_Name_Nr__c = 'Street Name', RecordTypeId = ADDRESS_TIMESTUDY_ADDRESS, Preferred_Address__c = true, Contact__c = contactToInsert[1].Id, Address_Line_3__c = 'line 3', Address_Line_2__c = 'line 2');
                       
                try{
                    insert adr2;
                    System.assert(false);
                 }catch(System.DMLException e){
                    System.debug('**** TEST Exception, should occur ' + e);
                 }
                 TriggerContext.reset();
                 
                 //3rd contact: set address not preferred and create new one
                Address__c adr3 = [Select c.Preferred_Address__c from Address__c c where c.Contact__c = :contactToInsert[2].Id];
                adr3.Preferred_Address__c = false;
                update adr3;
                TriggerContext.reset();
                
                //check that address is null
                Contact c3 = [Select c.ZIP_Code_Preferred__c, c.City_English__c, c.Street_Name_Nr_Preferred__c from Contact c where c.Id = :contactToInsert[2].Id limit 1];
                System.assertEquals(c3.ZIP_Code_Preferred__c ,null);
                System.assertEquals(c3.Street_Name_Nr_Preferred__c ,null);
                System.assertEquals(c3.City_English__c ,null);
                
                Address__c cp33 = new Address__c(City_English__c = 'Santa Barbara', ZIP_Code__c = '25630', Street_Name_Nr__c = 'Street Name', RecordTypeId = ADDRESS_TIMESTUDY_ADDRESS, Preferred_Address__c = true, Contact__c = contactToInsert[2].Id, Address_Line_3__c = 'line 3', Address_Line_2__c = 'line 2');      
                try{                    
                    System.debug('**** START INSERT ADDRESS');
                    insert cp33;
                    System.debug('**** END INSERT ADDRESS');
                    TriggerContext.reset();
                 }catch(System.DMLException e){
                    System.debug('**** TEST Exception ' + e);
                    System.assert(false);
                 }
                 
                cp33 = [Select Contact__c, City_English__c , ZIP_Code__c , Street_Name_Nr__c, Preferred_Address__c from Address__c where Id = :cp33.Id]; 
                System.assertEquals(cp33.ZIP_Code__c ,'25630');
                System.assertEquals(cp33.Street_Name_Nr__c ,'Street Name');
                System.assertEquals(cp33.City_English__c ,'Santa Barbara'); 
                System.assert(cp33.Preferred_Address__c);         
                
                 //check that address is updated
                Contact c5 = [Select c.ZIP_Code_Preferred__c, c.City_English__c, c.Street_Name_Nr_Preferred__c from Contact c where c.Id = :cp33.Contact__c limit 1];
                //TODO check
                //System.assertEquals(c3.ZIP_Code_Preferred__c ,'25630');
                //System.assertEquals(c3.Street_Name_Nr_Preferred__c ,'Street Name');
                //System.assertEquals(c3.City_English__c ,'Santa Barbara');
                
                
                //4th contact: update contact and check if preferred address has changed
                Contact c4 = contactToInsert[3];
                c4.Street_Name_Nr_Preferred__c = 'new street';
                c4.PO_Box_Preferred__c = 'new po';
                c4.City_English__c = 'Santa Barbara';
                c4.Address_Line_3_Preferred__c = 'new ad';
                c4.Address_Line_2_Preferred__c = 'new adr';
                c4.Address_Type__c = CONTACT_TIMESTUDY_ADDRESS;
                System.debug('**** TEST Update c4 now');
                update c4;
                TriggerContext.reset();
                
                Address__c adr4 = [Select a.City_English__c, a.PO_Box__c, a.Address_Line_3__c, a.Address_Line_2__c from Address__c a where a.Contact__c = :c4.Id and a.Preferred_Address__c = true];
                System.assertEquals(adr4.PO_Box__c, 'new po');
                System.assertEquals(adr4.City_English__c , 'Santa Barbara');
                System.assertEquals(adr4.Address_Line_3__c , 'new ad');
                System.assertEquals(adr4.Address_Line_2__c , 'new adr');
                
            }

        }catch(System.Exception e){
            System.debug('**** Final Exception ContactAddressTEST 3 ' + e);
            System.assert(false);

        }
     }
     
     
     static testMethod void contactAddressTestMethod4(){
        String REFERENCEDATA_CITY_TYPE = SystemSettings.REFERENCEDATA_CITY_TYPE;
        String REFERENCEDATA_COUNTRY_TYPE = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
                
        String CITY_F = 'parxF20100126';
        String CITY_E = 'parxE20100126';
        
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String ADDRESS_PRIVATE_ADDRESS = SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE;
        String ADDRESS_BILLING_ADDRESS = SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE;
        
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_STUDENT_PERMANENT_ADDRESS; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE
        String CONTACT_PRIVATE_ADDRESS = SystemSettings.CONTACT_PRIVATE_ADDRESS; //PICKLIST VALUE
        String CONTACT_BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        
        
        String FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        //Account
        String BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        //*****************************
       try{
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(guiUser) { 
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
                cityParx.ZIP_Code__c = '1256';
                insert cityParx;        
                          
               
                List<Account> accountList = new List<Account>();
                Account a = new Account(Name = 'Parx AG', City_English__c = 'Zurich', Address_Type__c = BILLING_ADDRESS);
                insert a; 
                TriggerContext.reset();       
                
            
                //insert contact with wrong city CH (with zip code)
                Contact c2 = new Contact(AccountId = a.Id, Lastname = 'MUSTER2', Firstname = 'tester', Street_Name_Nr_Preferred__c = 'Street n', ZIP_Code_Preferred__c = '8996', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Country_Preferred__c = 'SWITZERLAND', City_English__c = 'xxderwer45', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                try{
                    insert c2;
                    System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** contactAddressTestMethod4 Exception shoud happen> ' + e);
                }
                TriggerContext.reset();
                
                //insert contact with wrong city CH (with no code)
                Contact c3 = new Contact(AccountId = a.Id, Lastname = 'MUSTER3', Firstname = 'tester', Street_Name_Nr_Preferred__c = 'Street n', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Country_Preferred__c = 'SWITZERLAND', City_English__c = 'xxderwer45neu', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                try{
                    insert c3;
                    System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** contactAddressTestMethod4 Exception shoud happen> ' + e);
                }
                TriggerContext.reset();
                
                //insert contact with valid city CH (with zip code)
                Contact c4 = new Contact(AccountId = a.Id, Lastname = 'MUSTER4', Firstname = 'tester', Street_Name_Nr_Preferred__c = 'Street n', 
                                        ZIP_Code_Preferred__c = '1256', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, 
                                        Country_Preferred__c = 'SWITZERLAND', City_English__c = CITY_E, Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                insert c4;
                TriggerContext.reset();
                
                //insert contact with valid city CH (no zip code)
                Contact c5 = new Contact(AccountId = a.Id, Lastname = 'MUSTER5', Firstname = 'tester', Street_Name_Nr_Preferred__c = 'Street n', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Country_Preferred__c = 'SWITZERLAND', City_English__c = CITY_E, Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                insert c5;
                TriggerContext.reset();
                
                //insert contact not in switzerland
                Contact c6 = new Contact(AccountId = a.Id, Lastname = 'MUSTER6', Firstname = 'tester', Street_Name_Nr_Preferred__c = 'Street n', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Country_Preferred__c = 'ITALY', City_English__c = 'sfsdfrom', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                insert c6;
                TriggerContext.reset();
            }
        }catch(System.Exception e){
            System.debug('**** Final Exception ContactAddressTEST 4 ' + e);
            System.assert(false);

        }
     }
     
     static testMethod void contactAddressTestMethod44(){
        String REFERENCEDATA_CITY_TYPE = SystemSettings.REFERENCEDATA_CITY_TYPE;
        String REFERENCEDATA_COUNTRY_TYPE = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
                
        String CITY_F = 'parxF20100126';
        String CITY_E = 'parxE20100126';
        
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String ADDRESS_PRIVATE_ADDRESS = SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE;
        String ADDRESS_BILLING_ADDRESS = SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE;
        
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_STUDENT_PERMANENT_ADDRESS; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE
        String CONTACT_PRIVATE_ADDRESS = SystemSettings.CONTACT_PRIVATE_ADDRESS; //PICKLIST VALUE
        String CONTACT_BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        
        
        String FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        //Account
        String BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        //*****************************
       try{
            User nonGuiUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(nonGuiUser) { 
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
                cityParx.ZIP_Code__c = '1256';
                insert cityParx;        
                          
               
                List<Account> accountList = new List<Account>();
                Account a = new Account(Name = 'Parx AG', City_English__c = 'Zurich', Address_Type__c = BILLING_ADDRESS);
                insert a; 
                TriggerContext.reset();       
                
            
                //insert contact with wrong city CH (with zip code) ==> should work non gui user
                Contact c2 = new Contact(AccountId = a.Id, Lastname = 'MUSTER2', Firstname = 'tester', Street_Name_Nr_Preferred__c = 'Street n', ZIP_Code_Preferred__c = '8996', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Country_Preferred__c = 'SWITZERLAND', City_English__c = 'xxderwer45', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                try{
                    insert c2;
                }catch(System.DMLException e){
                   System.debug('**** contactAddressTestMethod4 Exception> ' + e);
                  System.assert(false);
                }
                TriggerContext.reset();
                
                 //set because non gui user
                Contact cc1 = [Select c.UpdatedBySpecialUser__c from Contact c where c.Id = :c2.Id];
                System.assert(cc1.UpdatedBySpecialUser__c);
                
                //insert contact with wrong city CH (with no code) ==> should work non gui user
                Contact c3 = new Contact(AccountId = a.Id, Lastname = 'MUSTER3', Firstname = 'tester', Street_Name_Nr_Preferred__c = 'Street n', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_BUSINESS_ADDRESS, Country_Preferred__c = 'SWITZERLAND', City_English__c = 'xxderwer45neu', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                try{
                    insert c3;
                }catch(System.DMLException e){
                   System.debug('**** contactAddressTestMethod4 Exception> ' + e);
                    System.assert(false);
                }
                TriggerContext.reset();
                 //set because non gui user
                cc1 = [Select c.UpdatedBySpecialUser__c from Contact c where c.Id = :c3.Id];
                System.assert(cc1.UpdatedBySpecialUser__c);
               
            }
        }catch(System.Exception e){
            System.debug('**** Final Exception ContactAddressTEST 44 ' + e);
            System.assert(false);

        }
     }
     
     
     static testMethod void contactAddressTestMethod5(){
        String ADDRESS_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE;
        String ADDRESS_STUDENT_PERMANENT_ADDRESS = SystemSettings.CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE;
        String ADDRESS_BUSINESS_ADDRESS = SystemSettings.CONTACT_ADDRESS_BUSINESS_RECORDTYPE;
        String ADDRESS_PRIVATE_ADDRESS = SystemSettings.CONTACT_ADDRESS_PRIVATE_RECORDTYPE;
        String ADDRESS_BILLING_ADDRESS = SystemSettings.CONTACT_ADDRESS_BILLING_RECORDTYPE;
        String ADDRESS_CONTACT_PERMANENT_TYPE = SystemSettings.CONTACT_ADDRESS_PERMANENT_RECORDTYPE;

    
        String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
        String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_STUDENT_PERMANENT_ADDRESS; //PICKLIST VALUE
        String CONTACT_BUSINESS_ADDRESS = SystemSettings.CONTACT_BUSINESS_ADDRESS; //PICKLIST VALUE
        String CONTACT_PRIVATE_ADDRESS = SystemSettings.CONTACT_PRIVATE_ADDRESS; //PICKLIST VALUE
        String CONTACT_BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        String CONTACT_PERMANENT_ADDRESS = SystemSettings.CONTACT_PERMANENT_ADDRESS; //PICKLIST VALUE
        
        String FRENCH = SystemSettings.LANGUAGE_FRENCH;
        
        //Account
        String BILLING_ADDRESS = SystemSettings.CONTACT_BILLING_ADDRESS; //PICKLIST VALUE
        //*****************************
        
        
        List<Address__c> addrList;
        
        try{
            
            String addressType = CONTACT_BILLING_ADDRESS;
            List<Account> accountList = new List<Account>();
            Account a = new Account(Name = 'Parx AG', City_English__c = 'Zurich', Address_Type__c = BILLING_ADDRESS);
            accountList.add(a);
            
            Account a2 = new Account(Name = 'Test AG 2', City_English__c = 'Las Vegas', Address_Line_3_Preferred__c = 'adr3', Address_Line_2_Preferred__c = 'adr2', Street_Name_Nr_Preferred__c = 'the street',  PO_Box_Preferred__c = 'po', Address_Type__c = BILLING_ADDRESS); 
            accountList.add(a2);
            insert accountList;
            
           
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(guiUser) { 
            
                //**********************************
                //attach new Account, change one contact to that account, check that account address is taken
                Contact c2 = new Contact(AccountId = a.Id, Lastname = 'MUSTER', Firstname = 'Erika', Street_Name_Nr_Preferred__c = 'Street', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = addressType, City_English__c = 'Zurich', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                insert c2;
                TriggerContext.reset();
                c2.AccountId = a2.Id;
                try{
                    update c2;
                    TriggerContext.reset();
                 }catch(System.DMLException e){
                    System.debug('**** TEST Exception ' + e);
                    System.assert(false);
                 }
                 
                Contact cc = [Select c.Id, c.City_English__c, Address_Line_3_Preferred__c from Contact c where c.Id = :c2.Id];
                System.assertEquals(cc.City_English__c , 'Las Vegas');
                System.assertEquals(cc.Address_Line_3_Preferred__c , 'adr3');
                
                //check that billing address was taken
                addrList = [Select c.RecordTypeId from Address__c c where c.Contact__c = :cc.Id];
                if(addrList.isEmpty()){
                    System.assert(false);
                }else{
                    System.assertEquals(addrList[0].RecordTypeId , ADDRESS_BILLING_ADDRESS);
                }
                
                //change recordtype to contact permanent, see if recordtype also changes
               c2.Address_Type__c = CONTACT_PERMANENT_ADDRESS;
               update c2;
                TriggerContext.reset();
               addrList = [Select c.RecordTypeId from Address__c c where c.Contact__c = :c2.Id];
                if(addrList.isEmpty()){
                    System.assert(false);
                }else{
                    System.assertEquals(addrList[0].RecordTypeId , ADDRESS_CONTACT_PERMANENT_TYPE);
                }
                
                //create contact with contact permanent, check that recordtype fits
                Contact c3 = new Contact(AccountId = a.Id, Lastname = 'MUSTER', Firstname = 'Erika', Street_Name_Nr_Preferred__c = 'Street', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', Address_Type__c = CONTACT_PERMANENT_ADDRESS, City_English__c = 'Zurich', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                insert c3;
                TriggerContext.reset();
                addrList = [Select c.RecordTypeId from Address__c c where c.Contact__c = :c3.Id];
                if(addrList.isEmpty()){
                    System.assert(false);
                }else{
                    System.assertEquals(addrList[0].RecordTypeId , ADDRESS_CONTACT_PERMANENT_TYPE);
                }
                
                //check if recordtype changes
                Contact c5 = new Contact(AccountId = a.Id, Lastname = 'MUSTER', Firstname = 'Erika', Address_Type__c = CONTACT_TIMESTUDY_ADDRESS, Street_Name_Nr_Preferred__c = 'Street', Preferred_Language__c = FRENCH, PO_Box_Preferred__c = 'po box', City_English__c = 'Zurich', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c  = 'Line 2');
                insert c5;
                TriggerContext.reset();
                Address__c adr5 = [Select c.RecordTypeId from Address__c c where c.Contact__c = :c5.Id];
                System.assertEquals(adr5.RecordTypeId , ADDRESS_TIMESTUDY_ADDRESS);
                
                c5.Address_Type__c = CONTACT_STUDENT_PERMANET_ADDRESS;
                c5.City_English__c = 'Zurich';
                update c5;
                TriggerContext.reset();
                adr5 = [Select c.City_English__c, c.RecordTypeId from Address__c c where c.Contact__c = :c5.Id];
                System.assertEquals(adr5.City_English__c , 'Zurich');
                System.assertEquals(adr5.RecordTypeId , ADDRESS_STUDENT_PERMANENT_ADDRESS);
            }
        }catch(System.Exception e){
            System.debug('**** Final Exception Testmethod> ' + e);
            System.assert(false);

        }
     }
     
     
     static testMethod void contactTestNetwork(){
        String ACCOUNTCONTACT_ID = SystemSettings.NEWTOWRK_ACCOUNTCONTACT_RECORDTYPE;
        String CONTACTACCOUNT_ID = SystemSettings.NEWTOWRK_CONTACTACCOUNT_RECORDTYPE;
        
        try{  
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(guiUser) {   
                List<Account> accountList = new List<Account>(); 
                Account a1 = new Account(Name = 'parx test ag1', City_English__c = 'xxrterTT', Zip_Code_Preferred__c = '5789', Street_Name_Nr_Preferred__c = 'teststrasse', Address_Type__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS);
                accountList.add(a1);
                Account a2 = new Account(Name = 'parx test ag2', City_English__c = 'whatever', Zip_Code_Preferred__c = '8004', Street_Name_Nr_Preferred__c = 'teststrasse 2', Address_Type__c = SystemSettings.ACCOUNT_BILLING_ADDRESS);
                accountList.add(a2);
                        
                try{
                    insert accountList;
                    TriggerContext.reset();
                }catch(System.DMLException e){
                    System.debug('**** TEST Exception insert account> ' + e);
                    System.assert(false);
                }
         
                List<Contact> contactList = new List<Contact>(); 
                Contact c1 = new Contact(AccountId = a1.Id, Lastname = 'MUSTER1', Firstname = 'Max1');
                contactList.add(c1);
                Contact c2 = new Contact(AccountId = a1.Id, Lastname = 'MUSTER2', Firstname = 'Max2');
                contactList.add(c2);
                
                try{
                    insert contactList;
                    TriggerContext.reset();
                }catch(System.DMLException e){
                    System.debug('**** TEST Exception insert contact> ' + e);
                    System.assert(false);
                }
                
                //check that no network is created
                List<Network__c> networks = [Select n.Id from Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and (Contact_to__c = :c1.Id or Contact_to__c = :c2.Id)];
                System.assert(networks.isEmpty());
                
                c2.Description = 'new test decription testmethod';
                update c2;
                TriggerContext.reset();
                
                networks = [Select n.Id from Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and Contact_to__c = :c2.Id];
                System.assert(networks.isEmpty());
                    
                //update account of c1
                c1.AccountId = a2.Id;
                update c1;
                TriggerContext.reset();
                
                networks = [Select n.Id from Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and Contact_to__c = :c1.Id];
                System.assertEquals(networks.size(), 1);
                
                networks = [Select n.Id from Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and Contact_from__c = :c1.Id];
                System.assertEquals(networks.size(), 1);
                
                //check that Belongs_to_this_Account_since__c is changed to today
                Contact c11 = [Select c.Belongs_to_this_Account_since__c, City_English__c, Zip_Code_Preferred__c, Street_Name_Nr_Preferred__c from Contact c where c.Id = :c1.Id];
                System.assertEquals(c11.Belongs_to_this_Account_since__c, Date.today());
                
                //check that address from new account is taken
                System.assertEquals(c11.City_English__c, 'whatever');
                System.assertEquals(c11.Street_Name_Nr_Preferred__c, 'teststrasse 2');
                System.assertEquals(c11.Zip_Code_Preferred__c, '8004');
                
                //check that also preferred address is updated
                List<Address__c> addrList = [Select a.City_English__c, a.Zip_Code__c, a.Street_Name_Nr__c, a.Preferred_Address__c From Address__c a where a.Preferred_Address__c = true and a.Contact__c = :c1.Id];
    
                if(!addrList.isEmpty()){
                    Address__c addr = addrList[0];
                    System.assert(addr.Preferred_Address__c);
                    System.assertEquals(addr.City_English__c, 'whatever');
                    System.assertEquals(addr.Street_Name_Nr__c, 'teststrasse 2');
                    System.assertEquals(addr.Zip_Code__c, '8004');
                }else{
                    System.assert(false);
                }
                
           }
        }catch(System.Exception e){
            System.debug('***** Final Exception ContactAddressTEST 5: ' + e);
            System.assert(false);
        }
    }
    
   
}