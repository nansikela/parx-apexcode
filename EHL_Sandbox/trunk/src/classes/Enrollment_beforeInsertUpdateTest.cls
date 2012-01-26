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
private class Enrollment_beforeInsertUpdateTest {

    static testMethod void myUnitTest() {
    	try {
     	Account[] accounts = new Account[]{
				new Account(Name = 'TestAccount1'),
				new Account(Name = 'TestAccount2'),
				new Account(Name = 'TestAccount3'),
				new Account(Name = 'TestAccount4')
			};
						
		insert accounts; 
	      
	      
		Contact[] contacts = new Contact[]{
				new Contact(LastName = 'LastName1', FirstName = 'FirstName1', Student_Name__c = 'StudentName1', AccountId = accounts[0].Id),
				new Contact(LastName = 'LastName2', FirstName = 'FirstName2', Student_Name__c = 'StudentName2', AccountId = accounts[1].Id),
				new Contact(LastName = 'LastName3', FirstName = 'FirstName3', Student_Name__c = 'StudentName3', AccountId = accounts[2].Id),
				new Contact(LastName = 'LastName4', FirstName = 'FirstName4', Student_Name__c = 'StudentName4', AccountId = accounts[3].Id)
			};
						
		insert contacts; 
	
	
	
		Application__c[] applications = new Application__c[]{
				new Application__c(Student__c = contacts[0].Id)
			};
						
		insert applications; 
	
	
		Enrollment__c[] enrollments = new Enrollment__c[]{
				new Enrollment__c(Application__c = applications[0].Id)
			};
						
		insert enrollments; 
	
	
	
	
		System.assertEquals([Select id, Student_Name__c from Enrollment__c where id = :enrollments[0].Id].Student_Name__c, 'FirstName1 Lastname1');


            
        }
        catch (System.Exception ex) {
            System.debug(ex);
            System.assert(false);
        }
	      
	}
}