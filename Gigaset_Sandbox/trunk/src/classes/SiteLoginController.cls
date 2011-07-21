/** 
 * An apex page controller that exposes the site login functionality 
 */
global class SiteLoginController {    
	global String username {get; set;}    
	global String password {get; set;}
	global String defaultlanguage { get; set; }
	global Boolean handleLoginErrorMessage { get; private set; }
	global String loginErrorSummary { get; private set; }
	global String loginErrorTitle { get; private set; }
	
	global PageReference login() {
		handleLoginErrorMessage=false;
		loginErrorSummary=Label.site.login_or_register_first + ' ' + Label.site.click_forget_password;
		loginErrorTitle='<span style="color: #C00; font-weight: bold;">' + Label.site.error2 + ':</span>';
		if (username==null || password==null || username=='' || password=='') {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.site.login_or_register_first);
			ApexPages.addMessage(msg);
			return null;
		}        
		//String startUrl = System.currentPageReference().getParameters().get('startURL');
		String startUrl = Page.page.getUrl()+'?pageid=' + System_Settings.homepageid;
		if (!System.currentPageReference().getParameters().isEmpty() && System.currentPageReference().getParameters().containsKey('pid')) {
			startUrl=Page.page.getUrl() + '?pageid=' + System.currentPageReference().getParameters().get('pid');
		}
		PageReference loginPageRef;

		loginPageRef=Site.login(username, password, startUrl);
		if (ApexPages.hasMessages()) {
			handleLoginErrorMessage=true;
			return null;
		}
		return loginPageRef;
	}         
	
	global SiteLoginController () {
		defaultlanguage=System_Settings.setLanguage();
		handleLoginErrorMessage=false;
		loginErrorSummary=Label.site.login_or_register_first + ' ' + Label.site.click_forget_password;
		loginErrorTitle='<span style="color: #C00; font-weight: bold">' + Label.site.error2 + ':</span>';
	}        
	
	
	global String getRegistrationPageId() {
		return System_Settings.registrationpageid;
	}
	
	global String getForgotPasswordPageId() {
		return System_Settings.forgotpasswordpageid;
	}
}