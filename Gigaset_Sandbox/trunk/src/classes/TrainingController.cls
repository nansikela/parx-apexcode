global class TrainingController {
	
	public  Integer Modules_currentSuccess {get;set;}
	public  String Modules_URLPage {get;set;}
	public  String Modules_Param {get;set;}
	public  Integer Modules_total {get;set;}
	public  Integer Modules_currentpoint {get;set;}
	public  Double Modules_currentbar {get;set;}
	public  Boolean Modules_showFirstpage {get;set;}
	public  boolean Modules_showThirdpage {get;set;}
	public  Boolean Modules_showProcesspage {get;set;}
	public  String  Modules_LektoraURL {get;set;}
	public  String  Mobile_LektoraURL {get;set;}
	public  Boolean isLektoraLoaded {get;set;}
	public  Training_Book__c Modules_book {get;set;}
	public  list<Training_Module__c> Modules_modulesSecondPage1 {get;set;}
	public  Training_Module__c Modules_SingleModule {get;set;}
   	//public  List<Modulen> Modules {get;set;}
   	list<Modulen> modules=new list<Modulen>();
    public  List<Modulen> Modules_modulesSecondPage2 {get;set;}
    public  List<Module> Modules_modulesSecondPageMobile {get;set;} //For mobile!
	//public  List<Booken> Books {get;set;} 
	public  String newsid {get;set;}
	public Boolean isPro { get; private set; }
	public final Boolean isMobile { get; private set; }
	public String portal { get; private set; }
	public String defaultlanguage { get; private set; }
	
	public  User u0{get;set;}
	public  Contact c0 {get;set;}
	
	public  String firstName {get;set;}
	public  String lastName {get;set;}
	public  String salutation {get;set;}
	
	public String progressURL {get;set;}
	
	public NextTopShop__c NTS {get;set;}
	//public PageReference CMSpage = Page.page;
	 
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
		public Double x1 {get;set;}
		public Double y1 {get;set;}
		public Double x2 {get;set;}
		public Double y2 {get;set;}
		public Double x3 {get;set;}
		public Double y3 {get;set;}
		public Double x4 {get;set;}
		public Double y4 {get;set;}
		public String function {get;set;}
		public Double Helfer_BH {get;set;}
		public Double Helfer_BH_Vertical {get;set;}
		public Booken() {
  			Book=new Training_Book__c();
  		} 
	}
	
	//NEEDED FOR MOBILE VERSION! -----------------------------------------------------------------
	
	private list<Attachment> atts;
	
	public class Module {
		public Training_Module__c element {get; set;}
		public String backgroundImgPath {get;set;}
		public Module(Training_Module__c tm) {
			element = tm;
			backgroundImgPath = '';
		}
	} 
	
	
	public TrainingController(TemplateController templateCtrl){
		
		String bookID;
		PageReference pageRef = ApexPages.currentPage();
		if (pageRef.getParameters().containsKey('bookID')) bookID = pageRef.getParameters().get('bookID');
		
		portal=System_Settings.portal;
		progressURL = Page.page.getUrl() + '?pageid=' + System_Settings.ProgressId;
		isPro=isPro;
		defaultlanguage=System_Settings.setLanguage();
		isMobile = System_Settings.isMobileActivated();
		//Books=getBooksForBooks();
		
		u0 = System_Settings.currentuser;
		c0 = System_Settings.currentusercontact;
		
		if(!backToBook(bookID)) {
			Modules_showFirstpage = true;
			Modules_showProcesspage = false;
			Modules_showThirdpage = false;
			
			initMobileHome();
		}
	}
	//END ----------------------------------------------------------------------------------------
	
	public TrainingController(CRD_pageTemplatesController templateCtrl){
		portal=System_Settings.portal;
		progressURL = Page.page.getUrl() + '?pageid=' + System_Settings.ProgressId;
		isPro=isPro;
		isMobile = System_Settings.isMobileActivated();
		defaultlanguage=System_Settings.setLanguage();
		//Books=getBooksForBooks();
		system.debug(isMobile);
		u0 = System_Settings.currentuser;
		c0 = System_Settings.currentusercontact;
		
		Modules_showFirstpage = true;
		Modules_showProcesspage = false;
		Modules_showThirdpage = false;
	}
	
	public TrainingController(){
		isLektoraLoaded = false;
		portal=System_Settings.portal;
		progressURL = Page.page.getUrl() + '?pageid=' + System_Settings.ProgressId;
		isPro=isPro;
		defaultlanguage=System_Settings.setLanguage();
		isMobile = System_Settings.isMobileActivated();
		//Books=getBooksForBooks();
		
		u0 = System_Settings.currentuser;
		c0 = System_Settings.currentusercontact;
		
		Modules_showFirstpage = true;
		Modules_showProcesspage = false;
		Modules_showThirdpage = false;
	}		
	

	public list<Booken> getBooks(){
		system.debug('page ref: '+system.currentPageReference());
		System.debug('Training getBooks Start');
		list<Training_Book__c> TB= new list<Training_Book__c>([select id, Buchhaenger__c, New_Modules__c, New_Modules_Mobile__c, Titel__c from Training_Book__c where Gigaset_Pro__c =: isPro AND Portal__c =:portal AND Aktiv__c = true ORDER by Sortierung__c]);
		Integer i = 0;
		list<Booken> Books = new list<Booken>(); 
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
					
					b.x1 = b.Helfer3 - 40;
					b.y1 = b.Helfer4;
					
					b.x2 = b.Helfer3 - 40 + 65;
					b.y2 = b.Helfer4;
					
					b.x3 = b.Helfer3 + 100;
					b.y3 = b.Helfer4 + 250;
					
					b.x4 = b.Helfer3 + 35;
					b.y4 = b.Helfer4 + 250;
				
				} else {
					b.Helfer8 = -70;
					b.Helfer2 = 65;
					b.Helfer4 = 55; //old value: 48
					b.Helfer_BH_Vertical = 44; // old value: 48
					b.Helfer5 = '0.00000000, 1.00000000, -1.00000000, 0.00000000';
					b.Helfer6 = 'M11=0.00000000, M12=-1.00000000, M21=1.00000000, M22=0.00000000';
					
					b.x1 = b.Helfer3 - 35;
					b.y1 = b.Helfer4;
				
					b.x2 = b.Helfer3 - 35 + 65;
					b.y2 = b.Helfer4;
				
					b.x3 = b.Helfer3 - 35 + 65;
					b.y3 = b.Helfer4 + 250;
				
					b.x4 = b.Helfer3 - 35 ;
					b.y4 = b.Helfer4 + 250;
				}
				
				b.function = 'buchrand'+i; 
			i++;
		}
		System.debug('Training getBooks End');
		return Books;
	}

	public PageReference firstPage(){
		if(UserInfo.getOrganizationId() == '00D20000000M2NzEAK') //liveId
			Modules_URLPage = Page.page.getUrl() + '?pageid=' + System_Settings.TrainingId;
		else
			Modules_URLPage = '/np/' + Page.page.getUrl() + '?pageid=' + System_Settings.TrainingId;
		Modules_showFirstpage = true;
		Modules_showProcesspage = false;
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
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: isPro AND Training_Book__r.Portal__c =:portal AND Training_Book__c =: Modules_SingleModule.Training_Book__c AND Aktiv__c = true ORDER by Sortierung__c]);
		
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
	
	//NEEDED FOR MOBILE VERSION --------------------------------------------------------------------
	public PageReference processPage() {
		getModules();
		Modules_showFirstpage = false;
		Modules_showProcesspage = true;
		Modules_showThirdpage = false;
		
		return null;
	}
	
	private Boolean backToBook(String bookID){
		String param;
		
		list<Training_Book__c> TB= new list<Training_Book__c>([select id, Titel__c, Subtitel__c, Beschreibung__c from Training_Book__c where Gigaset_Pro__c =: isPro AND Portal__c =:portal AND Aktiv__c = true ORDER by Sortierung__c]);
		
		for(Training_Book__c b:TB) {
			if(b.ID == bookID) {
				Modules_book = b;
				break;
			}
		}
		
		if(Modules_book == null)
			return false;
			
		Modules_showFirstpage = false;
		Modules_showProcesspage = false; 
		Modules_showThirdpage = false;
		
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Active_Mobile__c, Titel__c, Beschreibung__c, Training_Book__c, showTick__c, showCoins__c, Dauer__c, Punkte__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: isPro AND Training_Book__r.Portal__c =:portal AND Training_Book__c =: Modules_book.Id AND Aktiv__c = true ORDER by Sortierung__c]);

		// FOR MOBILE
		set<ID> moduleIDs = new set<ID>();
		for(Training_Module__c tm : TMList)
			if(!moduleIDs.contains(tm.ID))
				moduleIDs.add(tm.ID);
				
		if(moduleIDs.size() > 0) {
			atts = [Select Name, ParentID, Body From Attachment Where ParentID IN :moduleIDs AND Name Like '%mobile%'];
		}
		//END
		
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
		Modules_modulesSecondPageMobile = new list<Module>();
		Modulen modul = new Modulen();
		system.debug('TrainingController Debug: isMobile '+isMobile);
		for(Training_Module__c TM:TMlist) {
			if(isMobile) {
				if(TM.active_mobile__c) {
					Module m = new Module(TM);
					for(Attachment att : atts) {
						if(att.ParentID == TM.ID) {
							m.backgroundImgPath = '/servlet/servlet.FileDownload?file='+att.ID;
							break;
						}
					}
					Modules_modulesSecondPageMobile.add(m);
				}		
			}else{
				if(i<5)
					Modules_modulesSecondPage1.add(TM);
				else {
					modul.Module.add(TM);
					if(modul.Module.size()==5) {
						Modules_modulesSecondPage2.add(modul);
						modul = new Modulen();
					}			
				}
			}
			i++;
		}
		if(modul.Module.size()>0) {
			Modules_modulesSecondPage2.add(modul);
			modul = new Modulen();
		}
		
		return true;
	}
	//END -----------------------------------------------------------------------------------------
	
	public PageReference secondPage(){
		String param;
		//PageReference pageRef = Page.page;
		PageReference pageRef = ApexPages.currentPage();
		
		if (pageRef.getParameters().containsKey('param')) param = pageRef.getParameters().get('param');
		system.debug('Param: '+param+ ' / pageRef:'+ ApexPages.currentPage());
		Modules_showFirstpage = false;
		Modules_showProcesspage = false; 
		Modules_showThirdpage = false;
		list<Training_Book__c> TB= new list<Training_Book__c>([select id, Titel__c, Subtitel__c, Beschreibung__c from Training_Book__c where Gigaset_Pro__c =: isPro AND Portal__c =:portal AND Aktiv__c = true ORDER by Sortierung__c]);
		
		for(Training_Book__c b:TB) {
			if(b.Titel__c == param) {
				Modules_book = b;
				break;
			}

		}
		list<Training_Module__c> TMlist = new list<Training_Module__c>([select id, Titel__c, Active_Mobile__c, Beschreibung__c, Training_Book__c, showTick__c, showCoins__c, Dauer__c, Punkte__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: isPro AND Training_Book__r.Portal__c =:portal AND Training_Book__c =: Modules_book.Id AND Aktiv__c = true ORDER by Sortierung__c]);
		
		// FOR MOBILE
		set<ID> moduleIDs = new set<ID>();
		for(Training_Module__c tm : TMList)
			if(!moduleIDs.contains(tm.ID))
				moduleIDs.add(tm.ID);
				
		if(moduleIDs.size() > 0) {
			atts = [Select Name, ParentID, Body From Attachment Where ParentID IN :moduleIDs AND Name Like '%mobile%'];
		}
		//END
		
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
		Modules_modulesSecondPageMobile = new list<Module>();
		Modulen modul = new Modulen();
		system.debug('TrainingController Debug: isMobile '+isMobile);
		for(Training_Module__c TM:TMlist) {
			if(isMobile) {
				if(TM.active_mobile__c) {
					Module m = new Module(TM);
					for(Attachment att : atts) {
						if((att.ParentID+'').contains(TM.ID)) {
							m.backgroundImgPath = '/servlet/servlet.FileDownload?file='+att.ID;
							break;
						}
					}
					Modules_modulesSecondPageMobile.add(m);
				}		
			}else{
				if(i<5)
					Modules_modulesSecondPage1.add(TM);
				else {
					modul.Module.add(TM);
					if(modul.Module.size()==5) {
						Modules_modulesSecondPage2.add(modul);
						modul = new Modulen();
					}			
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
	
	public PageReference showMobileModule() {
		PageReference ref;
		try {
			ref = initModuleResult();
			ref = showModule();
			isLektoraLoaded = true;
		} catch(Exception e) {
			isLektoraLoaded = false;
		}
		ref = new PageReference(Mobile_LektoraURL);
		
		system.debug('Native URL: '+Modules_LektoraURL);
		system.debug('Mobile URL: '+Mobile_LektoraURL);
		system.debug('REF URL: '+ref.getURL());
		
		return ref;
	}
	
	public PageReference showModule(){
		String param = ApexPages.currentPage().getParameters().get('moduleId');
		system.debug(param);
		system.debug('isMobile: '+isMobile);
		Modules_Param = param;
		
		Modules_showFirstpage = false;
	
		Modules_SingleModule = [select id, Bild_URL__c, Titel__c, Beschreibung__c, Dauer__c, URL__c, Mobile_URL__c, Punkte__c, Sortierung__c, Training_Book__c, Verwandtes_Modul_1__c, Verwandtes_Modul_2__c, Verwandtes_Modul_3__c, Verwandtes_Modul_4__c, Verwandtes_Modul_Name_1__c, Verwandtes_Modul_Name_2__c, Verwandtes_Modul_Name_3__c, Verwandtes_Modul_Name_4__c from Training_Module__c where Id =: param];
		
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
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Beschreibung__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: isPro AND Training_Book__r.Portal__c =:portal AND Training_Book__c =: Modules_SingleModule.Training_Book__c AND Aktiv__c = true ORDER by Sortierung__c]);

		
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
		if(isMobile)
			secrettext = moduleId + '-' + contactId + '-' + nowTime + '-' + Modules_SingleModule.Mobile_URL__c + '-' + SECRET;
		
		String Code = DEInterfaceLinks.generateStringTestTraining(secrettext);

		
		Modules_LektoraURL = 'https://training.gigaset.com/relay/open_lectora_course.php?Closed='+ Code +'&modulId='+moduleId+'&ContactId='+contactId+'&timestamp='+nowTime+'&target='+Modules_SingleModule.URL__c ;
		Mobile_LektoraURL  = 'https://training.gigaset.com/relay/open_lectora_course.php?Closed='+ Code +'&modulId='+moduleId+'&ContactId='+contactId+'&timestamp='+nowTime+'&target='+Modules_SingleModule.Mobile_URL__c ;
		
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
		//if (modules==null) modules=new list<Modulen>();
		
		modules.clear();
		User u = [select id, Contact.Erfolgreiche_Ergebnisse__c, Contact.Gesamt_Ergebnis__c from User where Id=:UserInfo.getUserId()];
		Modules_currentSuccess = u.Contact.Erfolgreiche_Ergebnisse__c.intValue();
		Modules_currentpoint = u.Contact.Gesamt_Ergebnis__c.intValue();
		list<Training_Book__c> TBlist= new list<Training_Book__c>([select id, Titel__c from Training_Book__c where Gigaset_Pro__c =: isPro AND Portal__c =:portal AND Aktiv__c = true ORDER by Sortierung__c]);
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c from Training_Module__c where neues_modul__c = true AND Training_Book__r.Gigaset_Pro__c =: isPro AND Training_Book__r.Portal__c =:portal AND Aktiv__c = true ORDER by Sortierung__c]);
		list<Training_Module__c> TMlist_full= new list<Training_Module__c>([select id from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: isPro AND Training_Book__r.Portal__c =:portal AND Aktiv__c = true ORDER by Sortierung__c]);
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
		String browser = ApexPages.currentPage().getParameters().get('browser');
		String os = ApexPages.currentPage().getParameters().get('os');
		System.debug('##################### Browser: '+browser+' ##########################');
		System.debug('##################### OS: '+os+' ##########################');
		System.debug('##################### Method: initModuleResult ##########################');
		User u = [select id, ContactId from User where Id=:UserInfo.getUserId()];
		String contactID = u.ContactId;
		contactID = contactID.substring(0,15);
		Modules_Param = Modules_Param==null?ApexPages.currentPage().getParameters().get('moduleId'):Modules_Param;
		
		if (Modules_SingleModule==null) Modules_SingleModule = [select id, Bild_URL__c, Titel__c, Beschreibung__c, Dauer__c, URL__c, Punkte__c, Sortierung__c, Training_Book__c, Verwandtes_Modul_1__c, Verwandtes_Modul_2__c, Verwandtes_Modul_3__c, Verwandtes_Modul_4__c, Verwandtes_Modul_Name_1__c, Verwandtes_Modul_Name_2__c, Verwandtes_Modul_Name_3__c, Verwandtes_Modul_Name_4__c from Training_Module__c where Id =: Modules_Param];
		String moduleID = Modules_SingleModule.ID;
		moduleID = moduleID.substring(0,15);
		Date actualDate = system.now().date();
		
		list<Training_Ergebnis__c> results = [select id, Training_Modul__c, Tries__c, Completion_Status__c from Training_Ergebnis__c where Training_Modul__c = :moduleID AND Kontakt__c = :contactID];
		Training_Ergebnis__c item;
		
		if(results.size() == 0){
			System.debug('No result found. Needed to create new one with init values!');
			item = new Training_Ergebnis__c(Training_Modul__c = moduleID, Kontakt__c = contactID, Browser__c = (browser!=null?browser:''), Operation_System__c = (os!=null?os:''), ErgebnisID__c = moduleID+''+contactID, Last_Click__c = actualDate, Tries__c = 0);
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
	
	public PageReference initMobileHome() {
		Modules_showThirdpage = false;
	 	Modules_showProcesspage = false;
		Modules_showFirstpage = true;
		if(UserInfo.getOrganizationId() == '00D20000000M2NzEAK') //liveId
			Modules_URLPage = Page.page.getUrl() + '?pageid=' + System_Settings.TrainingId;
		else
			Modules_URLPage = '/np/' + Page.page.getUrl() + '?pageid=' + System_Settings.TrainingId;
		Cookie TopShop;
		u0 = [select Contact.Id, Contact.firstname, Contact.lastname, Contact.Salutation from User where Id=:UserInfo.getUserId()];
	    try {
	    	c0 = [select firstname, lastname, toLabel(Salutation) from Contact where Id =: u0.Contact.Id];
	    } catch(exception e) {}
	    
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
	 		System_Settings.showNextTopShop=false;
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
		    			camp = [select id, EndDate, StartDate, isActive from Campaign where RecordType.Name = 'Top Shop' AND Portal__c =: portal AND isPro__c =: isPro AND EndDate >= TODAY AND StartDate <= TODAY AND isActive = True limit 1]; 
		    		}
		    		catch(exception e){}
		    		if(camp != null)
		    			System_Settings.showNextTopShop=true;
		    		else
		    			System_Settings.showNextTopShop=false;
			}		
	 	}
	 	
	 	if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	return null;
	}
	
	public PageReference initHome() {
	 	Modules_showThirdpage = false;
	 	Modules_showProcesspage = false;
		Modules_showFirstpage = true;
		if(UserInfo.getOrganizationId() == '00D20000000M2NzEAK') //liveId
			Modules_URLPage = Page.page.getUrl() + '?pageid=' + System_Settings.TrainingId;
		else
			Modules_URLPage = '/np/' + Page.page.getUrl() + '?pageid=' + System_Settings.TrainingId;
		Cookie TopShop;
		u0 = [select Contact.Id, Contact.firstname, Contact.lastname, Contact.Salutation from User where Id=:UserInfo.getUserId()];
	    try {
	    	c0 = [select firstname, lastname, toLabel(Salutation) from Contact where Id =: u0.Contact.Id];
	    } catch(exception e) {}
	    
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
	 		System_Settings.showNextTopShop=false;
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
		    			camp = [select id, EndDate, StartDate, isActive from Campaign where RecordType.Name = 'Top Shop' AND Portal__c =: portal AND isPro__c =: isPro AND EndDate >= TODAY AND StartDate <= TODAY AND isActive = True limit 1]; 
		    		}
		    		catch(exception e){}
		    		if(camp != null)
		    			System_Settings.showNextTopShop=true;
		    		else
		    			System_Settings.showNextTopShop=false;
			}		
	 	}
	 	
	 	if (!System_Settings.isPortalUser()) return System_Settings.redirectToLogin();
	 	if (!ApexPages.currentPage().getParameters().containsKey('pageid')) return System_Settings.goHome();
	 	if (System_Settings.isPortalUser() && portal!=System_Settings.getPortalByPageId()) return System_Settings.goHome();
	 	return null; 
	 }
	 
	public String ModulesURLPage(){
		return Modules_URLPage;
	}
	
	public pageReference getRecentNewsId() {
	 	newsid=ApexPages.currentPage().getParameters().get('newsid');
	 	return null;
	}
	 
	 	
	public String getCampus_Title_1() {
		return System_Settings.getLabel('Campus_Title_1');
	}
	
	public String getCampus_Welcome() {
		return System_Settings.getLabel('Campus_Welcome');
	}
	
	public String getCampus_main_Description1() {
		return System_Settings.getLabel('Campus_main_Description1');
	}
	
	public String getCampus_main_Description2() {
		return System_Settings.getLabel('Campus_main_Description2');
	}
	
	public String getCampus_1_Title() {
		return System_Settings.getLabel('Campus_1_Title');
	}
	
	public String getCampus_2_Title() {
		return System_Settings.getLabel('Campus_2_Title');
	}
	
	public String getCampus_3_Title() {
		return System_Settings.getLabel('Campus_3_Title');
	}
	
	global static String getCampus_4_Title() {
		return System_Settings.getLabel('Campus_4_Title');
	}
	
	global static String getCampus_underTitle() {
		return System_Settings.getLabel('Campus_underTitle');
	}
	
	global static String getCampus_smallBox1() {
		return System_Settings.getLabel('Campus_smallBox1');
	}
	
	global static String getCampus_smallBox2() {
		return System_Settings.getLabel('Campus_smallBox2');
	}
	
	global static String getCampus_smallBox3() {
		return System_Settings.getLabel('Campus_smallBox3');
	}
	
	global static String getCampus_smallBox4() {
		return System_Settings.getLabel('Campus_smallBox4');
	}
	
	global static String getCampus_otherPage1() {
		return System_Settings.getLabel('Campus_otherPage1');
	}
	
	global static String getCampus_otherPage2() {
		return System_Settings.getLabel('Campus_otherPage2');
	}
	
	global static String getCampus_otherPage3() {
		return System_Settings.getLabel('Campus_otherPage3');
	}
	
	global static String getCampus_otherPage4() {
		return System_Settings.getLabel('Campus_otherPage4');
	}
	
	global static String getCampus_otherPage5() {
		return System_Settings.getLabel('Campus_otherPage5');
	}
	
	global static String getCampus_otherPage6() {
		return System_Settings.getLabel('Campus_otherPage6');
	}
	
	global static String getCampus_lastPage1() {
		return System_Settings.getLabel('Campus_lastPage1');
	}
	
	global static String getCampus_lastPage2() {
		return System_Settings.getLabel('Campus_lastPage2');
	}
	
}