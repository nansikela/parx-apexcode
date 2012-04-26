public class MobileLoginController {

	public String username {get; set;}    
    public String password {get; set;}
    public String defaultlanguage { get; set; }
    public Boolean handleLoginErrorMessage { get; private set; }
    public String loginErrorSummary { get; private set; }
    public String loginErrorTitle { get; private set; }
    public PageReference pageRef;
    public String homepageid;
    
    public PageReference login() {

        handleLoginErrorMessage=false;
        loginErrorSummary=Label.site.login_or_register_first + ' ' + Label.site.click_forget_password;
        loginErrorTitle='<span style="color: #C00; font-weight: bold;">' + Label.site.error2 + ':</span>';
        
        if (username==null || password==null || username=='' || password=='') {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.site.login_or_register_first);
            ApexPages.addMessage(msg);
            return null;
        }     
           
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        String startUrl = Page.page.getUrl()+'?pageid=' + homepageid;
        
        // TODO has to be activated before go live of mobile and to be tested
        if (!pageRef.getParameters().isEmpty() && pageRef.getParameters().containsKey('pid')) {
            startUrl=Page.page.getUrl() + '?pageid=' + pageRef.getParameters().get('pid');
        }
        
        PageReference loginPageRef=Site.login(username, password, startUrl);

        if (ApexPages.hasMessages()) {
            handleLoginErrorMessage=true;
            return null;
        }
		
        return loginPageRef;
    }         
    
    public MobileLoginController () {
        pageRef = system.currentPageReference();
        homepageid = System_Settings.homepageid;
        defaultlanguage=System_Settings.setLanguage();
        handleLoginErrorMessage=false;
        loginErrorSummary=Label.site.login_or_register_first + ' ' + Label.site.click_forget_password;
        loginErrorTitle='<span style="color: #C00; font-weight: bold">' + Label.site.error2 + ':</span>';
    	system.debug(pageRef);
    	system.debug(homepageid);
    }        
}