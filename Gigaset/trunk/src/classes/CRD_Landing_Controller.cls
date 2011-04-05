public class CRD_Landing_Controller {
	
	//private GlobalSettings__c portal_config;
	
	public CRD_Landing_Controller(){
		/*
		List<GlobalSettings__c> settings = [SELECT Name, Landing_Page_Aktivierung__c, Portal__c, isPro__c FROM GlobalSettings__c WHERE Portal__c = :System_Settings.portal AND IsPro__c = :System_Settings.isPro limit 1];
		if(settings.size() > 0)
			portal_config = settings.get(0);
			*/
	}
	
	public CRD_Landing_Controller(TemplateController ctrl){
		this();
		System_Settings.cookie = new Cookie('guest','2',null,100000000,false);
      	ApexPages.currentPage().setCookies(new Cookie[]{System_Settings.cookie});
	}
	
	public PageReference goToLogin(){
		// TODO die Landingpage respektiert zur Zeit nicht die Deeplink Technik
		return System_Settings.redirectToLogin();
	}	
}