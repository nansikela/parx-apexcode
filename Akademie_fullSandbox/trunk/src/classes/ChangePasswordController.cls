/**
* @author Christian Deckert
* @date 18/08/2011
* @description An apex page controller that exposes the change password functionality
*/

public class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    /**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Change password and return to new Page Reference
	* @return pageReference after password change
	*/
    public PageReference changePassword() {
        PageReference p = Site.changePassword(newPassword, verifyNewPassword, oldpassword);  
        if(p != null)
        {
        	return new PageReference('/startseite');
        }
        return p;  
    }     
    
    /**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Constructor
	*/
   	public ChangePasswordController() {}
    
    /**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Test change password
	*/
   	public static testMethod void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}