trigger onContactUpdate on Contact (before update) {
	Integer i=0;
	list<String> Ids = new list<String>();
	
	for(Contact trig:trigger.new) {
		ids.add(trig.Id);
	}
	
	for(User u: [SELECT Id, ContactId, Email FROM User where ContactId IN: Ids]) {
		for(i = 0 ; i < trigger.size ; i ++) {
			if(trigger.new[i].Id == u.ContactId) {
				if(trigger.new[i].Email == '' || trigger.new[i].Email == null)
					trigger.new[i].addError('Email nicht gültig');
				if(trigger.new[i].Email != trigger.old[i].Email)
					trigger.new[i].toUpdate__c = true;
			}
		}
	}

}