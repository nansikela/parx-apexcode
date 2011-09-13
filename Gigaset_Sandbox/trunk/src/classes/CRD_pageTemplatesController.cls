public class CRD_pageTemplatesController {


	public Boolean isAuthenticated { get; private set; }
	public Transient String defaultlanguage { get; private set; }
	public Transient Boolean showpresetcomp { get; private set; }
	public Transient Boolean showclearingcomp { get; private set; }
	public Transient Boolean showcontactportlet { get; private set; }
	public Transient Boolean showothercomp { get; private set; }
	public Transient Boolean showprivacy { get; private set; }
	public Transient Boolean showTraining { get; private set; }

	public CRD_pageTemplatesController() {
		defaultlanguage=System_Settings.setLanguage();
		showprivacy=System_Settings.showPrivacy();
		showpresetcomp=System_Settings.showPreset() & !showprivacy;
		showclearingcomp=System_Settings.showClearing() & !showprivacy;
		if (showclearingcomp) showpresetcomp=false;
		showothercomp=showpresetcomp || showclearingcomp || showprivacy;
		isAuthenticated=System_Settings.isPortalUser();
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
	
	public PageReference initHome(){ 
		if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	if (!ApexPages.currentPage().getParameters().containsKey('pageid')) return System_Settings.goHome();
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