public class LeadAddressEnrichBatch{
    
    public void startBatch(){  
        LeadAddressEnrichBatchable batchJob = new LeadAddressEnrichBatchable();
        Id asyncId = Database.executeBatch(batchJob, 1);  //batch size is only 1
        System.debug('*** asyncId: '+ asyncId);
    }
    
    
    
    //********** TESTMETHODS
    static testMethod void leadAddressEnricherTestMethod1() {
        try{                    
            String CITY_F1 = 'parxF20100129';
            String CITY_E1 = 'parxE20100129';
            
            String CITY_F2 = 'xparxF20100129x';
            String CITY_E2 = 'xparxE20100129x';
            
            String CITY_F3 = 'zxparxF20100129xz';
            String CITY_E3 = 'zxparxE20100129xz';

            String LANGUAGE_FRENCH = 'Français';
            String LANGUAGE_ENGLISH = 'English';
        
            User notGUIUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
         
            //create city
            Reference_Data__c countryPARX = new Reference_Data__c();
            countryPARX.Name = 'SWITZERLAND';
            countryPARX.RecordTypeId = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
            countryPARX.Country_Francais__c = 'SUISSE';
            countryPARX.Country_English__c = 'SWITZERLAND';
            countryPARX.Country_Code__c = 'CH';
            try{
                insert countryPARX;
            }catch(System.DMLException e){
                //query data if already exist
                countryPARX = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'SWITZERLAND' limit 1];   
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
            cityParx1.ZIP_Code__c = 'yy9898';
            cityParx1.State_Canton__c = 'AG';
            refList.add(cityParx1);
            
            Reference_Data__c cityParx2 = new Reference_Data__c();
            cityParx2.Name = CITY_E2;
            cityParx2.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx2.City_Francais__c = CITY_F2;
            cityParx2.City_English__c = CITY_E2;
            cityParx2.City_Country__c = countryPARX.Id;
            cityParx2.ZIP_Code__c = 'yy1256';
            cityParx2.State_Canton__c = 'ZH';
            refList.add(cityParx2);
            
            Reference_Data__c cityParx3 = new Reference_Data__c();
            cityParx3.Name = CITY_E3;
            cityParx3.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx3.City_Francais__c = CITY_F3;
            cityParx3.City_English__c = CITY_E3;
            cityParx3.City_Country__c = countryPARX.Id;
            cityParx3.ZIP_Code__c = 'yy5800';
            cityParx3.State_Canton__c = 'BE';
            refList.add(cityParx3);
            
            Reference_Data__c cityParx4 = new Reference_Data__c();
            cityParx4.Name = CITY_E3;
            cityParx4.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx4.City_Francais__c = CITY_F3;
            cityParx4.City_English__c = CITY_E3;
            cityParx4.City_Country__c = countryPARX.Id;
            cityParx4.ZIP_Code__c = 'yy5801';
            cityParx4.State_Canton__c = 'BE';
            refList.add(cityParx4);
            
            
            insert refList;
            
            List<Lead> leadList = new List<Lead>();
            List<Lead> leadList2 = new List<Lead>();
            
            System.runAs(notGUIUser) {
                //SUISSE
                //Lead with no zip
                Lead l1 = new Lead(Company = 'EHL 1', Firstname = 'Parx 1', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', City_English__c = CITY_F1, Country__c = 'SUISSE' );
                leadList.add(l1);
                
                //Lead with zip
                Lead l2 = new Lead(Company = 'EHL2 ', Firstname = 'Parx 2', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', City_English__c = CITY_E2, Country__c = 'SUISSE', ZIP_Code__c = 'yy1256' );
                leadList.add(l2);
                
                //Lead no zip
                Lead l3 = new Lead(Company = 'EHL 3', Firstname = 'Parx 3', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', City_English__c = CITY_E3, Country__c = 'SUISSE' );
                leadList.add(l3);
                
                
                //other countries
                //Lead with no zip
                Lead l4 = new Lead(Company = 'EHL 4', Firstname = 'Parx 4', Preferred_Language__c = LANGUAGE_FRENCH, Lastname = 'Muster', City_English__c = 'testCity', Country__c = 'ITALIE' );
                leadList.add(l4);
                
                //Lead with zip
                Lead l5 = new Lead(Company = 'EHL5', Firstname = 'Parx 5', Preferred_Language__c = LANGUAGE_FRENCH, Lastname = 'Muster', City_English__c = 'testCity', Country__c = 'ITALIE', ZIP_Code__c = '9855' );
                leadList.add(l5);
                
                insert leadList;
                
                //check that flag was set
                leadList2 = [Select l.UpdatedBySpecialUser__c from Lead l where l.Id in :leadList];
                for(Lead l : leadList2) {
                    System.assert(l.UpdatedBySpecialUser__c);
                }
            
                
                
                //********************** FIRST CONTACT
                String query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
                query = query + 'From Lead l ';
                query = query + 'where l.Id = \'' + l1.Id+ '\' and l.IsConverted = false';
    
                LeadAddressEnrichBatchable batch = new LeadAddressEnrichBatchable(query);
                System.debug('*** before batchjob1');
                Test.startTest();
                Id batchId1 = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId1);
                
                //********************** SECOND CONTACT
                query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
                query = query + 'From Lead l ';
                query = query + 'where l.Id = \'' + l2.Id+ '\' and l.IsConverted = false';
    
                batch = new LeadAddressEnrichBatchable(query);
                System.debug('*** before batchjob2');
                Id batchId2  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId2);
                
                //********************** THIRD CONTACT
                query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
                query = query + 'From Lead l ';
                query = query + 'where l.Id = \'' + l3.Id+ '\' and l.IsConverted = false';
    
                batch = new LeadAddressEnrichBatchable(query);
                System.debug('*** before batchjob3');
                Id batchId3  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId3);
                
                 //********************** FORTH CONTACT
                query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
                query = query + 'From Lead l ';
                query = query + 'where l.Id = \'' + l4.Id+ '\' and l.IsConverted = false';
    
                batch = new LeadAddressEnrichBatchable(query);
                System.debug('*** before batchjob2');
                Id batchId4  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId4);
                
                //********************** FIFTH CONTACT
                query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
                query = query + 'From Lead l ';
                query = query + 'where l.Id = \'' + l5.Id+ '\' and l.IsConverted = false';
    
                batch = new LeadAddressEnrichBatchable(query);
                System.debug('*** before batchjob3');
                Id batchId5  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId5);
    
                Test.stopTest();
                
                
                List<AsyncApexJob> jobList = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId3 or Id = :batchId2 or Id = :batchId1 or Id = :batchId4 or Id = :batchId5];
                for(AsyncApexJob a : jobList){
                    System.debug('**** Final results are: '+a);
                }
                
                //******************** CHECKING
                List<Task> taskList = [Select id from Task where WhoId = :l1.Id];
                System.assert(taskList.isEmpty());
                List<Lead> leadListAfter = [Select l.ZIP_Code__c, l.State__c, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c from Lead l where l.Id = :l1.Id];
                System.assertEquals(leadListAfter[0].Country__c, 'SWITZERLAND');
                System.assertEquals(leadListAfter[0].City_English__c, CITY_F1);
                System.assertEquals(leadListAfter[0].Country_PL__c, 'SWITZERLAND');
                
                
                taskList = [Select id from Task where WhoId = :l2.Id];
                System.assert(taskList.isEmpty());
                leadListAfter = [Select l.ZIP_Code__c, l.State__c, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c from Lead l where l.Id = :l2.Id];
                System.assertEquals(leadListAfter[0].ZIP_Code__c, 'yy1256');
                System.assertEquals(leadListAfter[0].Country__c, 'SWITZERLAND');
                System.assertEquals(leadListAfter[0].City_English__c, CITY_E2);
                System.assertEquals(leadListAfter[0].Country_PL__c, 'SWITZERLAND');
                
                taskList = [Select id from Task where WhoId = :l3.Id];
                System.assertEquals(taskList.size(), 0);
                leadListAfter = [Select l.ZIP_Code__c, l.State__c, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c from Lead l where l.Id = :l3.Id];
                System.assertEquals(leadListAfter[0].ZIP_Code__c, null);
                System.assertEquals(leadListAfter[0].State__c, null);
                System.assertEquals(leadListAfter[0].Country__c, 'SWITZERLAND');
                System.assertEquals(leadListAfter[0].City_English__c, CITY_E3);
                System.assertEquals(leadListAfter[0].Country_PL__c, 'SWITZERLAND');
                
                taskList = [Select id from Task where WhoId = :l4.Id];
                System.assert(taskList.isEmpty());
                leadListAfter = [Select l.ZIP_Code__c, l.State__c, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c from Lead l where l.Id = :l4.Id];
                System.assertEquals(leadListAfter[0].Country__c, 'ITALY');
                System.assertEquals(leadListAfter[0].City_English__c, 'testCity');
                
                taskList = [Select id from Task where WhoId = :l5.Id];
                System.assert(taskList.isEmpty());
                leadListAfter = [Select l.ZIP_Code__c, l.State__c, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c from Lead l where l.Id = :l5.Id];
                System.assertEquals(leadListAfter[0].ZIP_Code__c, '9855');
                System.assertEquals(leadListAfter[0].Country__c, 'ITALY');
                System.assertEquals(leadListAfter[0].City_English__c, 'testCity');
                
                 //check that flag was unset
                leadList2 = [Select l.UpdatedBySpecialUser__c from Lead l where l.Id in :leadList];
                for(Lead l : leadList2) {
                    System.assert(!l.UpdatedBySpecialUser__c);
                }
            }
            
        }catch(System.Exception e){
            System.debug('**** Exception occured: ' + e);
            System.assert(false);   
        }
        
    }
    
    /*
    //********** TESTMETHODS
    static testMethod void leadAddressEnricherTestMethod2() {
        try{                    
            String CITY_F = 'parxF20100111';
            String CITY_E = 'parxE20100111';

            String LANGUAGE_FRENCH = 'Français';
            String LANGUAGE_ENGLISH = 'English';
        
            User notGUIUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
            
            //create city
            Reference_Data__c countryPARX = new Reference_Data__c();
            countryPARX.Name = 'SWITZERLAND';
            countryPARX.RecordTypeId = SystemSettings.REFERENCEDATA_COUNTRY_TYPE;
            countryPARX.Country_Francais__c = 'SUISSE';
            countryPARX.Country_English__c = 'SWITZERLAND';
            countryPARX.Country_Code__c = 'CH';
            try{
                insert countryPARX;
            }catch(System.DMLException e){
                //query data if already exist
                countryPARX = [Select r.Id from Reference_Data__c r where r.RecordTypeId = :SystemSettings.REFERENCEDATA_COUNTRY_TYPE and r.Country_English__c = 'SWITZERLAND' limit 1];   
            }
            
            Reference_Data__c cityParx = new Reference_Data__c();
            cityParx.Name = CITY_E;
            cityParx.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx.City_Francais__c = CITY_F;
            cityParx.City_English__c = CITY_E;
            cityParx.City_Country__c = countryPARX.Id;
            cityParx.ZIP_Code__c = 'qq9898';
            cityParx.State_Canton__c = 'AG';
            
            insert cityParx;
            
            List<Lead> leadList = new List<Lead>();
            List<Lead> leadList2 = new List<Lead>();
            
            System.runAs(notGUIUser) {
                //English
                //Lead with only zip
                Lead l1 = new Lead(Company = 'EHL1', Firstname = 'Parx 1', Preferred_Language__c = LANGUAGE_ENGLISH, Lastname = 'Muster', Country__c = 'SUISSE', ZIP_Code__c = 'qq9898' );
                leadList.add(l1);
                
                
                //FRENCH
                //Lead with only zip
                Lead l2 = new Lead(Company = 'EHL2', Firstname = 'Parx 2', Preferred_Language__c = LANGUAGE_FRENCH, Lastname = 'Muster', Country__c = 'SUISSE', ZIP_Code__c = 'qq9898' );
                leadList.add(l2);
                
                insert leadList;
            
                //check that flag was set
                leadList2 = [Select l.UpdatedBySpecialUser__c from Lead l where l.Id in :leadList];
                for(Lead l : leadList2) {
                    System.assert(l.UpdatedBySpecialUser__c);
                }
                
                //********************** FIRST CONTACT
                String query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
                query = query + 'From Lead l ';
                query = query + 'where l.Id = \'' + l1.Id+ '\' and l.IsConverted = false';
    
                LeadAddressEnrichBatchable batch = new LeadAddressEnrichBatchable(query);
                System.debug('*** before batchjob1');
                Test.startTest();
                Id batchId1 = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId1);
                
                //********************** SECOND CONTACT
                query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
                query = query + 'From Lead l ';
                query = query + 'where l.Id = \'' + l2.Id+ '\' and l.IsConverted = false';
    
                batch = new LeadAddressEnrichBatchable(query);
                System.debug('*** before batchjob2');
                Id batchId2  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId2);
                Test.stopTest();
                
                
                List<AsyncApexJob> jobList = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId2 or Id = :batchId1];
                for(AsyncApexJob a : jobList){
                    System.debug('**** Final results are: '+a);
                }
                
                //******************** CHECKING
                List<Lead> leadListAfter = [Select l.ZIP_Code__c, l.State__c, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c from Lead l where l.Id = :l1.Id];
                System.assertEquals(leadListAfter[0].ZIP_Code__c, 'qq9898');
                System.assertEquals(leadListAfter[0].State__c, 'AG');
                System.assertEquals(leadListAfter[0].Country__c, 'SWITZERLAND');
                System.assertEquals(leadListAfter[0].City_English__c, CITY_E);
                System.assertEquals(leadListAfter[0].City_PL__c, CITY_E);
                System.assertEquals(leadListAfter[0].Country_PL__c, 'SWITZERLAND');
                
                leadListAfter = [Select l.ZIP_Code__c, l.State__c, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c from Lead l where l.Id = :l2.Id];
                System.assertEquals(leadListAfter[0].ZIP_Code__c, 'qq9898');
                System.assertEquals(leadListAfter[0].State__c, 'AG');
                System.assertEquals(leadListAfter[0].Country__c, 'SWITZERLAND');
                System.assertEquals(leadListAfter[0].City_English__c, CITY_E);
                System.assertEquals(leadListAfter[0].City_PL__c, CITY_F);
                System.assertEquals(leadListAfter[0].Country_PL__c, 'SUISSE');
            }
        }catch(System.Exception e){
            System.debug('**** Exception occured: ' + e);
            System.assert(false);   
        }
        
    }*/
}