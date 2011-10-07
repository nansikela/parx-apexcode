global class FALoginController 
{
	global String username {get; set;}
    global String password {get; set;}
    
    
    global FALoginController () {}
    
    
    global PageReference login() {
        String startUrl = '/startseite';
        
        PageReference returnURL = Site.login(username, password, startUrl);
        
        return returnURL;
    }
    
    
    
    global static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        FALoginController controller = new FALoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
        controller.login();   
        //System.assertEquals(controller.login(),null);                           
    }
}