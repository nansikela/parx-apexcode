trigger beforeInsertUpdateDeal on Group_Promotions__c (before insert, before update) {
	for(Group_Promotions__c gp: Trigger.new) {
		if (gp.Deal_Type__c == 'OnGoing') {
			gp.Promotion_Period_Start_Date__c = gp.Buy_Period_Start_Date__c;
			gp.Promotion_Period_End_Date__c = gp.Buy_Period_End_Date__c;
		}
		
		string soql = 'SELECT Id, Name, Condition__c FROM Vistex_Agreement_Types__c WHERE Channel__c = \'' + gp.Deal_Channel__c + '\' AND Method__c = \'' + gp.Deal_Method__c + '\' AND Application__c = \'' + gp.Application__c + '\' AND Activity__c includes (\'' + gp.Activity_Code__c + '\')'; 
		List<Vistex_Agreement_Types__c> vtypes = Database.query(soql);
		if (vtypes != null && vtypes.size() > 0) {
			gp.Vistex_Agreement_Type__c = vtypes[0].Name;
			gp.Vistex_Condition_Type__c = vtypes[0].Condition__c;
		} else {
			gp.Vistex_Agreement_Type__c = 'unknown';
		}
	}
}