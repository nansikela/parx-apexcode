global class onOpportunitySammelnummerBatch implements Database.Batchable<sObject>, Database.Stateful {
	global final String query;
	
	global onOpportunitySammelnummerBatch(String q){
		query=q;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		list<OpportunityLineItem> olis = new list<OpportunityLineItem>();
		for (sObject s: scope) {
			olis.add((OpportunityLineItem)s);
		}	
		onOpportunityLineItemHelper.start(olis);
	}
	
	global void finish(Database.BatchableContext BC){
		// Get the ID of the AsyncApexJob representing this batch job
		// from Database.BatchableContext.
		// Query the AsyncApexJob object to retrieve the current job's information.
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
		TotalJobItems, CreatedBy.Email
		from AsyncApexJob where Id =
		:BC.getJobId()];
		// Send an email to the Apex job's submitter notifying of job completion.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Sammelnummernerfassung (Mediathek) Status ' + a.Status);
		mail.setPlainTextBody
		('Die Sammelnummernerfassung wurde mit ' + String.valueOf(a.TotalJobItems) +
		' Batches ausgeführt. Es gab '+ String.valueOf(a.NumberOfErrors) + ' Fehler.' + 
		(String.valueOf(a.NumberOfErrors)!='0'?' Bitte löschen Sie die Sammelnummer aus dem Auftrag und erfassen Sie diese erneut. Sollte nochmals ein Fehler auftreten, wenden Sie sich bitte an Ihren Administrator.':''));
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}