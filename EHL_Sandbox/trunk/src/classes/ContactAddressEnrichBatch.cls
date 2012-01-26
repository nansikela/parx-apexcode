public class ContactAddressEnrichBatch{
    
    public void startBatch(){
        ContactAddressEnrichBatchable batchJob = new ContactAddressEnrichBatchable();
        Id asyncId = Database.executeBatch(batchJob, 1);  //batch size is only 1
        System.debug('*** asyncId: '+ asyncId);
    }
    
    
    
     //********** TESTMETHODS
    static testMethod void contactAddressEnricherTestMethod1() {
        try{                    
            String CITY_F1 = 'parxF20100127';
            String CITY_E1 = 'parxE20100ntry127';
            
            String CITY_F2 = 'xparxF20100127x';
            String CITY_E2 = 'xparxE20100127x';
            
            String CITY_F3 = 'zxparxF20100127xz';
            String CITY_E3 = 'zxparxE20100127xz';
            
            String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
            String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_PERMANENT_ADDRESS; //PICKLIST VALUE

            String LANGUAGE_FRENCH = SystemSettings.LANGUAGE_FRENCH;
            String LANGUAGE_ENGLISH = SystemSettings.LANGUAGE_ENGLISH;
            
            User notGUIUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
        
            //create city
            List<Reference_Data__c> tempList = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'SWITZERLAND' limit 1];
            Reference_Data__c countryPARX;
            if(tempList.isEmpty()) {
                countryPARX = new Reference_Data__c();
                countryPARX.Name = 'SWITZERLAND';
                countryPARX.RecordTypeId = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
                countryPARX.Country_Francais__c = 'SUISSE';
                countryPARX.Country_English__c = 'SWITZERLAND';
                countryPARX.Country_Code__c = 'CH';
                insert countryPARX;

                System.debug('**** countryPARX ' + countryPARX);
            } else {
                countryPARX = tempList[0];
                System.debug('**** countryPARX else ' + countryPARX);
                
            }
            Reference_Data__c countryItaly = new Reference_Data__c();
            countryItaly.Name = 'ITALY';
            countryItaly.RecordTypeId = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
            countryItaly.Country_Francais__c = 'ITALIE';
            countryItaly.Country_English__c = 'ITALY';
            countryItaly.Country_Code__c = 'IT';
            try{
                insert countryItaly;
            }catch(System.DMLException e){
                //query data if already exist
                countryItaly = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'ITALY' limit 1];   
            }
            
            List<Reference_Data__c> refList = new List<Reference_Data__c>();
            
            Reference_Data__c cityParx1 = new Reference_Data__c();
            cityParx1.Name = CITY_E1;
            cityParx1.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx1.City_Francais__c = CITY_F1;
            cityParx1.City_English__c = CITY_E1;
            cityParx1.City_Country__c = countryPARX.Id;
            cityParx1.ZIP_Code__c = 'tt9898';
            cityParx1.State_Canton__c = 'AG';
            refList.add(cityParx1);
            
            Reference_Data__c cityParx2 = new Reference_Data__c();
            cityParx2.Name = CITY_E2;
            cityParx2.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx2.City_Francais__c = CITY_F2;
            cityParx2.City_English__c = CITY_E2;
            cityParx2.City_Country__c = countryPARX.Id;
            cityParx2.ZIP_Code__c = 'tt1256';
            cityParx2.State_Canton__c = 'ZH';
            refList.add(cityParx2);           
            
            insert refList;
            
            System.runAs(notGUIUser) {
                
                List<Contact> contactList = new List<Contact>();
                
                //English
                //contact with no zip
                Contact c1 = new Contact(Firstname = 'Parx 1', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', City_English__c = CITY_F1, Address_Type__c = CONTACT_TIMESTUDY_ADDRESS, Country_Preferred__c = 'SUISSE' );
                contactList.add(c1);
                
                //contact with zip
                Contact c2 = new Contact(Firstname = 'Parx 2', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', City_English__c = CITY_E2, Address_Type__c = CONTACT_TIMESTUDY_ADDRESS, Country_Preferred__c = 'SUISSE', ZIP_Code_Preferred__c = 'tt1256' );
                contactList.add(c2);
                
                //contact with nonvalid city
                Contact c3 = new Contact(Firstname = 'Parx 3', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', City_English__c = 'nada', Address_Type__c = CONTACT_STUDENT_PERMANET_ADDRESS, Country_Preferred__c = 'SUISSE' );
                contactList.add(c3);
                
                
                //FRENCH
                //contact with no zip
                Contact c4 = new Contact(Firstname = 'Parx 4', Preferred_Language__c = LANGUAGE_FRENCH, Lastname = 'Muster', City_English__c = CITY_F1, Address_Type__c = CONTACT_TIMESTUDY_ADDRESS, Country_Preferred__c = 'SUISSE' );
                contactList.add(c4);
                
                //contact with zip
                Contact c5 = new Contact(Firstname = 'Parx 5', Preferred_Language__c = LANGUAGE_FRENCH, Lastname = 'Muster', City_English__c = CITY_E2, Address_Type__c = CONTACT_TIMESTUDY_ADDRESS, Country_Preferred__c = 'SUISSE', ZIP_Code_Preferred__c = 'tt1256' );
                contactList.add(c5);
            
            
                insert contactList;
                
                //check that flag was set
                List<Contact> contactList2 = [Select c.UpdatedBySpecialUser__c from Contact c where c.Id in :contactList];
                for(Contact c : contactList2) {
                    System.assert(c.UpdatedBySpecialUser__c);
                }
                
                //********************** FIRST CONTACT
                String query = 'Select c.ZIP_Code_Preferred__c, c.OwnerId, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.City_PL2__c ';
                query = query + 'From Contact c ';
                query = query + 'where c.Id = \'' + c1.Id+ '\'';
    
                ContactAddressEnrichBatchable batch = new ContactAddressEnrichBatchable(query);
                System.debug('*** before batchjob1');
                Test.startTest();
                Id batchId1 = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId1);
               
                //********************** SECOND CONTACT
                query = 'Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.OwnerId, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.City_PL2__c ';
                query = query + 'From Contact c ';
                query = query + 'where c.Id = \'' + c2.Id+ '\'';
    
                batch = new ContactAddressEnrichBatchable(query);
                System.debug('*** before batchjob2');
                Id batchId2  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId2);
                
                //********************** THIRD CONTACT
                query = 'Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.OwnerId, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.City_PL2__c ';
                query = query + 'From Contact c ';
                query = query + 'where c.Id = \'' + c3.Id+ '\'';
    
                batch = new ContactAddressEnrichBatchable(query);
                System.debug('*** before batchjob3');
                Id batchId3  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId3);
                
                 //********************** FORTH CONTACT
                query = 'Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.OwnerId, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.City_PL2__c ';
                query = query + 'From Contact c ';
                query = query + 'where c.Id = \'' + c4.Id+ '\'';
    
                batch = new ContactAddressEnrichBatchable(query);
                System.debug('*** before batchjob4');
                Id batchId4  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId4);
                
                //********************** FIFTH CONTACT
                query = 'Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.OwnerId, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.City_PL2__c ';
                query = query + 'From Contact c ';
                query = query + 'where c.Id = \'' + c5.Id+ '\'';
    
                batch = new ContactAddressEnrichBatchable(query);
                System.debug('*** before batchjob5');
                Id batchId5  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId5);
     
    
                Test.stopTest();
                
                
                List<AsyncApexJob> jobList = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId3 or Id = :batchId2 or Id = :batchId1 or Id = :batchId4 or Id = :batchId5];
                for(AsyncApexJob a : jobList){
                    System.debug('**** Final results are: '+a);
                }
                
                //******************** CHECKING
                List<Task> taskList = [Select subject, id from Task where WhoId = :c1.Id];
                System.assert(taskList.isEmpty());
                List<Contact> contactListAfter = [Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.City_PL2__c  from Contact c where c.Id = :c1.Id];
                System.assertEquals(contactListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(contactListAfter[0].City_English__c, CITY_F1);
                
                
                taskList = [Select id from Task where WhoId = :c2.Id];
                System.assert(taskList.isEmpty());
                contactListAfter = [Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.City_PL2__c  from Contact c where c.Id = :c2.Id];
                System.assertEquals(contactListAfter[0].ZIP_Code_Preferred__c, 'tt1256');
                System.assertEquals(contactListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(contactListAfter[0].City_English__c, CITY_E2);
                
                taskList = [Select id from Task where WhoId = :c3.Id];
                System.assertEquals(taskList.size(), 1);
                contactListAfter = [Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.City_PL2__c  from Contact c where c.Id = :c3.Id];
                System.assertEquals(contactListAfter[0].ZIP_Code_Preferred__c, null);
                System.assertEquals(contactListAfter[0].State_Preferred__c, null);
                System.assertEquals(contactListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                
                taskList = [Select id from Task where WhoId = :c4.Id];
                System.assert(taskList.isEmpty());
                contactListAfter = [Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.City_PL2__c  from Contact c where c.Id = :c4.Id];
                System.assertEquals(contactListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(contactListAfter[0].City_English__c, CITY_F1);
                
                taskList = [Select id from Task where WhoId = :c5.Id];
                System.assert(taskList.isEmpty());
                contactListAfter = [Select c.ZIP_Code_Preferred__c, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.City_PL2__c  from Contact c where c.Id = :c5.Id];
                System.assertEquals(contactListAfter[0].ZIP_Code_Preferred__c, 'tt1256');
                System.assertEquals(contactListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(contactListAfter[0].City_English__c, CITY_E2);
                
                 //check that flag was unset
                contactList2 = [Select c.UpdatedBySpecialUser__c from Contact c where c.Id in :contactList];
                for(Contact c : contactList2) {
                    System.assert(!c.UpdatedBySpecialUser__c);
                }
            }
        }catch(System.Exception e){
            System.debug('**** Exception occured: ' + e);
            System.assertEquals(e.getMessage(), null);
            System.assert(false);
        }
        
    }
    
    //********** TESTMETHODS
    static testMethod void contactAddressEnricherTestMethod2() {
        try{            
            String CITY_F1 = 'parxF20100131';
            String CITY_E1 = 'parxE20100127';
            
            String CITY_F2 = 'xparxF20100131x';
            String CITY_E2 = 'xparxE20100131x';
            
            String CITY_F3 = 'zxparxF20100131xz';
            String CITY_E3 = 'zxparxE20100131xz';
            
            String CONTACT_TIMESTUDY_ADDRESS = SystemSettings.CONTACT_TIME_OF_STUDY; //PICKLIST VALUE
            String CONTACT_STUDENT_PERMANET_ADDRESS = SystemSettings.CONTACT_PERMANENT_ADDRESS; //PICKLIST VALUE

            String LANGUAGE_FRENCH = SystemSettings.LANGUAGE_FRENCH;
            String LANGUAGE_ENGLISH = SystemSettings.LANGUAGE_ENGLISH;
            
            User notGUIUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
        
            //create city
            List<Reference_Data__c> tempList = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'SWITZERLAND' limit 1];
            Reference_Data__c countryPARX;
            if(tempList.isEmpty()) {
                countryPARX = new Reference_Data__c();
                countryPARX.Name = 'SWITZERLAND';
                countryPARX.RecordTypeId = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
                countryPARX.Country_Francais__c = 'SUISSE';
                countryPARX.Country_English__c = 'SWITZERLAND';
                countryPARX.Country_Code__c = 'CH';
                insert countryPARX;

                System.debug('**** countryPARX ' + countryPARX);
            } else {
                countryPARX = tempList[0];
                System.debug('**** countryPARX else ' + countryPARX);
                
            }
            Reference_Data__c countryItaly = new Reference_Data__c();
            countryItaly.Name = 'ITALY';
            countryItaly.RecordTypeId = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
            countryItaly.Country_Francais__c = 'ITALIE';
            countryItaly.Country_English__c = 'ITALY';
            countryItaly.Country_Code__c = 'IT';
            try{
                insert countryItaly;
            }catch(System.DMLException e){
                //query data if already exist
                countryItaly = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'ITALY' limit 1];   
            }
            
            List<Reference_Data__c> refList = new List<Reference_Data__c>();
            
            Reference_Data__c cityParx1 = new Reference_Data__c();
            cityParx1.Name = CITY_E1;
            cityParx1.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx1.City_Francais__c = CITY_F1;
            cityParx1.City_English__c = CITY_E1;
            cityParx1.City_Country__c = countryPARX.Id;
            cityParx1.ZIP_Code__c = 'tt9898';
            cityParx1.State_Canton__c = 'AG';
            refList.add(cityParx1);
            
            Reference_Data__c cityParx2 = new Reference_Data__c();
            cityParx2.Name = CITY_E2;
            cityParx2.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx2.City_Francais__c = CITY_F2;
            cityParx2.City_English__c = CITY_E2;
            cityParx2.City_Country__c = countryPARX.Id;
            cityParx2.ZIP_Code__c = 'tt1256';
            cityParx2.State_Canton__c = 'ZH';
            refList.add(cityParx2);
            
            Reference_Data__c cityParx3 = new Reference_Data__c();
            cityParx3.Name = CITY_E3;
            cityParx3.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx3.City_Francais__c = CITY_F3;
            cityParx3.City_English__c = CITY_E3;
            cityParx3.City_Country__c = countryPARX.Id;
            cityParx3.ZIP_Code__c = 'tt5800';
            cityParx3.State_Canton__c = 'BE';
            refList.add(cityParx3);
            
            Reference_Data__c cityParx4 = new Reference_Data__c();
            cityParx4.Name = CITY_E3;
            cityParx4.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx4.City_Francais__c = CITY_F3;
            cityParx4.City_English__c = CITY_E3;
            cityParx4.City_Country__c = countryPARX.Id;
            cityParx4.ZIP_Code__c = 'tt5801';
            cityParx4.State_Canton__c = 'BE';
            refList.add(cityParx4);            
            
            insert refList;
            
            System.runAs(notGUIUser) {
                List<Contact> contactList = new List<Contact>();
                
                //English
                
                //contact only zip
                Contact c1 = new Contact(Firstname = 'Parx 6', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', ZIP_Code_Preferred__c = 'tt9898', Address_Type__c = CONTACT_STUDENT_PERMANET_ADDRESS, Country_Preferred__c = 'SUISSE' );
                contactList.add(c1);
                
                
                //FRENCH
                //contact only zip
                Contact c2 = new Contact(Firstname = 'Parx 7', Preferred_Language__c = LANGUAGE_FRENCH, Lastname = 'Muster', ZIP_Code_Preferred__c = 'tt1256', Address_Type__c = CONTACT_STUDENT_PERMANET_ADDRESS, Country_Preferred__c = 'SUISSE' );
                contactList.add(c2);
                insert contactList;
                
                //********************** FIRST CONTACT
                String query = 'Select c.ZIP_Code_Preferred__c, c.OwnerId, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.City_PL2__c ';
                query = query + 'From Contact c ';
                query = query + 'where c.Id = \'' + c1.Id+ '\'';
    
                Test.startTest();
                ContactAddressEnrichBatchable batch = new ContactAddressEnrichBatchable(query);
                System.debug('*** before batchjob1');
                Id batchId1  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId1);
                
                
                //********************** SECOND CONTACT
                query = 'Select c.ZIP_Code_Preferred__c, c.OwnerId, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.City_PL2__c ';
                query = query + 'From Contact c ';
                query = query + 'where c.Id = \'' + c2.Id+ '\'';
    
                batch = new ContactAddressEnrichBatchable(query);
                System.debug('*** before batchjob2');
                Id batchId2  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId2);
    
                Test.stopTest();
                
                
                List<AsyncApexJob> jobList = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId2 or Id = :batchId1];
                for(AsyncApexJob a : jobList){
                    System.debug('**** Final results are: '+a);
                }
                
                //******************** CHECKING         
                List<Contact> contactListAfter = [Select c.ZIP_Code_Preferred__c, c.Country_Preferred__c from Contact c where c.Id = :c1.Id];
                System.assertEquals(contactListAfter[0].ZIP_Code_Preferred__c, 'tt9898');
                System.assertEquals(contactListAfter[0].Country_Preferred__c, 'SWITZERLAND');
       
                contactListAfter = [Select c.ZIP_Code_Preferred__c, c.Country_Preferred__c from Contact c where c.Id = :c2.Id];
                System.assertEquals(contactListAfter[0].ZIP_Code_Preferred__c, 'tt1256');
                System.assertEquals(contactListAfter[0].Country_Preferred__c, 'SWITZERLAND');
            }    
        }catch(System.Exception e){
            System.debug('**** Exception occured: ' + e);
            System.assertEquals(e.getMessage(), null);
            System.assert(false);
        }
        
    }
}