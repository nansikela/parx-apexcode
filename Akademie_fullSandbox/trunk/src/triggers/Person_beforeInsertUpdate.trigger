trigger Person_beforeInsertUpdate on Person__c (before insert, before update) {
	List<String>vorgesetztereMailAddressList = new List<String>(); 
	for(Person__c p : trigger.new)
	{
		if(p.eMail_Adresse_Vorgesetzter__c != null )
		{
			vorgesetztereMailAddressList.add(p.eMail_Adresse_Vorgesetzter__c);
		}
	}
	
	if(vorgesetztereMailAddressList.size()>0)
	{
		//Vorgesetzter to Map
		Map<String, String> eMail2Vorgesetzter = new Map<String, String>();
		for(Person__c v : [SELECT id, eMail__c FROM Person__c WHERE eMail__c != null AND eMail__c IN :vorgesetztereMailAddressList LIMIT 200])
		{
			eMail2Vorgesetzter.put(v.eMail__c, String.valueOf(v.id));
		}
		
		//Person Vorgesetzter zuordnung
		for(Person__c p: trigger.new)
		{
			if(p.eMail_Adresse_Vorgesetzter__c != null && eMail2Vorgesetzter.containsKey(p.eMail_Adresse_Vorgesetzter__c))
			{
				p.Vorgesetzer__c = eMail2Vorgesetzter.get(p.eMail_Adresse_Vorgesetzter__c);
			}
			
		}
	}
	
	
}