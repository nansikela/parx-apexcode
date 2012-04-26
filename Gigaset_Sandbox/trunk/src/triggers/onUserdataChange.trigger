trigger onUserdataChange on User (after update) {

	map<Id, User> selectiveMap=new map<Id, User>();
	
	for (User u: trigger.new) {
		if (u.id==UserInfo.getUserId() && !String.valueOf(u.UserType).contains('Partner')) {
			selectiveMap.put(u.id, u);
		}
	}
	TransferUserData.updateContact(selectiveMap);
}