public class CRD_pageTemplatesController {

	public Boolean isPro { get; private set; }
	public Boolean isAuthenticated { get; private set; }
	public  String defaultlanguage { get; private set; }
	public  Boolean showpresetcomp { get; private set; }
	public  Boolean showclearingcomp { get; private set; }
	public  Boolean showcontactportlet { get; private set; }
	public  Boolean showothercomp { get; private set; }
	public Boolean showprivacy { get; private set; }
	public Transient Boolean showTraining { get; private set; }
	
	public CRD_pageTemplatesController() {
		
		isAuthenticated=System_Settings.isPortalUser();
		System_Settings.cookie = ApexPages.currentPage().getCookies().get('guest');
		
		if(System_Settings.cookie == null){
			System_Settings.cookie = new Cookie('guest','1',null,100000000,false);
      		ApexPages.currentPage().setCookies(new Cookie[]{System_Settings.cookie, new Cookie('lastURL',Apexpages.currentPage().getUrl(),null,10000000,false)});
		} 
		isPro = System_settings.isPro;
		defaultlanguage=System_Settings.setLanguage();
		showprivacy=System_Settings.showPrivacy();
		showpresetcomp=System_Settings.showPreset() & !showprivacy;
		showclearingcomp=System_Settings.showClearing() & !showprivacy;
		if (showclearingcomp) showpresetcomp=false;
		showothercomp=showpresetcomp || showclearingcomp || showprivacy;
		
		if (ApexPages.currentPage().getParameters().containsKey('pageid')) {
			for (pages__c l:pages__c.getAll().values()) {
				if (l.Portal__c==System_Settings.portal && l.Label__c=='training_firstPage') {
					if(ApexPages.currentPage().getParameters().get('pageid') == l.PageId__c)
						showTraining = true;
					else
						showTraining = false;
				}
			}	
		}
	}
	
	public Boolean getGewinnSpiel(){
        User u = [select Contact.Keine_Teilnahme_Campus_Incentiv__c from User where Id=:UserInfo.getUserId()];
        if(u.Contact.Keine_Teilnahme_Campus_Incentiv__c) //user already clicked on "ich möchte nicht teilnehmen"
            return false;
        
        map<String, Cookie> Cookies = ApexPages.currentPage().getCookies();
        if(Cookies.containsKey('HideGewinnSpiel')) //user clicked during the current session on "jetzt nicht teilnehmen"
            return false;
            
        try {
            Campaign camp = [select id from Campaign where Portal__c =: System_Settings.portal and isActive = true and StartDate <=: system.today() and EndDate >=: system.today() limit 1];
        }
        catch(exception e) {
            return false;
        }
        
        return true;
    } 
	
	public PageReference initHome(){ 
	//	return new PageReference('http://www.google.de');
		if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	if (!ApexPages.currentPage().getParameters().containsKey('pageid') || 
	 		(ApexPages.currentPage().getParameters().containsKey('pageid') &&
	 		ApexPages.currentPage().getParameters().get('pageid')=='null'
	 		)
	 		) return System_Settings.goHome();
	 	return null; 
	}
	
	public PageReference init() {
		if (defaultlanguage=='' || defaultlanguage==null) defaultlanguage=System_Settings.setLanguage();
		CRD_Landing_Controller.init();
	 	if (ApexPages.currentPage().getParameters().containsKey('pid')) System_Settings.addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
	 	if (ApexPages.currentPage().getParameters().containsKey('newsid')) System_Settings.addParam=System_Settings.addParam+'&newsid='+ApexPages.currentPage().getParameters().get('newsid');
	 	if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	return null;
	} 
	
	public Boolean getshowNextTopShop() {
		// return System_Settings.showNextTopShop;
		return false;
	}
	
	public Boolean getisDone() {
		return ApexPages.currentPage().getParameters().containsKey('isDone');
	}
	

}