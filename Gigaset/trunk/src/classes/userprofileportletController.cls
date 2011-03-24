public class userprofileportletController {
	
	public String userid { get; set; }
	public String contactid { get; set; }
	public Contact contact { get; set; }
	pageReference CMSpage = Page.page;
	
	public userprofileportletController() {
		userid=UserInfo.getUserId();
		if (userid!=null) {
			try {
				contactid=[SELECT Id, contactId FROM User WHERE Id =:userid AND isActive=true].contactid;
			} catch (System.QueryException e) {
				System.debug('PARX User Query Error: ' + e.getMessage());
				System_Settings.logError('PARX  User Query Error: ' + e.getMessage(),'DEuserprofileportletController','getContacts','','ERROR');
				if (System_Settings.isDebug) throw e;
			}
		}
		if (contactid!=null) {
			try {
				contact=[SELECT Id, Lastname, Firstname, Email FROM Contact WHERE Id =:contactid ];
			} catch (System.QueryException e) {
				System.debug('PARX Contact Query Error: ' + e.getMessage());
				System_Settings.logError('PARX  Contact Query Error: ' + e.getMessage(),'DEuserprofileportletController','getContacts','','ERROR');
				if (System_Settings.isDebug) throw e;
			}
		}
	}
	
	// getter
	public String getBenutzerdatenUrl() {
		return CMSpage.getUrl() + '?pageid=' + System_Settings.userdatapageid;
	}
	
	// actions
	 public PageReference init() {
	 	return null;
	 }
	 
	 public static testMethod void testUserprofileportletController() {
	 	User u = [SELECT Id, ContactId FROM User WHERE isActive=true AND ContactId!=null limit 1];
	 	userprofileportletController ctrl = new userprofileportletController();
	 	ctrl.init();
	 	ctrl.getBenutzerdatenUrl();
	 	
	 	ctrl.userid=u.id;
	 	ctrl.contactid=u.ContactId;
	 	
	 }

}