/* a class for test data for the unit tests */
public class testData {
	public class werbemittelData {
		public list<Werbemittel__c> werbemittel { get; set; }
		public String portal { get; set; }
		public Boolean isPro { get; set; }
		
		public werbemittelData(String port, Boolean Pro) {
			portal=port; isPro=Pro;
			werbemittel=createWerbemittel();
		}
		
		public list<Werbemittel__c> createWerbemittel() {
			list<Werbemittel__c> wmlist= new list<Werbemittel__c>();
			for (Integer i=0;i<5;i++) {
				wmlist.add(new Werbemittel__c(Aktiv__c=true, Artikelnummer__c='1234',Portal__c=portal,Titel__c='Titel'));
				
			}
			insert wmlist;
			return wmlist;
		}
	}
	
	public class initData {
		public list<CustomLabel__c> CustomLabels {get; set;}
		public list<GlobalSettings__c> GlobalSettings { get; set; }
		public list<pages__c> PagesSet { get; set; }
		public list<Page__c> Pages { get; set; }
		public list<PageTemplate__c> PageTemplates { get; set; }
		public String portal { get; set; }
		public Boolean isPro { get; set; }
		public list<Account> accounts { get; set; }
		public list<Contact> contacts { get; set; }
		public User testuser { get; set; }
		
		public initData(String port, Boolean Pro) {
			portal=port; isPro=Pro;
			accounts=createAccounts();
			contacts=createContacts();
			testuser=createTestuser();
			CustomLabels=new list<CustomLabel__c>();
			GlobalSettings=new list<GlobalSettings__c>();
			PagesSet=new list<pages__c>();
			Pages=new list<Page__c>();
			PageTemplates=new list<PageTemplate__c>();
			CustomLabels=createCustomLabels();
			GlobalSettings=createGlobalSettings();
			PageTemplates=createPageTemplates();
			Pages=createPages();
			PagesSet=createPageSettings();
		}
		
		list<String> vfpages =new list<String>{'DE_Home', 
								'DE_Imprint', 
								'DE_Kontaktformular', 
								'DE_Login', 
								'DE_Register', 
								'DE_Rueckrufservice', 
								'DE_Userdata', 
								'DE_Werbemittel', 
								'DEPrivacy', 
								'DE_Training', 
								'CRD_Home', 
								'CRD_TwoColumnTemplate',
								'CRD_OneColumnTemplate', 
								'CRD_Imprint', 
								'CRD_Kontaktformular', 
								'CRD_Login', 
								'CRD_Marketing', 
								'CRD_NewsReader', 
								'CRD_Privacy', 
								'CRD_Register', 
								'CRD_Rueckrufservice', 
								'CRD_Training', 
								'CRD_Userdata', 
								'CRD_Werbemittel'};
		
		/* create some accounts */
		public list<Account> createAccounts() {
			list<Account> accs = new list<Account>();
			for (integer i=0;i<5;i++) {
				accs.add(new Account(Name='ParxTestAccount' + i, BillingCountry='Deutschland', Portal__c=portal));
			}
			insert accs;
			return [SELECT Id, BillingCity, BillingCountry, BillingPostalCode, BillingStreet, Name, Portal__c FROM Account WHERE Name like 'ParxTestAccount%'];
		}
		
		/* create some contacts for the accounts */
		public list<Contact> createContacts() {
			list<Contact> cons= new list<Contact>();
			for (Account a: Accounts) {
				cons.add(new Contact(AccountId=a.id, Lastname='ParxTest'+ a.Id, Firstname='ParxTest', Gigaset_Extranet__c=true, Gigaset_Pro__c=isPro, Email='test@parx.de'));
			}
			insert cons;
			return [SELECT Id, Lastname, Firstname, Gigaset_Extranet__c, Gigaset_Pro__c, Portal__c, AccountId, Email, toDeactivate__c FROM Contact WHERE LastName like 'ParxTest%'];
		}
		
		/* now lets create a testuser for contact0 */
		public User createTestuser() {
			User u=new User();
			u.Email='test@parx.de';
			u.ContactId=contacts.get(0).Id;
			u.LastName='TestP';
			u.FirstName='Parx';
			u.Username='test@parx.de';
			u.Alias='ptpt';
			u.EmailEncodingKey='UTF-8';
			u.LanguageLocaleKey='de';
			u.LocaleSidKey='de_DE_EURO';
			u.TimeZoneSidKey='Europe/Berlin';
			u.ProfileId=[SELECT Id FROM Profile WHERE Name like 'Kundenportal%ALL' limit 1].id;
			insert u;
			return u;
		}
		
       /* some custom labels */
       public list<CustomLabel__c> createCustomLabels() {
	       list<CustomLabel__c> clabels =new list<CustomLabel__c>();
	       for (Integer i=0;i<5;i++) {
	       	String ccode='clcode'+i;
	       	CustomLabel__c c=new CustomLabel__c(Name='clname'+portal+i,Portal__c=portal,IsPro__c=isPro,Commoncode__c=ccode);
	       	c.ExternalUrl__c='http://www.parx.de';
	       	c.Label__c='clabel';
	       	c.LanguageCode__c='de';
	       	c.ImportId__c='test';
	       	clabels.add(c);
	       }
	       insert clabels;
	       return [SELECT Id, Name, Portal__c, IsPro__c, Commoncode__c, ExternalUrl__c, Label__c, LanguageCode__c FROM CustomLabel__c WHERE ImportId__c='test'];
       }
       
       public list<GlobalSettings__c> createGlobalSettings() { 
	       /* some global settings */
	       list<GlobalSettings__c> gsettings=new list<GlobalSettings__c>();
	       GlobalSettings__c gs=new GlobalSettings__c();
	       gs.Name=portal+'_'+'de';
	       gs.Autofreischaltung__c=true;
	       gs.CountryForRegistration__c='Deutschland';
	       gs.Datenschutzabfrage__c=true;
	       gs.Freischaltung_Owner_Id__c=UserInfo.getUserId();
	       gs.Gebietsschema__c='de';
	       gs.isPro__c=isPro;
	       gs.Landing_Page_Aktivierung__c=true;
	       gs.Located_in_PartnerFinder__c=true;
	       gs.Picturemanagement_available__c=true;
	       gs.Portal__c=portal;
	       gs.Profile_Id__c=UserInfo.getProfileId();
	       gs.showAbsolutlyGigasetLogo__c=true;
	       gs.ImportId__c='test';
	       gs.Sprache__c='de';
	       insert gs;
	       return [SELECT Id, Name, Autofreischaltung__c, 
	       					CountryForRegistration__c, 
	       					Datenschutzabfrage__c, 
	       					Freischaltung_Owner_Id__c, 
	       					Gebietsschema__c, 
	       					isPro__c, 
	       					Landing_Page_Aktivierung__c, 
	       					Located_in_PartnerFinder__c,
	       					Picturemanagement_available__c,
	       					Portal__c,
	       					Profile_Id__c,
	       					showAbsolutlyGigasetLogo__c,
	       					Sprache__c
	       					FROM GlobalSettings__c WHERE ImportId__c='test'];
       }
       
       public list<PageTemplate__c> createPageTemplates() {
	       /* some pagetemplates */
	       list<PageTemplate__c> pts =new list<PageTemplate__c>();
	       for (String vfpage: vfpages) {
	       	PageTemplate__c pt=new PageTemplate__c();
	       	pt.Name=vfpage;
	       	pt.VisualForce_Page_Name__c=vfpage;
	       	pt.ImportId__c='test';
	       	pts.add(pt);
	       }
	       insert pts;
	       return [SELECT Id, Name, VisualForce_Page_Name__c FROM PageTemplate__c WHERE ImportId__c='test'];
       }
       
       public list<Page__c> createPages() {
	       /* some pages */
	       list<Page__c> cmspages = new list<Page__c>();
	       for (PageTemplate__c pt: PageTemplates) {
	       	Page__c p=new Page__c();
	       	p.ImportId__c='test';
	       	p.Name=pt.Name;
	       	//p.PageTemplateVFPage__c=pt.Name;
	       	p.PageTemplate__c=pt.Id;
	       	cmspages.add(p);
	       }
	       insert cmspages;
	       return [Select p.PageTemplate__c, p.PageTemplateVFPage__c, p.Name, p.ImportId__c From Page__c p WHERE ImportId__c='test'];
       }
       
       public list<pages__c> createPageSettings() {
	       /* some settings for pages */
	       list<pages__c> pagessettings = new list<pages__c>();
	       for (Page__c p:Pages) {
	       	pages__c ps=new pages__c();
	       	ps.isPro__c=isPro;
	       	ps.Portal__c=portal;
	       	ps.PageId__c=p.id;
	       	ps.Name=p.Name+'p.id';
	       	ps.Label__c=p.Name;
	       	if (p.Name.contains('ontakt')) p.Name='Kontakt';
	       	if (p.Name.contains('serdata')) p.Name='Benutzerdaten';
	       	if (p.Name.contains('ogin')) p.Name='Login';
	       	if (p.Name.contains('ueckrufservice')) p.Name='Rueckrufservice';
	       	if (p.Name.contains('tPassword')) p.Name='PasswortVergessen';
	       	if (p.Name.contains('egist')) p.Name='Registrierung';
	       	if (p.Name.contains('Home')) p.Name='Home';
	       	if (p.Name.contains('Imprint')) p.Name='Imprint';
	       	if (p.Name.contains('rivacy')) p.Name='PrivacyProtection';
	       	if (p.Name.contains('Werbemittel')) p.Name='Werbemittel';
	       	ps.IsActive__c=true;
	       	pagessettings.add(ps);
	       }
	       return [Select p.isPro__c, p.Portal__c, p.PageId__c, p.Name, p.Label__c, p.IsActive__c, p.Id From pages__c p];
       }
       
	}
}