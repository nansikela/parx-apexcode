/** * An apex page controller that exposes the site forgot password functionality */
public class ForgotPasswordController {    
	public String username {get; set;}    
	public Boolean success { get; set;}
	public String defaultlanguage { get; set; }
	private final String homepageid;
	      
	public ForgotPasswordController() {
		defaultlanguage=System_Settings.setLanguage();
		success=false;
		homepageid = System_Settings.homepageid;
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
  		return new PageReference(Page.page.getUrl() + '?pageid=' + homepageid);//System_Settings.goHome();
  	}         
	
	public static testMethod void testForgotPasswordController() {      
		// Instantiate a new controller with all parameters in the page      
		ForgotPasswordController controller = new ForgotPasswordController();      
		controller.username = 'test@salesforce.com';
		controller.goHome();                  
		System.assertEquals(controller.forgotPassword(),null);     
		}
	}