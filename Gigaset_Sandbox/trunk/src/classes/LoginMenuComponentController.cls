global class LoginMenuComponentController {

	public Transient String portal { get; set; }
	
	public Transient String homeurl { get; set; }

	global LoginMenuComponentController () {
		portal=System_Settings.portal;
		homeurl=System_Settings.goHome().getUrl();
	}

	global String getForgotPasswordPageId() {
		return System_Settings.forgotpasswordpageid;
	}
	
	global String getRegistrationPageId() {
		return System_Settings.registrationpageid;
	}
	
	global static testMethod void testController() { 
		LoginMenuComponentController ctrl=new LoginMenuComponentController();
       	ctrl.getForgotPasswordPageId();
        ctrl.getRegistrationPageId();
	}

}