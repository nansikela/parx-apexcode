public class DEuserprofileportletController {
	
	public String userid { get; set; }
	public String contactid { get; set; }
	public Contact contact { get; set; }
	pageReference CMSpage = Page.page;
	
	public DEuserprofileportletController() {
		userid=UserInfo.getUserId();
		if (userid!=null) {
			try {
				contactid=SystemSettings.contactid;
				if (contactid==null) contactid=[SELECT Id, contactId FROM User WHERE Id =:userid AND isActive=true].contactid;
			} catch (System.QueryException e) {
				System.debug('PARX User Query Error: ' + e.getMessage());
				SystemSettings.logError('PARX  User Query Error: ' + e.getMessage(),'DEuserprofileportletController','getContacts','','ERROR');
			}
		}
		if (contactid!=null) {
			try {
				contact=SystemSettings.currentusercontact;
				if (contact==null) contact=[SELECT Id, Lastname, Firstname, Email FROM Contact WHERE Id =:contactid ];
			} catch (System.QueryException e) {
				System.debug('PARX Contact Query Error: ' + e.getMessage());
				SystemSettings.logError('PARX  Contact Query Error: ' + e.getMessage(),'DEuserprofileportletController','getContacts','','ERROR');
			}
		}
	}
	
	// getter
	public String getBenutzerdatenUrl() {
		return CMSpage.getUrl() + '?pageid=' + SystemSettings.userdatapageid;
	}
	
	// actions
	 public PageReference init() {
	 	return null;
	 }

}