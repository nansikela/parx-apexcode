public class TransferUserdata {

	private static map<Id, Contact> cmap = new map<Id, Contact>();
	private static map<Id, Account> amap = new map<Id, Account>();
	private static map<Id, Contact> contactstoupdate = new map<Id, Contact>();
	private static map<Id, Account> accountstoupdate = new map<Id, Account>();
	private static Set<String> cids = new Set<String>();
	private static set<Id> aids = new set<Id>();

	public static void updateContact(map<Id, User> umap) {
		getContactIds(umap);
		getContacts();
		getAccounts();
		for (User u: umap.values()) {
			updateContactData(u);
			//if (u.Handelskanal__c!=null) 
			updateAccountData(u);
		}
		updateData(); 
	}
	
	private static void getContactIds(map<Id, User> umap) {
		for (User u: umap.values()) {
			if (u.contactId!=null && !cids.contains(u.ContactId)) cids.add(u.ContactId);
		}
	}
	
	private static void getContacts() {
		if (!cids.isEmpty()) { 
			try {   
				for (Contact c:[SELECT Contact.Id, Contact.Lastname, Contact.Firstname, Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.AccountId,
							Contact.Title, Contact.Salutation, Contact.Fax, Contact.Anmeldung_Hotlinetelefon__c, Contact.Sonstige_Telefonnummer__c,
							Contact.Anmeldung_Mobiltelefon__c, Contact.Funktion__c, Contact.Info_per_Email__c,
							Contact.Info_per_Post__c, Contact.Interne_Abteilungsbezeichnung__c,
							Contact.Status__c, Contact.Abteilung_Auswahl__c,
							Contact.Gigaset_Extranet__c, Contact.Gigaset_Pro__c, Contact.In_Freischaltung__c,
							Contact.MailingCity, Contact.MailingStreet, Contact.MailingCountry, Contact.MailingState, Contact.MailingPostalCode,
							Contact.Account.Status__c, Contact.Account.Name, Contact.Account.BillingStreet, Contact.Account.BillingCity, 
							Contact.Account.BillingPostalCode, Contact.Account.BillingCountry,
							Contact.Zustimmung_Datenschutzerkl_rung_am__c, Contact.Datenschutzerkl_rung_zugestimmt__c 
							FROM Contact WHERE Id IN :cids]) {
					if (!cmap.containsKey(c.id)) cmap.put(c.id,c);
					if (!aids.contains(c.AccountId)) aids.add(c.AccountId);
				}
			} catch ( System.QueryException e) {
				System.debug('PARX Contact SELECT has Errors: ' + e.getMessage());
				SystemSettings.logError('PARX Contact SELECT has Errors: ' + e.getMessage(),'TransferUserdata','getContacts','','ERROR');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static void getAccounts() {
		if (!aids.isEmpty()) {
			try {   
				for (Account a:[SELECT Id, Handelskanal__c, Distribution__c, Pro_Partner_Typ__c, PRO_VAR_MITARBEITERTZAHL__c, PRO_VAR_ANZ_SUPPORT__c, PRO_VAR_KUNDEN_MA_ANZ__c, PRO_VAR_SCHWERPUNKT__c, PRO_VAR_SCHWERPUNKT_ANDERER__c, PRO_VAR_ERFAHRUNGEN__c, PRO_SYSTEM_LIEFERANTEN__c, PRO_VAR_SYSTEMPARTNER_WEITERE__c, Description
							FROM Account WHERE Id IN :aids]) {
					if (!amap.containsKey(a.id)) amap.put(a.id,a);
				}
			} catch ( System.QueryException e) {
				System.debug('PARX Account SELECT has Errors: ' + e.getMessage());
				SystemSettings.logError('PARX Account SELECT has Errors: ' + e.getMessage(),'TransferUserdata','getAccounts','','ERROR');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static void updateData() {
		if (!contactstoupdate.isEmpty()) {
			try {
				update contactstoupdate.values();
			} catch ( System.DmlException e) {
				System.debug('PARX Contact update has Errors: ' + e.getMessage());
				//SystemSettings.logError('PARX Contact update has Errors: ' + e.getMessage(),'TransferUserdata','updateData','','ERROR');
				//if (SystemSettings.isDebug) throw e;
			}
		}
		if (!accountstoupdate.isEmpty()) {
			try {
				update accountstoupdate.values();
			} catch ( System.DmlException e) {
				System.debug('PARX Account update has Errors: ' + e.getMessage());
				//SystemSettings.logError('PARX Contact update has Errors: ' + e.getMessage(),'TransferUserdata','updateData','','ERROR');
				//if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	// this method has to be in sync with the SystemSetting getCurrentUpdatedUser
	// every new field has to be added to both functions!
	private static void updateContactData(User u) {
		if (u!=null) {
			if (u.ContactId!=null) {
				if (cmap.containsKey(u.ContactId)) {
					Contact c=cmap.get(u.ContactId);
					c.Lastname=u.Lastname;
					c.Firstname=u.Firstname;
					c.Title=u.Title_Kontakt__c;
					c.MobilePhone=u.MobilePhone_Kontakt__c;
					c.Sonstige_Telefonnummer__c=u.Sonstige_Telefonnummer__c;
					c.Salutation=u.Salutation_Kontakt__c;
					c.Fax=u.Fax_Kontakt__c;
					c.Email=u.Email;
					c.Anmeldung_Telefon__c=u.Anmeldung_Telefon__c;
					c.Anmeldung_Hotlinetelefon__c=u.Anmeldung_Hotlinetelefon__c;
					c.Anmeldung_Mobiltelefon__c=u.Anmeldung_Mobiltelefon__c;
					c.Funktion__c=u.Funktion__c;
					c.Info_per_Email__c=u.Info_per_Email__c;
					c.Info_per_Post__c=u.Info_per_Post__c;
					c.Interne_Abteilungsbezeichnung__c=u.Interne_Abteilungsbezeichnung__c;
					c.Status__c=u.Status__c;
					c.Phone=u.Telefon_Kontakt__c;
					c.Abteilung_Auswahl__c=u.Abteilung_Auswahl__c;
					c.MailingCity=u.MailingCity_Kontakt__c;
					c.MailingStreet=u.MailingStreet_Kontakt__c;
					c.MailingCountry=u.MailingCountry_Kontakt__c;
					c.MailingState=u.MailingState_Kontakt__c;
					c.MailingPostalCode=u.MailingPostalCode_Kontakt__c;
					c.In_Freischaltung__c=u.In_Freischaltung__c;
					c.Zustimmung_Datenschutzerkl_rung_am__c=u.Zustimmung_Datenschutzerkl_rung_am__c;
					c.Datenschutzerkl_rung_zugestimmt__c=u.Datenschutzerkl_rung_zugestimmt__c;
					if (!contactstoupdate.containsKey(c.id)) contactstoupdate.put(c.id,c);
				}
			}
		}
	}

	private static void updateAccountData(User u) {
		if (u!=null) {
			if (u.ContactId!=null) {
				if (cmap.containsKey(u.ContactId)) {
					Account a=amap.get(cmap.get(u.ContactId).AccountId);
					a.Handelskanal__c=u.Handelskanal__c;
					a.Distribution__c=u.Distribution__c;
					a.Pro_Partner_Typ__c=u.Pro_Partner_Typ__c;
					a.PRO_VAR_MITARBEITERTZAHL__c = u.PRO_VAR_MITARBEITERTZAHL__c;
					a.PRO_VAR_ANZ_SUPPORT__c = u.PRO_VAR_ANZ_SUPPORT__c;
					a.PRO_VAR_KUNDEN_MA_ANZ__c = u.PRO_VAR_KUNDEN_MA_ANZ__c;
					a.PRO_VAR_SCHWERPUNKT__c = u.PRO_VAR_SCHWERPUNKT__c;
					a.PRO_VAR_SCHWERPUNKT_ANDERER__c = u.PRO_VAR_SCHWERPUNKT_ANDERER__c;
					a.PRO_VAR_ERFAHRUNGEN__c = u.PRO_VAR_ERFAHRUNGEN__c;
					a.PRO_SYSTEM_LIEFERANTEN__c = u.PRO_SYSTEM_LIEFERANTEN__c;
					a.PRO_VAR_SYSTEMPARTNER_WEITERE__c = u.PRO_VAR_SYSTEMPARTNER_WEITERE__c;
					a.Description = u.Description__c;
					if (!accountstoupdate.containsKey(a.id)) accountstoupdate.put(a.id,a);
				}
			}
		}
	}
}