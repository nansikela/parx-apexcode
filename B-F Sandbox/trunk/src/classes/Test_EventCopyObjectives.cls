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
private class Test_EventCopyObjectives {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        insert u1;
                
        Market__c m = new Market__c();
        m.Name = 'Test Market'; 
        insert m;
                           
        
        test.starttest();
        	system.runas(u1) {
        		Account a = new Account();
        		a.Name = 'Test Account';
        		a.Market__c = m.Id;
        		insert a;
        
        		Event e = new Event();
        		e.DurationInMinutes = 60;
        		e.ActivityDateTime = date.today();
        		e.WhatId = a.Id;
        		e.Objectives__c = 'Test Objectives';
        		insert e;
        	}          
        test.stoptest();
    }
}