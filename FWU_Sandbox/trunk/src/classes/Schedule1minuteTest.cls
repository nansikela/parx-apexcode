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
private class Schedule1minuteTest {

    static testMethod void myUnitTest() {
        String AccId = testData.creationAccount();
        Opportunity o= new Opportunity(Name='test', AccountId=AccId, Conga_Workflow_for_Activation__c=True, CloseDate = system.today(), StageName = 'In Erstellung');
        insert o;
              
        test.startTest();
        Schedule1minute s = new Schedule1minute();
	  String hour = String.valueOf(Datetime.now().hour());
	  String min = String.valueOf(Datetime.now().minute());
	  String ss = String.valueOf(Datetime.now().second()+1);
	  String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
	  system.schedule('Start me once', nextFireTime, s); 
        test.stopTest();
        
        list<String> oList = new list<String>();
        oList.add(o.Id);
        CongaActivation.init(oList);
    }
}