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
private class DETemplateTest {

	/*
		Testclass for tests of all templates
	*/

    static testMethod void DETemplateControllerTest() {
    	testData.initData mytestData1=new testData.initData('de', false);
    	User u = [Select ID From User Where ContactId != null and isactive=true limit 1];
    	System.runas(u){
    	PageReference pageRef = Page.DE_Home;
        Test.setCurrentPage(pageRef);
        DETemplateController ctrl = new DETemplateController();
       
       /* create books */
       list<Training_Book__c> books = new list<Training_Book__c>();
       for (Integer i=0; i<5; i++) {
       	// create 5 books
       	Training_Book__c b= new Training_Book__c();
       	b.Buchhaenger__c=true;
       	b.Titel__c='Title'+i;
       	b.Aktiv__c=true;
       	b.Portal__c=SystemSettings.portal;
       	b.Gigaset_Pro__c=SystemSettings.isPro;
       	books.add(b);
       }
       insert books;
       
       /* create modules */
       list<Training_Module__c> tms= new list<Training_Module__c>();
       for (Training_Book__c b: [SELECT Id FROM Training_Book__c WHERE Titel__c LIKE 'Title%' AND Aktiv__c=true]) {
       	Training_Module__c m=new Training_Module__c();
       	m.Training_Book__c=b.id;
       	m.Titel__c='Title';
       	m.Aktiv__c=true;
       	tms.add(m);
       }
		insert tms;
		
       ctrl.init();
       ctrl.getImprintUrl();
       
       
        
	 ctrl.getKontaktformularUrl();
	 ctrl.getRueckrufserviceUrl();
	 ctrl.getCopyright();
	 ctrl.getShowNextTopShop();
	 ctrl.initHome();
	 ctrl.getModules_URLPage();
	 ctrl.getCampus_1_Title(); 
        ctrl.getCampus_2_Title();
        ctrl.getCampus_3_Title();
        ctrl.getCampus_4_Title();
        ctrl.getCampus_lastPage1();
        ctrl.getCampus_lastPage2();
        ctrl.getCampus_main_Description1();
        ctrl.getCampus_main_Description2();
        ctrl.getCampus_otherPage1();
        ctrl.getCampus_otherPage2();
        ctrl.getCampus_otherPage3();
        ctrl.getCampus_otherPage4();
        ctrl.getCampus_otherPage5();
        ctrl.getCampus_otherPage6();
        ctrl.getCampus_smallBox1();
        ctrl.getCampus_smallBox2();
        ctrl.getCampus_smallBox3();
        ctrl.getCampus_smallBox4();
        ctrl.getCampus_Title_1();
        ctrl.getCampus_underTitle();
        ctrl.getCampus_Welcome();
        
        DETrainingController.Modulen mods =new DETrainingController.Modulen();
        DETrainingController.Booken bbooks = new DETrainingController.Booken();
        ctrl.firstPage();
	 ctrl.getCurrentNavigationPointLabel(SystemSettings.loginpageid);
       System.assert(ctrl.isAuthenticated!=null);
       SystemSettings.logError('test', 'test', 'test', '', 'error');
       	ctrl.redirectTologin();
       	ctrl.getBooks();
       	ApexPages.currentPage().getParameters().put('moduleId',tms.get(0).id);
       	ctrl.showModule();
       	ctrl.getModules();
       	ctrl.initModuleResult();
    	}
    }
    
    static testMethod void DEtrainigTests() {
    	testData.initData mytestData2=new testData.initData('de', true);
    	PageReference pageRef = Page.DE_Home;
        Test.setCurrentPage(pageRef);
        DETemplateController ctrl = new DETemplateController();
        DETrainingController ctrlTrain = new DETrainingController(ctrl);
        
        /* create books */
       list<Training_Book__c> books = new list<Training_Book__c>();
       for (Integer i=0; i<5; i++) {
       	// create 5 books
       	Training_Book__c b= new Training_Book__c();
       	b.Buchhaenger__c=true;
       	b.Titel__c='Title'+i;
       	b.Aktiv__c=true;
       	b.Portal__c=SystemSettings.portal;
       	b.Gigaset_Pro__c=SystemSettings.isPro;
       	books.add(b);
       }
       insert books;
       
       /* create modules */
       list<Training_Module__c> tms= new list<Training_Module__c>();
       for (Training_Book__c b: [SELECT Id FROM Training_Book__c WHERE Titel__c LIKE 'Title%' AND Aktiv__c=true]) {
       	Training_Module__c m=new Training_Module__c();
       	m.Training_Book__c=b.id;
       	m.Titel__c='Title';
       	m.Aktiv__c=true;
       	tms.add(m);
       }
		insert tms;
		
		//training 
       User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
       /* create some results */
       list<Training_Ergebnis__c> tes = new list<Training_Ergebnis__c>();
       for (Training_Module__c tm: tms) {
       	Training_Ergebnis__c te= new Training_Ergebnis__c();
       	te.Kontakt__c=u.contactId;
       	te.Last_Click__c=system.today();
       	te.Training_Modul__c=tm.id;
       	tes.add(te);
       }
       insert tes;
	 	System.runAs(u) {
	 	test.startTest();
        ctrl.Modules_Param = tms.get(0).Id;
        ctrlTrain.Modules_Param = tms.get(0).Id;
        ApexPages.currentPage().getParameters().put('moduleId',  ctrl.Modules_Param);
        ctrlTrain.getBooks();
        ctrlTrain.getModules();
        ctrlTrain.firstPage();
        ctrl.Poller();
        ctrlTrain.Poller();
        ctrl.secondPage();
        ctrlTrain.secondPage();
        ctrlTrain.showModule();
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
        ctrlTrain.initModuleResult();
        ctrlTrain.initHome();
        test.stopTest();
	 	}
       //end of trainig 
    }
}