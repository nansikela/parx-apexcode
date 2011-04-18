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
    	testData.initData mytestData = new testData.initData('de',false);
    	
	 	test.setCurrentPage(Page.DE_Register);
	 	ApexPages.currentPage().getParameters().put('pageid',SystemSettings.registrationpageid);
        registerController ctrl = new registerController();
        ctrl.portal='de';
        ctrl.l.Lastname='Test';
        ctrl.l.Company='Test';
        ctrl.l.Datenschutzerkl_rung_zugestimmt__c=true;
        ctrl.selectedDistribution.add('Warenhaus');
        
        ctrl.getActive0();
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
        ctrl.step=1;
        ctrl.nextStep();
        ctrl.step=2;
        ctrl.nextStep();
        ctrl.step=3;
        ctrl.nextStep();
	 	ctrl.getActive1();
        
        ctrl.step=2;
        ctrl.l.Anmeldung_Telefon__c=true;
        ctrl.nextStep();
        ctrl.l.Anmeldung_Telefon__c=false;
        ctrl.l.Anmeldung_Mobiltelefon__c=true;
        ctrl.nextStep();
        ctrl.l.Anmeldung_Mobiltelefon__c=false;
        ctrl.l.Anmeldung_Hotlinetelefon__c=true;
        ctrl.nextStep();
        ctrl.l.Anmeldung_Hotlinetelefon__c=false;
        ctrl.l.Fax='+49 123454';
        ctrl.l.Phone='+49 123454';
        ctrl.l.Telefon_Kontakt__c='+49 123454';
        ctrl.l.Fax_Kontakt__c='+49 123454';
        ctrl.l.MobilePhone='+49 123454';
        ctrl.l.Sonstige_Telefonnummer__c='+49 123454';
        ctrl.nextStep();
    }
}