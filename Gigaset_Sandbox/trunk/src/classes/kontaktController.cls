public class kontaktController {

	public Boolean isAuthenticated { get; set; }
	public Boolean showform { get; set; }
	public Request__c rq { get; set; }
	public Boolean success { get; set; }
	public Transient String kontakttyp { get; set; }
	public Transient String goHomeUrl { get; set; }
	
	// constructor
	public kontaktController() {
		goHomeUrl=System_Settings.goHome().getUrl();
		showform=true;
		success=false;
		isAuthenticated=System_Settings.isPortalUser();
		if (ApexPages.currentPage().getParameters().containsKey('kontakttyp') && (kontakttyp==null || kontakttyp=='')) {
			kontakttyp=ApexPages.currentPage().getParameters().get('kontakttyp');
		} else
			kontakttyp='Kontakt';
		prefillRequest();
	}
	
	private void prefillRequest() {
		rq=new Request__c();
		rq.Typ__c=kontakttyp;
		rq.Gigaset_Extranet__c=!System_Settings.isPro;
		rq.Gigaset_Pro__c=System_Settings.isPro;
		if (isAuthenticated) {
			Id contactid;
			if (UserInfo.getUserId()!=null) {
				try {
					contactid=[SELECT ContactId FROM User WHERE Id= :UserInfo.getUserId()].ContactId;
				} catch (Exception e) {
					System.debug('PARX User not authenticated or has no Contact Id!');
					System_Settings.logError('PARX User not authenticated or has no Contact Id! ' + e.getMessage(),'DEkontaktController','prefillRequest','','ERROR');
					if (System_Settings.isDebug) throw e;
				}
			}
			rq.Kontakt__c=contactid;
			Contact c;
			try {
				c=[SELECT Id, Salutation, Lastname, Firstname, Email, Briefanrede__c, MailingCountry FROM Contact WHERE Id =: contactid];
			} catch (Exception e) {
				System.debug('PARX something went wrong, perhaps contact does not exist?');
				System_Settings.logError('PARX something went wrong, perhaps contact does not exist? ' + e.getMessage(),'DEkontaktController','prefillRequest','','ERROR');
				if (System_Settings.isDebug) throw e;
			}
			if (c!=null) {
				rq.Kontakt__c=c.id;
				rq.Email__c=c.Email;
				rq.Land__c=c.MailingCountry;
			}
		}
	}
	
	private Boolean insertRequest() {
		Boolean retval=false;
		if (rq!=null) {
			try {
				rq.Portal__c=System_Settings.portal;
				insert rq;
				retval=true;
			} catch (Exception e) {
				System.debug('PARX Could not save request!');
				ApexPages.Message pm = new ApexPages.Message(ApexPages.Severity.FATAL,System.label.contactform_not_send);
				ApexPages.addMessage(pm);
				if (System_Settings.isDebug) throw e;
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

}