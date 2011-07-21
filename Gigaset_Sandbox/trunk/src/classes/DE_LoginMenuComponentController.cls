global class DE_LoginMenuComponentController {

	public String portal { get; set; }
	public String homeurl { get; set; }

	global DE_LoginMenuComponentController () {
		portal=SystemSettings.portal;
		homeurl=SystemSettings.goHome().getUrl();
	}

	global String getForgotPasswordPageId() {
		return SystemSettings.forgotpasswordpageid;
	}
	
	global String getRegistrationPageId() {
		return SystemSettings.registrationpageid;
	}
	
	global static testMethod void testController() { 
		DE_LoginMenuComponentController ctrl=new DE_LoginMenuComponentController();
       	ctrl.getForgotPasswordPageId();
        	ctrl.getRegistrationPageId();
        
	}

}