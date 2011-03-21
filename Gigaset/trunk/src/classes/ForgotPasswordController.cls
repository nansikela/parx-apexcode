/** * An apex page controller that exposes the site forgot password functionality */
public class ForgotPasswordController {    
	public String username {get; set;}    
	public Boolean success { get; set;}
	public String defaultlanguage { get; set; }
	          
	public ForgotPasswordController() {
		defaultlanguage=SystemSettings.setLanguage();
		success=false;
	}
	
		
	public PageReference forgotPassword() { 
		if (username==null || username=='') {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.site.enter_password);
			ApexPages.addMessage(msg);
		} else {
			success = Site.forgotPassword(username);
		}
		return null;    
	}
	
	public PageReference goHome() {
  		return SystemSettings.goHome();
  	}         
	
	public static testMethod void testForgotPasswordController() {      
		// Instantiate a new controller with all parameters in the page      
		ForgotPasswordController controller = new ForgotPasswordController();      
		controller.username = 'test@salesforce.com';
		controller.goHome();                  
		System.assertEquals(controller.forgotPassword(),null);     
		}
	}