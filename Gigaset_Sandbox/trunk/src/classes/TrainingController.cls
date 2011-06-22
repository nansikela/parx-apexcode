global class TrainingController {
	
	global static Integer Modules_currentSuccess;
	global static String Modules_URLPage;
	global static String Modules_Param;
	global static Integer Modules_total;
	global static Integer Modules_currentpoint;
	global static Double Modules_currentbar;
	global static boolean Modules_showFirstpage;
	global static boolean Modules_showThirdpage;
	global static String Modules_LektoraURL;
	global static Training_Book__c Modules_book;
	global static list<Training_Module__c> Modules_modulesSecondPage1;
	global static Training_Module__c Modules_SingleModule;
   	global static List<Modulen> Modules = new list<Modulen>(); 
    global static List<Modulen> Modules_modulesSecondPage2;
	global static List<Booken> Books = new list<Booken>(); 
	global static String newsid;
	  
	global static User u0{get;set;}
	global static Contact c0 {get;set;}
	global static String firstName {get;set;}
	global static String lastName {get;set;}
	global static String salutation {get;set;}
	
	global static NextTopShop__c NTS;
	global static PageReference CMSpage = Page.page;
	 
	
	global class Modulen {
		public list<Training_Module__c> Module {get; set;}
		public integer ModuleNumber {get;set;}
		public boolean renderScroller {get;set;}
		public Modulen() {
  			Module=new list<Training_Module__c>();
  		}
	}

	global class Booken {
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
	
	public TrainingController(TemplateController templateCtrl){

		u0 = templateCtrl.u0;
		c0 = templateCtrl.c0;
	}
	
	global static list<Booken> getBooks(){
		list<Training_Book__c> TB= new list<Training_Book__c>([select id, Buchhaenger__c,New_Modules__c, Titel__c from Training_Book__c where Gigaset_Pro__c =: System_Settings.isPro AND Portal__c =:System_Settings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		Integer i = 0;
		Books = new list<Booken>(); 
		Booken book;
		for(Training_Book__c b:TB) {
			book = new Booken();
			book.Book = b;
			Books.add(book);
		}
		
		for(Booken b : TrainingController.Books) {
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
					b.Helfer4 = 50;
					b.Helfer_BH_Vertical = 60;
					b.Helfer5 = '0.34202014, 0.93969262, -0.93969262, 0.34202014';
					b.Helfer6 = 'M11=0.34202014, M12=-0.93969262, M21=0.93969262, M22=0.34202014';
					b.Helfer3 = 335;
					b.Helfer8 = -45; 
					b.Helfer9 = 100;
				}
				else {
					b.Helfer8 = -70;
					b.Helfer2 = 65;
					b.Helfer4 = 48;
					b.Helfer_BH_Vertical = 48;
					b.Helfer5 = '0.00000000, 1.00000000, -1.00000000, 0.00000000';
					b.Helfer6 = 'M11=0.00000000, M12=-1.00000000, M21=1.00000000, M22=0.00000000';
				}
			i++;
		}

		return Books;
	}
	
	global static PageReference firstPage(){
		Modules_showFirstpage = true;
		Modules_showThirdpage = false;
		return null;
	}
	
	global static PageReference Poller(){
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
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: System_Settings.isPro AND Training_Book__r.Portal__c =:System_Settings.Portal AND Training_Book__c =: Modules_SingleModule.Training_Book__c AND Aktiv__c = true ORDER by Sortierung__c]);

		
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
	
	global static PageReference secondPage(){
		String param = ApexPages.currentPage().getParameters().get('param');
		Modules_showFirstpage = false;
		Modules_showThirdpage = false;
		list<Training_Book__c> TB= new list<Training_Book__c>([select id, Titel__c, Subtitel__c, Beschreibung__c from Training_Book__c where Gigaset_Pro__c =: System_Settings.isPro AND Portal__c =:System_Settings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		
		for(Training_Book__c b:TB) {
			if(b.Titel__c == param) {
				Modules_book = b;
				break;
			}

		}
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: System_Settings.isPro AND Training_Book__r.Portal__c =:System_Settings.Portal AND Training_Book__c =: Modules_book.Id AND Aktiv__c = true ORDER by Sortierung__c]);

		
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
	
	global static PageReference showModule(){
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
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c, showTick__c, showCoins__c  from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: System_Settings.isPro AND Training_Book__r.Portal__c =:System_Settings.Portal AND Training_Book__c =: Modules_SingleModule.Training_Book__c AND Aktiv__c = true ORDER by Sortierung__c]);

		
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
	
	global static list<Modulen> getModules(){
		modules.clear();
		User u = [select id, Contact.Erfolgreiche_Ergebnisse__c, Contact.Gesamt_Ergebnis__c from User where Id=:UserInfo.getUserId()];
		Modules_currentSuccess = u.Contact.Erfolgreiche_Ergebnisse__c.intValue();
		Modules_currentpoint = u.Contact.Gesamt_Ergebnis__c.intValue();
		list<Training_Book__c> TBlist= new list<Training_Book__c>([select id, Titel__c from Training_Book__c where Gigaset_Pro__c =: System_Settings.isPro AND Portal__c =:System_Settings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		list<Training_Module__c> TMlist= new list<Training_Module__c>([select id, Titel__c, Training_Book__c from Training_Module__c where neues_modul__c = true AND Training_Book__r.Gigaset_Pro__c =: System_Settings.isPro AND Training_Book__r.Portal__c =:System_Settings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
		list<Training_Module__c> TMlist_full= new list<Training_Module__c>([select id from Training_Module__c where Training_Book__r.Gigaset_Pro__c =: System_Settings.isPro AND Training_Book__r.Portal__c =:System_Settings.Portal AND Aktiv__c = true ORDER by Sortierung__c]);
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
	
	global static PageReference initModuleResult(){
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
	
	global static PageReference initHome() {
	 	Modules_showThirdpage = false;
		Modules_showFirstpage = true;
		if(UserInfo.getOrganizationId() == '00D20000000M2NzEAK') //liveId
			Modules_URLPage = CMSpage.getUrl() + '?pageid=' + SystemSettings.TrainingId;
		else
			Modules_URLPage = '/np/' + CMSpage.getUrl() + '?pageid=' + System_Settings.TrainingId;
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
		    			camp = [select id, EndDate, StartDate, isActive from Campaign where RecordType.Name = 'Top Shop' AND Portal__c =: System_Settings.Portal AND isPro__c =: System_Settings.isPro AND EndDate >= TODAY AND StartDate <= TODAY AND isActive = True limit 1]; 
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
	 	if (System_Settings.isPortalUser() && System_Settings.portal!=System_Settings.getPortalByPageId()) return System_Settings.goHome();
	 	return null; 
	 }
	 
	global static String ModulesURLPage(){
		return Modules_URLPage;
	}
	
	global static pageReference getRecentNewsId() {
	 	newsid=ApexPages.currentPage().getParameters().get('newsid');
	 	return null;
	}
	 
	 	
	global static String getCampus_Title_1() {
		return System_Settings.getLabel('Campus_Title_1');
	}
	
	global static String getCampus_Welcome() {
		return System_Settings.getLabel('Campus_Welcome');
	}
	
	global static String getCampus_main_Description1() {
		return System_Settings.getLabel('Campus_main_Description1');
	}
	
	global static String getCampus_main_Description2() {
		return System_Settings.getLabel('Campus_main_Description2');
	}
	
	global static String getCampus_1_Title() {
		return System_Settings.getLabel('Campus_1_Title');
	}
	
	global static String getCampus_2_Title() {
		return System_Settings.getLabel('Campus_2_Title');
	}
	
	global static String getCampus_3_Title() {
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