global class ContactNameCheck_ApplicationBatchable implements Database.Batchable<sObject> {
    
    private String[] checkedFieldsList = new String[]{'LastName'};
    
    private String STATUS_COMPLETED = 'Completed';
    
    global ContactNameCheck_ApplicationBatchable(){
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC){
//        insert new ErrorMsg__c(Message__c = 'ContactNameCheck_ApplicationBatchable started'); 
        
        List<Application__c> applications = 
            [Select 
                a.Id,
                a.Applicant_Name__c, 
                a.Applicant_Last_Name__c, 
                a.Applicant_First_Name__c,
                a.Student__c,
                a.Student__r.Student_Name__c, 
//begin change 30052011 
				a.Student_Last_Name_Used__c,
				a.Student__r.Student_Last_Name_Used__c,
//end change 30052011
//              a.Student__r.FirstName, 
                a.Student__r.LastName,                              
                a.Student__r.LastModifiedDate               
                From Application__c a  
                where a.Student__r.LastModifiedDate = last_n_days:2];
                
                                     
        return applications ;
    }    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('**** ContactNameCheck_Batchable scope size: ' +scope.size());
    
        List<Application__c> updateApplications = new List<Application__c>();

		Set<Id> applicationIds = new Set<Id>();
	    
        for (Application__c app : (List<Application__c>)scope ) {      
        	applicationIds.add(app.Id);                  
            if (
                (app.Applicant_Last_Name__c == app.Student__r.LastName) &&
                (app.Applicant_First_Name__c == app.Student__r.Student_Name__c) &&
                (app.Student_Last_Name_Used__c == app.Student__r.Student_Last_Name_Used__c) 
                ) {
            }
            else {
                updateApplications.add(new Application__c(Id = app.Id));
            }
        }
        
        List<Enrollment__c> enrollmentsList = [Select 
        	e.Id, 
        	e.Application__r.Student__r.Student_Name__c, 
        	e.Application__r.Student__r.FirstName, 
        	e.Application__r.Student__r.LastName,
        	e.Student_First_Name__c,
        	e.Student_Last_Name__c,
        	e.Student_Name__c 
        	From Enrollment__c e where e.Application__c in :applicationIds];
        	
        List<Enrollment__c> updateEnrollment = new List<Enrollment__c>();
        String x = '';
        for (Enrollment__c enroll : enrollmentsList ) {      
            if (
            	( enroll.Student_First_Name__c.equals(enroll.Application__r.Student__r.Student_Name__c)) && 
				( enroll.Student_Last_Name__c.equals(enroll.Application__r.Student__r.LastName)) && 
				( enroll.Student_Name__c.equals(enroll.Application__r.Student__r.FirstName + ' ' + enroll.Application__r.Student__r.LastName)) 
                ) {
        	x = x + 'noupd:' + enroll.Id;
                	
            }
            else {
            
        	x = x + 'upd:' + enroll.Id;

                updateEnrollment.add(new Enrollment__c(Id = enroll.Id));
            }
        }
        
                
        update(updateApplications);
        update(updateEnrollment);
        
//      insert new ErrorMsg__c(Message__c = x); 
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
        mail.setSubject('Application Update Batch ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
    }
}