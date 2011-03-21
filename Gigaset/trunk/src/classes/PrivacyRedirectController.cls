public class PrivacyRedirectController {

	

	public PrivacyRedirectController () {
		
	}
	
	public PageReference redirect() {
		return new PageReference(Page.page.getUrl() + '?pageid=' + System_Settings.privacyprotectionid);
	}
	
	static testmethod void PrivacyRedirectControllertest() {
	 	User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
	 	PrivacyRedirectController ctrl = new PrivacyRedirectController();
	 	ctrl.redirect();
	 	}
	 }
}