public class DEMetanaviController {

	pageReference CMSpage = Page.page;

	public DEMetanaviController() {
		CMSpage = Page.page;
	}
	
	public String getLoginUrl() {
		return CMSpage.getUrl() + '?pageid=' + SystemSettings.loginpageid;
	}
	
	public String getRueckrufserviceUrl() {
		return CMSpage.getUrl() + '?pageid=' + SystemSettings.rueckrufservicepageid;
	}
	
	public String getHomepageUrl() {
		return CMSpage.getUrl() + '?pageid=' + SystemSettings.homepageid;
	}
	
	private static testMethod void testDEMetanaviController() {
		DEMetanaviController ctrl = new DEMetanaviController();
		ctrl.getHomepageUrl();
		ctrl.getLoginUrl();
		ctrl.getRueckrufserviceUrl();
	}

}