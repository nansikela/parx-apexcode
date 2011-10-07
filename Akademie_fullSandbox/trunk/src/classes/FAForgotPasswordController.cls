/**
* @author Christian Deckert
* @date 18/08/2011
* @description An apex page controller that exposes the site forgot password functionality
*/
public class FAForgotPasswordController {
	
    public String username {get; set;}   
    /**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Construktor ohne Inhalt
	*/
    public FAForgotPasswordController() {}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Passwort zurücksetzen funktion
	* @return bei erfolg wird auf die nächste Seite gegangen
	*/
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		
  		
  		if (success) {  			
  			return new PageReference('/FAForgotPassword?mode=send');
  		}
  		return null;
  	}
  	
  	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Test
	*/
  	 public static testMethod void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	FAForgotPasswordController controller = new FAForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}