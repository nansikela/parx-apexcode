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
private class TaskAfterUpdateHandlerTest {

    static testMethod void testShiftChainedTasks() {
        // create test data
        Lead l=new Lead(Lastname='test',Company='test');
        insert l;
        list<String> chainedtitles = new list<String>{ 'Welcome Call', 'Tech Call', '1. Review Call', '2. Review Call' };
        
        list<Task> tasks=new list<Task>();
        for (Integer i=0;i<chainedtitles.size();i++) {
        	Task t=new Task(Subject=chainedtitles.get(i),ActivityDate=System.today()+i,Status='Nicht begonnen',whoid=l.id);
        	tasks.add(t);
        }
        insert tasks;
        
        Test.startTest();
        	tasks.get(0).ActivityDate=System.today()+14;
        	update tasks;
        Test.stopTest();
        for(Task t:[SELECT Id, ActivityDate, Subject FROM Task WHERE Whoid=:l.id]) {
        	for (Integer i=0;i<chainedtitles.size();i++) {
        		if (tasks.get(i).Subject==t.Subject)
        			System.assertEquals(System.today().addDays(14+i),t.ActivityDate);
        	}
        }
    }
}