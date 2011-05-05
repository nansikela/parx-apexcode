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
private class ScheduleContacttoUserTest {

    static testMethod void myUnitTest() {
        Account a = new account (Name='test');
        insert a;
        contact c= new Contact(LastName='test', AccountId=a.Id, Email='test@asd.com', toActivate__c=True);
        insert c;
        case ca = new case(Origin ='Telefon', AccountId=a.Id, ContactId=c.Id, Description='test',Type='Frage');
        insert ca;
        
        test.startTest();
        ScheduleContacttoUser s = new ScheduleContacttoUser();
	  String hour = String.valueOf(Datetime.now().hour());
	  String min = String.valueOf(Datetime.now().minute());
	  String ss = String.valueOf(Datetime.now().second()+1);
	  if(Datetime.now().minute() + 1 > 59) {
			min='0';
			hour = String.valueOf(Datetime.now().hour()+1); 
		}
		        
		if(Datetime.now().hour() + 1 > 23) {
			hour = '0'; 
		}
	  String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
	  system.schedule('Start me once', nextFireTime, s); 
        test.stopTest();

        Activation.init(c.Id, False);
        c.toActivate__c = false;
        update c;
        Activation.init(c.Id, False);
        c.toActivate__c = false;
        update c;
        Activation.init(c.Id, True);
        Activation.init(c.Id, False);
        ContactRemove.remove(c.Id);
        c.toDeactivate__c = True;
        update C;
        ContactRemove.init();
    }
}