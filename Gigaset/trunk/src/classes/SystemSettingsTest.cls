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
private class SystemSettingsTest {

	class initData {
		public list<CustomLabel__c> CustomLabels {get; set;}
		public list<GlobalSettings__c> GlobalSettings { get; set; }
		public list<pages__c> PagesSet { get; set; }
		public list<Page__c> Pages { get; set; }
		public list<PageTemplate__c> PageTemplates { get; set; }
		public String portal { get; set; }
		public Boolean isPro { get; set; }
		
		initData(String port, Boolean Pro) {
			portal=port; isPro=Pro;
			CustomLabels=new list<CustomLabel__c>();
			GlobalSettings=new list<GlobalSettings__c>();
			PagesSet=new list<pages__c>();
			Pages=new list<Page__c>();
			PageTemplates=new list<PageTemplate__c>();
			CustomLabels=createCustomLabels();
			GlobalSettings=createGlobalSettings();
			PageTemplates=createPageTemplates();
			Pages=createPages();
			PagesSet=createPageSettings();
		}
		
		list<String> vfpages =new list<String>{'DE_Home', 
								'DE_Imprint', 
								'DE_Kontaktformular', 
								'DE_Login', 
								'DE_Register', 
								'DE_Rueckrufservice', 
								'DE_Userdata', 
								'DE_Werbemittel', 
								'DEPrivacy', 
								'DE_Training', 
								'CRD_Home', 
								'CRD_TwoColumnTemplate',
								'CRD_OneColumnTemplate', 
								'CRD_Imprint', 
								'CRD_Kontaktformular', 
								'CRD_Login', 
								'CRD_Marketing', 
								'CRD_NewsReader', 
								'CRD_Privacy', 
								'CRD_Register', 
								'CRD_Rueckrufservice', 
								'CRD_Training', 
								'CRD_Userdata', 
								'CRD_Werbemittel'};
		
       /* some custom labels */
       public list<CustomLabel__c> createCustomLabels() {
	       list<CustomLabel__c> clabels =new list<CustomLabel__c>();
	       for (Integer i=0;i<5;i++) {
	       	String ccode='clcode'+i;
	       	CustomLabel__c c=new CustomLabel__c(Name='clname'+i,Portal__c=portal,IsPro__c=isPro,Commoncode__c=ccode);
	       	c.ExternalUrl__c='http://www.parx.de';
	       	c.Label__c='clabel';
	       	c.LanguageCode__c='de';
	       	c.ImportId__c='test';
	       	clabels.add(c);
	       }
	       insert clabels;
	       return [SELECT Id, Name, Portal__c, IsPro__c, Commoncode__c, ExternalUrl__c, Label__c, LanguageCode__c FROM CustomLabel__c WHERE ImportId__c='test'];
       }
       
       public list<GlobalSettings__c> createGlobalSettings() { 
	       /* some global settings */
	       list<GlobalSettings__c> gsettings=new list<GlobalSettings__c>();
	       GlobalSettings__c gs=new GlobalSettings__c();
	       gs.Name=portal+'_'+'de';
	       gs.Autofreischaltung__c=true;
	       gs.CountryForRegistration__c='Deutschland';
	       gs.Datenschutzabfrage__c=true;
	       gs.Freischaltung_Owner_Id__c=UserInfo.getUserId();
	       gs.Gebietsschema__c='de';
	       gs.isPro__c=isPro;
	       gs.Landing_Page_Aktivierung__c=true;
	       gs.Located_in_PartnerFinder__c=true;
	       gs.Picturemanagement_available__c=true;
	       gs.Portal__c=portal;
	       gs.Profile_Id__c=UserInfo.getProfileId();
	       gs.showAbsolutlyGigasetLogo__c=true;
	       gs.ImportId__c='test';
	       gs.Sprache__c='de';
	       insert gs;
	       return [SELECT Id, Name, Autofreischaltung__c, 
	       					CountryForRegistration__c, 
	       					Datenschutzabfrage__c, 
	       					Freischaltung_Owner_Id__c, 
	       					Gebietsschema__c, 
	       					isPro__c, 
	       					Landing_Page_Aktivierung__c, 
	       					Located_in_PartnerFinder__c,
	       					Picturemanagement_available__c,
	       					Portal__c,
	       					Profile_Id__c,
	       					showAbsolutlyGigasetLogo__c,
	       					Sprache__c
	       					FROM GlobalSettings__c WHERE ImportId__c='test'];
       }
       
       public list<PageTemplate__c> createPageTemplates() {
	       /* some pagetemplates */
	       list<PageTemplate__c> pts =new list<PageTemplate__c>();
	       for (String vfpage: vfpages) {
	       	PageTemplate__c pt=new PageTemplate__c();
	       	pt.Name=vfpage;
	       	pt.VisualForce_Page_Name__c=vfpage;
	       	pt.ImportId__c='test';
	       	pts.add(pt);
	       }
	       insert pts;
	       return [SELECT Id, Name, VisualForce_Page_Name__c FROM PageTemplate__c WHERE ImportId__c='test'];
       }
       
       public list<Page__c> createPages() {
	       /* some pages */
	       list<Page__c> cmspages = new list<Page__c>();
	       for (PageTemplate__c pt: PageTemplates) {
	       	Page__c p=new Page__c();
	       	p.ImportId__c='test';
	       	p.Name=pt.Name;
	       	//p.PageTemplateVFPage__c=pt.Name;
	       	p.PageTemplate__c=pt.Id;
	       	cmspages.add(p);
	       }
	       insert cmspages;
	       return [Select p.PageTemplate__c, p.PageTemplateVFPage__c, p.Name, p.ImportId__c From Page__c p WHERE ImportId__c='test'];
       }
       
       public list<pages__c> createPageSettings() {
	       /* some settings for pages */
	       list<pages__c> pagessettings = new list<pages__c>();
	       for (Page__c p:Pages) {
	       	pages__c ps=new pages__c();
	       	ps.isPro__c=isPro;
	       	ps.Portal__c=portal;
	       	ps.PageId__c=p.id;
	       	ps.Name=p.Name+'p.id';
	       	ps.Label__c=p.Name;
	       	if (p.Name.contains('ontakt')) p.Name='Kontakt';
	       	if (p.Name.contains('serdata')) p.Name='Benutzerdaten';
	       	if (p.Name.contains('ogin')) p.Name='Login';
	       	if (p.Name.contains('ueckrufservice')) p.Name='Rueckrufservice';
	       	if (p.Name.contains('tPassword')) p.Name='PasswortVergessen';
	       	if (p.Name.contains('egist')) p.Name='Registrierung';
	       	if (p.Name.contains('Home')) p.Name='Home';
	       	if (p.Name.contains('Imprint')) p.Name='Imprint';
	       	if (p.Name.contains('rivacy')) p.Name='PrivacyProtection';
	       	if (p.Name.contains('Werbemittel')) p.Name='Werbemittel';
	       	ps.IsActive__c=true;
	       	pagessettings.add(ps);
	       }
	       return [Select p.isPro__c, p.Portal__c, p.PageId__c, p.Name, p.Label__c, p.IsActive__c, p.Id From pages__c p];
       }
       
	}	

    static testMethod void SystemSettingsTest() {
		initData testData = new initData(SystemSettings.portal, SystemSettings.isPro);
		test.startTest();
       System.assertNotEquals(SystemSettings.homepageid,null);
       test.setCurrentPageReference(SystemSettings.goHome());
       for (Integer i=0;i<testData.Pages.size();i++) {
       	SystemSettings.getCurrentNavigationPointLabel(testData.Pages.get(i).id);
       }
       SystemSettings.getCurrentUpdatedUser();
       SystemSettings.getExternalURL('clcode1');
       SystemSettings.getLabel('clcode0');
       SystemSettings.goHome();
       SystemSettings.init();
       SystemSettings.isPortalUser();
       SystemSettings.logError('123', '!23', '1233');
       SystemSettings.logError('1234', '23454', '234', '234', 'DEBUG');
       SystemSettings.redirectToLogin();
       SystemSettings.setLanguage();
       SystemSettings.showClearing();
       System.assert(SystemSettings.showPmLink());
       SystemSettings.showPreset();
       SystemSettings.showPrivacy();
       SystemSettings.showPrivacyAnonymous();
       test.stopTest();
    }
    
    static testMethod void SystemSettingsUserTest() {
    	User u;
    	String portal='de';
    	Boolean isPro=false;
    	try {
    		u=[SELECT Id, ContactId FROM User WHERE ContactId!=null AND IsPortalEnabled=true AND isActive=true limit 1];
    		if (u!=null && u.ContactId!=null) {
    			Contact c = [SELECT Id, Gigaset_Extranet__c, Gigaset_Pro__c, Portal__c FROM Contact WHERE Id=:u.contactId];
    			portal=c.Portal__c;
    			isPro=c.Gigaset_Pro__c;
    		}
    	} catch (System.QueryException e) {}
    	System.assertNotEquals(u, null);
    	if (u!=null) {
    		initData testData = new initData(portal, isPro);
    		System.runAs(u) {
    	
		
		test.startTest();
       System.assertNotEquals(SystemSettings.homepageid,null);
       test.setCurrentPageReference(SystemSettings.goHome());
       for (Integer i=0;i<testData.Pages.size();i++) {
       	SystemSettings.getCurrentNavigationPointLabel(testData.Pages.get(i).id);
       }
       SystemSettings.getCurrentUpdatedUser();
       SystemSettings.getExternalURL('clcode1');
       SystemSettings.getLabel('clcode0');
       SystemSettings.goHome();
       SystemSettings.init();
       SystemSettings.isPortalUser();
       SystemSettings.logError('123', '!23', '1233');
       SystemSettings.logError('1234', '23454', '234', '234', 'DEBUG');
       SystemSettings.redirectToLogin();
       SystemSettings.setLanguage();
       SystemSettings.showClearing();
       //System.assert(SystemSettings.showPmLink());
       SystemSettings.showPreset();
       SystemSettings.showPrivacy();
       SystemSettings.showPrivacyAnonymous();
       test.stopTest();
    		}
    	}
    }
}