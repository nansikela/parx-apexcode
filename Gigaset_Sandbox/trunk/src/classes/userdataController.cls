public class userdataController {

	public String step { get; set; }
	public Request__c rq { get; set; }
	public Contact c { get; set; }
	public User u { get; set; }
	public Boolean isPro {get; set; }
	public Boolean hasError { get; set; }
	public string messages { get; set; }
	public String portal {get; set; }
	public Boolean showPhoneErr { get; set; }
	public Boolean showMobileErr { get; set; }
	public Boolean showHotlineErr { get; set; }
	public String errorText { get; set; }
	public String labelPhone { get; set; }
	public String labelMobile { get; set; }
	public String labelSonstigephone { get; set; }
	//public String errStylePhone { get; set; }
	//public String errStyleMobilePhone { get; set; }
	public String success_headline { get; set; }

	public userdataController() {
		isPro = System_Settings.isPro;
		portal=System_Settings.portal;
		step='start';
		success_headline='';
		showPhoneErr=false;
		showMobileErr=false;
		showHotlineErr=false;
		errorText='<strong>' + System.Label.site.Error2 + ':</strong> ' + System.label.registration_errormsg;
		rq=new Request__c();
		u=System_Settings.getCurrentUpdatedUser();
		//getCurrentuser();
		//updateUserDataWithContactData();
		//errStylePhone='';
		//errStyleMobilePhone='';
		hasError=ApexPages.hasMessages();
		Schema.DescribeFieldResult f = Schema.sObjectType.User.fields.Telefon_Kontakt__c;
		labelPhone=f.getLabel();
		f = Schema.sObjectType.User.fields.MobilePhone_Kontakt__c;
		labelMobile=f.getLabel();
		f = Schema.sObjectType.User.fields.Sonstige_Telefonnummer__c;
		labelSonstigephone=f.getLabel();
	}
	
	/* not needed 
	private void getCurrentuser() {
		if (UserInfo.getUserId()!=null) {
			try {
				// TODO generic query 
				u=[SELECT Id, 
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
						IsActive
						FROM User WHERE Id = :UserInfo.getUserId() ];
			} catch (System.QueryException e) {
				System.debug('PARX User not found or not authenticated: ' + e.getMessage());
				System_Settings.logError('PARX User not found or not authenticated: ' + e.getMessage(),'DEuserdataController','getCurrentuser','','ERROR');
				if (System_Settings.isDebug) throw e;
			}
			if (u!=null && u.ContactId!=null) {
				try {
					// TODO generic query
					c=[SELECT Contact.Id, Contact.Lastname, Contact.Firstname, Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.AccountId,
							Contact.Title, Contact.Salutation, Contact.Anmeldung_Telefon__c,  Contact.Anmeldung_Hotlinetelefon__c, 
							Contact.Anmeldung_Mobiltelefon__c, Contact.Funktion__c, Contact.Info_per_Email__c,
							Contact.Info_per_Post__c, Contact.Interne_Abteilungsbezeichnung__c,
							Contact.Status__c, Contact.Abteilung_Auswahl__c, Contact.Fax,
							Contact.MailingCity, Contact.MailingStreet, Contact.MailingCountry, Contact.MailingState, Contact.MailingPostalCode,
							Contact.Account.Status__c, Contact.Account.Name, Contact.Account.BillingStreet, Contact.Account.BillingCity, 
							Contact.Account.BillingPostalCode, Contact.Account.BillingCountry
							FROM Contact WHERE Contact.Id = :u.ContactId];
				} catch (System.QueryException e) {
					System.debug('PARX User not found or not authenticated: ' + e.getMessage());
					System_Settings.logError('PARX User not found or not authenticated: ' + e.getMessage(),'DEuserdataController','getCurrentuser','','ERROR');
					if (System_Settings.isDebug) throw e;
				}
			}
		}
	}
	
	private void updateUserDataWithContactData() {
		if (u!=null && c!=null) {
			u.Lastname=c.Lastname;
			u.Firstname=c.Firstname;
			u.Title_Kontakt__c=c.Title;
			u.MobilePhone_Kontakt__c=c.MobilePhone;
			u.Salutation_Kontakt__c=c.Salutation;
			u.Fax_Kontakt__c=c.Fax;
			u.Email=c.Email;
			u.Anmeldung_Telefon__c=c.Anmeldung_Telefon__c;
			u.Anmeldung_Hotlinetelefon__c=c.Anmeldung_Hotlinetelefon__c;
			u.Anmeldung_Mobiltelefon__c=c.Anmeldung_Mobiltelefon__c;
			u.Funktion__c=c.Funktion__c;
			u.Info_per_Email__c=c.Info_per_Email__c;
			u.Info_per_Post__c=c.Info_per_Post__c;
			u.Interne_Abteilungsbezeichnung__c=c.Interne_Abteilungsbezeichnung__c;
			u.Status__c=c.Status__c;
			u.Telefon_Kontakt__c=c.Phone;
			u.Abteilung_Auswahl__c=c.Abteilung_Auswahl__c;
			u.MailingCity_Kontakt__c=c.MailingCity;
			u.MailingStreet_Kontakt__c=c.MailingStreet;
			u.MailingCountry_Kontakt__c=c.MailingCountry;
			u.MailingState_Kontakt__c=c.MailingState;
			u.MailingPostalCode_Kontakt__c=c.MailingPostalCode;
		}
	}
	*/
	
	private void updateUser() {
		System.debug('PARX Updating User Data!');
		if (u!=null) {
			try {
				update u;
			} catch (System.DmlException e) {
				System.debug('PARX Error updating user data: ' + e.getMessage());
				ApexPages.addMessages(e);
				if (System_Settings.isDebug) throw e;
			}
		}
	}
	
	private void insertRequest() {
		try {
			insert rq;
			rq = new Request__c();
		} catch (System.DmlException e) {
			System.debug('PARX Error inserting new request: ' + e.getMessage());
			ApexPages.addMessages(e);
			if (System_Settings.isDebug) throw e;
		}
	}
	
	// getter
	public String getServiceHotlineUrl() {
		pageReference basispage = Page.page;
		if (basispage!=null) 
			return Page.page.getUrl() + '?pageid=' + System_Settings.servicehotlineinfopageid;
		else 
			return '';
	}
	
	public list<SelectOption> getDeleteReasons() {
		list<SelectOption> options = new list<SelectOption>();
		Schema.DescribeFieldResult F = Request__c.Loeschung_Gruende__c.getDescribe();
		List <Schema.PicklistEntry> picklistentries = F.getPicklistValues();
		for (Schema.PicklistEntry pe : picklistentries) {
			if (pe.isActive()) {
				options.add(new SelectOption(pe.getValue(), pe.getLabel()));
			}
		}
		return options;
	}
	
	// actions
	public pageReference editUserdata() {
		step='userdata';
		hasError=ApexPages.hasMessages();
		return null;
	}
	
	public pageReference editInfoservice() {
		step='infoservice';
		hasError=ApexPages.hasMessages();
		return null;
	}
	
	public pageReference deleteUser() {
		step='userdelete';
		hasError=ApexPages.hasMessages();
		return null;
	}
	
	public pageReference deleteCompany() {
		PageReference basispage = Page.page;
		PageReference changecompanydata = new PageReference(basispage.getUrl() + '?pageid=' + System_Settings.kontaktpageid + '&kontakttyp=Löschung');
		changecompanydata.setRedirect(true);
		return changecompanydata;
	}
	
	public pageReference goBack() {
		if (step=='start') {
			PageReference basispage = Page.page;
			PageReference homepage=new PageReference(basispage.getUrl() + '?pageid=' + System_Settings.homepageid);
			return homepage;
		} else {
			step='start';
			return null;
		}
	}
	
	public pageReference saveData() {
		//errStylePhone='';
	 	//errStyleMobilePhone='';
	 	messages='';
	 	showPhoneErr=false;
	 	showMobileErr=false;
	 	showHotlineErr=false;
	 	// cares for userdata and infoservice
	 	success_headline=System.label.userdata_infoservice;
	 	if (step=='userdata') {
		 	if (messages!='' 
		 		|| (u.Anmeldung_Telefon__c && (u.Telefon_Kontakt__c==null || u.Telefon_Kontakt__c=='')) 
		 		|| (u.Anmeldung_Mobiltelefon__c && (u.MobilePhone_Kontakt__c==null || u.MobilePhone_Kontakt__c=='' ))
		 		|| (u.Anmeldung_Hotlinetelefon__c && (u.Sonstige_Telefonnummer__c==null || u.Sonstige_Telefonnummer__c=='' ))
		 		) {
		 		if (u.Anmeldung_Telefon__c && (u.Telefon_Kontakt__c==null || u.Telefon_Kontakt__c=='')) {
		 			//if (!messages.contains(System.label.registration_errorbase)) 
		 			//	messages=messages+' '+System.label.registration_errorbase+' ';
		 			//messages=messages+' ' + System.label.registration_nophone ;
		 			//errStylePhone='errorMsg';
		 			ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelPhone + ': ' + System.label.registration_errormsg);
		 			ApexPages.addMessage(apm);
		 			showPhoneErr=true;
		 		}
		 		if (u.Anmeldung_Mobiltelefon__c && (u.MobilePhone_Kontakt__c==null || u.MobilePhone_Kontakt__c=='')) {
		 			//if (!messages.contains(System.label.registration_errorbase)) 
		 			//	messages=messages+' '+System.label.registration_errorbase+' ';
		 			//messages=messages+' ' + System.label.registration_nomobilephone;
		 			//errStyleMobilePhone='errorMsg';
		 			ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelMobile + ': ' + System.label.registration_errormsg);
		 			ApexPages.addMessage(apm);
		 			showMobileErr=true;
		 		}
		 		if (u.Anmeldung_Hotlinetelefon__c && (u.Sonstige_Telefonnummer__c==null || u.Sonstige_Telefonnummer__c=='')) {
		 			//if (!messages.contains(System.label.registration_errorbase)) 
		 			//	messages=messages+' '+System.label.registration_errorbase+' ';
		 			//messages=messages+' ' + System.label.registration_nomobilephone;
		 			//errStyleMobilePhone='errorMsg';
		 			ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelSonstigephone + ': ' + System.label.registration_errormsg);
		 			ApexPages.addMessage(apm);
		 			showHotlineErr=true;
		 		}
		 	}
		 	success_headline=System.label.clientdata_userdata;
	 	}
	 	if (!showMobileErr && !showPhoneErr && !showHotlineErr) {
	 		// update user
	 		updateUser();
	 		if (!ApexPages.hasMessages()) step='userdata_success';
	 	} else {
	 		//ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.site.Error2 + ': ' + System.label.registration_errormsg);
	 		//ApexPages.addMessage(apm);
	 	}
	 	hasError=ApexPages.hasMessages() || showMobileErr || showPhoneErr || showHotlineErr ;
		return null;
	}
	
	public pageReference saveUserdelete() {
		rq.Kontakt__c=u.contactid;
		rq.Typ__c='Selbstlöschung Kontakt';
		u.Status__c='Selbstlöschung';
		//u.isActive=false;
		// TODO is the savepoint really necessary here?
		if (!ApexPages.hasMessages()) {
			Savepoint s = Database.setSavepoint();
			insertRequest();
			// no change of contact status
			// updateUser();
			if (ApexPages.hasMessages()) Database.rollback(s);
		}
		hasError=ApexPages.hasMessages();
		if (!ApexPages.hasMessages()) step='userdelete_success';
		return null;
	} 
	
	public pageReference editCompanydata() {
		PageReference basispage = Page.page;
		PageReference changecompanydata = new PageReference(basispage.getUrl() + '?pageid=' + System_Settings.kontaktpageid + '&kontakttyp=Änderung Firmendaten');
		changecompanydata.setRedirect(true);
		return changecompanydata;
	}

}