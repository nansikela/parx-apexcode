/** 
 * An apex page controller that exposes the site login functionality 
 */
global class DESiteLoginController {    
	global String username {get; set;}    
	global String password {get; set;}
	global String defaultlanguage { get; set; }
	
	global PageReference login() {
		defaultlanguage=SystemSettings.setLanguage();
		if (username==null || password==null) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.site.login_or_register_first);
			ApexPages.addMessage(msg);
			return null;
		}        
		//String startUrl = System.currentPageReference().getParameters().get('startURL');
		String startUrl = Page.page.getUrl()+'?pageid=' + SystemSettings.homepageid;
		if (!System.currentPageReference().getParameters().isEmpty() && System.currentPageReference().getParameters().containsKey('pid')) {
			startUrl=Page.page.getUrl() + '?pageid=' + System.currentPageReference().getParameters().get('pid');
		}
		return Site.login(username, password, startUrl);
	}         
	
	global DESiteLoginController () {}        
	
	
	global String getRegistrationPageId() {
		return SystemSettings.registrationpageid;
	}
	
	global String getForgotPasswordPageId() {
		return SystemSettings.forgotpasswordpageid;
	}
}