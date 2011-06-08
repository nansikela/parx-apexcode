global class DE_LoginMenuComponentController {

	global DE_LoginMenuComponentController () {
		
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