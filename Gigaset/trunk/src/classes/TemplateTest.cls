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
private class TemplateTest {

	/*
		Testclass for tests of all templates
	*/

    static testMethod void DETemplateControllerTest() {
       DETemplateController ctrl = new DETemplateController();
       DETrainingController ctrlTrain = new DETrainingController(ctrl);
       ctrl.init();
       ctrl.getImprintUrl();
       
       //training 
       User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
	 		
        ctrlTrain.Modules_Param = [select id from Training_Module__c limit 1].Id;
        ApexPages.currentPage().getParameters().put('moduleId',  ctrlTrain.Modules_Param);
        ctrlTrain.getBooks();
        ctrlTrain.firstPage();
        ctrlTrain.Poller();
        ctrlTrain.secondPage();
        ctrlTrain.showModule();
        ctrlTrain.getModules();
        ctrlTrain.getCampus_1_Title(); 
        ctrlTrain.getCampus_2_Title();
        ctrlTrain.getCampus_3_Title();
        ctrlTrain.getCampus_4_Title();
        ctrlTrain.getCampus_lastPage1();
        ctrlTrain.getCampus_lastPage2();
        ctrlTrain.getCampus_main_Description1();
        ctrlTrain.getCampus_main_Description2();
        ctrlTrain.getCampus_otherPage1();
        ctrlTrain.getCampus_otherPage2();
        ctrlTrain.getCampus_otherPage3();
        ctrlTrain.getCampus_otherPage4();
        ctrlTrain.getCampus_otherPage5();
        ctrlTrain.getCampus_otherPage6();
        ctrlTrain.getCampus_smallBox1();
        ctrlTrain.getCampus_smallBox2();
        ctrlTrain.getCampus_smallBox3();
        ctrlTrain.getCampus_smallBox4();
        ctrlTrain.getCampus_Title_1();
        ctrlTrain.getCampus_underTitle();
        ctrlTrain.getCampus_Welcome();
	 	}
       //end of trainig 
        
	 ctrl.getKontaktformularUrl();
	 ctrl.getRueckrufserviceUrl();
	 ctrl.getCopyright();
	 ctrlTrain.initHome();
	 ctrl.getComponentControllerMap();
	 ctrl.getMyComponentController();
	 ctrlTrain.getRecentNewsId();
	 ctrl.getThis();
	 ctrl.getCurrentNavigationPointLabel(SystemSettings.loginpageid);
       System.assert(ctrl.isAuthenticated!=null);
       SystemSettings.logError('test', 'test', 'test', '', 'error');
    }
}