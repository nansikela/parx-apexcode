trigger onLizenz on Lizenz__c (after insert, after update) {
	
	list<String> mediaIds = new list<String>();
	list<String> lizenzIds = new list<String>();
	
	
	if(trigger.isInsert) {
		for(Lizenz__c trig:trigger.new) {
			if(trig.Aktiv__c == true && trig.MED017__c != null) {
				mediaIds.add(trig.MED017__c); //medienart id
				lizenzIds.add(trig.Id);
			}
		}
	}
	
	if(trigger.isUpdate) {
		for(Lizenz__c trig:trigger.new) {
			if((trig.Aktiv__c == true && trigger.oldMap.get(trig.Id).Aktiv__c == false && trig.MED017__c != null)) {
				mediaIds.add(trig.MED017__c); //medienart id
				lizenzIds.add(trig.Id);
			}
		}
	}
	if(!lizenzIds.isEmpty())
		onLizenz.listtodo(lizenzIds, mediaIds);
}