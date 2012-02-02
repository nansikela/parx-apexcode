global class ReportCalculationBatch implements Database.Batchable<sObject>,Database.Stateful {

	global String query;
	global ReportResult__c rresult;
	global ReportKonfiguration__c rkonf;
	
	global ReportCalculationBatch(String q, ReportKonfiguration__c rk){
		rresult=new ReportResult__c(); 
		query=q; 
		rkonf=rk;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		//rresult=ReportCalculation.ReportCalculationRun(scope,rkonf,rresult);
	}
	
	global void finish(Database.BatchableContext BC){
		
		/*
		// Get the ID of the AsyncApexJob representing this batch job
		// from Database.BatchableContext.
		// Query the AsyncApexJob object to retrieve the current job's information.
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
		TotalJobItems, CreatedBy.Email
		from AsyncApexJob where Id =
		:BC.getJobId()];
		// finish
		if (a.Status=='Completed' || a.Status=='Abgeschlossen' || a.NumberOfErrors==0) {
			insert rresult;
		}
		// Send an email to the Apex job's submitter notifying of job completion.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Report Ergebnis Status ' + a.Status);
		String reportid=rresult.id!=null?String.valueOf(rresult.id):'none';
		String plainString='';
		String htmlString='';
		if (reportid!='none') {
			plainString='Der angeforderte Report wurde erzeugt: https://emea.salesforce.com/' + reportid;
			htmlString='Der angeforderte Report wurde erzeugt: <a href="https://emea.salesforce.com/' + reportid + '">' + reportid + '</a>';
		} else {
			plainString='Der angeforderte Report konnte nicht erzeugt werden, wenden Sie sich bitte an Ihren Administrator!';
			htmlString='Der angeforderte Report konnte nicht erzeugt werden, wenden Sie sich bitte an Ihren Administrator!';
		}
		mail.setPlainTextBody(plainString);
		mail.setHtmlBody(htmlString);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		*/
	}
}