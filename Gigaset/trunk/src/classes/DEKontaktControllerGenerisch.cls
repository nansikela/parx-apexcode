public class DEKontaktControllerGenerisch {

	public Boolean isAuthenticated { get; set; }
	public Boolean showform { get; set; }
	public Request__c rq { get; set; }
	public Boolean success { get; set; }
	public String goHomeUrl { get; set; }
	public String defaultlanguage { get; set; }
	public String kontakttyp { get; set; }
	public String HeaderLabel { get; set; }
	public String TextLabel { get; set; }
	public String ReturnLabel { get; set; }
	
	// constructor
	public DEKontaktControllerGenerisch() {
		goHomeUrl=SystemSettings.goHome().getUrl();
		showform=true;
		success=false;
		String Header;
		String Text;
		String ReturnT;
		defaultlanguage=SystemSettings.setLanguage();
		isAuthenticated=SystemSettings.isPortalUser();
		if (ApexPages.currentPage().getParameters().containsKey('Typ')) {
			kontakttyp=ApexPages.currentPage().getParameters().get('Typ');
		} else
			kontakttyp='Kontakt';
		if (ApexPages.currentPage().getParameters().containsKey('Header')) {
			Header=ApexPages.currentPage().getParameters().get('Header');
		} else
			Header='';
		if (ApexPages.currentPage().getParameters().containsKey('Text')) {
			Text=ApexPages.currentPage().getParameters().get('Text');
		} else
			Text='';
		if (ApexPages.currentPage().getParameters().containsKey('Return')) {
			ReturnT=ApexPages.currentPage().getParameters().get('Return');
		} else
			ReturnT='';
		for(CustomLabel__c CL:[select Name, LanguageCode__c, IsPro__c, Portal__c, CommonCode__c from CustomLabel__c where Name =: Text OR Name =:Header OR Name =:ReturnT]){
			if(CL.IsPro__c == SystemSettings.isPro && CL.Portal__c.toLowerCase() == SystemSettings.portal.toLowerCase() && CL.LanguageCode__c.toLowerCase() == defaultlanguage.toLowerCase()) {
				if(CL.Name == Header)
					HeaderLabel = CL.CommonCode__c;
				if(CL.Name == Text)
					TextLabel = CL.CommonCode__c;
				if(CL.Name == ReturnT)
					ReturnLabel = CL.CommonCode__c;
			}
		}
				
		prefillRequest();
	}
	
	private void prefillRequest() {
		rq=new Request__c();
		rq.Typ__c=kontakttyp;
		rq.Gigaset_Extranet__c=!SystemSettings.isPro;
		rq.Gigaset_Pro__c=SystemSettings.isPro;
		if (isAuthenticated) {
			Id contactid;
			if (UserInfo.getUserId()!=null) {
				try {
					contactid=[SELECT ContactId FROM User WHERE Id= :UserInfo.getUserId()].ContactId;
				} catch (Exception e) {
					System.debug('PARX User not authenticated or has no Contact Id!');
					SystemSettings.logError('PARX User not authenticated or has no Contact Id! ' + e.getMessage(),'DEkontaktController','prefillRequest','','ERROR');
					if (SystemSettings.isDebug) throw e;
				}
				if (contactid!=null) {
					rq.Kontakt__c=contactid;
					Contact c;
					try {
						c=[SELECT Id, Salutation, Lastname, Firstname, Email, Briefanrede__c, Account.BillingCity, Account.BillingCountry, Account.BillingStreet, Account.BillingPostalCode FROM Contact WHERE Id =: contactid];
					} catch (Exception e) {
						System.debug('PARX something went wrong, perhaps contact does not exist?');
						SystemSettings.logError('PARX something went wrong, perhaps contact does not exist? ' + e.getMessage(),'DEkontaktController','prefillRequest','','ERROR');
						if (SystemSettings.isDebug) throw e;
					}
					if (c!=null) {
						rq.Email__c=c.Email;
						rq.Land__c=c.Account.BillingCountry;
						rq.Stadt__c=c.Account.BillingCity;
						rq.PLZ__c=c.Account.BillingPostalCode;
					}
 				}
			}
		}
	}
	
	private Boolean insertRequest() {
		Boolean retval=false;
		if (rq!=null) {
			try {
				rq.Portal__c=SystemSettings.portal;
				insert rq;
				retval=true;
			} catch (Exception e) {
				System.debug('PARX Could not save request!');
				ApexPages.Message pm = new ApexPages.Message(ApexPages.Severity.FATAL,System.label.contactform_not_send);
				ApexPages.addMessage(pm);
				if (SystemSettings.isDebug) throw e;
			}
		}
		return retval;
	}

	// actions
	 public PageReference saveRequest() {
	 	success=insertRequest();
	 	showform=false;
	 	return null;
	 }
	 
	 public PageReference init() {
	 	return null;
	 }
	 
	 
	 @isTest
	 public static void testingMethod() {
	 	User u = [select id from User where isActive = true limit 1];
	 	system.runAs(u) {
		 	DEKontaktControllerGenerisch CG = new DEKontaktControllerGenerisch();
		 	CG.insertRequest();
		 	CG.saveRequest();
		 	CG.init();
	 	}
	 }

}