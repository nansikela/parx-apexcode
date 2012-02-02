global class OpportunityStockAndInvoicingBatch implements Database.Batchable<sObject>, Database.Stateful {
	global final String query;
	global OpportunityStockAndInvoicingHelper.globalwrapper oppsandinvoices=new OpportunityStockAndInvoicingHelper.globalwrapper();
	
	global OpportunityStockAndInvoicingBatch(String q){
		query=q;
		oppsandinvoices=new OpportunityStockAndInvoicingHelper.globalwrapper();
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){	
		oppsandinvoices=OpportunityStockAndInvoicing.Run(scope, oppsandinvoices);
	}
	
	global void finish(Database.BatchableContext BC){
		// jobs to do with opps and invoices ...
		if (oppsandinvoices!=null && !oppsandinvoices.opportunities.isEmpty()) {
			OpportunityStockAndInvoicingHelper.print(oppsandinvoices.opportunities, oppsandinvoices.opportunitiesNoFak, oppsandinvoices.invoices);
			OpportunityStockAndInvoicingHelper.lockOpportunities(oppsandinvoices);
		}
		// Auftragsbestaetigungen muessen gedruckt werden wenn:
		// Latzte Rechnung = NULL AND Zahl_der_Fakturierungen__c=1
		// TODO Code fuer Auftragsbestaetung 
		for(Opportunity o:oppsandinvoices.Opportunities.values()) {
			if(o.Letzte_Rechnung__c == null && o.Zahl_der_Fakturierungen__c == 1) {
				o.Locked__c = false;
                o.Conga_Workflow_Trigger__c = True;
			}
		}
		update oppsandinvoices.Opportunities.values();
		for(Opportunity o:oppsandinvoices.Opportunities.values()) {
            if(o.Letzte_Rechnung__c == null && o.Zahl_der_Fakturierungen__c == 1) {
                o.Locked__c = true;
            }
        }
        update oppsandinvoices.Opportunities.values();
		
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
		mail.setSubject('Freigabe Fakturierung Status ' + a.Status);
		mail.setPlainTextBody
		('The batch Apex job processed ' + a.TotalJobItems +
		' batches with '+ a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}