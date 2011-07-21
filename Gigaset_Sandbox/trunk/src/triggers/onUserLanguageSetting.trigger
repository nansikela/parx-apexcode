trigger onUserLanguageSetting on User (before insert, before update) {

	if (trigger.isInsert) {
		for (User u: trigger.new) {
			u.LanguageSetting__c=u.LanguageLocaleKey;
		}
	}
	
	if (trigger.isUpdate) {
		for (User u: trigger.new) {
			if (trigger.oldMap.get(u.id).LanguageLocaleKey!=u.LanguageLocaleKey || (!trigger.oldMap.get(u.id).isActive && u.IsActive))
				u.LanguageSetting__c=u.LanguageLocaleKey;
		}
	}
}