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
private class Lead_AfterUpdate_MigrateSegmTEST {

    static testMethod void myUnitTest() {
  
		// create lead
		Lead testLead = new Lead();
		testLead.LastName 	= 'Mueller';
		testLead.FirstName 	= 'Peter';
		testLead.Company	= 'Parx';
		insert testLead;     	
		
		// create segmentation attached to prospect
		Segmentation__c testSegmentation1 	= 	new Segmentation__c();
		testSegmentation1.RecordTypeId 		= 	'0122000000050Kq';
		testSegmentation1.Prospect__c 		= 	testLead.id;
		insert testSegmentation1;
		System.debug('***** ID of segmentation is: ' + testSegmentation1.id);
	
		// convert lead to contact
		Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(testLead.id);
		LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
		lc.setConvertedStatus(convertStatus.MasterLabel);
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		System.assert(lcr.isSuccess());
	
	    // check if segmentation was transferred to contact and has correct RT 
		String newContactId = lcr.getContactId();
		List<Segmentation__c> segmentationsList = [Select id, RecordTypeId,Contact__c from Segmentation__c where id=:testSegmentation1.Id];
		System.assert(segmentationsList.size() == 1);
		Segmentation__c currentSegmentation = segmentationsList.get(0);
		System.debug('***** ID of (reloaded) segmentation is: ' + currentSegmentation.id);
		System.debug('***** RT of segmentation is: ' + currentSegmentation.recordTypeId);
		system.assert(currentSegmentation.recordTypeId == '0122000000050Kl');
		System.debug('***** Contact of segmentation is: ' + currentSegmentation.Contact__c);
		system.assert(currentSegmentation.Contact__c == newContactId);
       
    }
}