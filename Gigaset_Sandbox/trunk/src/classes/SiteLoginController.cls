/** 
 * An apex page controller that exposes the site login functionality 
 */
global class SiteLoginController { 
       
    global String username {get; set;}    
    global String password {get; set;}
    global String defaultlanguage { get; set; }
    global Boolean handleLoginErrorMessage { get; private set; }
    global String loginErrorSummary { get; private set; }
    global String loginErrorTitle { get; private set; }
    global final PageReference pageRef;
    global final String homepageid {get; private set;} 
    global final String portal {get; private set;} //For security comparison
    global final Boolean isMobile {get; private set;}
    
    
    global PageReference login() {
		try {
			ApexPages.getMessages().clear();
	        handleLoginErrorMessage=false;
	        loginErrorSummary=Label.site.login_or_register_first + ' ' + Label.site.click_forget_password;
	        loginErrorTitle='<span style="color: #C00; font-weight: bold;">' + Label.site.error2 + ':</span>';
	        
	        if (username==null || password==null || username=='' || password=='') {
	        	system.debug('ERROR: Fields not entered!');
	            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.site.login_or_register_first);
	            ApexPages.addMessage(msg);
	            loginErrorSummary = Label.site.login_or_register_first;
	            handleLoginErrorMessage = true;
	            return null;
	        }
	        
	        system.debug('Login: isMobile: '+isMobile);
	        if (!isMobile && portal == 'mobi') {
	        	system.debug('ERROR: Unknown mobile device!');
	        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.campus_none_mobile_device);
	            ApexPages.addMessage(msg);
	        	loginErrorSummary = Label.campus_none_mobile_device;
	        	handleLoginErrorMessage = true;
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
	            system.debug('ERROR: OTHERS');
	            return null;
	        }
			
			if(portal == 'mobi') {
				User u = [Select Portal__c From User Where Username = :username]; 
			
				for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
					if (gs.Portal__c.toLowerCase()==u.Portal__c.toLowerCase() && !gs.isPro__c && homepageid == System_Settings.homemobileid) {
						if(!gs.Mobile_version_activated__c) {
							system.debug('ERROR: Portal deactivated!');
							loginErrorSummary = Label.campus_mobile_deactivated;
	        				handleLoginErrorMessage = true;
							return null;
						}
					}
				}
			}
			
	        return loginPageRef;
        } catch(Exception e) {
        	system.debug(e.getstackTraceString());
        }
        
        return null;
    }         
    
    global SiteLoginController () {
        pageRef = system.currentPageReference();
        isMobile = System_Settings.isMobile;
        portal = System_Settings.portal;
        
        if(isMobile)
        	homepageid = System_Settings.homemobileid;
        else
        	homepageid = System_Settings.homepageid;
        defaultlanguage=System_Settings.setLanguage();
        handleLoginErrorMessage=false;
        loginErrorSummary=Label.site.login_or_register_first + ' ' + Label.site.click_forget_password;
        loginErrorTitle='<span style="color: #C00; font-weight: bold">' + Label.site.error2 + ':</span>';
    	system.debug(pageRef);
    	system.debug(homepageid);
    }
    
    
    global String getRegistrationPageId() {
        return System_Settings.registrationpageid;
    }
    
    global String getForgotPasswordPageId() {
        return System_Settings.forgotpasswordpageid;
    }
}