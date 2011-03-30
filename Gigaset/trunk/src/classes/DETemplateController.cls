public class DETemplateController extends PageControllerBase {

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
	
	public String Modules_URLPage {get;set;}
	public String firstName {get;set;}
	public String lastName {get;set;}
	public String salutation {get;set;}
	public Boolean showNextTopShop { get; set; }
	public Integer Modules_currentSuccess {get;set;}
	public String Modules_Param {get;set;}
	public Integer Modules_total {get;set;}
	public Integer Modules_currentpoint {get;set;}
	public Double Modules_currentbar {get;set;}
	public boolean Modules_showFirstpage {get;set;}
	public boolean Modules_showThirdpage {get;set;}
	public String Modules_LektoraURL {get;set;}
	public Training_Book__c Modules_book {get;set;}
	public String newsid { get; set; }
	public list<Training_Module__c> Modules_modulesSecondPage1 {get;set;}
	public Training_Module__c Modules_SingleModule {get;set;}
   	List<Modulen> Modules = new list<Modulen>(); 
    public List<Modulen> Modules_modulesSecondPage2 {get;set;}
	List<Booken> Books = new list<Booken>(); 
	
	NextTopShop__c NTS;
	String addParam='';
	
	public Boolean getShowNextTopShop(){
		return SystemSettings.showNextTopShop;
	} 
	
	// Controller for topnews component to get the current newsid
	public DEtopnews topnewsController {set;
		get{
			//get the map, then the component controller using the appropriate key
			if(getComponentControllerMap()!=null){
				DEtopnews mcc;
				mcc = (DEtopnews )getComponentControllerMap().get('topnews');
				if(mcc!= null)
					return mcc;
			}
			//just in case something goes wrong return something...this can be handled better
			return new DEtopnews();
		}
	}
	
	// Controller for newsreader component to set the current newsid
	public DEnewsreader newsreaderController {set;
		get{
			//get the map, then the component controller using the appropriate key
			if(getComponentControllerMap()!=null){
				DEnewsreader mcc;
				mcc = (DEnewsreader )getComponentControllerMap().get('newsreader');
				if(mcc!= null)
					return mcc;
			}
			//just in case something goes wrong return something...this can be handled better
			return new DEnewsreader();
		}
	}
	
	public String getModules_URLPage(){
		return null;
	}
	
	// constructor
	public DETemplateController() {
	
		newsid=topnewsController.newsid;
		test=Label.loginpage;
		isPro=SystemSettings.isPro;
		styleSelector=isPro?'pro':'normal';
		isDone = ApexPages.currentPage().getParameters().containsKey('isDone');
		callback_imgurl=SystemSettings.getLabel('callback_imgurl');
		if (callback_imgurl=='') showcontactportlet=false;
		else showcontactportlet=true;
		showprivacy=SystemSettings.showPrivacy();
		showpresetcomp=SystemSettings.showPreset() & !showprivacy;
		showclearingcomp=SystemSettings.showClearing() & !showprivacy;
		if (showclearingcomp) showpresetcomp=false;
		showothercomp=showpresetcomp || showclearingcomp || showprivacy;
		defaultlanguage=SystemSettings.setLanguage();
		label_menu_home=SystemSettings.getCurrentNavigationPointLabel(SystemSettings.homepageid);
		kontaktpageid=SystemSettings.kontaktpageid;
		isAuthenticated=SystemSettings.isPortalUser();
		currentNavigationPoint='';
		u0 = [select Contact.Id, Contact.firstname, Contact.lastname, Contact.Salutation from User where Id=:UserInfo.getUserId()];
	    try {
	    	c0 = [select firstname, lastname, toLabel(Salutation) from Contact where Id =: u0.Contact.Id];
	    } catch(exception e) {}
	    System.debug('#################################################### Begrüßung: '+u0.Contact.lastname);
	    firstName = u0.Contact.firstName;
	    lastName = u0.Contact.lastName;
	    salutation = u0.Contact.salutation;
		
		if (ApexPages.currentPage().getParameters().containsKey('pageid')) {
			currentNavigationPoint=getCurrentNavigationPointLabel(ApexPages.currentPage().getParameters().get('pageid'));
			
			for (pages__c l:pages__c.getAll().values()) {
				if (l.Portal__c==SystemSettings.portal && l.Label__c=='training_firstPage') {
					if(ApexPages.currentPage().getParameters().get('pageid') == l.PageId__c)
						showTraining = true;
					else
						showTraining = false;
				}
			}	
		}
		homeurl=SystemSettings.goHome().getUrl();
			
		//System.debug('******* Zustand: showprivacy: ' + showprivacy + ' / showpresetcomp: '+ showpresetcomp + ' / showclearingcomp: ' +showclearingcomp + ' / showothercomp: ' + showothercomp + ' / shownexttopshop: ' + showNextTopShop + ' / isAuthenticated: ' + isAuthenticated + ' / isPro: ' + isPro +  ' / Portal: ' + SystemSettings.portal + ' / UserId: ' + UserInfo.getUserId() );
	}
	 
	public String getCurrentNavigationPointLabel(String pageid) {
		String homepageid=SystemSettings.homepageid;
		String link01pageid=SystemSettings.link01pageid;
		String link02pageid=SystemSettings.link02pageid;
		String link03pageid=SystemSettings.link03pageid;
		String link04pageid=SystemSettings.link04pageid;
		String link05pageid=SystemSettings.link05pageid;
		String werbemittelpageid=SystemSettings.werbemittelpageid;
		String imprintpageid=SystemSettings.imprintpageid;
		kontaktpageid=SystemSettings.kontaktpageid;
		registrationpageid=SystemSettings.registrationpageid;
		String userdatapageid=SystemSettings.userdatapageid;
		String loginpageid=SystemSettings.loginpageid;
		String rueckrufservicepageid=SystemSettings.rueckrufservicepageid;
		String forgotpasswordpageid=SystemSettings.forgotpasswordpageid;
		// portal specific labels/navigationpoints
		if (pageid.startsWith(homepageid)|| (Site.getPrefix()!=null && Site.getPrefix().contains('Home'))) return SystemSettings.getLabel('home');
		if (link01pageid!='' && pageid.startsWith(link01pageid)) return SystemSettings.getLabel('link01');
		if (link02pageid!='' && pageid.startsWith(link02pageid)) return SystemSettings.getLabel('link02');
		if (link03pageid!='' && pageid.startsWith(link03pageid)) return SystemSettings.getLabel('link03');
		if (link04pageid!='' && pageid.startsWith(link04pageid)) return SystemSettings.getLabel('link04');
		if (link05pageid!='' && pageid.startsWith(link05pageid)) return SystemSettings.getLabel('link05');
		if (werbemittelpageid!='' && pageid.startsWith(werbemittelpageid)) return SystemSettings.getLabel('Werbemittel');
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
	
	public PageReference redirectToLogin() {
		
		PageReference basispage=Page.page;
		PageReference login=new PageReference( basispage.getUrl() + '?pageid=' + SystemSettings.loginpageid + addParam);
		login.setRedirect(true);
		Boolean isAlreadyLoginPage=false;
		if (ApexPages.currentPage()==login) isAlreadyLoginPage=true;
		if (ApexPages.currentPage().getParameters().containsKey('pageid') && ApexPages.currentPage().getParameters().get('pageid').startsWith(SystemSettings.loginpageid)) isAlreadyLoginPage=true;
		
		if (isAlreadyLoginPage) return null;
		else return login;
	}
	
	// getter
	public String getKontaktformularUrl() {
		return CMSpage.getUrl() + '?pageid=' + SystemSettings.kontaktpageid;
	}
	
	public String getImprintUrl() {
		return CMSpage.getUrl() + '?pageid=' + SystemSettings.imprintpageid;
	}
	
	public String getRueckrufserviceUrl() {
		if (SystemSettings.rueckrufservicepageid!='')
			return CMSpage.getUrl() + '?pageid=' + SystemSettings.rueckrufservicepageid;
		else
			return '';
	}
	
	public String getCopyright() {
		String copyright='';
		for (CustomLabel__c l:CustomLabel__c.getAll().values()) {
			if (l.Portal__c==SystemSettings.portal && l.LanguageCode__c==defaultlanguage && l.CommonCode__c=='copyright') copyright=l.Label__c;
		}
		return copyright;
	}
	
	public String getCampus_Title_1() {
		return SystemSettings.getLabel('Campus_Title_1');
	}
	
	public String getCampus_Welcome() {
		return SystemSettings.getLabel('Campus_Welcome');
	}
	
	public String getCampus_main_Description1() {
		return SystemSettings.getLabel('Campus_main_Description1');
	}
	
	public String getCampus_main_Description2() {
		return SystemSettings.getLabel('Campus_main_Description2');
	}
	
	public String getCampus_1_Title() {
		return SystemSettings.getLabel('Campus_1_Title');
	}
	
	public String getCampus_2_Title() {
		return SystemSettings.getLabel('Campus_2_Title');
	}
	
	public String getCampus_3_Title() {
		return SystemSettings.getLabel('Campus_3_Title');
	}
	
	public String getCampus_4_Title() {
		return SystemSettings.getLabel('Campus_4_Title');
	}
	
	public String getCampus_underTitle() {
		return SystemSettings.getLabel('Campus_underTitle');
	}
	
	public String getCampus_smallBox1() {
		return SystemSettings.getLabel('Campus_smallBox1');
	}
	
	public String getCampus_smallBox2() {
		return SystemSettings.getLabel('Campus_smallBox2');
	}
	
	public String getCampus_smallBox3() {
		return SystemSettings.getLabel('Campus_smallBox3');
	}
	
	public String getCampus_smallBox4() {
		return SystemSettings.getLabel('Campus_smallBox4');
	}
	
	public String getCampus_otherPage1() {
		return SystemSettings.getLabel('Campus_otherPage1');
	}
	
	public String getCampus_otherPage2() {
		return SystemSettings.getLabel('Campus_otherPage2');
	}
	
	public String getCampus_otherPage3() {
		return SystemSettings.getLabel('Campus_otherPage3');
	}
	
	public String getCampus_otherPage4() {
		return SystemSettings.getLabel('Campus_otherPage4');
	}
	
	public String getCampus_otherPage5() {
		return SystemSettings.getLabel('Campus_otherPage5');
	}
	
	public String getCampus_otherPage6() {
		return SystemSettings.getLabel('Campus_otherPage6');
	}
	
	public String getCampus_lastPage1() {
		return SystemSettings.getLabel('Campus_lastPage1');
	}
	
	public String getCampus_lastPage2() {
		return SystemSettings.getLabel('Campus_lastPage2');
	}
	
	
	// actions
	 public PageReference init() {
	 	system.debug('Session id ... ' + UserInfo.getSessionId());
	 	if (ApexPages.currentPage().getParameters().containsKey('pid')) SystemSettings.addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
	 	if (!SystemSettings.isPortalUser()) return redirectToLogin();
	 	return null;
	 }
	 
	
	public class Modulen {
		public list<Training_Module__c> Module {get; set;}
		public integer ModuleNumber {get;set;}
		public boolean renderScroller {get;set;}
		public Modulen() {
  			Module=new list<Training_Module__c>();
  		}
	} 

	public class Booken {
		public Training_Book__c Book {get; set;}
		public Double Helfer {get;set;}
		public Double Helfer2 {get;set;}
		public Double Helfer3 {get;set;}
		public Double Helfer4 {get;set;}
		public String Helfer5 {get;set;}
		public String Helfer6 {get;set;}
		public Double Helfer7 {get;set;}
		public Double Helfer8 {get;set;}
		public Double Helfer9 {get;set;}
		public Double Helfer_BH {get;set;}
		public Double Helfer_BH_Vertical {get;set;}
		public Booken() {
  			Book=new Training_Book__c();
  		} 
	}
	 
	public list<Booken> getBooks(){
		list<Training_Book__c> TB= new list<Training_Book__c>([select id, Buchhaenger__c,New_Modules__c, Titel__c from Training_Book__c where Gigaset_Pro__c =: SystemSettings.isPro AND Portal__c =:SystemSettings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		Integer i = 0;
		Books = new list<Booken>(); 
		Booken book;
		for(Training_Book__c b:TB) {
			book = new Booken();
			book.Book = b;
			Books.add(book);
		}
		
		for(Booken b:Books) {
		//	if(b.Buchhaenger__c) {
				b.Helfer = 70 * i + 58;
				b.Helfer_BH = 72.5 * i + 15;
				b.Helfer7 = -30;
				b.Helfer9 = 80 + i * 4.8;
				b.Helfer3 = b.Helfer; 
				//if(i == 0 || i == 1)
					//b.Helfer3__c -= 15;
				if(i == 4) {
					b.Helfer7 = 5;
					b.Helfer4 = 55; //old value: 50
					b.Helfer_BH_Vertical = 56; //old value: 60
					b.Helfer5 = '0.34202014, 0.93969262, -0.93969262, 0.34202014';
					b.Helfer6 = 'M11=0.34202014, M12=-0.93969262, M21=0.93969262, M22=0.34202014';
					b.Helfer3 = 335; //old value: 335
					b.Helfer8 = -45; 
					b.Helfer9 = 100;
				}
				else {
					b.Helfer8 = -70;
					b.Helfer2 = 65;
					b.Helfer4 = 55; //old value: 48
					b.Helfer_BH_Vertical = 44; // old value: 48
					b.Helfer5 = '0.00000000, 1.00000000, -1.00000000, 0.00000000';
					b.Helfer6 = 'M11=0.00000000, M12=-1.00000000, M21=1.00000000, M22=0.00000000';
				}
			i++;
		}

		return Books;
	}
	
	public PageReference firstPage(){
		Modules_showFirstpage = true;
		Modules_showThirdpage = false;
		return null;
	}
	
	public PageReference Poller(){
		String param = Modules_Param;
	
		Modules_SingleModule = [select id, Bild_URL__c, Titel__c, Beschreibung__c, Dauer__c, URL__c, Punkte__c, Sortierung__c, Training_Book__c, Verwandtes_Modul_1__c, Verwandtes_Modul_2__c, Verwandtes_Modul_3__c, Verwandtes_Modul_4__c, Verwandtes_Modul_Name_1__c, Verwandtes_Modul_Name_2__c, Verwandtes_Modul_Name_3__c, Verwandtes_Modul_Name_4__c from Training_Module__c where Id =: param];
		
		Modules_book = [select id, Titel__c, Subtitel__c, Beschreibung__c from Training_Book__c where Id =: Modules_SingleModule.Training_Book__c ];
		
		Attachment Bild_Attachment;
		try {
			Bild_Attachment = [select id from Attachment where ParentId =: Modules_SingleModule.Id];
		}
		catch(Exception e) {}
		if(Bild_Attachment != null) {
			Modules_SingleModule.Bild_URL__c = '/servlet/servlet.FileDownload?file='+Bild_Attachment.Id;
			update Modules_SingleModule;
		}
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: SystemSettings.isPro AND Training_Book__r.Portal__c =:SystemSettings.Portal AND Training_Book__c =: Modules_SingleModule.Training_Book__c AND Aktiv__c = true ORDER by Sortierung__c]);

		
		list<String> TMIds = new list<String>();
		for(Training_Module__c TM:TMlist) {
			TMIds.add(TM.Id);
		}
		User u = [select id, ContactId from User where Id=:UserInfo.getUserId()];
		
		String SECRET = 'mJ724siW;';
		
		String contactId = u.ContactId;
		contactId = contactId.substring(0,15);
		
		String moduleId = Modules_SingleModule.Id;
		moduleId = moduleId.substring(0,15);
		Long nowTime = system.now().getTime();
		
		String secrettext = moduleId + '-' + contactId + '-' + nowTime + '-' + Modules_SingleModule.URL__c + '-' + SECRET;
		String Code = DEInterfaceLinks.generateStringTestTraining(secrettext);

		
		Modules_LektoraURL = 'https://training.gigaset.com/relay/open_lectora_course.php?Closed='+ Code +'&modulId='+moduleId+'&ContactId='+contactId+'&timestamp='+nowTime+'&target='+Modules_SingleModule.URL__c ;
		
		
		list<Training_Ergebnis__c> TElist= new list<Training_Ergebnis__c>([select id, Training_Modul__c, Completion_Status__c from Training_Ergebnis__c where Training_Modul__c IN:TMIds AND Kontakt__c =: u.ContactId]);
		
		for(Training_Module__c TM:TMlist) {
			for(Training_Ergebnis__c TE:TElist) {
				if(TE.Training_Modul__c == TM.Id) {
					TM.showTick__c = true;
					if(TE.Completion_Status__c == 'Success')
						TM.showCoins__c = true;
				}		
			}
		}
		Integer i=0;
		Modules_modulesSecondPage2 = new list<Modulen>();
		Modules_modulesSecondPage1 = new list<Training_Module__c>();
		Modulen modul = new Modulen();
		for(Training_Module__c TM:TMlist) {
			if(i<5)
				Modules_modulesSecondPage1.add(TM);
			else {
				modul.Module.add(TM);
				if(modul.Module.size()==5) {
					Modules_modulesSecondPage2.add(modul);
					modul = new Modulen();
				}			
			}
			i++;
		}
		if(modul.Module.size()>0) {
			Modules_modulesSecondPage2.add(modul);
			modul = new Modulen();
		}
		return null;
		
	}
	
	public PageReference secondPage(){
		String param = ApexPages.currentPage().getParameters().get('param');
		Modules_showFirstpage = false;
		Modules_showThirdpage = false;
		list<Training_Book__c> TB= new list<Training_Book__c>([select id, Titel__c, Subtitel__c, Beschreibung__c from Training_Book__c where Gigaset_Pro__c =: SystemSettings.isPro AND Portal__c =:SystemSettings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		
		for(Training_Book__c b:TB) {
			if(b.Titel__c == param) {
				Modules_book = b;
				break;
			}

		}
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: SystemSettings.isPro AND Training_Book__r.Portal__c =:SystemSettings.Portal AND Training_Book__c =: Modules_book.Id AND Aktiv__c = true ORDER by Sortierung__c]);

		
		list<String> TMIds = new list<String>();
		for(Training_Module__c TM:TMlist) {
			TMIds.add(TM.Id);
		}
		User u = [select id, ContactId from User where Id=:UserInfo.getUserId()];
		
		list<Training_Ergebnis__c> TElist= new list<Training_Ergebnis__c>([select id, Training_Modul__c, Completion_Status__c from Training_Ergebnis__c where Training_Modul__c IN:TMIds AND Kontakt__c =: u.ContactId]);
		
		for(Training_Module__c TM:TMlist) {
			for(Training_Ergebnis__c TE:TElist) {
				if(TE.Training_Modul__c == TM.Id) {
					TM.showTick__c = true;
					if(TE.Completion_Status__c == 'Success')
						TM.showCoins__c = true;
				}		
			}
		}
		Integer i=0;
		Modules_modulesSecondPage2 = new list<Modulen>();
		Modules_modulesSecondPage1 = new list<Training_Module__c>();
		Modulen modul = new Modulen();
		for(Training_Module__c TM:TMlist) {
			if(i<5)
				Modules_modulesSecondPage1.add(TM);
			else {
				modul.Module.add(TM);
				if(modul.Module.size()==5) {
					Modules_modulesSecondPage2.add(modul);
					modul = new Modulen();
				}			
			}
			i++;
		}
		if(modul.Module.size()>0) {
			Modules_modulesSecondPage2.add(modul);
			modul = new Modulen();
		}
		
		return null;
	}
	
	public PageReference showModule(){
		String param = ApexPages.currentPage().getParameters().get('moduleId');
		Modules_Param = param;
		
		Modules_showFirstpage = false;
	
		Modules_SingleModule = [select id, Bild_URL__c, Titel__c, Beschreibung__c, Dauer__c, URL__c, Punkte__c, Sortierung__c, Training_Book__c, Verwandtes_Modul_1__c, Verwandtes_Modul_2__c, Verwandtes_Modul_3__c, Verwandtes_Modul_4__c, Verwandtes_Modul_Name_1__c, Verwandtes_Modul_Name_2__c, Verwandtes_Modul_Name_3__c, Verwandtes_Modul_Name_4__c from Training_Module__c where Id =: param];
		
		Modules_book = [select id, Titel__c, Subtitel__c, Beschreibung__c from Training_Book__c where Id =: Modules_SingleModule.Training_Book__c ];
		
		Attachment Bild_Attachment;
		try {
			Bild_Attachment = [select id from Attachment where ParentId =: Modules_SingleModule.Id];
		}
		catch(Exception e) {}
		if(Bild_Attachment != null) {
			Modules_SingleModule.Bild_URL__c = '/servlet/servlet.FileDownload?file='+Bild_Attachment.Id;
			update Modules_SingleModule;
		}
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: SystemSettings.isPro AND Training_Book__r.Portal__c =:SystemSettings.Portal AND Training_Book__c =: Modules_SingleModule.Training_Book__c AND Aktiv__c = true ORDER by Sortierung__c]);

		
		list<String> TMIds = new list<String>();
		for(Training_Module__c TM:TMlist) {
			TMIds.add(TM.Id);
		}
		User u = [select id, ContactId from User where Id=:UserInfo.getUserId()];
		
		String SECRET = 'mJ724siW;';
		
		String contactId = u.ContactId;
		contactId = contactId.substring(0,15);
		
		String moduleId = Modules_SingleModule.Id;
		moduleId = moduleId.substring(0,15);
		Long nowTime = system.now().getTime();
		
		String secrettext = moduleId + '-' + contactId + '-' + nowTime + '-' + Modules_SingleModule.URL__c + '-' + SECRET;
		String Code = DEInterfaceLinks.generateStringTestTraining(secrettext);

		
		Modules_LektoraURL = 'https://training.gigaset.com/relay/open_lectora_course.php?Closed='+ Code +'&modulId='+moduleId+'&ContactId='+contactId+'&timestamp='+nowTime+'&target='+Modules_SingleModule.URL__c ;
		
		
		list<Training_Ergebnis__c> TElist= new list<Training_Ergebnis__c>([select id, Training_Modul__c, Completion_Status__c from Training_Ergebnis__c where Training_Modul__c IN:TMIds AND Kontakt__c =: u.ContactId]);
		
		for(Training_Module__c TM:TMlist) {
			for(Training_Ergebnis__c TE:TElist) {
				if(TE.Training_Modul__c == TM.Id) {
					TM.showTick__c = true;
					if(TE.Completion_Status__c == 'Success')
						TM.showCoins__c = true;
				}		
			}
		}
		Integer i=0;
		Modules_modulesSecondPage2 = new list<Modulen>();
		Modules_modulesSecondPage1 = new list<Training_Module__c>();
		Modulen modul = new Modulen();
		for(Training_Module__c TM:TMlist) {
			if(i<5)
				Modules_modulesSecondPage1.add(TM);
			else {
				modul.Module.add(TM);
				if(modul.Module.size()==5) {
					Modules_modulesSecondPage2.add(modul);
					modul = new Modulen();
				}			
			}
			i++;
		}
		if(modul.Module.size()>0) {
			Modules_modulesSecondPage2.add(modul);
			modul = new Modulen();
		}
		
		
		Modules_showThirdpage = true;
		return null;
	}
	public list<Modulen> getModules(){
		modules.clear();
		User u = [select id, Contact.Erfolgreiche_Ergebnisse__c, Contact.Gesamt_Ergebnis__c from User where Id=:UserInfo.getUserId()];
		Modules_currentSuccess = u.Contact.Erfolgreiche_Ergebnisse__c.intValue();
		Modules_currentpoint = u.Contact.Gesamt_Ergebnis__c.intValue();
		list<Training_Book__c> TBlist= new list<Training_Book__c>([select id, Titel__c from Training_Book__c where Gigaset_Pro__c =: SystemSettings.isPro AND Portal__c =:SystemSettings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c from Training_Module__c where neues_modul__c = true AND Training_Book__r.Gigaset_Pro__c =: SystemSettings.isPro AND Training_Book__r.Portal__c =:SystemSettings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		list<Training_Module__c> TMlist_full= new list<Training_Module__c>([select id from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: SystemSettings.isPro AND Training_Book__r.Portal__c =:SystemSettings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		Modules_total = TMlist_full.size();
		if(Modules_total != 0)
			Modules_currentbar = u.Contact.Erfolgreiche_Ergebnisse__c * 100 / Modules_total  ;
		else 
			Modules_currentbar = 0;
		//system.debug('size... ' + TMlist.size() + TMlist);
		
		Modulen modul;
		for(Integer i=0; i<TBlist.size(); i++) {
			modul = new Modulen();
			list<Training_Module__c> listTM = new list<Training_Module__c>();
			for(Training_Module__c TM:TMlist) {
				if(TBlist.get(i).Id == TM.Training_Book__c) {
					listTM.add(TM);
					 
				}
				if(listTM.size() == 5)
					break;
			}
			modul.Module = listTM;
			modul.ModuleNumber = i;
			if(listTM.size()> 3)
				modul.renderScroller = true;
			else
				modul.renderScroller = false;
			modules.add(modul);
		}
		
		return modules;
	}
	
	public PageReference initModuleResult(){
		System.debug('##################### Method: initModuleResult ##########################');
		User u = [select id, ContactId from User where Id=:UserInfo.getUserId()];
		String contactID = u.ContactId;
		contactID = contactID.substring(0,15);
		String moduleID = Modules_SingleModule.ID;
		moduleID = moduleID.substring(0,15);
		Date actualDate = system.now().date();
		
		list<Training_Ergebnis__c> results = [select id, Training_Modul__c, Tries__c, Completion_Status__c from Training_Ergebnis__c where Training_Modul__c = :moduleID AND Kontakt__c = :contactID];
		Training_Ergebnis__c item;
		
		if(results.size() == 0){
			System.debug('No result found. Needed to create new one with init values!');
			item = new Training_Ergebnis__c(Training_Modul__c = moduleID, Kontakt__c = contactID, ErgebnisID__c = moduleID+''+contactID, Last_Click__c = actualDate, Tries__c = 0);
			insert item;
		}else{
			item = results.get(0);
		}
		
		item.Last_Click__c = actualDate;	

		if(item.Completion_Status__c == null || item.Completion_Status__c != 'Success')
			item.Tries__c = item.Tries__c + 1;
		
		update item;
		
		return null;	
	}
	
	public PageReference initHome() {
		
  		
	 	Modules_showThirdpage = false;
		Modules_showFirstpage = true;
		Modules_URLPage =  CMSpage.getUrl() + '?pageid=' + SystemSettings.TrainingId;
		Cookie TopShop;
		u0 = [select Contact.Id, Contact.firstname, Contact.lastname, Contact.Salutation from User where Id=:UserInfo.getUserId()];
	    try {
	    	c0 = [select firstname, lastname, toLabel(Salutation) from Contact where Id =: u0.Contact.Id];
	    } catch(exception e) {}
	    System.debug('#################################################### Begrüßung: '+u0.Contact.lastname);
	    firstName = u0.Contact.firstName;
	    lastName = u0.Contact.lastName;
	    salutation = u0.Contact.salutation;
		
	 	if (NTS==null) {
		 	try{
		 		NTS = [select Status_der_Teilnahme__c, Kampagne__c from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
		 	}
		 	catch(exception e){}
	 	}
	 	if(NTS != null && (NTS.Status_der_Teilnahme__c == 'Abgesendet' || NTS.Status_der_Teilnahme__c == 'keine Teilnahme'))
	 		showNextTopShop=false;
	 	else{
		 	if (ApexPages.currentPage().getCookies() != null)
		 		TopShop = ApexPages.currentPage().getCookies().get('HideTopShop');
			User u;
			try {
				u = [select id, Contact.Gigaset_Pro__c from User where Id=:UserInfo.getUserId()];
			} catch(exception e){}
			
			if(NTS == null && u != null) {
				Campaign camp;
		    		try{
		    			camp = [select id, EndDate, StartDate, isActive from Campaign where RecordType.Name = 'Top Shop' AND Portal__c =: systemSettings.Portal AND isPro__c =: SystemSettings.isPro AND EndDate >= TODAY AND StartDate <= TODAY AND isActive = True limit 1]; 
		    		}
		    		catch(exception e){}
		    		if(camp != null)
		    			showNextTopShop=true;
		    		else
		    			showNextTopShop=false;
			}		
			/*else if(NTS != null && NTS.Kampagne__c != null && TopShop == null && u != null) {
	    			Campaign camp;
	    			try{
	    				camp = [select id, EndDate, StartDate, isActive from Campaign where Id =: NTS.Kampagne__c limit 1]; 
	    			}
	    			catch(exception e){}
	    			if(camp != null && camp.StartDate<=system.today() && camp.EndDate >= system.today() && camp.isActive)
	    				showNextTopShop = true;
	    			else
	    				showNextTopShop=false;
    			}
    			else
	    			showNextTopShop=false;	
	    			
		    	if(TopShop != null) 
	        		showNextTopShop=false;
	    		//}*/
	
	 	}
	 	
	 	if (!SystemSettings.isPortalUser()) return redirectToLogin();
	 	if (!ApexPages.currentPage().getParameters().containsKey('pageid')) return SystemSettings.goHome();
	 	return null;
	}
	
	public pageReference getRecentNewsId() {
	 	newsid=ApexPages.currentPage().getParameters().get('newsid');
	 	return null;
	 }
	 
}