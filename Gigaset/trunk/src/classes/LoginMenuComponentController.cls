global class LoginMenuComponentController {

	global LoginMenuComponentController () {
		
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