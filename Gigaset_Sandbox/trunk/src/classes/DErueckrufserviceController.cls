public class DErueckrufserviceController {
	
	public Boolean isAuthenticated { get; set; }
	public Boolean showform { get; set; }
	public Request__c rq { get; set; }
	public Boolean success { get; set; }
	public String Anrede { get; set; }
	public String goHomeUrl { get; set; }
	
	// constructor
	public DErueckrufserviceController() {
		showform=true;
		success=false;
		isAuthenticated=isPortalUser();
		prefillRequest();
		goHomeUrl=SystemSettings.goHome().getUrl();
	}
	
	private Boolean isAuthenticated() {
		if (UserInfo.getUserId()!=null) return true;
		else return false;
	}
	
	private Boolean isPortalUser() {
		if (UserInfo.getUserType().contains('CustomerSuccess')) return true;
		else return false;
	}
	
	private void prefillRequest() {
		rq=new Request__c();
		rq.Typ__c='Rückruf';
		rq.Gigaset_Extranet__c=!SystemSettings.isPro;
		rq.Gigaset_Pro__c=SystemSettings.isPro;
		rq.Datum__c=System.today();
		rq.Von__c=System.now().hour()+1<10?'0'+String.valueOf(System.now().hour()+1):'' + String.valueOf(System.now().hour()+1);
		rq.Bis__c=System.now().hour()+2<10?'0'+String.valueOf(System.now().hour()+2):'' + String.valueOf(System.now().hour()+2);
		if (isAuthenticated) {
			Id contactid;
			if (UserInfo.getUserId()!=null) {
				try {
					contactid=[SELECT ContactId FROM User WHERE Id= :UserInfo.getUserId()].ContactId;
				} catch (Exception e) {
					System.debug('PARX User not authenticated or has no Contact Id!');
					SystemSettings.logError('PARX User not authenticated or has no Contact Id! ' + e.getMessage(),'DErueckrufserviceController','prefillRequest','','ERROR');
					if (SystemSettings.isDebug) throw e;
				}
				if (contactid!=null) {
					rq.Kontakt__c=contactid;
					Contact c;
					try {
						c=[SELECT Id, Salutation, Lastname, Firstname, Phone, Briefanrede__c FROM Contact WHERE Id =: contactid];
					} catch (Exception e) {
						System.debug('PARX something went wrong, perhaps contact does not exist?');
						SystemSettings.logError('PARX something went wrong, perhaps contact does not exist? ' + e.getMessage(),'DErueckrufserviceController','prefillRequest','','ERROR');
						if (SystemSettings.isDebug) throw e;
					}
					if (c!=null) {
						rq.Telefon__c=c.Phone;
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
				// custom label
				ApexPages.Message pm = new ApexPages.Message(ApexPages.Severity.FATAL,System.label.callback_not_send);
				ApexPages.addMessage(pm);
				//messages=System.label.callback_not_send;
				if (SystemSettings.isDebug) throw e;
			}
		}
		return retval;
	}
	
	private PageReference redirectToLogin() {
		PageReference basispage=Page.page;
		PageReference login=new PageReference( basispage.getUrl() + '?pageid=' + SystemSettings.loginpageid);
		login.setRedirect(true);
		return login;
	}

	// actions
	 public PageReference saveRequest() {
	 	success=insertRequest();
	 	if (success)
	 		showform=false;
	 	return null;
	 }
	 
	 public PageReference init() {
	 	if (!isAuthenticated) return redirectToLogin();
	 	return null;
	 }
}