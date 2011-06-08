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

    
    static testMethod void TemplateControllerTest() {
    	User u = [Select ID From User Where ContactId != null and isactive=true limit 1];
    	System.runas(u){
    	PageReference pageRef = Page.CRD_Home;
        Test.setCurrentPage(pageRef);
       TemplateController ctrl = new TemplateController();
       
       /* create books */
       list<Training_Book__c> books = new list<Training_Book__c>();
       for (Integer i=0; i<5; i++) {
       	// create 5 books
       	Training_Book__c b= new Training_Book__c();
       	b.Buchhaenger__c=true;
       	b.Titel__c='Title'+i;
       	b.Aktiv__c=true;
       	b.Portal__c=System_Settings.portal;
       	b.Gigaset_Pro__c=System_Settings.isPro;
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
        
        TrainingController.Modulen mods =new TrainingController.Modulen();
        TrainingController.Booken bbooks = new TrainingController.Booken();
        ctrl.firstPage();
	 ctrl.getCurrentNavigationPointLabel(System_Settings.loginpageid);
       System.assert(ctrl.isAuthenticated!=null);
       SystemSettings.logError('test', 'test', 'test', '', 'error');
       ctrl.redirectTologin();
       	ctrl.getBooks();
       	ApexPages.currentPage().getParameters().put('moduleId',tms.get(0).id);
       	ctrl.showModule();
       	ctrl.getModules();
       	ctrl.initModuleResult();
       	ctrl.getFirstName();
       	ctrl.getLastName();
       	ctrl.getSalutation();
       	ctrl.getModules_currentSuccess();
       	ctrl.getModules_Param();
       	ctrl.getModules_total();
       	ctrl.getModules_currentpoint();
       	ctrl.getModules_currentbar();
       	ctrl.getModules_showFirstpage();
       	ctrl.getModules_showThirdpage();
       	ctrl.getModules_LektoraURL();
       	ctrl.getNewsid();
       	ctrl.getModules_book();
       	ctrl.getModules_modulesSecondPage1();
       	ctrl.getModules_SingleModule();
       	ctrl.Poller();
       	ctrl.secondPage();
       	ctrl.getModules_modulesSecondPage2();
       	ctrl.getNTS();
       	ctrl.getTarget();
       	ctrl.getPopupurl();
       	ctrl.getIsPDF();
       	ctrl.getIsFlash();
       	ctrl.getIsNative();
    	}
    }
    
    static testMethod void trainigTests() {
    	PageReference pageRef = Page.CRD_Home;
        Test.setCurrentPage(pageRef);
        TemplateController ctrl = new TemplateController();
        TrainingController ctrlTrain = new TrainingController(ctrl);
        
        /* create books */
       list<Training_Book__c> books = new list<Training_Book__c>();
       for (Integer i=0; i<5; i++) {
       	// create 5 books
       	Training_Book__c b= new Training_Book__c();
       	b.Buchhaenger__c=true;
       	b.Titel__c='Title'+i;
       	b.Aktiv__c=true;
       	b.Portal__c=System_Settings.portal;
       	b.Gigaset_Pro__c=System_Settings.isPro;
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
        TrainingController.Modules_Param = tms.get(0).Id;
        ApexPages.currentPage().getParameters().put('moduleId',  TrainingController.Modules_Param);
        TrainingController.getBooks();
        TrainingController.getModules();
        TrainingController.firstPage();
        TrainingController.Poller();
        TrainingController.secondPage();
        TrainingController.showModule();
        TrainingController.getCampus_1_Title(); 
        TrainingController.getCampus_2_Title();
        TrainingController.getCampus_3_Title();
        TrainingController.getCampus_4_Title();
        TrainingController.getCampus_lastPage1();
        TrainingController.getCampus_lastPage2();
        TrainingController.getCampus_main_Description1();
        TrainingController.getCampus_main_Description2();
        TrainingController.getCampus_otherPage1();
        TrainingController.getCampus_otherPage2();
        TrainingController.getCampus_otherPage3();
        TrainingController.getCampus_otherPage4();
        TrainingController.getCampus_otherPage5();
        TrainingController.getCampus_otherPage6();
        TrainingController.getCampus_smallBox1();
        TrainingController.getCampus_smallBox2();
        TrainingController.getCampus_smallBox3();
        TrainingController.getCampus_smallBox4();
        TrainingController.getCampus_Title_1();
        TrainingController.getCampus_underTitle();
        TrainingController.getCampus_Welcome();
        test.stopTest();
	 	}
       //end of trainig 
    }
}