public class LeadAddressHandlerTEST {
    
    static testMethod void leadHandlerTestGUIMethod(){
        String CITY_F = 'parxF20100122';
        String CITY_E = 'parxE20100122';
        
        String LANGUAGE_ENGLISH = 'English';
        
        try{
            User guiUse = [Select u.Id from User u where u.IsActive = true and u.Id not in :SystemSettings.API_USERID limit 1];
         
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
            cityParx.ZIP_Code__c = '9898';
            insert cityParx;
            
            
            System.runAs(guiUse) {
                //invalid zip in switzerland --> should get error
                Lead l = new Lead(Company = 'Parx', 
                                LastName = 'MUSTER', FirstName = 'Max', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, 
                                City_English__c = CITY_E, ZIP_Code__c = '2555', Country__c = 'SWITZERLAND', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l;
                   System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestGUIMethod Exception shoud happen> ' + e);
                }
                
                //set correct zip
                l.ZIP_Code__c = '9898';
                try{
                   insert l;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestGUIMethod Exception> ' + e);
                   System.assert(false);
                }
                
                Lead ll = [Select l.UpdatedBySpecialUser__c from Lead l where l.Id = :l.Id];
                System.assert(!ll.UpdatedBySpecialUser__c);
                
                //update Lead, invalid city --> should get error
                l.City_English__c = 'xdsff';
                try{
                  update l;
                  System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestGUIMethod Exception shoud happen> ' + e);
                }
                
                
                //invalid city in switzerland with no zip --> should get error
                Lead l3 = new Lead(Company = 'Parx', LastName = 'MUSTER3', FirstName = 'Max3', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, City_English__c = 'invalidParxCity', Country__c = 'SWITZERLAND', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l3;
                   System.assert(false);
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestGUIMethod Exception shoud happen> ' + e);
                }
                
                
                //lead not in switzerland, should not be validated
                Lead l2 = new Lead(Company = 'Parx2', LastName = 'MUSTER2', FirstName = 'Max2', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, City_English__c = 'citysomething', Country__c = 'anything', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l2;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestGUIMethod Exception> ' + e);
                   System.assert(false);
                }
                
                
                //valid in switzerland with zip
                Lead l4 = new Lead(Company = 'Parx', LastName = 'MUSTER4', FirstName = 'Max4', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, City_English__c = CITY_E, ZIP_Code__c = '9898', Country__c = 'SWITZERLAND', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l4;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestGUIMethod Exception> ' + e);
                   System.assert(false);
                }
            }
        }catch(System.Exception e){
            System.debug('**** Final Exception leadHandlerTestGUIMethod ' + e);
            System.assert(false);
        }   
    }
    
    
    static testMethod void leadHandlerTestNotGUIMethod(){
        
        String CITY_F = 'parxF20100122';
        String CITY_E = 'parxE20100122';
        
        String LANGUAGE_ENGLISH = 'English';        

        try{
            User notGUIUser = [Select u.Id from User u where u.IsActive = true and u.Id in :SystemSettings.API_USERID limit 1];
         
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
            cityParx.ZIP_Code__c = '9898';
            insert cityParx;
            
            System.runAs(notGUIUser) {
                //invalid zip in switzerland --> should get error
                Lead l = new Lead(Company = 'Parx', LastName = 'MUSTER', FirstName = 'Max', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, City_English__c = CITY_E, ZIP_Code__c = '2555', Country__c = 'SWITZERLAND', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestNotGUIMethod Exception> ' + e);
                   System.assert(false);
                }
                
                //check that UpdatedBySpecialUser__c is set
                Lead ll = [Select l.UpdatedBySpecialUser__c from Lead l where l.Id = :l.Id];
                System.assert(ll.UpdatedBySpecialUser__c);
                
                //update Lead, invalid city --> should get error
                l.City_English__c = 'xdsff';
                try{
                  update l;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestNotGUIMethod Exception> ' + e);
                  System.assert(false);
                }
                
                
                //invalid city in switzerland with no zip --> should get error
                Lead l3 = new Lead(Company = 'Parx', LastName = 'MUSTER3', FirstName = 'Max3', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, City_English__c = 'invalidParxCity', Country__c = 'SWITZERLAND', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l3;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestNotGUIMethod Exception> ' + e);
                   System.assert(false);
                }
                
                
                //lead not in switzerland, should not be validated
                Lead l2 = new Lead(Company = 'Parx2', LastName = 'MUSTER2', FirstName = 'Max2', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, City_English__c = 'citysomething', Country__c = 'anything', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l2;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestNotGUIMethod Exception> ' + e);
                   System.assert(false);
                }
                
                
                //valid in switzerland with zip
                Lead l4 = new Lead(Company = 'Parx', LastName = 'MUSTER4', FirstName = 'Max4', Address_Type_for_Account__c = SystemSettings.ACCOUNT_SHIPPING_ADDRESS, Address_Type_for_Contact__c = SystemSettings.CONTACT_TIME_OF_STUDY, City_English__c = CITY_E, ZIP_Code__c = '9898', Country__c = 'SWITZERLAND', Preferred_Language__c = LANGUAGE_ENGLISH);
                try{
                   insert l4;
                }catch(System.DMLException e){
                   System.debug('**** leadHandlerTestNotGUIMethod Exception> ' + e);
                   System.assert(false);
                }
            }
        }catch(System.Exception e){
            System.debug('**** Final Exception leadHandlerTestNotGUIMethod ' + e);
            System.assert(false);
        }   
    }
    
}