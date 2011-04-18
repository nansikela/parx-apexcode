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
private class DEwerbemittelControllerTest {

    static testMethod void DEwerbemittelControllerTest1() {
    	testData.initData mytestData = new testData.initData('de',false);
    	testData.werbemittelData wmData = new testData.werbemittelData('de',false);
        DEwerbemittelController ctrl = new DEwerbemittelController();
        
        DEuserdataController uCtrl = ctrl.getctrl();
        uCtrl = new DEuserdataController();
        System.debug(uCtrl.u.Id);
        
        for(Contact c : [SELECT Id, AccountId FROM Contact WHERE  id =: uCtrl.u.ContactId])
        	uCtrl.c = c;
        	
        ctrl.firstPage();
        ctrl.secondPage(); //For else Case
        
        DEwerbemittelController.myterm t = new DEwerbemittelController.myterm();
        t.quantity = '011';
        insert t.term;
        ctrl.Verify(t);
        //ctrl.setTerms(t);
        ctrl.setTerms2(t);
        
        ctrl.secondPage(); //For if Case
        ctrl.thirdPage();
        
        ctrl.setbestellungTemp();
        ctrl.getbestellungTemp();
        
        ctrl.getTerms();
        ctrl.getTerms2();
    }
    
    static testMethod void DEwerbemittelControllerTest2() {
    	testData.initData mytestData = new testData.initData('de',false);
    	testData.werbemittelData wmData = new testData.werbemittelData('de',false);
    	System.runAs(mytestData.testuser) {
        DEwerbemittelController ctrl = new DEwerbemittelController();
        
        DEuserdataController uCtrl = ctrl.getctrl();
        uCtrl = new DEuserdataController();
        System.debug(uCtrl.u.Id);
        
        
        	uCtrl.c = mytestData.contacts.get(0);
        	
        ctrl.firstPage();
        ctrl.secondPage(); //For else Case
        
        DEwerbemittelController.myterm t = new DEwerbemittelController.myterm();
        t.quantity = '011';
        insert t.term;
        ctrl.setTerms2(t);
        
        ctrl.secondPage(); //For if Case
        ctrl.thirdPage();
        
        ctrl.setbestellungTemp();
        ctrl.getbestellungTemp();
        
        ctrl.getTerms();
        ctrl.getTerms2();
    	}
    }
}