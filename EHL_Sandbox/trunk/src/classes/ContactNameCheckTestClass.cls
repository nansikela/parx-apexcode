/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ContactNameCheckTestClass {

    static testMethod void myUnitTest() {
     	Account[] accounts = new Account[]{
				new Account(Name = 'TestAccount1', Country_Preferred__c = 'NIX'),
				new Account(Name = 'TestAccount2', Country_Preferred__c = 'NIX'),
				new Account(Name = 'TestAccount3', Country_Preferred__c = 'NIX'),
				new Account(Name = 'TestAccount4', Country_Preferred__c = 'NIX')
			};
						
		insert accounts; 
	      
	      
		Contact[] contacts = new Contact[]{
				new Contact(LastName = 'LastName1', FirstName = 'FirstName1', Student_Name__c = 'StudentName1', AccountId = accounts[0].Id),
				new Contact(LastName = 'LastName2', FirstName = 'FirstName2', Student_Name__c = 'StudentName2', AccountId = accounts[1].Id),
				new Contact(LastName = 'LastName3', FirstName = 'FirstName3', Student_Name__c = 'StudentName3', AccountId = accounts[2].Id),
				new Contact(LastName = 'LastName4', FirstName = 'FirstName4', Student_Name__c = 'StudentName4', AccountId = accounts[3].Id)
			};
						
		insert contacts; 
	      	      
		Opportunity[] opportunities = new Opportunity[]{
				new Opportunity(AccountId = accounts[0].Id, Contact_Student__c = contacts[0].Id, StageName = 'Application in Process', CloseDate = date.today().addDays(2)),
				new Opportunity(AccountId = accounts[1].Id, Contact_Student__c = contacts[1].Id, StageName = 'Application in Process', CloseDate = date.today().addDays(2)),
				new Opportunity(AccountId = accounts[2].Id, Contact_Student__c = contacts[2].Id, StageName = 'Application in Process', CloseDate = date.today().addDays(2)),
				new Opportunity(AccountId = accounts[3].Id, Contact_Student__c = contacts[3].Id, StageName = 'Application in Process', CloseDate = date.today().addDays(2))
			};
			  
			      
	      
		insert opportunities; 
		   
		contacts[0].LastName = 'LastName1_neu'; 		   
		contacts[0].FirstName = 'FirstName1_neu';  		   
		contacts[0].Student_Name__c = 'StudentName1_neu'; 		   
		   
		contacts[1].LastName = 'LastName2_neu'; 		   
		contacts[1].FirstName = 'FirstName2_neu';  		   
		contacts[1].Student_Name__c = 'StudentName2_neu'; 		   
		   
		contacts[2].LastName = 'LastName3_neu'; 		   
		contacts[2].FirstName = 'FirstName3_neu';  		   
		contacts[2].Student_Name__c = 'StudentName3_neu'; 		   
		   
		contacts[3].LastName = 'LastName4_neu'; 		   
		contacts[3].FirstName = 'FirstName4_neu';  		   
		contacts[3].Student_Name__c = 'StudentName4_neu'; 		   
		   
		update contacts;		   
    	Test.startTest();   
		   
		datetime starttime = datetime.now().addSeconds( 10);
		 
//		String cron_string = starttime.format('s') + ' ' + starttime.format('m') + ' ' + starttime.format('k') + ' * * ?';
//		System.debug('cron_string  = ' + cron_string);
//		String jobId = System.schedule('ContactNameCheck_Schedulable',
//			cron_string, new ContactNameCheck_Schedulable());
		
//		System.debug('jobId  = ' + jobId);
    
    
    
    	System.debug('********************** execute methode der Klasse ContactNameCheck_Schedulable');
        
        ContactNameCheck_OpportunityBatchable oppBatchJob = new ContactNameCheck_OpportunityBatchable();
		System.debug('********************** ContactNameCheck_OpportunityBatchable batchprocessid:' + Database.executeBatch(oppBatchJob,50));
		
        ContactNameCheck_ApplicationBatchable appBatchJob = new ContactNameCheck_ApplicationBatchable();
		System.debug('********************** ContactNameCheck_ApplicationBatchable batchprocessid:' + Database.executeBatch(appBatchJob,50));
    
		Test.stopTest();      
		
/*		System.debug('********************** Opportunity.name:' + [Select id, Name from Opportunity where id = :opportunities[0].Id].Name);		
		System.assertEquals([Select id, Name from Opportunity where id = :opportunities[0].Id].Name, 'FirstName1_neu Lastname1_neu: -');
		System.debug('********************** Opportunity.name:' + [Select id, Name from Opportunity where id = :opportunities[1].Id].Name);		
		System.assertEquals([Select id, Name from Opportunity where id = :opportunities[1].Id].Name, 'FirstName2_neu Lastname2_neu: -');
		System.debug('********************** Opportunity.name:' + [Select id, Name from Opportunity where id = :opportunities[2].Id].Name);		
		System.assertEquals([Select id, Name from Opportunity where id = :opportunities[2].Id].Name, 'FirstName3_neu Lastname3_neu: -');
		System.debug('********************** Opportunity.name:' + [Select id, Name from Opportunity where id = :opportunities[3].Id].Name);		
		System.assertEquals([Select id, Name from Opportunity where id = :opportunities[3].Id].Name, 'FirstName4_neu Lastname4_neu: -');
		
		*/
		
		
//   		AsyncApexJob aaj = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.MethodName, a.JobType, a.JobItemsProcessed, a.Id, a.CreatedDate, a.CreatedById, a.CompletedDate, a.ApexClassId From AsyncApexJob a WHERE a.ID =: jobId ];
//   		System.debug('AsyncApexJob TotalJobItems:' + aaj.TotalJobItems + 'AsyncApexJob CreatedDate:' + aaj.CreatedDate + 'AsyncApexJob CompletedDate:' + aaj.CompletedDate);
      
    }
}