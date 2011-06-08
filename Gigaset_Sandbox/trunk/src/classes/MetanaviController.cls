public class MetanaviController {

	pageReference CMSpage = Page.page;

	public MetanaviController() {
		CMSpage = Page.page;
	}
	
	public String getLoginUrl() {
		return CMSpage.getUrl() + '?pageid=' + System_Settings.loginpageid;
	}
	
	public String getRueckrufserviceUrl() {
		return CMSpage.getUrl() + '?pageid=' + System_Settings.rueckrufservicepageid;
	}
	
	public String getHomepageUrl() {
		return CMSpage.getUrl() + '?pageid=' + System_Settings.homepageid;
	}
	
	private static testMethod void testMetanaviController() {
		MetanaviController ctrl = new MetanaviController();
		ctrl.getHomepageUrl();
		ctrl.getLoginUrl();
		ctrl.getRueckrufserviceUrl();
	}

}