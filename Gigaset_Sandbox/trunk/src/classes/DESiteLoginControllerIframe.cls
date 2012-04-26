/** 
 * An apex page controller that exposes the site login functionality 
 */
global class DESiteLoginControllerIframe{    
 
  global String username {get; set;}    
  global String password {get; set;}
  global String defaultlanguage { get; set; }
  global Boolean handleLoginErrorMessage { get; private set; }
  global String loginErrorSummary { get; private set; }
  global String loginErrorTitle { get; private set; }
  
  global PageReference login() {
    handleLoginErrorMessage=false;
    if (username==null || password==null || username=='' || password=='') {
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.site.login_or_register_first);
      ApexPages.addMessage(msg);
      return null;
    }        
    //String startUrl = System.currentPageReference().getParameters().get('startURL');
   /* String startUrl = Page.page.getUrl()+'?pageid=' + SystemSettings.homepageid;
    if (!System.currentPageReference().getParameters().isEmpty() && System.currentPageReference().getParameters().containsKey('pid')) {
      startUrl=Page.page.getUrl() + '?pageid=' + System.currentPageReference().getParameters().get('pid');
    }*/
    String startUrl = '/answer';
    
    PageReference loginPageRef;

    loginPageRef=Site.login(username, password, startUrl);
    if (ApexPages.hasMessages()) {
      handleLoginErrorMessage=true;
    }
    return loginPageRef;
  }         
  
  global DESiteLoginControllerIframe () {
    handleLoginErrorMessage=false;
    loginErrorSummary=Label.site.login_or_register_first + ' ' + Label.site.click_forget_password;
    loginErrorTitle='<span style="color: #C00;">' + Label.site.error2 + ':</span>';
    defaultlanguage=SystemSettings.setLanguage();
  }        
  
  
  global String getRegistrationPageId() {
    return SystemSettings.registrationpageid;
  }
  
  global String getForgotPasswordPageId() {
    return SystemSettings.forgotpasswordpageid;
  }
}