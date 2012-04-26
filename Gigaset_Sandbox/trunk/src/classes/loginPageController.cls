public class loginPageController {
	
	public String defaultlanguage { get; private set; }

	public loginPageController() {
		defaultlanguage=System_Settings.setLanguage();
		system.debug(defaultlanguage);
	}
	
	public pageReference init() {
		system.debug('loginPageController isMobile: '+System_Settings.isMobile);
		if (defaultlanguage=='' || defaultlanguage==null) defaultlanguage=System_Settings.setLanguage();
	 	CRD_Landing_Controller.init();
	 	if (ApexPages.currentPage().getParameters().containsKey('pid')) System_Settings.addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
	 	if (ApexPages.currentPage().getParameters().containsKey('newsid')) System_Settings.addParam=System_Settings.addParam+'&newsid='+ApexPages.currentPage().getParameters().get('newsid');
	 	if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	return null;
	}
	
	
	public PageReference redirectToLogin(){
		return System_Settings.redirectDirectlyToLogin();
	}
	
	public String getLoginpageid() {
		return System_Settings.loginpageid;
	}
	
	public String getRegistrationID() {
		return System_Settings.registrationpageid;
	}
}