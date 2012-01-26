global class AccountAddressEnrichBatchable implements Database.Batchable<sObject> {
        
    private String query;
    
    global AccountAddressEnrichBatchable(){
        query = 'Select a.ZIP_Code_Preferred__c, a.OwnerId, a.State_Preferred__c, a.Country_Preferred__c, a.City_English__c ';
        query = query + 'From Account a '; 
        query = query + 'where a.UpdatedBySpecialUser__c = true and a.Country_Preferred__c != null';
    }
    
    global AccountAddressEnrichBatchable(String pQuery){
        this();
        query = pQuery;        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    
    //batch job is always executed only with one city object
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('**** AccountAddressEnrichBatchable scope size: ' +scope.size());
        AccountAddressEnricher helper = new AccountAddressEnricher();
        helper.enrich((Account) scope[0]);
    }    
    
    global void finish(Database.BatchableContext BC){
       
    }
}