trigger onKontakt on Contact (after insert, after update) {
	
	if(!salesforce2magento.inFutureContext && (trigger.isInsert || trigger.isUpdate)) {

		list<String> Ids = new list<String>();
		Integer i=0;
		for(Contact c:trigger.new){
			if((c.MagentoId__c == null || c.MagentoId__c == '') && c.Anlage_in_Magento__c && (trigger.isInsert || (trigger.isUpdate && trigger.old[i].Anlage_in_Magento__c == false)))
				Ids.add(c.Id);
			i++;
		}
		if(!Ids.isEmpty()) {
			salesforce2magento.job(Ids, false, false);
		}
	}
}