public class TemplateController {

	public Boolean isAuthenticated { get; set; }
	
	public Boolean showTraining { get; set; }
	public Boolean isDone {get; set; }
	public  Boolean isPro { get; private set; }
	public  String portal { get; private set; }
    public String currentNavigationPoint;
    public  String homeurl { get; set; }
	pageReference CMSpage = Page.page;
	public  Id kontaktpageid { get; private set; }
	public  Id registrationpageid { get; private set; }
	public  Id userdatapageid { get; private set; }
	public Id trainingpageid { get; private set; }
	public  String label_menu_home { get; set; }
	public  String defaultlanguage { get; set; }
	public  Boolean showpresetcomp { get; set; }
	public  Boolean showclearingcomp { get; set; }
	public  Boolean showcontactportlet { get; set; }
	public  Boolean showothercomp { get; set; }
	public  Boolean showprivacy { get; set; }
	public  String callback_imgurl { get; set; }
	public  String styleSelector { get; set; }
	public String test {get;set;}
	public  String loginBackgroundImageId { get; private set; }
	
	public User u0{get;set;}
	public Contact c0 {get;set;}
	
	public Boolean trainingActivation {get;set;}
	public CustomLabel__c menuImpressum {get;set;}
	
	// constructor
	public TemplateController() {
		
		defaultlanguage=System_Settings.setLanguage();
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
		System_Settings.cookie = ApexPages.currentPage().getCookies().get('guest');
		
		if(System_Settings.cookie == null){
			System_Settings.cookie = new Cookie('guest','1',null,100000000,false);
      		ApexPages.currentPage().setCookies(new Cookie[]{System_Settings.cookie, new Cookie('lastURL',Apexpages.currentPage().getUrl(),null,10000000,false)});
		}
		//test=Label.loginpage;
		//isPro=System_Settings.isPro;
		isPro=false;
		portal=System_Settings.portal;
		//styleSelector=isPro?'pro':'normal';
		styleSelector='normal';
		isDone = ApexPages.currentPage().getParameters().containsKey('isDone');
		callback_imgurl=System_Settings.getLabel('callback_imgurl');
		if (callback_imgurl=='') showcontactportlet=false;
		else showcontactportlet=true;
		showprivacy=System_Settings.showPrivacy();
		showpresetcomp=System_Settings.showPreset() & !showprivacy;
		showclearingcomp=System_Settings.showClearing() & !showprivacy;
		if (showclearingcomp) showpresetcomp=false;
		showothercomp=showpresetcomp || showclearingcomp || showprivacy;
		label_menu_home=System_Settings.getCurrentNavigationPointLabel(System_Settings.homepageid);
		loginBackgroundImageId=System_Settings.getLabel('loginBackgroundImageId');
		kontaktpageid=System_Settings.kontaktpageid;
		userdatapageid=System_Settings.userdatapageid;
		trainingpageid=System_Settings.TrainingId;
		isAuthenticated=System_Settings.isPortalUser();
		
		try {
			system.debug('PRO: '+isPro+' / Portal: '+portal+' / LanguageCode: '+System_Settings.setLanguage());
          menuImpressum = [SELECT Label__c, ExternalUrl__c FROM CustomLabel__c WHERE isPro__c = :isPro AND Portal__c = :portal AND LanguageCode__c = :System_Settings.setLanguage() AND CommonCode__c = 'extranet_topNavi_Impressum' ];
        }
        catch(exception e) {
        	system.debug(e.getStackTraceString());
        }
		if (ApexPages.currentPage().getParameters().containsKey('pageid')) {
			for (pages__c l:pages__c.getAll().values()) {
				if (l.Portal__c==portal && l.Label__c=='training_firstPage') {
					if(ApexPages.currentPage().getParameters().get('pageid') == l.PageId__c)
						showTraining = true;
					else
						showTraining = false;
				}
			}
		}	
		
		homeurl=System_Settings.goHome().getUrl();
		u0=System_Settings.currentuser;
		c0=System_Settings.currentusercontact;
		//System.debug('******* Zustand: showprivacy: ' + showprivacy + ' / showpresetcomp: '+ showpresetcomp + ' / showclearingcomp: ' +showclearingcomp + ' / showothercomp: ' + showothercomp + ' / shownexttopshop: ' + showNextTopShop + ' / isAuthenticated: ' + isAuthenticated + ' / isPro: ' + isPro +  ' / Portal: ' + System_Settings.portal + ' / UserId: ' + UserInfo.getUserId() );
	}
	
	public String getBaseTopNaviUrl() {
       /* if(isPro)
            return System_Settings.baseurl+'pro/'+portal.substring(0,2)+'/'+String.valueOf(System_Settings.setLanguage()).substring(0,2)+'/';
        else*/
            return System_Settings.baseurl+portal.substring(0,2)+'/'+String.valueOf(System_Settings.setLanguage()).substring(0,2)+'/';
    }
    
	public String getcurrentNavigationPoint() {
		//if (currentNavigationPoint==null) {
			currentNavigationPoint='';
			if (ApexPages.currentPage()!=null && ApexPages.currentPage().getParameters()!=null && !ApexPages.currentPage().getParameters().isEmpty() && ApexPages.currentPage().getParameters().containsKey('pageid')) {
				currentNavigationPoint=getCurrentNavigationPointLabel(ApexPages.currentPage().getParameters().get('pageid'));
			}
		//}
		return currentNavigationPoint;
	}
	 
	public String getCurrentNavigationPointLabel(String pid) {
		Id pageid;
		if (defaultlanguage=='' || defaultlanguage==null) defaultlanguage=System_Settings.setLanguage();
		if (pid!=null) {
			try {
				pageid=Id.valueOf(pid);
			} catch (System.Exception e) {}
		}
		if (pageid!=null) {
			Id landingpageid=System_Settings.landing_page; 
			Id homepageid=System_Settings.homepageid;
			Id link01pageid=System_Settings.link01pageid;
			Id link02pageid=System_Settings.link02pageid;
			Id link03pageid=System_Settings.link03pageid;
			Id link04pageid=System_Settings.link04pageid;
			Id link05pageid=System_Settings.link05pageid;
			Id link06pageid=System_Settings.link06pageid;
			Id newsreaderpageid=System_Settings.newsreaderpageid;
			//String werbemittelpageid=System_Settings.werbemittelpageid;
			Id imprintpageid=System_Settings.imprintpageid;
			Id kontaktpageid=kontaktpageid;
			Id registrationpageid=System_Settings.registrationpageid;
			Id userdatapageid=System_Settings.userdatapageid;
			Id loginpageid=System_Settings.loginpageid;
			Id rueckrufservicepageid=System_Settings.rueckrufservicepageid;
			Id forgotpasswordpageid=System_Settings.forgotpasswordpageid;
			// portal specific labels/navigationpoints
			if(landingpageid!=null && pageid==landingpageid) return System.Label.loginpage;//System_Settings.getLabel('Landing');
			if (pageid==homepageid || (Site.getPrefix()!=null && Site.getPrefix().contains('Home'))) return System_Settings.getLabel('home');
			if (link01pageid!=null && pageid==link01pageid) return System_Settings.getLabel('link01');
			if (link02pageid!=null && pageid==link02pageid) return System_Settings.getLabel('link02');
			if (link03pageid!=null && pageid==link03pageid) return System_Settings.getLabel('link03');
			if (link04pageid!=null && pageid==link04pageid) return System_Settings.getLabel('link04');
			if (link05pageid!=null && pageid==link05pageid) return System_Settings.getLabel('link05');
			if (link06pageid!=null && pageid==link06pageid) return System_Settings.getLabel('link06');
			//if (werbemittelpageid!='' && pageid.startsWith(werbemittelpageid)) return System_Settings.getLabel('Werbemittel');
			if (newsreaderpageid!=null && pageid==newsreaderpageid) return System_Settings.getLabel('NewsReader');
			// cross portal navigation points
			if (imprintpageid!=null && pageid==imprintpageid) return System.Label.tplt_label_imprint;
			if (kontaktpageid!=null && pageid==kontaktpageid) return System.Label.contact;
			if (userdatapageid!=null && pageid==userdatapageid) return System.Label.userdata_your_userdata;
			if (loginpageid!=null && pageid==loginpageid) return System.Label.loginpage;
			if (registrationpageid!=null && pageid==registrationpageid) return System.Label.registration;
			if (rueckrufservicepageid!=null && pageid==rueckrufservicepageid) return System.Label.callback;
			if (forgotpasswordpageid!=null && pageid==forgotpasswordpageid) return System.Label.forgotpassword_forgot_password;
			if (System.currentPageReference().getUrl()!=null && System.currentPageReference().getUrl().contains('ChangePassword')) return System.Label.changepw_changepw;
			else return '';
		} else return '';
	}

	// actions
	public PageReference init() {
		system.debug(System_Settings.isMobile);
		if (defaultlanguage=='' || defaultlanguage==null) defaultlanguage=System_Settings.setLanguage();
		CRD_Landing_Controller.init();
	 	if (ApexPages.currentPage().getParameters().containsKey('pid')) System_Settings.addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
	 	if (ApexPages.currentPage().getParameters().containsKey('newsid')) System_Settings.addParam=System_Settings.addParam+'&newsid='+ApexPages.currentPage().getParameters().get('newsid');
	 	if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	return null;
	}
	
	public PageReference initSiteTemplate() {
		PageReference basispage=Page.page;
		PageReference homepage=new PageReference( basispage.getUrl() + '?pageid=' + System_Settings.homepageid);
		homepage.setRedirect(true);
		if (System_Settings.isPortalUser() && !Site.isPasswordExpired() && portal!=System_Settings.getPortalByPageId()) return homepage;
		else return null;
	}
	
	public PageReference initHome(){ 
		//TrainingController.initHome(); 
		if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	if (!ApexPages.currentPage().getParameters().containsKey('pageid')) return System_Settings.goHome();
	 	return null; 
	} 
	
	public Id getRegistrationID(){
		// TODO die Landingpage respektiert zur Zeit nicht die Deeplink Technik
		return System_Settings.registrationpageid;
	}	
	
	// getter
	public String getKontaktformularUrl() {
		return CMSpage.getUrl() + '?pageid=' + kontaktpageid;
	}
	
	public String getImprintUrl() {
		return CMSpage.getUrl() + '?pageid=' + System_Settings.imprintpageid;
	}
	
	public String getRueckrufserviceUrl() {
		if (System_Settings.rueckrufservicepageid!=null)
			return CMSpage.getUrl() + '?pageid=' + System_Settings.rueckrufservicepageid;
		else
			return '';
	}
	
	public String getCopyright() {
		String copyright='';
		for (CustomLabel__c l:CustomLabel__c.getAll().values()) {
			if (l.Portal__c==portal && l.LanguageCode__c==defaultlanguage && l.CommonCode__c=='copyright') copyright=l.Label__c;
		}
		return copyright;
	}

	public Boolean getShowNextTopShop(){
		return System_Settings.showNextTopShop;
	}

	public PageReference redirectToLogin(){
		return System_Settings.redirectDirectlyToLogin();
	}
	
	public String getTarget(){
		return 'pdf_logo.pdf';
	}
	
	public Boolean getIsPDF(){
		return System_Settings.popupIsPDF;
	}
	
	public Boolean getIsFlash(){
		return System_Settings.popupIsPDF;
	}
	
	public Boolean getIsNative(){
		return System_Settings.popupIsPDF;
	}
	
	public Boolean isPro() {
		return isPro;
	}
	
	public String getPortal() {
		return portal;
	}
	
	public String getPopupurl() {  
		if(System_Settings.popupIsFlash)
			return Site.getCurrentSiteUrl()+'page';
		
		if(System_Settings.popupIsNative)
			return Site.getCurrentSiteUrl()+'page' + '?pageid=' + System_Settings.popupPageId;
	
		return null;
	}
	
	public Boolean getGewinnSpiel(){
        User u = [select Contact.Keine_Teilnahme_Campus_Incentiv__c from User where Id=:UserInfo.getUserId()];
        if(u.Contact.Keine_Teilnahme_Campus_Incentiv__c) //user already clicked on "ich möchte nicht teilnehmen"
            return false;
        
        map<String, Cookie> Cookies = ApexPages.currentPage().getCookies();
        if(Cookies.containsKey('HideGewinnSpiel')) //user clicked during the current session on "jetzt nicht teilnehmen"
            return false;
            
        try {
            Campaign camp = [select id from Campaign where RecordType.developerName = 'Top_Shop' AND Portal__c =: SystemSettings.portal and isActive = true and StartDate <=: system.today() and EndDate >=: system.today() limit 1];
        }
        catch(exception e) {
            return false;
        }
        
        return true;
    } 
}