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
private class ClearingControllerTest {

    static testmethod void clearingtest() {
    	testData.initData mytestData= new testData.initData('de',false);
    	// be sure that clearing will be shown
    	mytestData.contacts.get(0).Gigaset_Extranet__c=false;
    	mytestData.contacts.get(0).Gigaset_Pro__c=true;
    	update mytestData.contacts.get(0);
	 	System.runAs(mytestData.testuser) {
		 	System.debug('Will clearing be shown? ' + System_Settings.showClearing());
		 	ClearingController ctrl = new ClearingController();
		 	ctrl.isAuthenticated=true;
		 	ctrl.getCurrentUser();
		 	
		 	ctrl.getItems();
		 	ctrl.relationshipSelectionAction();
		 	ctrl.saveData();
		 	ctrl.step=1;
		 	ctrl.previousStep();
		 	ctrl.selectedDistribution=new list<String>();
		 	ctrl.selectedDistribution.add('Warenhaus');
		 	ctrl.showDistribution=true;
		 	ctrl.getCurrentUser();
		 	ctrl.getItems();
		 	ctrl.relationshipSelectionAction();
		 	ctrl.saveData();
	 	}
	 	mytestData.testuser.In_Freischaltung__c=true;
	 	update mytestData.testuser;
	 	System.runAs(mytestData.testuser) {
	 	ClearingController ctrl = new ClearingController();
	 	ctrl.isAuthenticated=true;
	 	ctrl.getCurrentUser();
	 	ctrl.step=1;
	 	ctrl.previousStep();
	 	ctrl.saveData();
	 	ctrl.getItems();
	 	ctrl.relationshipSelectionAction();
	 	ctrl.selectedDistribution=new list<String>();
	 	ctrl.selectedDistribution.add('Warenhaus');
	 	ctrl.showDistribution=true;
	 	ctrl.getCurrentUser();
	 	ctrl.getItems();
	 	ctrl.relationshipSelectionAction();
	 	ctrl.saveData();
	 	
	 	}
	 }
}