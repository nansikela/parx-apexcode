global class VisitReportGeneratorBatchable implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {
/*************************************************************
*Name : VisitReportGeneratorBatchable
*Created By : Thomas Schnocklake (Parx)
*Created Date : 3st march,2012
*Purpose : The class will start batch jobs that collect Visit Items corresponding the the criteria 
*         in a Visit Report Configuration and insert corresponding Visit_Report_Configurations
*Pseudo Code : .       
****************************************************************/
    
    global final Visit_Report_Configuration__c configuration;    
    global final String cronId;    
    
    global final static Integer batchSize = 100;
    global final static String debuggingEmailAddress = null;
   
    global final static	List<String> configFields = new List<String>{
			'Id', 
			'Name', 

			'All_Data__c', 

			'Period1_From__c', 
			'Period1_To__c', 
			'Period2_From__c', 
			'Period2_To__c', 

			'IsRecurrence__c', 
			'Recurrence_Int__c', 
			'Recurrence_Unit__c', 
			'Recurrence_Number__c', 
			'LastRecalculation__c', 

			'Outlet_Class__c', 
			'Group__c', 
			'Channel__c', 
			'Market__c'
			};
    global final static	List<String> oviFields = new List<String>{
					'Bottle_Price__c', 'Shelf__c', 'Channel__c', 'BackBarVisit__c', 'CreatedById', 'LastModifiedDate', 'Legacy_Code__c', 'Id', 'Double_Price__c', 'Name', 'IsDeleted', 'RecordTypeId', 'Shelf_Category_Item__c', 'Custom_Product__c', 'SystemModstamp', 'Drink_Price__c', 'Brand__c', 'CocktailCount__c', 'Outlet_Visit_Item_Key__c', 'Location_On__c', 'Location_Off__c', 'Product__c', 'Available__c', 'Double_Price_Special__c', 'PriceTypeFlag__c', 'Position__c', 'CreatedDate', 'Bottle_Price_Special__c', 'Space_Placement__c', 'Location_Reporting__c', 'Placement__c', 'Outlet_Visit__c', 'Drink_Price_Special__c', 'Facing__c', 'LastModifiedById', 'CurrencyIsoCode'
				};    
    
    global final static	List<String> accountFields = new List<String>{
    		'Id', 
			'Name' 
    		};   
   
    global static String recalculationCheck(String cronJobId){
		/**
			* exposed REST WebService that is triggered to process pending recalculation of recurring Visit Report Configurations
			*
			* will search unprocessed configurations and schedule ONE batchjob for the first found.
			* 
			* @date    03.04.2012
			* @author  Thomas Schnocklake
		*/    	
    	
		System.debug('Parameter cronJobId = ' + cronJobId);
		
		// Select the "Visit Report Configurations" that have recurrence 		
		
		
		
    	QueryBuilder query = new QueryBuilder(configFields, 'Visit_Report_Configuration__c');    	

        //Build WHERE Parameters
		List < QueryBuilder.IQueryPart > whereParts = new List < QueryBuilder.IQueryPart > ();

		whereParts.add(new QueryBuilder.BooleanQueryPart('IsRecurrence__c', true));

		query.addWhereParts(whereParts);    			
    			 
		System.debug('********************** query:' + query.getQueryString());       
 			
		List<Visit_Report_Configuration__c> configurationToReclculate = (List<Visit_Report_Configuration__c>) Database.query(query.getQueryString());
		       
		Visit_Report_Configuration__c confToRecalc = checkRecalculationAndUpdate(configurationToReclculate);		       
		if (confToRecalc == null) {
			return 'nothing to recalculate';	
		}		       	
		update confToRecalc;
		
				
		//start the jobs		
		VisitReportGeneratorBatchable batchJob = new VisitReportGeneratorBatchable(configurationToReclculate[0], cronJobId);
		String batchprocessid = Database.executeBatch(batchJob,batchSize);
        System.debug('********************** VisitReportGeneratorBatchable batchprocessid:' + batchprocessid);    

		return '********************** VisitReportGeneratorBatchable batchprocessid:' + batchprocessid;
	}
    

	public static Visit_Report_Configuration__c checkRecalculationAndUpdate(List<Visit_Report_Configuration__c> configurationToReclculate) {
		for (Visit_Report_Configuration__c conf : configurationToReclculate) {
			if (conf.LastRecalculation__c == null) {
				return conf;
			}
			if (conf.Recurrence_Int__c == 'Free Selection') {
				if (conf.Recurrence_Unit__c == 'Day(s)' && conf.LastRecalculation__c <= System.today().addDays(-1 * conf.Recurrence_Number__c.intValue())) {	
					conf.LastRecalculation__c = null;
					conf.Period1_From__c = conf.Period1_From__c.addDays(1 * conf.Recurrence_Number__c.intValue()); 				
					conf.Period1_To__c = conf.Period1_To__c.addDays(1 * conf.Recurrence_Number__c.intValue()); 				
					conf.Period2_From__c = conf.Period2_From__c.addDays(1 * conf.Recurrence_Number__c.intValue()); 				
					conf.Period2_To__c = conf.Period2_To__c.addDays(1 * conf.Recurrence_Number__c.intValue()); 				
					if (conf.Period2_To__c <= System.today()) {
						return conf;					
					} 							
				}
				if (conf.Recurrence_Unit__c == 'Week(s)' && conf.LastRecalculation__c <= System.today().addDays(-7 * conf.Recurrence_Number__c.intValue())) {					
					conf.LastRecalculation__c = null;
					conf.Period1_From__c = conf.Period1_From__c.addDays(7 * conf.Recurrence_Number__c.intValue()); 				
					conf.Period1_To__c = conf.Period1_To__c.addDays(7 * conf.Recurrence_Number__c.intValue()); 				
					conf.Period2_From__c = conf.Period2_From__c.addDays(7 * conf.Recurrence_Number__c.intValue()); 				
					conf.Period2_To__c = conf.Period2_To__c.addDays(7 * conf.Recurrence_Number__c.intValue()); 				
					if (conf.Period2_To__c <= System.today()) {
						return conf;					
					} 							
				}
				if (conf.Recurrence_Unit__c == 'Month(s)' && conf.LastRecalculation__c <= System.today().addMonths(-1 * conf.Recurrence_Number__c.intValue())) {					
					conf.LastRecalculation__c = null;
					conf.Period1_From__c = conf.Period1_From__c.addMonths(1 * conf.Recurrence_Number__c.intValue()).toStartOfMonth(); 				
					conf.Period1_To__c = conf.Period1_To__c.addMonths(1 * conf.Recurrence_Number__c.intValue()).addMonths(1).toStartOfMonth().addDays(-1);
					conf.Period2_From__c = conf.Period2_From__c.addMonths(1 * conf.Recurrence_Number__c.intValue()).toStartOfMonth(); 		 				
					conf.Period2_To__c = conf.Period2_To__c.addMonths(1 * conf.Recurrence_Number__c.intValue()).addMonths(1).toStartOfMonth().addDays(-1); 	 				
					if (conf.Period2_To__c <= System.today()) {
						return conf;					
					} 							
				}
				if (conf.Recurrence_Unit__c == 'Year(s)' && conf.LastRecalculation__c <= System.today().addYears(-1 * conf.Recurrence_Number__c.intValue())) {					
					conf.LastRecalculation__c = null;
					conf.Period1_From__c = conf.Period1_From__c.addYears(1 * conf.Recurrence_Number__c.intValue()).toStartOfMonth(); 				
					conf.Period1_To__c = conf.Period1_To__c.addYears(1 * conf.Recurrence_Number__c.intValue()).addMonths(1).toStartOfMonth().addDays(-1);
					conf.Period2_From__c = conf.Period2_From__c.addYears(1 * conf.Recurrence_Number__c.intValue()).toStartOfMonth(); 		 				
					conf.Period2_To__c = conf.Period2_To__c.addYears(1 * conf.Recurrence_Number__c.intValue()).addMonths(1).toStartOfMonth().addDays(-1); 	 				
					if (conf.Period2_To__c <= System.today()) {
						return conf;					
					} 							
				}
			}
			if (conf.Recurrence_Int__c == 'Weekly' && conf.LastRecalculation__c <= System.today().addDays(-7)) {
				conf.LastRecalculation__c = null;
				conf.Period1_From__c = conf.Period1_From__c.addDays(7); 				
				conf.Period1_To__c = conf.Period1_To__c.addDays(7);
				conf.Period2_From__c = conf.Period2_From__c.addDays(7); 		 				
				conf.Period2_To__c = conf.Period2_To__c.addDays(7); 	 				
				if (conf.Period2_To__c <= System.today()) {
					return conf;					
				} 							
			}			
			if (conf.Recurrence_Int__c == 'Monthly' && conf.LastRecalculation__c <= System.today().addMonths(-1)) {
				conf.LastRecalculation__c = null;
				conf.Period1_From__c = conf.Period1_From__c.addMonths(1).toStartOfMonth(); 				
				conf.Period1_To__c = conf.Period1_To__c.addMonths(1).addMonths(1).toStartOfMonth().addDays(-1);
				conf.Period2_From__c = conf.Period2_From__c.addMonths(1).toStartOfMonth(); 		 				
				conf.Period2_To__c = conf.Period2_To__c.addMonths(1).addMonths(1).toStartOfMonth().addDays(-1); 	 				
				if (conf.Period2_To__c <= System.today()) {
					return conf;					
				} 							
			}			
			if (conf.Recurrence_Int__c == 'Quarterly' && conf.LastRecalculation__c <= System.today().addMonths(-3)) {
				conf.LastRecalculation__c = null;
				conf.Period1_From__c = conf.Period1_From__c.addMonths(3).toStartOfMonth(); 				
				conf.Period1_To__c = conf.Period1_To__c.addMonths(3).addMonths(1).toStartOfMonth().addDays(-1);
				conf.Period2_From__c = conf.Period2_From__c.addMonths(3).toStartOfMonth(); 		 				
				conf.Period2_To__c = conf.Period2_To__c.addMonths(3).addMonths(1).toStartOfMonth().addDays(-1); 	 				
				if (conf.Period2_To__c <= System.today()) {
					return conf;					
				} 							
			}			
			if (conf.Recurrence_Int__c == 'Yearly' && conf.LastRecalculation__c <= System.today().addYears(-1)) {
				conf.LastRecalculation__c = null;
				conf.Period1_From__c = conf.Period1_From__c.addYears(1).toStartOfMonth(); 				
				conf.Period1_To__c = conf.Period1_To__c.addYears(1).addMonths(1).toStartOfMonth().addDays(-1);
				conf.Period2_From__c = conf.Period2_From__c.addYears(1).toStartOfMonth(); 		 				
				conf.Period2_To__c = conf.Period2_To__c.addYears(1).addMonths(1).toStartOfMonth().addDays(-1); 	 				
				if (conf.Period2_To__c <= System.today()) {
					return conf;					
				} 							
			}			
		}	 
		return null; 
	}
    
    static webservice string collectVisitItems(String visitreportconfigurationid) {
		/**
			* exposed WebService for Button in Visit_Report_Configuration__c Layout
			*
			* will trigger two batch jobs to collect date for "Visit Report Configurations".
			* The first job will olllect the first, the second job will collect the secont period
			* 
			* @date    03.04.2012
			* @author  Thomas Schnocklake
		*/    	
		
		// Select the "Visit Report Configurations" 	
			
    	QueryBuilder query = new QueryBuilder(configFields, 'Visit_Report_Configuration__c');    	

        //Build WHERE Parameters
		List < QueryBuilder.IQueryPart > whereParts = new List < QueryBuilder.IQueryPart > ();
		whereParts.add(new QueryBuilder.StringQueryPart('Id', QueryBuilder.SoqlCompareType.kEquals, visitreportconfigurationid));
		query.addWhereParts(whereParts);
    	
    			
		Visit_Report_Configuration__c configuration = (Visit_Report_Configuration__c) Database.query(query.getQueryString());
		
		ApexClass myClass = [Select Id, Name From ApexClass where Name = :'VisitReportGeneratorBatchable'];
		
		List<AsyncApexJob> runningJobs = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Id from AsyncApexJob where ( Status = 'Queued' OR Status = 'Preparing' OR Status = 'Processing') ];
		if (runningJobs.size() >= 5) {
			return System.Label.OutlookVisitReporting_tooManyRecalculations;
		}
		for (AsyncApexJob job : runningJobs) {
			if ( UserInfo.getUserId() == job.CreatedBy.Id || job.ApexClassId == myClass.Id) {								
				return System.Label.OutlookVisitReporting_concurrentPersonalRecalulation;
			} 						
		}

		if (configuration.IsRecurrence__c) {		
			Visit_Report_Configuration__c configurationToUpdate = checkRecalculationAndUpdate(new List<Visit_Report_Configuration__c>{configuration});
			if (configurationToUpdate != null) {
				update configurationToUpdate;	
			}				       
		}		        
						
		//start the jobs		
		VisitReportGeneratorBatchable batchJob = new VisitReportGeneratorBatchable(configuration, null);
        System.debug('********************** VisitReportGeneratorBatchable batchprocessid:' + Database.executeBatch(batchJob,batchSize));    
        return 'batch job started';   
    }
    
    global VisitReportGeneratorBatchable() {
    	
    }
    global VisitReportGeneratorBatchable(Visit_Report_Configuration__c configuration, String cronId) {
    	this.configuration = configuration; 
    	this.cronId = cronId; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
		//delete the already existing data (configuration_to_visit__c)
		delete [select id from configuration_to_visit__c WHERE Visit_Report_Configuration__c=:configuration.id];

		configuration.LastRecalculation__c = System.today();
		update configuration;
		
		return Database.getQueryLocator(generateAccountSelectionStatement(configuration));
    }
    
    
    
    
    // the main selection
    
    public static String generateAccountSelectionStatement(Visit_Report_Configuration__c configuration) {
		/**
			* Select accounts matching the criteria in the configuration
			*
			* Criteria:
			* With "On" only the "Group" Picklist will be taken into account. With "Off" only the Outlet Class will be used. With "Both" you can choose both of them. 
			* "Wholeseller" will only select Visits of "Wholeseller" Accounts ignoring Group and Class.	
			* 
			* @date    03.04.2012
			* @author  Thomas Schnocklake
		*/    	

    		
		List < QueryBuilder.IQueryPart > whereParts = new List < QueryBuilder.IQueryPart > ();

		if (configuration.Market__c != null) {
			whereParts.add(new QueryBuilder.StringQueryPart('Market__c', QueryBuilder.SoqlCompareType.kEquals, configuration.Market__c));
		}

		if (configuration.Channel__c == 'On') {
			//With "On" only the "Group" Picklist will be taken into account.
			if (configuration.Group__c != null) {				
				whereParts.add(new QueryBuilder.ListQueryPart('Group__c', configuration.Group__c.split(';',0)));
			}				
		} else if (configuration.Channel__c == 'Off') {
			//With "Off" only the Outlet Class will be used. 
			if (configuration.Outlet_Class__c != null) {
				whereParts.add(new QueryBuilder.StringQueryPart('Outlet_Class__c', QueryBuilder.SoqlCompareType.kEquals, configuration.Outlet_Class__c));
			}							
		} else if (configuration.Channel__c == 'Both') {
			//With "Both" you can choose both of them.
			if (configuration.Group__c != null) {				
				whereParts.add(new QueryBuilder.ListQueryPart('Group__c', configuration.Group__c.split(';',0)));
			}				
			if (configuration.Outlet_Class__c != null) {
				whereParts.add(new QueryBuilder.StringQueryPart('Outlet_Class__c', QueryBuilder.SoqlCompareType.kEquals, configuration.Outlet_Class__c));
			}							
		} else if (configuration.Channel__c == 'Wholesaler') {
			if (configuration.Group__c != null) {				
				whereParts.add(new QueryBuilder.ListQueryPart('Group__c', new String[]{'Wholesaler'}));
			}				
		} else {
//		todo		
		}
			
			
		QueryBuilder query;
		//List<String> fields = new List<String>{'Name','Id'};

    	
    	
    	query = new QueryBuilder(accountFields, 'Account');    	
		query.addWhereParts(whereParts);				
						
		String queryString = query.getQueryString();// + ' GROUP By Name';
		System.debug(queryString);					
			
		return queryString;
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
		/**
			* Select the Visit_Report_Configurations for the last Visit a period matching the accounts and 
			* insert the corresponding Configuration_to_Visits
			* 
			* @date    03.04.2012
			* @author  Thomas Schnocklake
		*/    	
    	
        String debugging = '';  

        List<Configuration_to_Visit__c> ctovlist = new List<Configuration_To_Visit__c>();
        
        
        for (Integer period : new Integer[]{1,2}) {
	        for (Account account : (List<Account>)scope ) {
				debugging += '\n' + account + '  ' + period;	
	
				List < QueryBuilder.IQueryPart > whereParts = new List < QueryBuilder.IQueryPart > ();
				whereParts.add(new QueryBuilder.ListQueryPart('Outlet_Visit__r.Status__c', new String[]{'Complete'}));
				
				whereParts.add(new QueryBuilder.StringQueryPart('Outlet_Visit__r.Account__c', QueryBuilder.SoqlCompareType.kEquals, account.Id));
				
				if (period == 1) {
					whereParts.add(new QueryBuilder.DateQueryPart('Outlet_Visit__r.Visit_Date__c', QueryBuilder.DateCompareType.kAfter, configuration.Period1_From__c));
					whereParts.add(new QueryBuilder.DateQueryPart('Outlet_Visit__r.Visit_Date__c', QueryBuilder.DateCompareType.kBefore, configuration.Period1_To__c));
				} else if (period == 2) {
					whereParts.add(new QueryBuilder.DateQueryPart('Outlet_Visit__r.Visit_Date__c', QueryBuilder.DateCompareType.kAfter, configuration.Period2_From__c));
					whereParts.add(new QueryBuilder.DateQueryPart('Outlet_Visit__r.Visit_Date__c', QueryBuilder.DateCompareType.kBefore, configuration.Period2_To__c));
				} else {
					// not possible 
				}
	
	
				QueryBuilder query;
				
			
		    	query = new QueryBuilder(oviFields, 'Outlet_Visit_Item__c');    	
				query.addWhereParts(whereParts);
	 
				if (!configuration.All_Data__c) {
					query.setOrder('Outlet_Visit__r.Visit_Date__c DESC');
					query.setLimit(1);
				}
	
				debugging += '\n:\n' + query.getQueryString() + '\n\n\n\n\n';
				
		        for (Outlet_Visit_Item__c ovi: ((List<Outlet_Visit_Item__c>)Database.query(query.getQueryString()))) {
		            debugging += '\n ovi :  ' + ovi;
		            
		            Configuration_to_Visit__c ctov = new Configuration_to_Visit__c();
	            	ctov.Visit_Report_Configuration__c=configuration.id;
	            	ctov.Outlet_Visit_Item__c=ovi.id;
	            	ctovlist.add(ctov);
	        	}
	        }        
        }

		insert ctovlist;
		
		if (debuggingEmailAddress != null) {		
			//debugging only		
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] { debuggingEmailAddress };
			mail.setToAddresses(toAddresses);
			mail.setSubject('Visit Report Generator ');
			mail.setPlainTextBody(debugging);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}		       		
    }    
    
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];

        if (a.NumberOfErrors <= 0) {
			datetime starttime = datetime.now().addSeconds( 10);
			String cron_string = starttime.format('s') + ' ' + starttime.format('m') + ' ' + starttime.format('k') + ' ' + starttime.format('d') + ' ' + starttime.format('M') + ' ? ' + starttime.format('yyyy') + '';
			System.debug('cron_string  = ' + cron_string);
			String jobId = System.schedule('Autostart+VisitReportGeneratorBatchable'+cron_string, cron_string, new VisitReportGeneratorBatchable());
					 
			System.debug('jobId  = ' + jobId); 
        	
        } 
    }







    global void execute(SchedulableContext SC) {
		VisitReportGeneratorBatchable.recalculationCheck(SC.getTriggerId());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
        			        FROM CronTrigger WHERE Id = :SC.getTriggerId()];
		 
		if (ct.NextFireTime == null) { 
			System.abortjob(SC.getTriggerId());
		}


    }
}