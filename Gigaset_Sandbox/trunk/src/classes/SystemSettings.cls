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
    global static Contact currentusercontact;
    global static Account currentuseraccount;
    
    // pageids
    global static final Id userdatapageid=getPageId('Benutzerdaten');
    global static final Id servicehotlineinfopageid=getPageid('ServiceHotline');
    global static final Id loginpageid=getPageid('Login');
    global static final Id rueckrufservicepageid=getPageid('Rueckrufservice');
    global static final Id forgotpasswordpageid=getPageid('PasswortVergessen');
    global static final Id registrationpageid=getPageid('Registrierung');
    global static final Id homepageid=getPageid('Home');
    global static final Id imprintpageid=getPageid('Imprint');
    global static final Id privacyprotectionid=getPageId('PrivacyProtection');
     
    // menu
    global static final Id kontaktpageid=getPageid('Kontakt');
    global static final Id link01pageid=getPageid('Link01');
    global static final Id link02pageid=getPageid('Link02');
    global static final Id link03pageid=getPageid('Link03');
    global static final Id link04pageid=getPageid('Link04');
    global static final Id link05pageid=getPageid('Link05');
    
    global static final String TrainingId=getPageid('training');
    
    global static final String werbemittelpageid=getPageid('Werbemittel');
    
    // interface
    global static final String picturemanagementLink = 'https://dam.gigaset.com/index.php?extra_login=';
    //global static final String picturemanagementLink = 'http://gigaset-dev.kurt.picturemanagement.de/index.php?extra_login=';
    global static final String werbemittelLink = 'http://62.26.5.13/webstore30/scripts/anmeldung.asp?extra_login=';
    
    global static String addParam='';
    global static Boolean showNextTopShop;
    
    // systemsettings private methods
    private static Id getPageid(String name) {
        Id pid;
        for (Pages__c p: Pages__c.getAll().values()) {
            if (p.IsActive__c && p.Portal__c==portal && p.Label__c==name && p.isPro__c==isPro) pid=Id.valueOf(p.PageId__c);
        }
        
        return pid;
    }
    
    public static Id getPageid(String name, String localportal, Boolean localisPro) {
        Id pid;
        for (Pages__c p: Pages__c.getAll().values()) {
            if (p.IsActive__c && p.Portal__c==localportal && p.Label__c==name && p.isPro__c==localisPro) pid=Id.valueOf(p.PageId__c);
        }
        
        return pid;
    }
    
    public static String getPortalByPageId() {
        if (System.currentPageReference()!=null && System.currentPageReference().getParameters().containsKey('pageid')) {
            for (Pages__c p: Pages__c.getAll().values()) {
                if (Id.ValueOf(p.PageId__c)==Id.valueOf(System.currentPageReference().getParameters().get('pageid'))) return p.Portal__c;
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
        system.debug('PKB');
        //FOR PKB!!!!!!
        try {
            if(ApexPages.currentPage().getParameters().containsKey('portal'))
                System.debug('Found portal via URL parameter:' + ApexPages.currentPage().getParameters().get('portal').substring(0,2));
                return ApexPages.currentPage().getParameters().get('portal').substring(0,2);
        }
        catch(Exception ex){
            System.debug('SystemSettings.getPortalSign executed without context of ApexPages.currentPage');
            System.debug(ex);
        }
        
        system.debug('Portal from authenticated user');
        // get portal from authenticated user
        if (currentusercontact==null && SystemSettings.isPortalUser()) {
            currentusercontact=getContact(ContactId);
        }
        if (currentusercontact!=null && currentusercontact.Portal__c!=null) sign=currentusercontact.Portal__c;
       
        
        system.debug('Portal from page');
        // get portal from page
        if (System.currentPageReference()!=null && System.currentPageReference().getParameters().containsKey('pageid')) {
            for (Pages__c p: Pages__c.getAll().values()) {
                if (Id.valueOf(p.PageId__c)==Id.ValueOf(ApexPages.currentPage().getParameters().get('pageid'))){
                    sign=p.Portal__c;
                    system.debug(sign);
                }
            }
        }
        System.debug('Found Portal 1: ' + sign);
        
        
        system.debug('Portal from parameter');
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
        
        
        system.debug('Portal from custom webaddress');
        // get portal form custom webaddress
        if (Site.getCustomWebAddress()!=null) System.debug('####### CustomWebAddress: ' + Site.getCustomWebAddress() + ' / substring: ' + Site.getCustomWebAddress().substring(7,9));
        if (Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().substring(9,10)=='.' && sign=='00')
            return Site.getCustomWebAddress().substring(7,9);
        else if (Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().substring(11,12)=='.' && sign=='00')
            return Site.getCustomWebAddress().substring(7,11);
        System.debug('Found Portal 2: ' + sign);
        
        
        system.debug('Portal from site name');
        // get portal form site name
        if (Site.getName()!=null && sign=='00')
            if (Site.getName().toLowerCase().contains('pro'))
                return Site.getName().substring(0,Site.getName().toLowerCase().indexOf('pro')).toLowerCase();
            else
                return Site.getName().toLowerCase();
        System.debug('Found Portal 3: ' + sign);
        
        
        system.debug('Portal from existing url');
        // get portal form existing url
        if ((sign==null || sign=='00') && ApexPages.currentPage()!=null && ApexPages.currentPage().getUrl()!=null) sign=ApexPages.currentPage().getUrl().substring(ApexPages.currentPage().getUrl().length()-2);
        System.debug('Found Portal: ' + sign);
        return sign;
    }
    
    private static String getPortalCountry() {
        String ctry='Germany';
        for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
            if (gs.Portal__c==getPortalSign() && gs.isPro__c==(Site.getCustomWebAddress()!=null && Site.getCustomWebAddress().contains('pro')) ) 
                ctry=gs.CountryForRegistration__c;
        }
        return ctry;
    }
    
    private static Boolean isPro() {
        //FIX FOR PKB!!!
        if(Site.getName() == 'Knowledge_Base')
            return true;
            
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
        if (currentusercontact==null && SystemSettings.contactid!=null && SystemSettings.contactid!='') {
            currentusercontact=getContact(contactid);
        }   
        if (currentusercontact!=null) { 
            if (currentusercontact!=null && currentusercontact.AccountId!=null && currentuseraccount==null) {
                currentuseraccount=getAccount(currentusercontact.AccountId);
            }
            if (currentuseraccount!=null && 
                (
                (!SystemSettings.isPro && (currentuseraccount.Handelskanal__c==null || currentuseraccount.Handelskanal__c=='')) 
                ||
                (SystemSettings.isPro && (currentuseraccount.Handelskanal__c==null || currentuseraccount.Handelskanal__c=='' || currentuseraccount.Pro_Distribution__c==null || currentuseraccount.Pro_Distribution__c==''))
                )) return true;
        }
        return false;
    }
    
    global static Boolean showPrivacy() {
        if (privacyprotectionid==null) return false;
        Boolean privacyEnabled=false;
        for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
            if (gs.Portal__c==portal && gs.isPro__c==isPro ) privacyEnabled=gs.Datenschutzabfrage__c;
        }
        if (currentusercontact==null && SystemSettings.contactid!=null && SystemSettings.contactid!='' && privacyEnabled) {
            currentusercontact=getContact(contactid);
        }   
        if (privacyEnabled) {   
            if (currentusercontact!=null && (currentusercontact.Datenschutzerkl_rung_zugestimmt__c==null || !currentusercontact.Datenschutzerkl_rung_zugestimmt__c)) {
                return true;
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
        if (currentusercontact==null && SystemSettings.contactid!=null && SystemSettings.contactid!='') {
            currentusercontact=getContact(contactid);
        }
        if (currentusercontact!=null) {
            if (currentusercontact!=null && currentusercontact.AccountId!=null) {
                if (SystemSettings.isPro && !currentusercontact.Gigaset_Pro__c && currentusercontact.Gigaset_Extranet__c) return true;
                if (!SystemSettings.isPro && !currentusercontact.Gigaset_Extranet__c && currentusercontact.Gigaset_Pro__c) return true;
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
        /*try {
            if (ApexPages.currentPage().getParameters().get('l') != null ) {
                language = ApexPages.currentPage().getParameters().get('l');
                System.debug('got language from url parameter: ' + language);
                return language;
            }
        }
        catch (Exception ex){
            System.debug('did not succeed in gettin language from url parameter');
        }*/
        for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
            if (gs!=null && gs.Portal__c==portal && gs.isPro__c==isPro && gs.Sprache__c!=null) language=gs.Sprache__c;
        }
        return language;
    }
    
    public static PageReference redirectToLogin() {
        PageReference basispage=Page.page;
        System.debug('[RedirectToLogin()] PageID: '+loginpageid);
        PageReference login=new PageReference( basispage.getUrl() + '?pageid=' + loginpageid + addParam);
        login.setRedirect(true);
        Boolean isAlreadyLoginPage=false;
        if (ApexPages.currentPage()==login) isAlreadyLoginPage=true;
        if (ApexPages.currentPage().getParameters().containsKey('pageid') && loginpageid!=null && Id.ValueOf(ApexPages.currentPage().getParameters().get('pageid'))==loginpageid) isAlreadyLoginPage=true;
        
        if (isAlreadyLoginPage) return null;
        else return login;
    }

    /* not needed anymore */
    /*
    public static PageReference init() {
        if (ApexPages.currentPage().getParameters().containsKey('pid')) addParam='&pid='+ApexPages.currentPage().getParameters().get('pid');
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
            if (cl.CommonCode__c==ccode && cl.Portal__c==portal && cl.LanguageCode__c==setLanguage() && cl.isPro__c==SystemSettings.isPro) label=cl.Label__c;
        }
        
        return label;
    }
    
    global static String getCurrentNavigationPointLabel(String pid) {
        Id pageid;
        if (pid!=null) {
            try {
                pageid=Id.valueOf(pid);
            } catch (System.Exception e) {}
        }
            
        if (pageid!=null) {
        // portal specific labels/navigationpoints
        if (pageid==homepageid|| (Site.getPrefix()!=null && Site.getPrefix().contains('Home'))) return getLabel('home');
        if (link01pageid!=null && pageid==link01pageid) return getLabel('link01');
        if (link02pageid!=null && pageid==link02pageid) return getLabel('link02');
        if (link03pageid!=null && pageid==link03pageid) return getLabel('link03');
        if (link04pageid!=null && pageid==link04pageid) return getLabel('link04');
        if (link05pageid!=null && pageid==link05pageid) return getLabel('link05');
        if (werbemittelpageid!=null && pageid==werbemittelpageid) return getLabel('Werbemittel');
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
        } else return '';
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
                    Portal__c, 
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
                Portal__c, 
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
    
    public static set<String> getPicklistItems(String picklistname) {
        set<String> retset=new set<String>();
        if (picklistname!=null) {
            for (PicklistConfiguration__c pc: PicklistConfiguration__c.getAll().values()) {
                if (pc.Portal__c==portal && pc.isPro__c==isPro && pc.Picklistname__c==picklistname && !retset.contains(pc.value__c) && (pc.LanguageCode__c==setLanguage() || pc.LanguageCode__c==null || pc.LanguageCode__c=='')) {
                    retset.add(pc.value__c);
                }
            }
        }
        return retset;
    }
}