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
private class registerControllerTest {
 
    static testMethod void testRegisterController() {
    	User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
        registerController ctrl = new registerController();
        ctrl.l.Lastname='Test';
        ctrl.l.Company='Test';
        ctrl.getActive1();
        ctrl.getActive2();
        ctrl.getActive3();
        ctrl.getServiceHotlineUrl();
        ctrl.goToStep();
        ctrl.init();
        ctrl.nextStep();
        ctrl.previousStep();
        ctrl.relationshipSelectionAction();
        ctrl.saveLead();
        ctrl.showShippingAddressAction();
        ctrl.getItems();
	 	}
    }
}