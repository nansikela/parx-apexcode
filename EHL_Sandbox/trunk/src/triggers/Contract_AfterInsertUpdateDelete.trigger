trigger Contract_AfterInsertUpdateDelete on Contract (after delete, after insert, after update) {
	Map<id, Account> accountsForUpdate = new Map<id, Account>();
	if(!trigger.isDelete)
	{
		for(Contract currentContract :trigger.new )
		{
			if(currentContract.AccountId != null)
			{
				Account acc = new Account(Id = currentContract.AccountId);
				if(!accountsForUpdate.containsKey(acc.id))
				{
					accountsForUpdate.put(acc.id, acc);
				}
				
				
			}
		}
	}
	
	if(!trigger.isInsert)
	{
		for(Contract currentContract :trigger.old )
		{
			if(currentContract.AccountId != null)
			{
				Account acc = new Account(Id = currentContract.AccountId);
				if(!accountsForUpdate.containsKey(acc.id))
				{
					accountsForUpdate.put(acc.id, acc);
				}
				
				
			}
		}
	}
	if(accountsForUpdate.size()>0)
	{
		update accountsForUpdate.values();
	}
	
}