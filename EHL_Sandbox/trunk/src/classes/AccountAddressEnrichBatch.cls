public class AccountAddressEnrichBatch {
    public AccountAddressEnrichBatch(){
        
    }
    
    public void startBatch(){
        AccountAddressEnrichBatchable batchJob = new AccountAddressEnrichBatchable();
        Id asyncId = Database.executeBatch(batchJob, 1);  //batch size is only 1
        System.debug('*** asyncId: '+ asyncId);
    }
    
     
    //********** TESTMETHODS
    static testMethod void accountAddressEnricherTestMethod() {
        try{                    
            String CITY_F1 = 'parxF20100126';
            String CITY_E1 = 'parxE20100126';
            
            String CITY_F2 = 'xparxF20100126x';
            String CITY_E2 = 'xparxE20100126x';
            
            String CITY_F3 = 'zxparxF20100126xz';
            String CITY_E3 = 'zxparxE20100126xz';
            
            String ACCOUNT_SHIPPING_ADDRESS = SystemSettings.ACCOUNT_SHIPPING_ADDRESS; //PICKLIST VALUE
            String ACCOUNT_BILLING_ADDRESS = SystemSettings.ACCOUNT_BILLING_ADDRESS; //PICKLIST VALUE

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
            cityParx1.ZIP_Code__c = 'xx9898';
            cityParx1.State_Canton__c = 'AG';
            refList.add(cityParx1);
            
            Reference_Data__c cityParx2 = new Reference_Data__c();
            cityParx2.Name = CITY_E2;
            cityParx2.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx2.City_Francais__c = CITY_F2;
            cityParx2.City_English__c = CITY_E2;
            cityParx2.City_Country__c = countryPARX.Id;
            cityParx2.ZIP_Code__c = 'xx1256';
            cityParx2.State_Canton__c = 'ZH';
            refList.add(cityParx2);         
            
            
            insert refList;
            
            System.runAs(notGUIUser) {
                List<Account> accList = new List<Account>();
                
                //account with no zip
                Account a1 = new Account(Name = 'Parx 1', City_English__c = CITY_F1, Address_Type__c = ACCOUNT_SHIPPING_ADDRESS, Country_Preferred__c = 'Suisse' );
                accList.add(a1);
                
                //account with zip
                Account a2 = new Account(Name = 'Parx 2', City_English__c = CITY_E2, Address_Type__c = ACCOUNT_BILLING_ADDRESS, Country_Preferred__c = 'Suisse', ZIP_Code_Preferred__c = 'xx1256' );
                accList.add(a2);
                
                //account with wrong city name
                Account a3 = new Account(Name = 'Parx 3', City_English__c = 'nada', Address_Type__c = ACCOUNT_BILLING_ADDRESS, Country_Preferred__c = 'Suisse' );
                accList.add(a3);
                
                //account only zip
                Account a4 = new Account(Name = 'Parx 4', ZIP_Code_Preferred__c = 'xx1256', Address_Type__c = ACCOUNT_BILLING_ADDRESS, Country_Preferred__c = 'Suisse' );
                accList.add(a4);
            
                //account only zip
                Account a5 = new Account(Name = 'Parx 5', City_English__c = 'xxNoCity', Address_Type__c = ACCOUNT_BILLING_ADDRESS, Country_Preferred__c = 'Italie' );
                accList.add(a5);
                
                insert accList;
                
                //check that flag was set
                List<Account> accList2 = [Select a.UpdatedBySpecialUser__c from Account a where a.Id in :accList];
                for(Account a : accList2) {
                    System.assert(a.UpdatedBySpecialUser__c);
                }
                
                //********************** FIRST ACCOUNT
                String query = 'Select a.OwnerId, a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.City_English__c ';
                query = query + 'From Account a ';
                query = query + 'where a.Id = \'' + a1.Id+ '\'';
    
                AccountAddressEnrichBatchable batch = new AccountAddressEnrichBatchable(query);
                System.debug('*** before batchjob1');
                Test.startTest();
                Id batchId1 = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId1);
                
                //********************** SECOND ACCOUNT
                query = 'Select a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.OwnerId, a.Country_Preferred__c, a.City_English__c ';
                query = query + 'From Account a ';
                query = query + 'where a.Id = \'' + a2.Id+ '\'';
    
                batch = new AccountAddressEnrichBatchable(query);
                System.debug('*** before batchjob2');
                Id batchId2  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId2);
                
                //********************** THIRD ACCOUNT
                query = 'Select a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.OwnerId, a.Country_Preferred__c, a.City_English__c ';
                query = query + 'From Account a ';
                query = query + 'where a.Id = \'' + a3.Id+ '\'';
    
                batch = new AccountAddressEnrichBatchable(query);
                System.debug('*** before batchjob3');
                Id batchId3  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId3);
                
                //********************** FORTH ACCOUNT
                query = 'Select a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.OwnerId, a.Country_Preferred__c, a.City_English__c ';
                query = query + 'From Account a ';
                query = query + 'where a.Id = \'' + a4.Id+ '\'';
    
                batch = new AccountAddressEnrichBatchable(query);
                System.debug('*** before batchjob4');
                Id batchId4  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId4);
    
                 //********************** FIFHT ACCOUNT
                query = 'Select a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.OwnerId, a.Country_Preferred__c, a.City_English__c ';
                query = query + 'From Account a ';
                query = query + 'where a.Id = \'' + a5.Id+ '\'';
    
                batch = new AccountAddressEnrichBatchable(query);
                System.debug('*** before batchjob5');
                Id batchId5  = Database.executeBatch(batch, 1);  //batch size is only 1
                System.debug('*** asyncId: '+ batchId5);
                
                Test.stopTest();
                
                
                List<AsyncApexJob> jobList = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId3 or Id = :batchId2 or Id = :batchId1 or Id = :batchId4];
                for(AsyncApexJob a : jobList){
                    System.debug('**** Final results are: '+a);
                }
                
                //******************** CHECKING
                List<Task> taskList = [Select Id from Task where WhatId = :a1.Id];
                System.assert(taskList.isEmpty());
                List<Account> accListAfter = [Select a.Country_Francais__c, a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.City_English__c  from Account a where a.Id = :a1.Id];
                System.assertEquals(accListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(accListAfter[0].Country_Francais__c, 'SUISSE');
                System.assertEquals(accListAfter[0].City_English__c, CITY_F1);
                
                taskList = [Select Id from Task where WhatId = :a2.Id];
                System.assert(taskList.isEmpty());
                accListAfter = [Select a.Country_Francais__c, a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.City_English__c  from Account a where a.Id = :a2.Id];
                System.assertEquals(accListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(accListAfter[0].Country_Francais__c, 'SUISSE');
                System.assertEquals(accListAfter[0].City_English__c, CITY_E2);
                System.assertEquals(accListAfter[0].ZIP_Code_Preferred__c, 'xx1256');
                
                taskList = [Select Id from Task where WhatId = :a3.Id];
                System.assertEquals(taskList.size(), 1);
                accListAfter = [Select a.Country_Francais__c, a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.City_English__c  from Account a where a.Id = :a3.Id];
                System.assertEquals(accListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(accListAfter[0].Country_Francais__c, 'SUISSE');
                System.assertEquals(accListAfter[0].City_English__c, 'nada');
                System.assertEquals(accListAfter[0].ZIP_Code_Preferred__c, null);
                
                taskList = [Select subject, Id from Task where WhatId = :a4.Id];
                System.assert(taskList.isEmpty());
                accListAfter = [Select a.Country_Francais__c, a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.City_English__c  from Account a where a.Id = :a4.Id];
                System.assertEquals(accListAfter[0].Country_Preferred__c, 'SWITZERLAND');
                System.assertEquals(accListAfter[0].Country_Francais__c, 'SUISSE');
                System.assertEquals(accListAfter[0].ZIP_Code_Preferred__c, 'xx1256');
                
                taskList = [Select subject, Id from Task where WhatId = :a5.Id];
                System.assert(taskList.isEmpty());
                accListAfter = [Select a.Country_Francais__c, a.ZIP_Code_Preferred__c, a.State_Preferred__c, a.Country_Preferred__c, a.City_English__c  from Account a where a.Id = :a5.Id];
                System.assertEquals(accListAfter[0].Country_Preferred__c, 'ITALY');
                System.assertEquals(accListAfter[0].Country_Francais__c, 'ITALIE');
                System.assertEquals(accListAfter[0].City_English__c, 'xxNoCity');
                
                //check that flag was unset
                accList2 = [Select a.UpdatedBySpecialUser__c from Account a where a.Id in :accList];
                for(Account a : accList2) {
                    System.assert(!a.UpdatedBySpecialUser__c);
                }
            }
        }catch(System.Exception e){
            System.debug('**** Exception occured: ' + e);
            System.assert(false);  
        }
        
    }
    
    
     //********** TESTMETHODS
    static testMethod void accountAddressSchedulableTestMethod() {
        try{ 
            String ACCOUNT_SHIPPING_ADDRESS = SystemSettings.ACCOUNT_SHIPPING_ADDRESS; //PICKLIST VALUE
            String city = 'parxTest20100315xx';
            String cityF = 'parxTest20100315xxFF';
            
            User notGUIUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
            
            Test.startTest();
            
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
            
            Reference_Data__c cityParx = new Reference_Data__c();
            cityParx.Name = city;
            cityParx.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx.City_Francais__c = cityF;
            cityParx.City_English__c = city;
            cityParx.City_Country__c = countryPARX.Id;
            cityParx.ZIP_Code__c = 'xx5801';
            cityParx.State_Canton__c = 'BE';            
            
            insert cityParx;
            
            System.runAs(notGUIUser) {
                //account with no zip
                Account a1 = new Account(Name = 'Parx 1', City_English__c = city, Address_Type__c = ACCOUNT_SHIPPING_ADDRESS, Country_Preferred__c = 'Suisse' );
                insert a1;
                
                //create Cron
                // Run the scheduled job at midnight Sept. 3rd. 2022
                String CRON_EXP = '0 0 0 3 9 ? 2022';
                
                //schedule the job
                String jobId = System.schedule('testScheduledApex', CRON_EXP, new AccountAddressEnrichSchedulable());
                CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                System.assertEquals(0, ct.TimesTriggered);
                System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
            }
        }catch(System.Exception e){
            System.debug('**** Exception occured: ' + e);
            System.assert(false);  
        }
    }
}