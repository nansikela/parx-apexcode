global class ContacttoUser {
	
	static list<Map<String, User>> userdeeplist = new list<Map<String, User>>();

	static String emailencodingkey='UTF-8';

	static String timezonesidkey='Europe/Berlin';
	static list<Set<String>> unames= new list<Set<String>>();
	
	//@future(callout=true) 
	public static void init() {	
		getContact();
		cleanOutExistingUsers();
		if(!userdeeplist.isEmpty()) {
			insertUser();
		}
      }
      
      public static void changeEmail() {
      	updateContact();
      }
      private static void updateContact() {
      	list<User> UsertoUpdate = new list<User>();
      	list<Contact> ContacttoUpdate = new list<Contact>();
      	
      	for (User u: [Select Contact.Email, Contact.Portal__c, Email, Id From User WHERE Contact.toUpdate__c=True]) {
      		u.Email = u.Contact.Email;
      		UsertoUpdate.add(u);
      	}
      	if(!UsertoUpdate.isEmpty()) {
      		try {
      			update UsertoUpdate;
      		}
      		catch(exception e) {
      			String error = '';
      			String PortalContact = '';
      			for(User us:UsertoUpdate) {
      				error += us.Id + ' ';
      				PortalContact += us.Contact.Portal__c + ',';
      			}
      			SystemSettings.logError(e.getMessage() + error, PortalContact, 'UserUpdateError');
      		}
      	}
      		 
      	for (Contact c: [Select toUpdate__c, Id, Portal__c From Contact WHERE toUpdate__c=True]) {
			c.toUpdate__c = false;
			ContacttoUpdate.add(c);
      	}
      		try {
      			update ContacttoUpdate;
      		}
      		catch(exception e) {
      			String error = '';
      			String PortalContact = '';
      			for(Contact con:ContacttoUpdate) {
      				error += con.Id + ' ';
      				PortalContact += con.Portal__c + ',';
      			}
      			SystemSettings.logError(e.getMessage(), PortalContact, 'UserUpdateError');
      		}
      } 
      
      
      private static void getContact() {
      	Integer i=0;
		Integer j=0;
		Integer k=0;
		Boolean hasContact = false;
		
		if (userdeeplist.isEmpty()) {
			userdeeplist.add(new Map<String, User>());
			unames.add(new Set<String>());
		} else {
			i=userdeeplist.size();
			j=unames.size();
		}
		List<GlobalSettings__c> settings = GlobalSettings__c.getall().values();
	
		map<String, map<Boolean, GlobalSettings__c>> GSettings = new map<String, map<Boolean, GlobalSettings__c>>();
		for(GlobalSettings__c GS:settings) {
			if(GSettings.containsKey(GS.Portal__c))
				GSettings.get(GS.Portal__c).put(GS.isPro__c, GS);
			else
				GSettings.put(GS.portal__c, new map<Boolean, GlobalSettings__c> {
					GS.isPro__c => GS});
		}
		
		list<contact> toUpdate = new list<Contact>();
		list<Case> ca = new list<Case>([select id, ContactId, Case.Contact.Email from Case where isAlreadyPortalUser__c = False AND (Contact.Email != null OR Contact.Email != '') ]);
		list<String> Ids = new list<String>();
		for(Case temp:ca) {
			Ids.add(temp.ContactId);
		}
		
    	for (Contact c: [SELECT c.Id, c.Lastname, c.Firstname, c.Email, c.AccountId, c.Account.Portal__c, Gigaset_Pro__c, Portal__c FROM Contact c WHERE (toActivate__c=True OR Id IN: Ids) AND (Email!= Null OR Email!= '')]) {
			hasContact = true;
			if (userdeeplist.get(i).size()==1000) {
				userdeeplist.add(new map<String, User>()); 
				i++;
			}
			if (unames.get(j).size()==1000) {
				unames.add(new Set<String>());
				j++;
			}
			User u=new User(
				alias=c.Firstname!=null?c.Firstname.substring(0,1):''+c.LastName.substring(0,3),
				email=c.Email,
				//email=testemail,
				username=c.Email,
				emailencodingkey=emailencodingkey,
				contactId=c.id,
				timezonesidkey=timezonesidkey,
				lastname=c.Lastname,
				firstname=c.FirstName!=null?c.Firstname:''
				);
			if(GSettings.containsKey(c.Account.Portal__c.toLowerCase()) 
				&& GSettings.get(c.Account.Portal__c.toLowerCase()).containsKey(c.Gigaset_Pro__c) 
				&& GSettings.get(c.Account.Portal__c.toLowerCase()).get(c.Gigaset_Pro__c).Profile_Id__c!=null
				&& GSettings.get(c.Account.Portal__c.toLowerCase()).get(c.Gigaset_Pro__c).Sprache__c!=null
				&& GSettings.get(c.Account.Portal__c.toLowerCase()).get(c.Gigaset_Pro__c).Gebietsschema__c!=null
				) {

	 				u.profileid = GSettings.get(c.Account.Portal__c.toLowerCase()).get(c.Gigaset_Pro__c).Profile_Id__c;

					u.languagelocalekey = GSettings.get(c.Account.Portal__c.toLowerCase()).get(c.Gigaset_Pro__c).Sprache__c;

					u.localesidkey = GSettings.get(c.Account.Portal__c.toLowerCase()).get(c.Gigaset_Pro__c).Gebietsschema__c;
			}
			else {
				SystemSettings.logError('problem bei den Custom Settings. bitte prüfen!', 'ContacttoUser', 'insertUsers', '', 'UserUpdateError');
				continue;
			}
			
			if (!userdeeplist.get(i).containsKey(c.Email)) 
				userdeeplist.get(i).put(c.Email, u);
			else {
				SystemSettings.logError('duplicate email address:'+ c.Email, c.Portal__c, 'UserUpdateError');
				continue;
			}
			
			c.toActivate__c = false;
			c.Autofreischaltung__c = true;
			toUpdate.add(c);
			
		}
		
		if(!ca.isEmpty() || hasContact)
			UpdateCaseContact(Ids );

      }
      
      private static void cleanOutExistingUsers() {
		if (!userdeeplist.isEmpty()) {
			for (Integer i=0;i<userdeeplist.size();i++) {
				for (User u: [SELECT Id, Username, Contact.Portal__c FROM User WHERE Username IN: userdeeplist.get(i).keySet()]) {
					if (userdeeplist.get(i).containsKey(u.Username)) {
						userdeeplist.get(i).remove(u.Username);
						SystemSettings.logError('duplicate username: ' + u.Username, u.Contact.Portal__c, 'UserUpdateError');
					}
				}
			}
		}
	}
	
	static void insertUser() {
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerUserEmail = true;
		Boolean hasError=false;
		for (Integer i=0; i<userdeeplist.size();i++) {
			for (User u: userdeeplist.get(i).values()) {
				u.setOptions(dmo);
			} 
			Savepoint sp = database.setSavepoint();
			try {
				insert userdeeplist.get(i).values();
			} catch (System.DmlException e) { 
				database.rollback(sp);
				String PortalContact = '';
				for(User u:userdeeplist.get(i).values()) {
					PortalContact += u.Contact.Portal__c + ',';
				}
				SystemSettings.logError(e.getMessage(), 'de', 'UserUpdateError');
			}			
		}
	}
	
	@future(callout=true)
	static void UpdateCaseContact(list<String> Ids ) {
		list<Case> ca = new list<Case>([select id, ContactId, Case.Contact.Email, isAlreadyPortalUser__c from Case where isAlreadyPortalUser__c = False AND (Contact.Email != null OR Contact.Email != '') ]);
    		list<Contact> co = new list<Contact>([SELECT c.Id, c.Lastname, c.Firstname, c.Email, c.Autofreischaltung__c, toActivate__c, c.AccountId, c.Account.Portal__c FROM Contact c WHERE (toActivate__c=True OR Id IN: Ids) AND (Email!= Null OR Email!= '')]);
		
		for(Case caTemp:ca){
			if(caTemp.Contact.Email != null && caTemp.Contact.Email != '')
				caTemp.isAlreadyPortalUser__c = True;
		}
		
		for(Contact coTemp:co){
			coTemp.Autofreischaltung__c = true;
			coTemp.toActivate__c = false;
		}	
		  
			
		if(!ca.isEmpty()){
			try{
				update ca;
				}
      		catch(exception e) {
      			String error = '';
      			for(Case cas:ca) {
      				error += cas.Id + ' ';
      			}
      			SystemSettings.logError(e.getMessage(), 'ContacttoUser.UpdateCaseContact', 'Bug on Case', error, 'UserUpdateError');
      		}
		}
		if(!co.isEmpty()){
			try {
				update co;
			}
      		catch(exception e) {
      			String error = '';
      			String PortalContact = '';
      			for(Contact con:co) {
      				error += con.Id + ' ';
      				PortalContact += con.Portal__c + ',';
      			}
      			SystemSettings.logError(error, PortalContact,'UserUpdateError');
      		}
		}
	}
			
}