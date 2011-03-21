public class CRD_Landing_Controller {
	
	private GlobalSettings__c portal_config;
	
	public CRD_Landing_Controller(){
		portal_config = [SELECT Name, Landing_Page_Aktivierung__c, Portal__c, isPro__c FROM GlobalSettings__c WHERE Portal__c = :System_Settings.portal AND IsPro__c = :System_Settings.isPro];
	}
	
	public PageReference goToLogin(){
		PageReference href = null;
		
		if(!portal_config.Landing_Page_Aktivierung__c){
			String tag = portal_config.Name + '_%';
			Page__c p = [SELECT Id FROM Page__c WHERE Name LIKE :tag];
		
			href = new PageReference('/'+System_Settings.portal+'/page?pageid='+p.Id);
		}
		
		return href;
	}	
}