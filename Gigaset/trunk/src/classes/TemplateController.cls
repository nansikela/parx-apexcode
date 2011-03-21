public class TemplateController extends PageControllerBase {

	public Boolean isAuthenticated { get; set; }
	
	public Boolean showTraining { get; set; }
	public Boolean isDone {get; set; }
	public Boolean isPro { get; set; }
    public String currentNavigationPoint { get; set; }
    public String homeurl { get; set; }
	pageReference CMSpage = Page.page;
	public String kontaktpageid { get; set; }
	public String registrationpageid { get; set; }
	public String label_menu_home { get; set; }
	public String defaultlanguage { get; set; }
	public Boolean showpresetcomp { get; set; }
	public Boolean showclearingcomp { get; set; }
	public Boolean showcontactportlet { get; set; }
	public Boolean showothercomp { get; set; }
	public Boolean showprivacy { get; set; }
	public String callback_imgurl { get; set; }
	public String styleSelector { get; set; }
	public String test {get;set;}
	
	public User u0{get;set;}
	public Contact c0 {get;set;}
	
	public Boolean trainingActivation {get;set;}
	// zu entsorgen, wird so nicht mehr benötigt
	// Controller for topnews component to get the current newsid
	public topnews topnewsController {set;
		get{
			//get the map, then the component controller using the appropriate key
			if(getComponentControllerMap()!=null){
				topnews mcc;
				mcc = (topnews )getComponentControllerMap().get('topnews');
				if(mcc!= null)
					return mcc;
			}
			//just in case something goes wrong return something...this can be handled better
			return new topnews();
		}
	}
	
	// Controller for newsreader component to set the current newsid
	public newsreader newsreaderController {set;
		get{
			//get the map, then the component controller using the appropriate key
			if(getComponentControllerMap()!=null){
				newsreader mcc;
				mcc = (newsreader )getComponentControllerMap().get('newsreader');
				if(mcc!= null)
					return mcc;
			}
			//just in case something goes wrong return something...this can be handled better
			return new newsreader();
		}
	}
	
	
	// constructor
	public TemplateController() {
		test=Label.loginpage;
		isPro=System_Settings.isPro;
		styleSelector=isPro?'pro':'normal';
		isDone = ApexPages.currentPage().getParameters().containsKey('isDone');
		callback_imgurl=System_Settings.getLabel('callback_imgurl');
		if (callback_imgurl=='') showcontactportlet=false;
		else showcontactportlet=true;
		showprivacy=System_Settings.showPrivacy();
		showpresetcomp=System_Settings.showPreset() & !showprivacy;
		showclearingcomp=System_Settings.showClearing() & !showprivacy;
		if (showclearingcomp) showpresetcomp=false;
		showothercomp=showpresetcomp || showclearingcomp || showprivacy;
		defaultlanguage=System_Settings.setLanguage();
		label_menu_home=System_Settings.getCurrentNavigationPointLabel(System_Settings.homepageid);
		kontaktpageid=System_Settings.kontaktpageid;
		isAuthenticated=System_Settings.isPortalUser();
		currentNavigationPoint='';
		if (ApexPages.currentPage().getParameters().containsKey('pageid')) {
			currentNavigationPoint=getCurrentNavigationPointLabel(ApexPages.currentPage().getParameters().get('pageid'));
			
			for (pages__c l:pages__c.getAll().values()) {
				if (l.Portal__c==System_Settings.portal && l.Label__c=='training_firstPage') {
					if(ApexPages.currentPage().getParameters().get('pageid') == l.PageId__c)
						showTraining = true;
					else
						showTraining = false;
				}
			}	
		}
		homeurl=System_Settings.goHome().getUrl();
			
		//System.debug('******* Zustand: showprivacy: ' + showprivacy + ' / showpresetcomp: '+ showpresetcomp + ' / showclearingcomp: ' +showclearingcomp + ' / showothercomp: ' + showothercomp + ' / shownexttopshop: ' + showNextTopShop + ' / isAuthenticated: ' + isAuthenticated + ' / isPro: ' + isPro +  ' / Portal: ' + System_Settings.portal + ' / UserId: ' + UserInfo.getUserId() );
	}
	 
	public String getCurrentNavigationPointLabel(String pageid) {
		String homepageid=System_Settings.homepageid;
		String link01pageid=System_Settings.link01pageid;
		String link02pageid=System_Settings.link02pageid;
		String link03pageid=System_Settings.link03pageid;
		String link04pageid=System_Settings.link04pageid;
		String link05pageid=System_Settings.link05pageid;
		String werbemittelpageid=System_Settings.werbemittelpageid;
		String imprintpageid=System_Settings.imprintpageid;
		kontaktpageid=System_Settings.kontaktpageid;
		registrationpageid=System_Settings.registrationpageid;
		String userdatapageid=System_Settings.userdatapageid;
		String loginpageid=System_Settings.loginpageid;
		String rueckrufservicepageid=System_Settings.rueckrufservicepageid;
		String forgotpasswordpageid=System_Settings.forgotpasswordpageid;
		// portal specific labels/navigationpoints
		if (pageid.startsWith(homepageid)|| (Site.getPrefix()!=null && Site.getPrefix().contains('Home'))) return System_Settings.getLabel('home');
		if (link01pageid!='' && pageid.startsWith(link01pageid)) return System_Settings.getLabel('link01');
		if (link02pageid!='' && pageid.startsWith(link02pageid)) return System_Settings.getLabel('link02');
		if (link03pageid!='' && pageid.startsWith(link03pageid)) return System_Settings.getLabel('link03');
		if (link04pageid!='' && pageid.startsWith(link04pageid)) return System_Settings.getLabel('link04');
		if (link05pageid!='' && pageid.startsWith(link05pageid)) return System_Settings.getLabel('link05');
		if (werbemittelpageid!='' && pageid.startsWith(werbemittelpageid)) return System_Settings.getLabel('Werbemittel');
		// cross portal navigation points
		if (imprintpageid!='' && pageid.startsWith(imprintpageid)) return System.Label.tplt_label_imprint;
		if (kontaktpageid!='' && pageid.startsWith(kontaktpageid)) return System.Label.contact;
		if (userdatapageid!='' && pageid.startsWith(userdatapageid)) return System.Label.userdata_your_userdata;
		if (loginpageid!='' && pageid.startsWith(loginpageid)) return System.Label.loginpage;
		if (registrationpageid!='' && pageid.startsWith(registrationpageid)) return System.Label.registration;
		if (rueckrufservicepageid!='' && pageid.startsWith(rueckrufservicepageid)) return System.Label.callback;
		if (forgotpasswordpageid!='' && pageid.startsWith(forgotpasswordpageid)) return System.Label.forgotpassword_forgot_password;
		if (System.currentPageReference().getUrl()!=null && System.currentPageReference().getUrl().contains('ChangePassword')) return System.Label.changepw_changepw;
		else return '';
	}

	// actions
	public PageReference init() {
	 	if (ApexPages.currentPage().getParameters().containsKey('pid')) System_Settings.addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
	 	if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin(); 
	 	return null;
	}
	
	public PageReference initHome(){
		return TrainingController.initHome();
	} 
	
	// getter
	public String getKontaktformularUrl() {
		return CMSpage.getUrl() + '?pageid=' + System_Settings.kontaktpageid;
	}
	
	public String getImprintUrl() {
		return CMSpage.getUrl() + '?pageid=' + System_Settings.imprintpageid;
	}
	
	public String getRueckrufserviceUrl() {
		if (System_Settings.rueckrufservicepageid!='')
			return CMSpage.getUrl() + '?pageid=' + System_Settings.rueckrufservicepageid;
		else
			return '';
	}
	
	public String getCopyright() {
		String copyright='';
		for (CustomLabel__c l:CustomLabel__c.getAll().values()) {
			if (l.Portal__c==System_Settings.portal && l.LanguageCode__c==defaultlanguage && l.CommonCode__c=='copyright') copyright=l.Label__c;
		}
		return copyright;
	}

	public String getModules_URLPage(){
		return TrainingController.Modules_URLPage;
	}
	
	public String getFirstName(){
		return TrainingController.firstName;
	}
	
	public String getLastName(){
		return TrainingController.lastName;
	}
	
	public String getSalutation(){
		return TrainingController.salutation;
	}
	
	public Boolean getShowNextTopShop(){
		return System_Settings.showNextTopShop;
	}
	 
	public Integer getModules_currentSuccess(){
		return TrainingController.Modules_currentSuccess;
	}
	
	public String getModules_Param(){
		return TrainingController.Modules_Param;
	}
	
	public Integer getModules_total(){
		return TrainingController.Modules_total;
	}
	
	public Integer getModules_currentpoint(){
		return TrainingController.Modules_currentpoint;
	}
	
	public Double getModules_currentbar(){
		return TrainingController.Modules_currentbar;
	}
	
	public Boolean getModules_showFirstpage(){
		return TrainingController.Modules_showFirstpage;
	}
	
	public Boolean getModules_showThirdpage(){
		return TrainingController.Modules_showThirdpage;
	}
	
	public String getModules_LektoraURL(){
		return TrainingController.Modules_LektoraURL;
	}
	
	public String getNewsid(){
		return TrainingController.newsid;
	}
	
	public Training_Book__c getModules_book(){
		return TrainingController.Modules_book;
	}
	
	public list<Training_Module__c> getModules_modulesSecondPage1(){
		return TrainingController.Modules_modulesSecondPage1;
	}
	
	public Training_Module__c getModules_SingleModule(){
		return TrainingController.Modules_SingleModule;
	}
	
	public list<TrainingController.Modulen> getModules(){
		return TrainingController.Modules;
	}
	
	public PageReference Poller(){
		return TrainingController.Poller();
	}
	
	public PageReference firstPage(){
		return TrainingController.firstPage();
	}
	
	public PageReference secondPage(){
		return TrainingController.secondPage();
	}
	
	public PageReference showModule(){
		return TrainingController.showModule();
	}
	
	public PageReference initModuleResult(){
		return TrainingController.initModuleResult();
	}
	
	public list<TrainingController.Modulen> getModules_modulesSecondPage2(){
		return TrainingController.Modules_modulesSecondPage2;
	}
	
	public list<TrainingController.Booken> getBooks(){
		return TrainingController.Books;
	}
	
	
	public NextTopShop__c getNTS(){
		return TrainingController.NTS;
	}
	
	public String getCampus_Title_1() {
		return TrainingController.getCampus_Title_1();
	}
	
	public String getCampus_Welcome() {
		return TrainingController.getCampus_Welcome();
	}
	
	public String getCampus_main_Description1() {
		return TrainingController.getCampus_main_Description1();
	}
	
	public String getCampus_main_Description2() {
		return TrainingController.getCampus_main_Description2();
	}
	
	public String getCampus_1_Title() {
		return TrainingController.getCampus_1_Title();
	}
	
	public String getCampus_2_Title() {
		return TrainingController.getCampus_2_Title();
	}
	
	public String getCampus_3_Title() {
		return TrainingController.getCampus_3_Title();
	}
	
	public String getCampus_4_Title() {
		return TrainingController.getCampus_4_Title();
	}
	
	public String getCampus_underTitle() {
		return TrainingController.getCampus_underTitle();
	}
	
	public String getCampus_smallBox1() {
		return TrainingController.getCampus_smallBox1();
	}
	
	public String getCampus_smallBox2() {
		return TrainingController.getCampus_smallBox2();
	}
	
	public String getCampus_smallBox3() {
		return TrainingController.getCampus_smallBox3();
	}
	
	public String getCampus_smallBox4() {
		return TrainingController.getCampus_smallBox4();
	}
	
	public String getCampus_otherPage1() {
		return TrainingController.getCampus_otherPage1();
	}
	
	public String getCampus_otherPage2() {
		return TrainingController.getCampus_otherPage2();
	}
	
	public String getCampus_otherPage3() {
		return TrainingController.getCampus_otherPage3();
	}
	
	public String getCampus_otherPage4() {
		return TrainingController.getCampus_otherPage4();
	}
	
	public String getCampus_otherPage5() {
		return TrainingController.getCampus_otherPage5();
	}
	
	public String getCampus_otherPage6() {
		return TrainingController.getCampus_otherPage6();
	} 
	
	public String getCampus_lastPage1() {
		return TrainingController.getCampus_lastPage1();
	}
	
	public String getCampus_lastPage2() {
		return TrainingController.getCampus_lastPage2();
	}
	
	public PageReference redirectToLogin(){
		return System_Settings.redirectDirectlyToLogin();
	}
}