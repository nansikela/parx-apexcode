global class CRD_Landing_Controller {
	
	public CRD_Landing_Controller(){

	}
	
	public CRD_Landing_Controller(TemplateController ctrl){
		this();
	}

	public static void init() {
		System_Settings.cookie = ApexPages.currentPage().getCookies().get('guest');
		
		if(System_Settings.cookie == null){
			System_Settings.cookie = new Cookie('guest','1',null,100000000,false);
      		ApexPages.currentPage().setCookies(new Cookie[]{System_Settings.cookie, new Cookie('lastURL',Apexpages.currentPage().getUrl(),null,10000000,false)});
		}
	}	
	
	public static void landingpage_already_visited() {
		System_Settings.cookie = new Cookie('guest','2',null,100000000,false);
     	ApexPages.currentPage().setCookies(new Cookie[]{System_Settings.cookie, new Cookie('lastURL',Apexpages.currentPage().getUrl(),null,10000000,false)});
	}
	
	public PageReference goToLogin(){
		// TODO die Landingpage respektiert zur Zeit nicht die Deeplink Technik
		return System_Settings.redirectToLogin();
	}
}