/** 
 * An apex page controller that exposes the site login functionality 
 */
global class SiteLoginController {    
	global String username {get; set;}    
	global String password {get; set;}
	global String defaultlanguage { get; set; }
	
	global PageReference login() {
		defaultlanguage=System_Settings.setLanguage();
		if (username==null || password==null) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.site.login_or_register_first);
			ApexPages.addMessage(msg);
			return null;
		}        
		//String startUrl = System.currentPageReference().getParameters().get('startURL');
		String startUrl = Page.page.getUrl()+'?pageid=' + System_Settings.homepageid;
		if (!System.currentPageReference().getParameters().isEmpty() && System.currentPageReference().getParameters().containsKey('pid')) {
			startUrl=Page.page.getUrl() + '?pageid=' + System.currentPageReference().getParameters().get('pid');
		}
		return Site.login(username, password, startUrl);
	}         
	
	global SiteLoginController () {}        
	
	
	global String getRegistrationPageId() {
		return System_Settings.registrationpageid;
	}
	
	global String getForgotPasswordPageId() {
		return System_Settings.forgotpasswordpageid;
	}
}