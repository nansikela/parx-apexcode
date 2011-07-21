global class managePortalUsers {
	
	static map<Id, User> portalusers = new map<Id, User>();
	static map<Id, Contact> portalcontacts = new map<Id, Contact>();
	static map<Id, Group> publicportalgroups  = new map<Id, Group>();
	static map<Id, map<String, GroupMember>> groupmembers = new map<Id, map<String, GroupMember>>();
	static set<String> portals = new set<String>();
	static map<String, Id> groupNameToId = new map<String, Id>();
	static map<Id, Id> contactToUser = new map<Id, Id>();
	
	static list<GroupMember> newgroupmembers = new list<GroupMember>();
	static list<GroupMember> groupmembersToDelete = new list<GroupMember>();
	
	static final String defaultgroupname='KundenportalBenutzer';

	static webservice void managePortalUsers() {
		getPortalUsers();
		getContacts();
		getPublicGroups();
		createMissingGroups();
		getExistingGroupMembers();
		createMissingGroupMembers();
		deleteGroupMembers();
		insertGroupMembers();
	}
	
	private static void getPortalUsers() {
		// there are many Portal Users, we need to split the query
		for(list<User> usersublist: [SELECT Id, Name, isPortalEnabled, isActive, ContactId FROM User WHERE isPortalEnabled=true AND isActive=true AND ContactId!=null]) {
			for (User u: usersublist) {
				if (!portalusers.containsKey(u.id)) portalusers.put(u.id, u);
				contactToUser.put(u.ContactId, u.id);
			}
		}
	}
	
	private static void getContacts() {
		for(list<Contact> contactsublist: [SELECT Id, Portal__c FROM Contact WHERE Id IN :contactToUser.keySet()]) {
			for (Contact c: contactsublist) {
				if (!portals.contains(c.Portal__c.toLowerCase())) portals.add(c.Portal__c.toLowerCase());
				if (!portalcontacts.containsKey(c.id)) portalcontacts.put(c.id,c);
			}
		}
	}
	
	private static void getPublicGroups() {
		for(Group grp: [SELECT Id, Name, Type FROM Group WHERE Name IN :createNameList() AND Type='Regular']) {
			publicportalgroups.put(grp.id, grp);
			groupNameToId.put(grp.Name,grp.Id);
		}
	}

	private static void getExistingGroupMembers() {
		for (GroupMember grpmember: [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g WHERE g.GroupId IN :publicportalgroups.keySet()]) {
			if (!groupmembers.containsKey(grpmember.UserOrGroupId)) groupmembers.put(grpmember.UserOrGroupId, new map<String, GroupMember>());
			if (!groupmembers.get(grpmember.UserOrGroupId).containsKey(grpmember.GroupId)) groupmembers.get(grpmember.UserOrGroupId).put(publicportalgroups.get(grpmember.GroupId).Name, grpmember);
		}
	}
	
	private static void createMissingGroups() {
		list<Group> newgroups = new list<Group>();
		set<String> groupnames= createNameList();
		Integer origsize=groupnames.size();
		for (String groupname: createNameList()) {
			for (Group grp:publicportalgroups.values()) {
				if(groupname==grp.Name) groupnames.remove(groupname);
			}
		}
		if (!groupnames.isEmpty()) {
			for (String groupname:groupnames) {
				newgroups.add(new Group(Name=groupname, Type='Regular'));
			}
			insert newgroups;
			for (Group grp:newgroups) {
				if (grp.id!=null && !publicportalgroups.containsKey(grp.id)) {
					publicportalgroups.put(grp.id, grp);
					groupNameToId.put(grp.Name,grp.Id);
				}
			}
		}
		// check if we really have the complete group list
		System.assertEquals(origsize, publicportalgroups.size());
	}
	
	private static void createMissingGroupMembers() {
		for (User u:portalusers.values()) {
			String portal=defaultgroupname+String.valueOf(portalcontacts.get(u.ContactId).Portal__c).toUpperCase();
			if (groupmembers.containsKey(u.id) && !groupmembers.get(u.id).isEmpty()) {
				// check that existing group is the right one
				set<String> grpnames=groupmembers.get(u.id).keySet();
				for (String grpname : groupmembers.get(u.id).keySet()) {
					if (grpname!=portal) groupmembersToDelete.add(groupmembers.get(u.id).get(grpname));
				}
				if (!grpnames.contains(portal)) {
					newgroupmembers.add(new GroupMember(UserOrGroupId=u.Id,GroupId=groupNameToId.get(portal)));
				}
			} else {
				// create new groupmember
				newgroupmembers.add(new GroupMember(UserOrGroupId=u.Id,GroupId=groupNameToId.get(portal)));
			}
		}
	}
	
	private static void insertGroupMembers() {
		insert newgroupmembers;
	}
	
	private static void deleteGroupMembers() {
		delete groupmembersToDelete;
	}

	private static set<String> createNameList() {
		set<String> retlist=new set<String>();
		for (String s: portals) {
			retlist.add(defaultgroupname + s.toUpperCase());
		}
		return retlist;
	}

}