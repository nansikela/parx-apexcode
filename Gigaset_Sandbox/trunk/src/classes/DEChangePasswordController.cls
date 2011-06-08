/** * An apex page controller that exposes the change password functionality */
public class DEChangePasswordController {    
	public String oldPassword {get; set;}    
	public String newPassword {get; set;}    
	public String verifyNewPassword {get; set;}           
	public PageReference changePassword() {        
		return Site.changePassword(newPassword, verifyNewPassword, oldpassword);   
	}
	              
	public DEChangePasswordController() {}         
	
	public static testMethod void testDEChangePasswordController() {       
		// Instantiate a new controller with all parameters in the page        
		DEChangePasswordController controller = new DEChangePasswordController();        
		controller.oldPassword = '123456';        
		controller.newPassword = 'qwerty1';         
		controller.verifyNewPassword = 'qwerty1';                                
		System.assertEquals(controller.changePassword(),null);                               
	}    
}