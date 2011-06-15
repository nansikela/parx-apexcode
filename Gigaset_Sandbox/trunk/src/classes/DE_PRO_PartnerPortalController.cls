public class DE_PRO_PartnerPortalController {

	public Boolean isAuthenticated { get; set; }
	public Boolean isPro { get; set; }
	public String defaultlanguage { get; set; }
	public String styleSelector { get; set; }
	public String portal { get; set; }
	
	public String homeurl { get; set; }
	pageReference CMSpage = Page.page;
	
	public DE_PRO_PartnerPortalController() {
		isPro=true;
		isAuthenticated=false;
		portal='de';
        if (Apexpages.currentPage().getParameters().containsKey('portal')) portal=Apexpages.currentPage().getParameters().get('portal');
		homeurl=Apexpages.currentPage().getUrl();
		styleSelector='pro';
		defaultlanguage=[select LanguageLocaleKey from User where Id =: UserInfo.getUserId()].LanguageLocaleKey;
		for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
			if (gs!=null && gs.Portal__c==portal && gs.isPro__c==isPro && gs.Sprache__c!=null) defaultlanguage=gs.Sprache__c;
		}
	}
	
	

}