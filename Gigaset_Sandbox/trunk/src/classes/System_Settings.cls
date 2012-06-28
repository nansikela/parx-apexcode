global class System_Settings {
    // General Debug Mode
    global static final Boolean isDebug=false;
    global static Boolean isTest=false;
    //global static final String portal=Site.getCustomWebAddress()==null?'':Site.getCustomWebAddress().substring(7,9);
    //global static final String portal=Site.getCustomWebAddress()==null?'':Site.getCustomWebAddress().substring(9,10)=='.'?Site.getCustomWebAddress().substring(7,9):'';
    global static String portal=getPortalSign();
    //global static final String portal='se';
    global static final String PortalCountry=getPortalCountry();
    //global static final Boolean isPro=isPro();
    // beeing only in Cordless area this defaults to false
    global static final Boolean isPro=false;
    global static final Boolean isMobile = isMobileActivated();
    global static String contactid='';
    static String language='de'; 
    global static String baseurl='http://gigaset.com/';
    global static User currentuser;
    global static Contact currentusercontact;
    global static Account currentuseraccount;
    global static GlobalSettings__c landing_config;
	global static Cookie cookie = null;
	global static String remindPageId; 
	global static String popupPageId;
	global static Boolean popupIsPDF = true;
	global static Boolean popupIsFlash = false;
	global static Boolean popupIsNative = false;
    // pageids
    global static final Id userdatapageid=getPageId('Benutzerdaten');
    global static final Id servicehotlineinfopageid=getPageid('ServiceHotline');
    global static final Id loginpageid=getPageid('Login');
    global static final Id rueckrufservicepageid=getPageid('Rueckrufservice');
    global static final Id forgotpasswordpageid=getPageid('PasswortVergessen');
    global static final Id registrationpageid=getPageid('Registrierung');
    global static final Id homepageid=getPageid('Home');
    global static final Id loginmobileid=getPageid('Login Mobile');
    global static final Id homemobileid=getPageid('Home Mobile');
    global static final Id imprintpageid=getPageid('Imprint');
    global static final Id privacyprotectionid=getPageId('PrivacyProtection');
    global static final Id termsOfUseid=getPageId('Terms of Use');
    global static final Id landing_page = getPageId('Landing'); 
    global static final Id newsreaderpageid=getPageId('NewsReader');
    
    // menu
    global static final Id kontaktpageid=getPageid('Kontakt');
    global static final Id link01pageid=getPageid('Link01');
    global static final Id link02pageid=getPageid('Link02');
    global static final Id link03pageid=getPageid('Link03');
    global static final Id link04pageid=getPageid('Link04');
    global static final Id link05pageid=getPageid('Link05');
    global static final Id link06pageid=getPageid('Link06');
    
    global static final Id TrainingId=getPageid('training');
    global static final Id ProgressId=getPageid('Progress');
    
    // interface
    global static final String picturemanagementLink = 'https://dam.gigaset.com/index.php?extra_login=';
    //global static final String picturemanagementLink = 'http://gigaset-dev.kurt.picturemanagement.de/index.php?extra_login=';
    //global static final String werbemittelLink = 'http://62.26.5.13/webstore30/scripts/anmeldung.asp?extra_login=';
    
    global static String addParam='';
    global static Boolean showNextTopShop;
    
    // System_Settings private methods
    private static Id getPageid(String name) {
		Id pid;
		if (portal==null || portal=='00') portal=getPortalSign();
		String original = portal;
		
		if((name == 'Home Mobile' || name == 'Login Mobile') && System_Settings.isMobile) {
			system.debug('Mobile is true');
			original = portal;
			portal = 'mobi';
			if(name == 'Home Mobile')
				name = 'Home';
			if(name == 'Login Mobile')
				name = 'Login';
		}
		
		System.debug('getpageid portal: ' + portal + ' / name: '+name);
		//try {
		//	pid=Id.valueOf([SELECT PageId__c FROM Pages__c WHERE Label__c=:name AND IsActive__c=true AND Portal__c=:portal AND isPro__c=:isPro].PageId__c);
		//} catch (System.Exception e) {}
		//if (pid==null) {
			for (Pages__c p: Pages__c.getAll().values()) {
				if (p.IsActive__c && p.Portal__c==portal && p.Label__c==name && p.isPro__c==isPro) pid=Id.valueOf(p.PageId__c);
			}
		//}
		
		portal = original; 
		return pid;
	}
	
    public static String getPortalByPageId() {
    	if (System.currentPageReference()!=null && System.currentPageReference().getParameters().containsKey('pageid')) {
			for (Pages__c p: Pages__c.getAll().values()) {
				if (Id.ValueOf(p.PageId__c)==Id.ValueOf(ApexPages.currentPage().getParameters().get('pageid'))) return p.Portal__c;
			}
			try {
				String pagename=[Select Id, Name FROM Page__c WHERE Id = :Id.valueOf(System.currentPageReference().getParameters().get('pageid'))].Name;
				return pagename.split('_').get(0);
			} catch (System.QueryException e) {
				return '';
			}
		} else return '';
    }
    
    private static String getPortalSign() {
        String sign='00';
        
        // get portal from authenticated user
        if (currentusercontact==null && System_Settings.isPortalUser()) {
        	currentusercontact=getContact(ContactId);
        }
        if (currentusercontact!=null && currentusercontact.Portal__c!=null) sign=currentusercontact.Portal__c;
       
        // get portal from parameter ONLY if page type of mobi 
        //IS NECESSARY BECAUSE MOBILE VERSION DISCARD THE ORIGINAL PORTAL SIGN AFTER REDIRECT FROM LANDING PAGE TO MOBILE_LOGIN!
        if (ApexPages.currentPage()!=null && ApexPages.currentPage().getParameters().containsKey('pageid') && ApexPages.currentPage().getParameters().get('portal') != null && sign=='00') {
			for (Pages__c p: Pages__c.getAll().values()) {
				if (Id.ValueOf(p.PageId__c)==Id.ValueOf(ApexPages.currentPage().getParameters().get('pageid'))) 
					if(p.Portal__c == 'mobi')
						sign = ApexPages.currentPage().getParameters().get('portal');
			}
		}
		
		// get portal from page
		if (System.currentPageReference()!=null && System.currentPageReference().getParameters().containsKey('pageid') && sign=='00') {
			for (Pages__c p: Pages__c.getAll().values()) {
				if (Id.ValueOf(p.PageId__c)==Id.ValueOf(ApexPages.currentPage().getParameters().get('pageid'))) sign=p.Portal__c;
			}
		}
		System.debug('Found Portal 1: ' + sign);
		
		// get portal from parameter
		if (System.currentPageReference()!=null && System.currentPageReference().getParameters().containsKey('portal') && sign=='00') {
			// prevent sql injection, only values configured in globalSettings are allowed
			//sign=System.currentPageReference().getParameters().get('portal');
			for (GlobalSettings__c gs: GlobalSettings__c.getAll().values()) {
				if (gs.Portal__c==System.currentPageReference().getParameters().get('portal')) {
					sign=System.currentPageReference().getParameters().get('portal');
					break;
				}
			}
		}
		System.debug('Found Portal 2: ' + sign);
		
		// get portal form custom webaddress
		if (Site.getCustomWebAddress()!=null) System.debug('####### CustomWebAddress: ' + Site.getCustomWebAddress() + ' / substring: ' + Site.getCustomWebAddress().substring(7,9));
		if (Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().substring(9,10)=='.' && sign=='00')
			return Site.getCustomWebAddress().substring(7,9);
		else if (Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().substring(11,12)=='.' && sign=='00')
			return Site.getCustomWebAddress().substring(7,11);
		System.debug('Found Portal 3: ' + sign);
		
		// get portal from site name
		if (Site.getName()!=null && sign=='00') {
			if (Site.getName().toLowerCase().contains('pro'))
				return Site.getName().substring(0,Site.getName().toLowerCase().indexOf('pro')).toLowerCase();
			else
				return Site.getName().toLowerCase();
		}
		System.debug('Found Portal 4: ' + sign + ' / SiteName: '+Site.getName());
		 
		// get portal form existing url
		if ((sign==null || sign=='00') && ApexPages.currentPage()!=null && ApexPages.currentPage().getUrl()!=null) sign=ApexPages.currentPage().getUrl().substring(ApexPages.currentPage().getUrl().length()-2);
		System.debug('Found Portal 5: ' + sign);
		
		return sign;
    }
    
    public static Boolean isMobileActivated() {
		Boolean isActive = false;
		String userAgent = '';
		Boolean m = false;
		try {
			userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
			String device = ApexPages.currentPage().getParameters().get('device');
		
			if(userAgent == null || Site.getName() != 'Mobi')
				return m;
		  
			m = (userAgent.contains('iPhone') || device == 'mobile');
			if(!m)
				m = (userAgent.contains('iPad') && device != 'mobile');
			if(!m)
				m = (userAgent.contains('Android') || device == 'mobile');
		}catch(Exception e) {
			system.debug(e);
		}
		system.debug('Is mobile active: '+m);
		return m;
    }
    
    private static Boolean isPro() {
        if (Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().contains('pro'))
            return true;
        else
            return false;
    }
    
    private static User getCurrentUser() {
        if (currentuser==null) {
            if (UserInfo.getUserId()!=null) 
                        currentuser=[SELECT Id, 
                        Lastname, 
                        Firstname, 
                        Email, 
                        UserType, 
                        ContactId,
                        MobilePhone_Kontakt__c, 
                        Title_Kontakt__c, 
                        Salutation_Kontakt__c,
                        Fax_Kontakt__c, 
                        Anmeldung_Telefon__c, 
                        Anmeldung_Hotlinetelefon__c, 
                        Sonstige_Telefonnummer__c,
                        Anmeldung_Mobiltelefon__c, 
                        Funktion__c, 
                        Info_per_Email__c,
                        Info_per_Post__c, 
                        Interne_Abteilungsbezeichnung__c,
                        Status__c, 
                        Telefon_Kontakt__c, 
                        Abteilung_Auswahl__c,
                        MailingCity_Kontakt__c, 
                        MailingStreet_Kontakt__c, 
                        MailingCountry_Kontakt__c, 
                        MailingState_Kontakt__c, 
                        MailingPostalCode_Kontakt__c,
                        Pro_Partner_Typ__c, 
                        In_Freischaltung__c,
                        PRO_VAR_MITARBEITERTZAHL__c,
                        PRO_VAR_ANZ_SUPPORT__c,
                        PRO_VAR_KUNDEN_MA_ANZ__c,
                        PRO_VAR_SCHWERPUNKT__c,
                        PRO_VAR_SCHWERPUNKT_ANDERER__c,
                        PRO_VAR_ERFAHRUNGEN__c,
                        PRO_SYSTEM_LIEFERANTEN__c,
                        PRO_VAR_SYSTEMPARTNER_WEITERE__c,
                        Pro_Distribution__c,
                        Description__c,
                        IsPortalEnabled, 
                        IsActive
                        FROM User WHERE Id =:UserInfo.getUserId()];
            System.debug('######################## Current User: '+currentuser.Id);
            if (currentuser!=null) {
                if (currentuser.ContactId!=null)
                    contactid=currentuser.contactid;
            }
        }
        return currentuser;
    }

    
    // systemwide methods
    global static Boolean isPortalUser() {
        currentuser = getCurrentUser();
        if (currentuser!=null) {
            return currentuser.IsPortalEnabled;
        }
        else return false;
    }
    
    // the preset should only be visible for crd at the moment
    // the condition is restricted to Cordless, so it does not work for isPro=true!
    global static Boolean showPreset() {
    	// if (System_Settings.contactid!=null && System_Settings.contactid!='' && System_Settings.portal=='de' && !System_Settings.isPro) {
    	if (System_Settings.contactid==null || System_Settings.contactid=='')
    		System_Settings.contactid=System_Settings.getCurrentUser().ContactId;
    	System.debug('showPreset: contactid ' + System_Settings.contactid);
        if (contactid!=null && contactid!='' && !isPro) {
        	if (currentusercontact==null) currentusercontact=getContact(contactid);
        if (currentusercontact!=null && System_Settings.contactid!=null && System_Settings.contactid!='' && !isPro)
            if (currentusercontact!=null && currentusercontact.AccountId!=null ) {
                if (currentuseraccount==null) currentuseraccount=getAccount(currentusercontact.AccountId);
                if (currentuseraccount!=null && 
					(currentuseraccount.Handelskanal__c==null || currentuseraccount.Handelskanal__c=='')
					) return true;
            }
        }
        return false;
    }
    
    global static Boolean showPrivacy() {
    	System.debug('showprivacy privacyprotectionid: ' + privacyprotectionid);
        if (privacyprotectionid==null) return false;
        Boolean privacyEnabled=false;
        System.debug('showprivacy portal: ' + portal);
        for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
            if (gs.Portal__c==portal && gs.isPro__c==isPro ) privacyEnabled=gs.Datenschutzabfrage__c;
        }
        System.debug('showprivacy privacyEnabled: ' + privacyEnabled);
        if (privacyEnabled && System_Settings.contactid==null || System_Settings.contactid=='')
    		System_Settings.contactid=System_Settings.getCurrentUser().ContactId;
    	System.debug('showPrivacy: contactid ' + System_Settings.contactid);
        if (System_Settings.contactid!=null && System_Settings.contactid!='' && privacyEnabled) {
        	if (currentusercontact==null) currentusercontact=getContact(contactid);
            if (currentusercontact!=null && (currentusercontact.Datenschutzerkl_rung_zugestimmt__c==null || !currentusercontact.Datenschutzerkl_rung_zugestimmt__c)) {
               return false; //Privacy Approval is for already registered users not required anymore. - Date: 14.06.12
            }
        }
        return false;
    }
    
    global static Boolean showPrivacyAnonymous() {
        if (privacyprotectionid==null) return false;
        for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
            if (gs.Portal__c==portal && gs.isPro__c==isPro ) return gs.Datenschutzabfrage__c;
        }
        return false;
    }
    
    global static Boolean showClearing() {
    	if (System_Settings.contactid==null || System_Settings.contactid=='')
    		System_Settings.contactid=System_Settings.getCurrentUser().ContactId;
    	System.debug('showClearing: contactid ' + System_Settings.contactid);
        if (System_Settings.contactid!=null && System_Settings.contactid!='') {
            if (currentusercontact==null) currentusercontact=getContact(contactid);
            if (currentusercontact!=null /*&& currentusercontact.AccountId!=null*/) {
                if (isPro && !currentusercontact.Gigaset_Pro__c && currentusercontact.Gigaset_Extranet__c) return true;
                if (!isPro && !currentusercontact.Gigaset_Extranet__c && currentusercontact.Gigaset_Pro__c) return true;
            }
        }
        return false;
    }
    
    global static Boolean showPmLink() {
        for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
            if (gs.Portal__c==portal && gs.isPro__c==isPro ) return gs.Picturemanagement_available__c;
        }
        return false;
    }
    
    global static PageReference goHome() {
        PageReference homepage = null;
		homepage = new PageReference(Page.page.getUrl() + '?pageid=' + homepageid);	
        homepage.setRedirect(true);
        return homepage;
    }
    
    global static String setLanguage() {
        for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
			if (gs!=null && gs.Portal__c==portal && gs.isPro__c==isPro && gs.Sprache__c!=null) language=gs.Sprache__c;
		}
        return language;
    }
    
    public static PageReference redirectToLogin() {
        try {
        System.debug('redirectToLogin start: mobile? '+isMobile + ' language? '+language);
		Boolean isAlreadyLoginPage=false;
        
        PageReference login = null;
        PageReference basispage=Page.page;
        if(!isMobile) {
			if (cookie != null) {	
        		if(System_Settings.landing_config == null){
        			List<GlobalSettings__c> res = [SELECT Name, Landing_Page_Aktivierung__c, Portal__c, isPro__c FROM GlobalSettings__c WHERE Portal__c = :portal AND IsPro__c = :isPro LIMIT 1];
        			if(res.size() > 0)
        				System_Settings.landing_config = res.get(0);
        		}
 				if (System_Settings.landing_config != null && cookie.getValue().equals('1') && System_Settings.landing_config.Landing_Page_Aktivierung__c){
					login = new PageReference( basispage.getUrl() + '?pageid=' + getPageid('Landing')+ addParam);
       		 		CRD_Landing_Controller.landingpage_already_visited();
       		 	}
       		 	
    		} else {
        		isAlreadyLoginPage=true;
    		}
        } else {
        	addParam += '&portal='+portal;	
        }
            
       	if(login == null){
        	login = new PageReference( basispage.getUrl() + '?pageid=' + (isMobile?loginmobileid:loginpageid) + addParam);
        }
        System.debug('loginpageid: ' + loginpageid);
        login.setRedirect(true);
        if (ApexPages.currentPage()==login) { isAlreadyLoginPage=true; system.debug('ApexPages.currentPage()==login : true');}
        if (ApexPages.currentPage().getParameters().containsKey('pageid') 
        	&& (isMobile?loginmobileid:loginpageid)!=null 
        	&& (Id.ValueOf(ApexPages.currentPage().getParameters().get('pageid'))==(isMobile?loginmobileid:loginpageid) 
        	|| (Id.ValueOf(ApexPages.currentPage().getParameters().get('pageid'))==getPageid('Landing') && !isMobile))
        	) { isAlreadyLoginPage=true; system.debug('long IF condition = true'); }
        	
        System.debug('redirectToLogin return: isAlreadyLoginPage ' + isAlreadyLoginPage + ' login is ' + login);
        if (isAlreadyLoginPage) return null;
        else return login;
        }catch(Exception e) {
        	system.debug(e.getStackTraceString());
        	return null;
        }
    }
    
    public static PageReference redirectDirectlyToLogin() {
        
        PageReference basispage=Page.page;
        PageReference login = new PageReference( basispage.getUrl() + '?pageid=' + loginpageid + addParam);
        
        login.setRedirect(true);
        Boolean isAlreadyLoginPage=false;
        if (ApexPages.currentPage()==login) isAlreadyLoginPage=true;
        if (ApexPages.currentPage().getParameters().containsKey('pageid') && (ApexPages.currentPage().getParameters().get('pageid').startsWith(loginpageid) )) isAlreadyLoginPage=true;
        
        if (isAlreadyLoginPage) return null;
        else return login;
    }

	/* not needed anymore */
	/*
    public static PageReference init() {
        if (ApexPages.currentPage().getParameters().containsKey('pid')) addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
        if (ApexPages.currentPage().getParameters().containsKey('pid')) addParam=addParam + '&newsid='+ApexPages.currentPage().getParameters().get('newsid');
        System.debug(addParam);
        
        if (!isPortalUser()) return redirectToLogin();
        return null;
    }
    */
    // not used, if you want to acivate this again please take care of isPro!
    //global static String getLabelByName(String name) {
    //  setLanguage();
    //  return CustomLabel__c.getValues(name).Label__c;
    //}
    
    global static String getLabel(String ccode) {
        String label='';
        for (CustomLabel__c cl:CustomLabel__c.getAll().values()) {
            if (cl.CommonCode__c==ccode && cl.Portal__c==portal && cl.LanguageCode__c==setLanguage() && cl.isPro__c==isPro) label=cl.Label__c;
        }
        
        return label;
    }
    
    private static String getPortalCountry() {
		String ctry='Germany';
		if (portal==null || portal=='') portal=getPortalSign();
		for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
			if (gs.Portal__c==portal && gs.isPro__c==(Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().contains('pro')) ) 
				ctry=gs.CountryForRegistration__c;
		}
		return ctry;
	}
    
    global static String getCurrentNavigationPointLabel(String pid) {
    	Id pageid;
		if (pid!=null) {
			try {
				pageid=Id.valueOf(pid);
			} catch (System.Exception e) {}
		}
        // portal specific labels/navigationpoints
        if (pageid==homepageid|| (Site.getPrefix()!=null && Site.getPrefix().contains('Home'))) return getLabel('home');
        if (newsreaderpageid!=null && pageid==newsreaderpageid) return getLabel('NewsReader');
        if (link01pageid!=null && pageid==link01pageid) return getLabel('link01');
        if (link02pageid!=null && pageid==link02pageid) return getLabel('link02');
        if (link03pageid!=null && pageid==link03pageid) return getLabel('link03');
        if (link04pageid!=null && pageid==link04pageid) return getLabel('link04');
        if (link05pageid!=null && pageid==link05pageid) return getLabel('link05');
        if (link06pageid!=null && pageid==link06pageid) return getLabel('link06');
        //if (werbemittelpageid!='' && pageid.startsWith(werbemittelpageid)) return getLabel('Werbemittel');
        // cross portal navigation points
        if (imprintpageid!=null && pageid==imprintpageid) return System.Label.tplt_label_imprint;
        if (kontaktpageid!=null && pageid==kontaktpageid) return System.Label.contact;
        if (userdatapageid!=null && pageid==userdatapageid) return System.Label.userdata_your_userdata;
        if (loginpageid!=null && pageid==loginpageid) return System.Label.loginpage;
        if (registrationpageid!=null && pageid==registrationpageid) return System.Label.registration;
        if (rueckrufservicepageid!=null && pageid==rueckrufservicepageid) return System.Label.callback;
        if (forgotpasswordpageid!=null && pageid==forgotpasswordpageid) return System.Label.forgotpassword_forgot_password;
        //if (Site.getPrefix()!=null && Site.getPrefix().contains('ChangePassword')) return Label.changepw_changepw;
        //if (ApexPages.currentPage().getUrl().contains('ChangePassword')) return Label.changepw_changepw;
        if (System.currentPageReference().getUrl()!=null && System.currentPageReference().getUrl().contains('ChangePassword')) return System.Label.changepw_changepw;
        else return '';
    }
    
    global static String getExternalURL(String ccode){
        String label='';
        for (CustomLabel__c cl:CustomLabel__c.getAll().values()) {
            if (cl.CommonCode__c==ccode && cl.Portal__c==portal && cl.LanguageCode__c==setLanguage() && cl.isPro__c==isPro) label=cl.ExternalUrl__c;
        }
        
        return label;
    }
    
    global static void logError(String msg, String job, String comp, String errorid, String loglevel) {
        if (msg!=null) {
            System.debug('ErrorLog - Job: ' + job==null?'':job + ' Component: ' + comp==null?'':comp + ' loglevel: ' + loglevel + ' errorid: ' + errorid==null?'':errorid + ' Message: ' + msg);
            ErrorLog__c el=new ErrorLog__c();
            el.Message__c=msg.substring(0,msg.length()<254?msg.length():254);
            el.Job__c=job;
            el.Component__c=comp;
            el.ErrorIdText__c=errorid==null?'':errorid;
            el.LogLevel__c=loglevel;
            el.Portal__c = portal;
            try {
                insert el;
            } catch (System.Dmlexception e) {
                if (System_Settings.isDebug) throw e;
                // now we can't do more
            }
        }
    }
    
    global static void logError(String errorid, String PortalContact, String msg) {
        if (msg!=null) {
            System.debug(' errorid: ' + errorid==null?'':errorid + ' Message: ' + msg);
            ErrorLog__c el=new ErrorLog__c();
            el.Message__c=msg.substring(0,msg.length()<254?msg.length():254);
            el.ErrorIdText__c=errorid==null?'':errorid;
            el.Portal__c = PortalContact;
            el.Job__c='';
            
            try {
                insert el;
            } catch (System.Dmlexception e) {
                if (System_Settings.isDebug) throw e;
                // now we can't do more
            }
        }
    }
    
    // this method has to be in sync with the TransferUserdata Trigger
    // every new field has to be added to both functions!
    global static User getCurrentUpdatedUser() {
        // we want to be sure to get an update here
        currentuser=null;
        getCurrentUser();
        if (currentuser!=null) {
            if (currentuser.contactid!=null) {
                Contact c=getContact(currentuser.contactid);
                if (c!=null && c.AccountId!=null) {
                    Account a=getAccount(c.AccountId);
                    if (c!=null && a!=null) updateCurrentUser(c, a);
                }
            }
        }
        return currentuser;
    }
    
    private static Contact getContact(Id cid) {
        Contact c;
        try {
            c=[SELECT Id, 
                    Lastname, 
                    Firstname, 
                    Email, 
                    Phone, 
                    MobilePhone, 
                    AccountId,
                    Portal__c,
                    Title, 
                    Salutation, 
                    Anmeldung_Telefon__c, 
                    Anmeldung_Hotlinetelefon__c, 
                    Anmeldung_Mobiltelefon__c, 
                    Funktion__c, 
                    Info_per_Email__c,
                    Info_per_Post__c, 
                    Interne_Abteilungsbezeichnung__c,
                    Status__c, 
                    Abteilung_Auswahl__c, 
                    Fax,
                    MailingCity, 
                    MailingStreet,
                    MailingCountry, 
                    MailingState, 
                    MailingPostalCode,
                    Sonstige_Telefonnummer__c,
                    Account.Status__c,
                    Account.Name, 
                    Account.BillingStreet, 
                    Account.BillingCity, 
                    Account.BillingPostalCode, 
                    Account.BillingCountry,
                    Account.Handelskanal__c,
                    Account.Distribution__c,
                    Account.Pro_Distribution__c,
                    Zustimmung_Datenschutzerkl_rung_am__c,
                    Datenschutzerkl_rung_zugestimmt__c,
                    In_Freischaltung__c, 
                    Gigaset_Extranet__c, 
                    Gigaset_Pro__c
                    FROM Contact WHERE Id=:cid];
        } catch (System.QueryException e) {
            logError(cid!=null?String.valueOf(cid):'',portal,e.getMessage());
            if (isDebug) throw e;
        }
        return c;
    }
    
    private static Account getAccount(Id aid) {
        Account a;
        try {
            a=[SELECT Id, 
                PRO_VAR_MITARBEITERTZAHL__c, 
                PRO_VAR_ANZ_SUPPORT__c, 
                PRO_VAR_KUNDEN_MA_ANZ__c, 
                PRO_VAR_SCHWERPUNKT__c, 
                PRO_VAR_SCHWERPUNKT_ANDERER__c, 
                PRO_VAR_ERFAHRUNGEN__c, 
                PRO_SYSTEM_LIEFERANTEN__c, 
                PRO_VAR_SYSTEMPARTNER_WEITERE__c,
                Pro_Distribution__c,
                Handelskanal__c,
                Portal__c,
                Distribution__c,
                Pro_Partner_Typ__c, 
                Description
                FROM Account WHERE Id=:aid];
        } catch (System.QueryException e) {
            logError(aid!=null?String.valueOf(aid):'',portal,e.getMessage());
            if (isDebug) throw e;
        }
        return a;
    }
    
    private static void updateCurrentUser(Contact c, Account a) {
        if (currentuser!=null && c!=null && a!=null) {
            currentuser.Lastname=c.Lastname;
            currentuser.Firstname=c.Firstname;
            currentuser.Title_Kontakt__c=c.Title;
            currentuser.MobilePhone_Kontakt__c=c.MobilePhone;
            currentuser.Sonstige_Telefonnummer__c=c.Sonstige_Telefonnummer__c;
            currentuser.Salutation_Kontakt__c=c.Salutation;
            currentuser.Fax_Kontakt__c=c.Fax;
            currentuser.Email=c.Email;
            currentuser.Anmeldung_Telefon__c=c.Anmeldung_Telefon__c;
            currentuser.Anmeldung_Hotlinetelefon__c=c.Anmeldung_Hotlinetelefon__c;
            currentuser.Anmeldung_Mobiltelefon__c=c.Anmeldung_Mobiltelefon__c;
            currentuser.Funktion__c=c.Funktion__c;
            currentuser.Info_per_Email__c=c.Info_per_Email__c;
            currentuser.Info_per_Post__c=c.Info_per_Post__c;
            currentuser.Interne_Abteilungsbezeichnung__c=c.Interne_Abteilungsbezeichnung__c;
            currentuser.Status__c=c.Status__c;
            currentuser.Telefon_Kontakt__c=c.Phone;
            currentuser.Abteilung_Auswahl__c=c.Abteilung_Auswahl__c;
            currentuser.MailingCity_Kontakt__c=c.MailingCity;
            currentuser.MailingStreet_Kontakt__c=c.MailingStreet;
            currentuser.MailingCountry_Kontakt__c=c.MailingCountry;
            currentuser.MailingState_Kontakt__c=c.MailingState;
            currentuser.MailingPostalCode_Kontakt__c=c.MailingPostalCode;
            currentuser.In_Freischaltung__c=c.In_Freischaltung__c;
            currentuser.Zustimmung_Datenschutzerkl_rung_am__c=c.Zustimmung_Datenschutzerkl_rung_am__c;
            currentuser.Datenschutzerkl_rung_zugestimmt__c=c.Datenschutzerkl_rung_zugestimmt__c;
            currentuser.Handelskanal__c=a.Handelskanal__c;
            currentuser.Distribution__c=a.Distribution__c;
            currentuser.Pro_Partner_Typ__c=a.Pro_Partner_Typ__c;
            currentuser.PRO_VAR_MITARBEITERTZAHL__c = a.PRO_VAR_MITARBEITERTZAHL__c;
            currentuser.PRO_VAR_ANZ_SUPPORT__c = a.PRO_VAR_ANZ_SUPPORT__c;
            currentuser.PRO_VAR_KUNDEN_MA_ANZ__c = a.PRO_VAR_KUNDEN_MA_ANZ__c;
            currentuser.PRO_VAR_SCHWERPUNKT__c = a.PRO_VAR_SCHWERPUNKT__c;
            currentuser.PRO_VAR_SCHWERPUNKT_ANDERER__c = a.PRO_VAR_SCHWERPUNKT_ANDERER__c;
            currentuser.PRO_VAR_ERFAHRUNGEN__c = a.PRO_VAR_ERFAHRUNGEN__c;
            currentuser.PRO_SYSTEM_LIEFERANTEN__c = a.PRO_SYSTEM_LIEFERANTEN__c;
            currentuser.PRO_VAR_SYSTEMPARTNER_WEITERE__c = a.PRO_VAR_SYSTEMPARTNER_WEITERE__c;
            currentuser.Description__c = a.Description;
            currentuser.Pro_Distribution__c=a.Pro_Distribution__c;
        }
    }
}