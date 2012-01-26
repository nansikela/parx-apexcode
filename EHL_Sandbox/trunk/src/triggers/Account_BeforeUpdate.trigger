trigger Account_BeforeUpdate on Account (before update) {
	for(Account currentAccount : trigger.new)
	{
		currentAccount.Number_of_Contracts__c = 0;
	}
	
	
	for(AggregateResult a : [SELECT count(id) counter, AccountId AccountId FROM Contract WHERE AccountId IN :trigger.newMap.keySet() GROUP BY AccountId])
	{
		if(String.valueOf(a.get('AccountId'))!= null && String.valueOf(a.get('AccountId'))!= '')
		{
			trigger.newMap.get((id)(a.get('AccountId'))).Number_of_Contracts__c = Double.valueOf(a.get('counter'));
		}
	}
}