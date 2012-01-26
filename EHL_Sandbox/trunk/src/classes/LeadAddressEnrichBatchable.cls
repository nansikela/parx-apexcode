global class LeadAddressEnrichBatchable implements Database.Batchable<sObject> {
    private String query;
    
    global LeadAddressEnrichBatchable(){
        query = 'Select l.ZIP_Code__c, l.State__c, l.OwnerId, l.Preferred_Language__c, l.Country__c, l.Country_PL__c, l.City_PL__c, l.City_English__c ';
        query = query + 'From Lead l '; 
        query = query + 'where l.UpdatedBySpecialUser__c = true and l.IsConverted = false';
    }
    
    global LeadAddressEnrichBatchable(String pQuery){
    	this();
        query = pQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    
    //batch job is always executed only with one city object
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('**** scope size: ' +scope.size());

        LeadAddressEnricher helper = new LeadAddressEnricher();
        helper.enrich((Lead) scope[0]);        
    }
    
    global void finish(Database.BatchableContext BC){
       
    }


}