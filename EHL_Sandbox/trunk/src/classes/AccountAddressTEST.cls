public class AccountAddressTEST {
   
    static testMethod void accountAddressTestMethod1(){     
        
        Integer i;
        String addressType = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
        
       // try{            
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
         
            List<Account> accountList = new List<Account>();
            System.runAs(guiUser) {   
                for(i=0; i<100; i++){
                    if(addressType == SystemSettings.ACCOUNT_SHIPPING_ADDRESS){
                        addressType = SystemSettings.ACCOUNT_BILLING_ADDRESS;
                    }else{
                        addressType = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
                    }
                    Account a = new Account(Name = 'Test AG '+ i, Address_Type__c = addressType, City_English__c = 'MyCity');
                    accountList.add(a);     
                }
                
                insert accountList;
                TriggerContext.reset();
                
                //check if address is created
                List<Address__c> addrList = [Select c.City_English__c, c.Account__c From Address__c c where c.Preferred_Address__c = true and c.Account__c = :accountList[0].Id limit 1];
                if(!addrList.isEmpty()){
                    Address__c addr = addrList[0];
                    System.assertEquals(addr.City_English__c, 'MyCity');
                }else{
                    System.assert(false);
                }
                
                
                //check if update works (select one account that is just created)
                Account acc = [Select a.Id, a.Name, a.Address_Type__c, a.City_English__c From Account a where a.Address_Type__c = :SystemSettings.ACCOUNT_SHIPPING_ADDRESS and a.Id in :accountList limit 1];
                acc.Address_Type__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
                acc.Street_Name_Nr_Preferred__c = 'Street 1';
                acc.PO_Box_Preferred__c = 'PO BOX';
                acc.City_English__c = 'MyCity2';
                acc.Address_Line_3_Preferred__c = 'adr';
                acc.Address_Line_2_Preferred__c = 'adr2';
                
                System.debug('**** accountAddressTestMethod1 before update');
                update acc;
                System.debug('**** accountAddressTestMethod1 after update');
                TriggerContext.reset();
    
                addrList = [Select c.City_English__c, c.Address_Line_3__c, c.Address_Line_2__c, c.RecordTypeId, c.Preferred_Address__c From Address__c c where c.Account__c = :acc.Id];
    
                if(!addrList.isEmpty()){
                    Address__c addr = addrList[0];
                    System.assert(addr.Preferred_Address__c);
                    System.assertEquals(addr.RecordTypeId, SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE);
                    System.assertEquals(addr.City_English__c, 'MyCity2');
                    System.assertEquals(addr.Address_Line_3__c, 'adr');
                    System.assertEquals(addr.Address_Line_2__c, 'adr2');
                }else{
                    System.assert(false);
                }
                
                //check that when only p o is provided, no commuication will be insert
                Account aSimpel = new Account(Name = 'Test AG '+ i, Address_Type__c = addressType, PO_Box_Preferred__c = 'Po');
                insert aSimpel;
                TriggerContext.reset();
                addrList = [Select c.Country__c, c.Zip_Code__c, c.City_English__c, c.Account__c From Address__c c where c.Preferred_Address__c = true and c.Account__c = :aSimpel.Id limit 1];
                System.assert(addrList.isEmpty());
                
                //create account, delete cp and then create new one
                Account a1 = new Account(Name = 'Test Unternehmen ', City_English__c = 'NewCity', Address_Type__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Street_Name_Nr_Preferred__c = 'The Street', PO_Box_Preferred__c = 'PO Box', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c = 'Line 2');
                insert a1;
                TriggerContext.reset();
                Address__c c1 = [Select c.Id from Address__c c where Preferred_Address__c = true and c.Account__c = :a1.Id];
                delete c1;
                TriggerContext.reset(); 
                
                Account a11 = [Select a.Id, a.City_English__c from Account a where a.Id = :a1.Id];
                System.assertEquals(a11.City_English__c, null);
                
                Address__c addr1 = new Address__c(Account__c = a11.Id,  Street_Name_Nr__c = 'Teststrasse', RecordTypeId = SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE, Preferred_Address__c = true, PO_Box__c = 'Po', Address_Line_3__c = 'adr 3', Address_Line_2__c = 'adr 2');
                insert addr1;  
                
                Account a111 = [Select a.Id, a.Street_Name_Nr_Preferred__c from Account a where a.Id = :a11.Id];
                System.assertEquals(a111.Street_Name_Nr_Preferred__c, 'Teststrasse');
            }
        /*}catch(System.Exception e){
            System.debug('**** Final Exception accountAddressTestMethod1: ' + e);
            System.assert(false, e);
        }*/
    }
    
    
   static testMethod void accountAddressTestMethod3(){
        try{                    
            String CITY_F = 'parxF20100125';
            String CITY_E = 'parxE20100125';
            
            Integer i;
            String addressType = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
            
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
            
            Reference_Data__c cityParx = new Reference_Data__c();
            cityParx.Name = CITY_E;
            cityParx.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx.City_Francais__c = CITY_F;
            cityParx.City_English__c = CITY_E;
            cityParx.City_Country__c = countryPARX.Id;
            cityParx.ZIP_Code__c = '9898';
            insert cityParx;
            
            System.debug('**** cityParx ' + cityParx.Id);
            
            User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(guiUser) { 
                //account in switzerland with city that is not valid                
                Account a1 = new Account(Name = 'Parx 1', City_English__c = 'xxrterTT', Address_Type__c = addressType, Country_Preferred__c = 'SWITZERLAND' );
                try{
                    insert a1;
                    System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** accountAddressTestMethod3 Exception shoud happen 1> ' + e);
                }
                TriggerContext.reset();
                
                //account in switzerland with valid city
                Account a2 = new Account(Name = 'Parx 2', City_English__c = CITY_E, Address_Type__c = addressType, Country_Preferred__c = 'SWITZERLAND' );
                System.debug('**** INSERT Start************** ');
                insert a2;
                System.debug('**** INSERT END************** ');
                TriggerContext.reset();
               
                
                //update account with wrong address, see if it works
                a2.City_English__c = 'dsfsdtwt435';             
                try{
                    update a2;
                    System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** accountAddressTestMethod3 Exception shoud happen 2> ' + e);
                }
                TriggerContext.reset();
                
                //insert account with wrong zip
                Account a3 = new Account(Name = 'Parx 2', City_English__c = CITY_E, ZIP_Code_Preferred__c = '9890', Address_Type__c = addressType, Country_Preferred__c = 'SWITZERLAND' );
                try{
                    insert a3;
                    System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** accountAddressTestMethod3 Exception shoud happen 3> ' + e);
                }
                TriggerContext.reset();
                
                //insert account with valid zip
                Account a4 = new Account(Name = 'Parx 2', City_English__c = CITY_E, ZIP_Code_Preferred__c = '9898', Address_Type__c = addressType, Country_Preferred__c = 'SWITZERLAND' );
                insert a4;
                TriggerContext.reset();
            }
        }catch(System.Exception e){
            System.debug('**** Final Exception accountAddressTestMethod3 ' + e);
            System.assert(false, e);
        }             
    }
    
    
    static testMethod void addressAccountTestMethod2(){        
            Integer i;
            String addressType = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
            
            try{
                User guiUser = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
                
                System.runAs(guiUser) { 
                    List<Account> accountList = new List<Account>();
                    
                    for(i=0; i<50; i++){
                        if(addressType == SystemSettings.ACCOUNT_SHIPPING_ADDRESS){
                            addressType = SystemSettings.ACCOUNT_BILLING_ADDRESS;
                        }else{
                            addressType = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
                        }
                       
                        Account a = new Account(Name = 'Parx '+ i, City_English__c = 'Basel', Address_Type__c = addressType, Street_Name_Nr_Preferred__c = 'The Street', PO_Box_Preferred__c = 'PO Box', Address_Line_3_Preferred__c = 'Line 3', Address_Line_2_Preferred__c = 'Line 2');
                        accountList.add(a);     
                    }
                    
                    try{
                        insert accountList;
                        TriggerContext.reset();
                    }catch(System.DMLException e){
                        System.debug('**** TEST Exception ' + e);
                        System.assert(false);
                    }
                    
                    
                    //not set because gui user
                    Account aa1 = [Select a.UpdatedBySpecialUser__c from Account a where a.Id in :accountList limit 1];
                    System.assert(!aa1.UpdatedBySpecialUser__c);
                
                    //check if address is created, check if zip is the same
                    List<Address__c> addrList = [Select c.City_English__c From Address__c c where c.Preferred_Address__c = true and c.Account__c = :accountList[0].Id];
                                    
                    if(!addrList.isEmpty()){
                        System.assertEquals(addrList[0].City_English__c, 'Basel');
                    }else{
                        System.assert(false);
                    }
                     
                    //create new preferred address, should give an error
                    Address__c addressNeu = new Address__c(Account__c = accountList[0].Id, Street_Name_Nr__c = 'Teststrasse', RecordTypeId = SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE, Preferred_Address__c = true, City_English__c = 'Zurich', PO_Box__c = 'Po', Address_Line_3__c = 'adr 3', Address_Line_2__c = 'adr 2');
                    try{
                        insert addressNeu;
                        System.assert(false);
                    }catch(System.DMLException e){
                        System.debug('**** TEST Exception, should occur ' + e);
                    }
                    TriggerContext.reset();
                     
                    
                    //update preferred address and check that account also updated
                    Address__c cUpdate = [Select c.Id From Address__c c where c.Preferred_Address__c = true and c.Account__c = :accountList[2].Id];
                    cUpdate.City_English__c = 'LA';
                    
                    try{
                        update cUpdate;
                    }catch(System.DMLException e){
                        System.debug('**** TEST Exception ' + e);
                        System.assert(false);
                    }
                    TriggerContext.reset();
                    
                    Address__c cUpdate2 = [Select c.City_English__c, c.Account__c from Address__c c where c.Id = :cUpdate.Id];
                    System.assertEquals(cUpdate2.City_English__c, 'LA');
                     
                    Account aUpdate2 = [Select a.Id, a.UpdatedBySpecialUser__c, a.City_English__c from Account a where a.Id = :cUpdate2.Account__c];
                    System.assertEquals(aUpdate2.City_English__c, 'LA');
                    System.assert(!aUpdate2.UpdatedBySpecialUser__c);
                     
                    //create non preferred address
                    addressNeu = new Address__c(Account__c = aUpdate2.Id, Street_Name_Nr__c = 'Teststrasse', RecordTypeId = SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE, PO_Box__c = 'Po', Address_Line_3__c = 'adr 3', Address_Line_2__c = 'adr 2');
                    try{
                        insert addressNeu;
                        TriggerContext.reset();
                    }catch(System.DMLException e){
                        System.debug('**** TEST Exception ' + e);
                        System.assert(false);
                    }
                    
                    //update to preferred, should give an error
                    addressNeu.Preferred_Address__c = true;
                    try{
                        update addressNeu;
                        System.assert(false);
                    }catch(System.DMLException e){
                        System.debug('**** TEST Exception, should occur ' + e);
                    }
                    TriggerContext.reset();
                     
                    
                    //set account to inactive, check that all cp also set to inactive
                     Account aActive = accountList[1];
                     addressNeu = new Address__c(Account__c = aActive.Id, Street_Name_Nr__c = 'Main Street', RecordTypeId = SystemSettings.ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE, PO_Box__c = 'Po', Address_Line_3__c = 'adr 3', Address_Line_2__c = 'adr 2');
    
                     try{
                        insert addressNeu;
                        TriggerContext.reset();
                     }catch(System.DMLException e){
                        System.debug('**** TEST Exception ' + e);
                        System.assert(false);
                     }
                    
                     aActive.Status__c = SystemSettings.STATUS_INACTIVE; 
                     try{
                        update aActive;
                        TriggerContext.reset();
                     }catch(System.DMLException e){
                        System.debug('**** TEST Exception ' + e);
                        System.assert(false);
                     }
                    
                     addressNeu = [Select c.Status__c from Address__c c where c.Id = :addressNeu.Id];
                     System.assertEquals(addressNeu.Status__c, SystemSettings.STATUS_INACTIVE);
                     
                     //delete inactive account, check that address also deleted
                     delete aActive;
                    TriggerContext.reset();
                     addrList = [Select a.Status__c from Address__c a where a.Account__c = :aActive.Id];
                     System.assert(addrList.isEmpty());
                     
                     //delete active account, check that address also deleted
                     Id a3Id = accountList[3].Id;
                     delete accountList[3];
                     TriggerContext.reset();
                     
                     addrList = [Select a.Status__c from Address__c a where a.Account__c = :a3Id];
                     System.assert(addrList.isEmpty());
                }
            }catch(System.Exception e){
                System.debug('**** Final Exception addressAccountTestMethod2 ' + e);
                System.assert(false, e);
            }
    }
    
    static testMethod void accountAddressTestMethod4(){
        try{                    
            String CITY_F = 'parxF20100125';
            String CITY_E = 'parxE20100125';
            
            Integer i;
            String addressType = SystemSettings.ACCOUNT_SHIPPING_ADDRESS;
            
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
            
            Reference_Data__c cityParx = new Reference_Data__c();
            cityParx.Name = CITY_E;
            cityParx.RecordTypeId = SystemSettings.REFERENCEDATA_CITY_TYPE;
            cityParx.City_Francais__c = CITY_F;
            cityParx.City_English__c = CITY_E;
            cityParx.City_Country__c = countryPARX.Id;
            cityParx.ZIP_Code__c = '9898';
            insert cityParx;
            
            System.debug('**** cityParx ' + cityParx.Id);
            
            User nonGuiUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
            
                
            System.runAs(nonGuiUser) { 
                //account in switzerland with city that is not valid --> should work anyway         
                Account a1 = new Account(Name = 'Parx 1', City_English__c = 'xxrterTT', Address_Type__c = addressType, Country_Preferred__c = 'SWITZERLAND' );
                try{
                    insert a1;
                    TriggerContext.reset();
                }catch(System.DMLException e){
                   System.debug('**** accountAddressTestMethod4 Exception> ' + e);
                  System.assert(false);
                }
                
                //set because non gui user
                Account aa1 = [Select a.UpdatedBySpecialUser__c from Account a where a.Id = :a1.Id];
                System.assert(aa1.UpdatedBySpecialUser__c);
                
                //account in switzerland with valid city
                Account a2 = new Account(Name = 'Parx 2', City_English__c = CITY_E, Address_Type__c = addressType, Country_Preferred__c = 'SWITZERLAND' );
                System.debug('**** INSERT Start************** ');
                insert a2;
                TriggerContext.reset();
                System.debug('**** INSERT END************** ');
               
                
                //update account with wrong address, see if it works --> should work with non gui user
                a2.City_English__c = 'dsfsdtwt435';             
                try{
                    update a2;
                    TriggerContext.reset();
                }catch(System.DMLException e){
                   System.debug('**** accountAddressTestMethod4 Exception> ' + e);
                  System.assert(false);
                }
                
                //insert account with wrong zip --> should work
                Account a3 = new Account(Name = 'Parx 2', City_English__c = CITY_E, ZIP_Code_Preferred__c = '9890', Address_Type__c = addressType, Country_Preferred__c = 'SWITZERLAND' );
                try{
                    insert a3;
                    TriggerContext.reset();
                }catch(System.DMLException e){
                   System.debug('**** accountAddressTestMethod4 Exception> ' + e);
                    System.assert(false);
                }
            }
        }catch(System.Exception e){
            System.debug('**** Final Exception accountAddressTestMethod4 ' + e);
            System.assert(false, e);
        }             
    }
}