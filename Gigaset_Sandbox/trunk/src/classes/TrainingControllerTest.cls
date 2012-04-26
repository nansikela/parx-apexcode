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
private class TrainingControllerTest {

    static testMethod void TrainingControllerTest() {
    	testData.initData mytestData = new testData.initData('zy',false);
    	 /* create books */
       list<Training_Book__c> books = new list<Training_Book__c>();
       for (Integer i=0; i<5; i++) {
       	// create 5 books
       	Training_Book__c b= new Training_Book__c();
       	b.Buchhaenger__c=true;
       	b.Titel__c='Title'+i;
       	b.Aktiv__c=true;
       	b.Portal__c='zy';
       	b.Gigaset_Pro__c=false;
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
		PageReference pageRef = Page.CRD_Home;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('moduleid',tms.get(0).id);
		System.runAs(mytestData.testuser) {
	    	CRD_pageTemplatesController templateCtrl = new CRD_pageTemplatesController();
	        TrainingController ctrl = new TrainingController(templateCtrl);
	        ctrl.initHome();
	        ctrl.firstPage();
	        ctrl.getBooks();
	        ctrl.getCampus_1_Title();
	        ctrl.getCampus_2_Title();
	        ctrl.getCampus_3_Title();
	        ctrl.getCampus_main_Description1();
	        ctrl.getCampus_main_Description2();
	        ctrl.getCampus_Title_1();
	        ctrl.getCampus_Welcome();
	        ctrl.getModules();
	        ctrl.getRecentNewsId();
	        ctrl.initModuleResult();
	        ctrl.Poller();
	        ctrl.secondPage();
	        ctrl.showModule();
	        
	        TrainingController.getCampus_4_Title();
 			TrainingController.getCampus_underTitle();
 			TrainingController.getCampus_smallBox1();
 			TrainingController.getCampus_smallBox2();
 			TrainingController.getCampus_smallBox3();
 			TrainingController.getCampus_smallBox4();
 			TrainingController.getCampus_otherPage1();
 			TrainingController.getCampus_otherPage2();
 			TrainingController.getCampus_otherPage3();
 			TrainingController.getCampus_otherPage4();
 			TrainingController.getCampus_otherPage5();
 			TrainingController.getCampus_otherPage6();
 			TrainingController.getCampus_lastPage1();
			TrainingController.getCampus_lastPage2();
		}
    }
    
    static testMethod void MobileTrainingControllerTest() {
    	testData.initData mytestData = new testData.initData('zy',false);
    	 /* create books */
       list<Training_Book__c> books = new list<Training_Book__c>();
       for (Integer i=0; i<5; i++) {
       	// create 5 books
       	Training_Book__c b= new Training_Book__c();
       	b.Buchhaenger__c=true;
       	b.Titel__c='Title'+i;
       	b.Aktiv__c=true;
       	b.Portal__c='zy';
       	b.Gigaset_Pro__c=false;
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
		PageReference pageRef = Page.Mobile_Home;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('moduleid',tms.get(0).id);
		System.runAs(mytestData.testuser) {
	        TrainingController ctrl = new TrainingController();
	    	TemplateController templateCtrl = new TemplateController();
	        ctrl = new TrainingController(templateCtrl);
	        ctrl.initMobileHome();
	        ctrl.firstPage();
	        ctrl.getBooks();
	        ctrl.getCampus_1_Title();
	        ctrl.getCampus_2_Title();
	        ctrl.getCampus_3_Title();
	        ctrl.getCampus_main_Description1();
	        ctrl.getCampus_main_Description2();
	        ctrl.getCampus_Title_1();
	        ctrl.getCampus_Welcome();
	        ctrl.getModules();
	        ctrl.getRecentNewsId();
	        ctrl.initModuleResult();
	        ctrl.Poller();
	        ctrl.secondPage();
	        ctrl.showMobileModule();
	        ctrl.processPage();
	        
        	ApexPages.currentPage().getParameters().put('bookID',books.get(0).id);
	        ctrl = new TrainingController(templateCtrl);
		}
    }
}