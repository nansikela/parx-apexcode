global class SystemSettings {
	// General Debug Mode
	global static final Boolean isDebug=false;
	//global static final String portal=Site.getCustomWebAddress()==null?'':Site.getCustomWebAddress().substring(7,9);
	//global static final String portal=Site.getCustomWebAddress()==null?'':Site.getCustomWebAddress().substring(9,10)=='.'?Site.getCustomWebAddress().substring(7,9):'';
	global static final String portal=getPortalSign();
	global static final String PortalCountry=getPortalCountry();
	global static final Boolean isPro=isPro();
	global static String contactid='';
	static String language='de';
	global static String baseurl='http://gigaset.com/';
	global static User currentuser;
	
	// pageids
	global static final String userdatapageid=getPageId('Benutzerdaten');
	global static final String servicehotlineinfopageid=getPageid('ServiceHotline');
	global static final String loginpageid=getPageid('Login');
	global static final String rueckrufservicepageid=getPageid('Rueckrufservice');
	global static final String forgotpasswordpageid=getPageid('PasswortVergessen');
	global static final String registrationpageid=getPageid('Registrierung');
	global static final String homepageid=getPageid('Home');
	global static final String imprintpageid=getPageid('Imprint');
	global static final String privacyprotectionid=getPageId('PrivacyProtection');
	 
	// menu
	global static final String kontaktpageid=getPageid('Kontakt');
	global static final String link01pageid=getPageid('Link01');
	global static final String link02pageid=getPageid('Link02');
	global static final String link03pageid=getPageid('Link03');
	global static final String link04pageid=getPageid('Link04');
	global static final String link05pageid=getPageid('Link05');
	
	global static final String TrainingId=getPageid('training');
	
	global static final String werbemittelpageid=getPageid('Werbemittel');
	
	// interface
	global static final String picturemanagementLink = 'https://dam.gigaset.com/index.php?extra_login=';
	//global static final String picturemanagementLink = 'http://gigaset-dev.kurt.picturemanagement.de/index.php?extra_login=';
	global static final String werbemittelLink = 'http://62.26.5.13/webstore30/scripts/anmeldung.asp?extra_login=';
	
	global static String addParam='';
	global static Boolean showNextTopShop;
	
	// systemsettings private methods
	private static String getPageid(String name) {
		String pid='';
		for (Pages__c p: Pages__c.getAll().values()) {
			if (p.IsActive__c && p.Portal__c==portal && p.Label__c==name && p.isPro__c==SystemSettings.isPro) pid=p.PageId__c;
		}
		
		return pid;
	}
	
	private static String getPortalSign() {
		String sign='ZZ';
		if (System.currentPageReference()!=null && System.currentPageReference().getParameters().containsKey('pageid')) {
			for (Pages__c p: Pages__c.getAll().values()) {
				if (p.PageId__c==ApexPages.currentPage().getParameters().get('pageid')) sign=p.Portal__c;
			}
		}
		if (Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().substring(9,10)=='.' && sign=='ZZ')
			return Site.getCustomWebAddress().substring(7,9);
		if (Site.getName()!=null && sign=='ZZ')
			return Site.getName().toLowerCase();
		//sign='nl';
		return sign;
	}
	
	private static String getPortalCountry() {
		String ctry='Deutschland';
		for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
			if (gs.Portal__c==portal && gs.isPro__c==isPro ) ctry=gs.CountryForRegistration__c;
		}
		return ctry;
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
		User u = getCurrentUser();
		if (u!=null) {
			return u.IsPortalEnabled;
		}
		else return false;
	}
	
	// preset should be visible if
	// with Cordless:
	// Handelskanal__c or Distribution__c has no content
	// with Pro:
	// Handelskanal__c or Pro_Distribution__c has no content
	global static Boolean showPreset() {
		if (SystemSettings.contactid!=null && SystemSettings.contactid!='') {
			Contact c=[SELECT Id, AccountId, Gigaset_Extranet__c, Gigaset_Pro__c FROM Contact WHERE Id=:contactid];
			if (c!=null && c.AccountId!=null ) {
				Account a=[SELECT Id, Handelskanal__c, Distribution__c, Pro_Distribution__c FROM Account WHERE Id=:c.AccountId];
				if (a!=null && 
					(
					(!SystemSettings.isPro && (a.Handelskanal__c==null || a.Handelskanal__c=='')) 
					||
					(SystemSettings.isPro && (a.Handelskanal__c==null || a.Handelskanal__c=='' || a.Pro_Distribution__c==null || a.Pro_Distribution__c==''))
					)) return true;
			}
		}
		return false;
	}
	
	global static Boolean showPrivacy() {
		if (privacyprotectionid=='') return false;
		Boolean privacyEnabled=false;
		for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
			if (gs.Portal__c==portal && gs.isPro__c==isPro ) privacyEnabled=gs.Datenschutzabfrage__c;
		}
		if (SystemSettings.contactid!=null && SystemSettings.contactid!='' && privacyEnabled) {
			Contact c=[SELECT Id, AccountId, Datenschutzerkl_rung_zugestimmt__c FROM Contact WHERE Id=:SystemSettings.contactid];
			if (c!=null && (c.Datenschutzerkl_rung_zugestimmt__c==null || !c.Datenschutzerkl_rung_zugestimmt__c)) {
				return true;
			}
		}
		return false;
	}
	
	global static Boolean showPrivacyAnonymous() {
		if (privacyprotectionid=='') return false;
		for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
			if (gs.Portal__c==portal && gs.isPro__c==isPro ) return gs.Datenschutzabfrage__c;
		}
		return false;
	}
	
	global static Boolean showClearing() {
		if (SystemSettings.contactid!=null && SystemSettings.contactid!='') {
			Contact c=[SELECT Id, AccountId, Gigaset_Extranet__c, Gigaset_Pro__c FROM Contact WHERE Id=:SystemSettings.contactid];
			if (c!=null && c.AccountId!=null) {
				if (SystemSettings.isPro && !c.Gigaset_Pro__c && c.Gigaset_Extranet__c) return true;
				if (!SystemSettings.isPro && !c.Gigaset_Extranet__c && c.Gigaset_Pro__c) return true;
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
		PageReference homepage=new PageReference(Page.page.getUrl() + '?pageid=' + SystemSettings.homepageid);
		homepage.setRedirect(true);
		return homepage;
	}
	
	global static String setLanguage() {
		PortalLanguage__c pl=PortalLanguage__c.getValues(portal);
		if (pl!=null) language=pl.LanguageCode__c;
		return language;
	}
	
	public static PageReference redirectToLogin() {
		PageReference basispage=Page.page;
		PageReference login=new PageReference( basispage.getUrl() + '?pageid=' + loginpageid + addParam);
		login.setRedirect(true);
		Boolean isAlreadyLoginPage=false;
		if (ApexPages.currentPage()==login) isAlreadyLoginPage=true;
		if (ApexPages.currentPage().getParameters().containsKey('pageid') && ApexPages.currentPage().getParameters().get('pageid').startsWith(loginpageid)) isAlreadyLoginPage=true;
		
		if (isAlreadyLoginPage) return null;
		else return login;
	}

	public static PageReference init() {
	 	if (ApexPages.currentPage().getParameters().containsKey('pid')) addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
	 	System.debug(addParam);
	 	if (!isPortalUser()) return redirectToLogin();
	 	return null;
	}
	// not used, if you want to acivate this again please take care of isPro!
	//global static String getLabelByName(String name) {
	//	setLanguage();
	//	return CustomLabel__c.getValues(name).Label__c;
	//}
	
	global static String getLabel(String ccode) {
		String label='';
		for (CustomLabel__c cl:CustomLabel__c.getAll().values()) {
			if (cl.CommonCode__c==ccode && cl.Portal__c==portal && cl.LanguageCode__c==setLanguage() && cl.isPro__c==SystemSettings.isPro) label=cl.Label__c;
		}
		
		return label;
	}
	
	global static String getCurrentNavigationPointLabel(String pageid) {
		// portal specific labels/navigationpoints
		if (pageid.startsWith(homepageid)|| (Site.getPrefix()!=null && Site.getPrefix().contains('Home'))) return getLabel('home');
		if (link01pageid!='' && pageid.startsWith(link01pageid)) return getLabel('link01');
		if (link02pageid!='' && pageid.startsWith(link02pageid)) return getLabel('link02');
		if (link03pageid!='' && pageid.startsWith(link03pageid)) return getLabel('link03');
		if (link04pageid!='' && pageid.startsWith(link04pageid)) return getLabel('link04');
		if (link05pageid!='' && pageid.startsWith(link05pageid)) return getLabel('link05');
		if (werbemittelpageid!='' && pageid.startsWith(werbemittelpageid)) return getLabel('Werbemittel');
		// cross portal navigation points
		if (imprintpageid!='' && pageid.startsWith(imprintpageid)) return System.Label.tplt_label_imprint;
		if (kontaktpageid!='' && pageid.startsWith(kontaktpageid)) return System.Label.contact;
		if (userdatapageid!='' && pageid.startsWith(userdatapageid)) return System.Label.userdata_your_userdata;
		if (loginpageid!='' && pageid.startsWith(loginpageid)) return System.Label.loginpage;
		if (registrationpageid!='' && pageid.startsWith(registrationpageid)) return System.Label.registration;
		if (rueckrufservicepageid!='' && pageid.startsWith(rueckrufservicepageid)) return System.Label.callback;
		if (forgotpasswordpageid!='' && pageid.startsWith(forgotpasswordpageid)) return System.Label.forgotpassword_forgot_password;
		//if (Site.getPrefix()!=null && Site.getPrefix().contains('ChangePassword')) return Label.changepw_changepw;
		//if (ApexPages.currentPage().getUrl().contains('ChangePassword')) return Label.changepw_changepw;
		if (System.currentPageReference().getUrl()!=null && System.currentPageReference().getUrl().contains('ChangePassword')) return System.Label.changepw_changepw;
		else return '';
	}
	
	global static String getExternalURL(String ccode){
		String label='';
		for (CustomLabel__c cl:CustomLabel__c.getAll().values()) {
			if (cl.CommonCode__c==ccode && cl.Portal__c==portal && cl.LanguageCode__c==setLanguage() && cl.isPro__c==SystemSettings.isPro) label=cl.ExternalUrl__c;
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
				if (SystemSettings.isDebug) throw e;
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
			try {
				insert el;
			} catch (System.Dmlexception e) {
				if (SystemSettings.isDebug) throw e;
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
			currentuser.Pro_Distribution__c = a.Pro_Distribution__c;
		}
	}
}