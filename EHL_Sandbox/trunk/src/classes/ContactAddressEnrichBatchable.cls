global class ContactAddressEnrichBatchable implements Database.Batchable<sObject> {   
    
    private String query;  
    
    global ContactAddressEnrichBatchable(){
        query = 'Select c.ZIP_Code_Preferred__c, c.OwnerId, c.State_Preferred__c, c.Country_Preferred__c, c.City_English__c, c.Preferred_Language__c, c.Country_PL__c, c.City_PL2__c ';
        query = query + 'From Contact c '; 
        query = query + 'where c.UpdatedBySpecialUser__c = true and c.Country_Preferred__c != null';
    }
    
    global ContactAddressEnrichBatchable(String pQuery){
        this();
        query = pQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    
    //batch job is always executed only with one city object
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('**** scope size: ' +scope.size());
        
        ContactAddressEnricher helper = new ContactAddressEnricher();
        helper.enrich((Contact) scope[0]);
    }
    
    global void finish(Database.BatchableContext BC){
       
    }
}