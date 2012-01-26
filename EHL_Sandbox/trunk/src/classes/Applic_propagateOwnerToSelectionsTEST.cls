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
private class Applic_propagateOwnerToSelectionsTEST {

    static testMethod void myUnitTest() {
        
        String OWNER_USERID = '005200000015uHC';
        
        
        // create application
        Application__c myApp = new Application__c();
        myApp.ownerid = OWNER_USERID;
        insert myApp;        
        
        // create selections 
        Selection__c mySelectionA = new Selection__c();
        mySelectionA.application__c = myApp.id;
        
        Selection__c mySelectionB = new Selection__c();
        mySelectionB.application__c = myApp.id;
        
        Selection__c mySelectionC = new Selection__c();
        
        insert mySelectionA;
        insert mySelectionB;
        insert mySelectionC;
        
        system.assert(mySelectionA.Application_Owner__c == null);
        system.assert(mySelectionB.Application_Owner__c == null);
        system.assert(mySelectionC.Application_Owner__c == null);
        
        
        // update application
        myApp.Final_GPA__c  = '123';
        update myApp;

        
        // check if application owner was correctly copied to selections 
		List<Selection__c> theSelections = [SELECT Application_Owner__c FROM Selection__c WHERE id IN (:mySelectionA.id, :mySelectionB.id, :mySelectionC.id)] ;     
        system.assert(theSelections.size() == 3);
         
        for(Selection__c selection : theSelections) {
        
        	if(selection.id == mySelectionA.id){
        		system.assert(selection.Application_Owner__c == OWNER_USERID);
        	}
        	else if(selection.id == mySelectionB.id){
        		system.assert(selection.Application_Owner__c == OWNER_USERID);
        	}
        	else{
        		system.assert(selection.Application_Owner__c == null);
        	}
        
        }
        
    }
    
}