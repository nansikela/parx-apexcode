global class ContactNameCheck_OpportunityBatchable implements Database.Batchable<sObject> {
    
    private String[] checkedFieldsList = new String[]{'LastName'};
        
    private String STATUS_COMPLETED = 'Completed';
    
    global ContactNameCheck_OpportunityBatchable(){
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC){
        List<Opportunity> opportunities = [Select o.Name, o.Id, o.Contact_Student__r.LastModifiedDate, o.Contact_Student__r.Name, o.Contact_Student__c From Opportunity o where o.Contact_Student__r.LastModifiedDate = last_n_days:2];                      
        return opportunities ;
    }    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('ContactNameCheck_Batchable scope size: ' +scope.size());
    
        List<Opportunity> updateOpportunities = new List<Opportunity>();

        for (Opportunity opp : (List<Opportunity>)scope ) {                        
            if (!opp.Name.split(':').get(0).equals(opp.Contact_Student__r.Name)) {
                updateOpportunities.add(new Opportunity(Id = opp.Id));
            }
        }

        update(updateOpportunities);
//      insert new ErrorMsg__c(Message__c = 'execute ContactNameCheck_OpportunityBatchable ' + 'scope size: ' +scope.size() + 'updateOpportunities size: ' + updateOpportunities.size());        
    }    
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//      String[] toAddresses = new String[] {a.CreatedBy.Email};
        String[] toAddresses = new String[] {a.CreatedBy.Email, 'salesforce.admin@parx.ch'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Opportunity Update Batch ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }
}