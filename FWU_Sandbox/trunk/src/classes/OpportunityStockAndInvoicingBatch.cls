global class OpportunityStockAndInvoicingBatch implements Database.Batchable<sObject>, Database.Stateful {
	global final String query;
	global final String[] initialoppids;
	global OpportunityStockAndInvoicingHelper.globalwrapper oppsandinvoices=new OpportunityStockAndInvoicingHelper.globalwrapper();
	
	global OpportunityStockAndInvoicingBatch(String q, String[] oppids){
	//global OpportunityStockAndInvoicingBatch(String q){
		query=q;
		initialoppids=oppids;
		oppsandinvoices=new OpportunityStockAndInvoicingHelper.globalwrapper();
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Savepoint startInvoicing = database.setSavepoint();
		if (oppsandinvoices!=null && !oppsandinvoices.hasError)	
			oppsandinvoices=OpportunityStockAndInvoicing.Run(scope, oppsandinvoices);
		if (oppsandinvoices!=null && oppsandinvoices.hasError)
			database.rollback(startInvoicing);
	}
	
	global void finish(Database.BatchableContext BC){
		// jobs to do with opps and invoices ...
		SystemSettings.logError('Number of initial Opps' + initialoppids.size());
		SystemSettings.logError('HasError: ' + oppsandinvoices.hasError);
		OpportunityStockAndInvoicingHelper.freeOpportunities(initialoppids, oppsandinvoices);
		if (oppsandinvoices!=null && !oppsandinvoices.hasError && !oppsandinvoices.opportunities.isEmpty()) {
			OpportunityStockAndInvoicingHelper.print(oppsandinvoices.opportunities, oppsandinvoices.opportunitiesNoFak, oppsandinvoices.invoices);
		}
		// Auftragsbestaetigungen muessen gedruckt werden wenn:
		// Latzte Rechnung = NULL AND Zahl_der_Fakturierungen__c=1
		// TODO Code fuer Auftragsbestaetung 
		if (oppsandinvoices!=null && !oppsandinvoices.hasError) {
			list<Opportunity> oppstoupdate = new list<Opportunity>();
			for(Opportunity o:[ SELECT Id, Letzte_Rechnung__c, Zahl_der_Fakturierungen__c FROM Opportunity WHERE Id IN: oppsandinvoices.Opportunities.keySet()]) {
				if(o.Letzte_Rechnung__c == null && o.Zahl_der_Fakturierungen__c == 1 && o.Zahl_der_Fakturierungen__c!=oppsandinvoices.opportunitiesNoFak.get(o.id)) {
	                o.Conga_Workflow_for_Activation__c = True;
	                oppstoupdate.add(o);
				}
			}
			try {
				update oppstoupdate;
			} catch (System.DmlException e) {
				SystemSettings.logError('Print Auftragsbestaetigung ist fehlgeschlagen! ' + e.getMessage());
			}
		}
		
		// finally lock opp
		if (!oppsandinvoices.opportunities.isEmpty()) {
			OpportunityStockAndInvoicingHelper.lockOpportunities(oppsandinvoices);
		}

		SystemSettings.insertErrors();
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