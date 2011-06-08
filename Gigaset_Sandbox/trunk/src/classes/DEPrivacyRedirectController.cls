public class DEPrivacyRedirectController {

	

	public DEPrivacyRedirectController () {
		
	}
	
	public PageReference redirect() {
		return new PageReference(Page.page.getUrl() + '?pageid=' + SystemSettings.privacyprotectionid);
	}
	
	static testmethod void DEPrivacyRedirectControllertest() {
	 	User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
	 	DEPrivacyRedirectController ctrl = new DEPrivacyRedirectController();
	 	ctrl.redirect();
	 	}
	 }
}