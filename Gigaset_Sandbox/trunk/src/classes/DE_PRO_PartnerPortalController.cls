public class DE_PRO_PartnerPortalController {

	public Boolean isAuthenticated { get; set; }
	public Boolean isPro { get; set; }
	public String defaultlanguage { get; set; }
	public String styleSelector { get; set; }
	
	public String homeurl { get; set; }
	pageReference CMSpage = Page.page;
	
	public DE_PRO_PartnerPortalController() {
		isPro=true;
		isAuthenticated=false;
		homeurl=SystemSettings.goHome().getUrl();
		styleSelector='pro';
		defaultlanguage='de';
	}
	
	

}