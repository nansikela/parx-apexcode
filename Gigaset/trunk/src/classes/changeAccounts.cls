public class changeAccounts {

	private static map<id, Account> accounts = new map<id, Account>();
	
	public static void ChangeAccounts(list<Id> accountids) {
		for(Account a : [SELECT Id, Gigaset_pro__c FROM Account WHERE Id IN :accountids]){
			a.Gigaset_pro__c = false;
			accounts.put(a.Id, a);
		}
					
		for(Contact c : [SELECT Id, Name, Gigaset_pro__c, AccountId FROM Contact WHERE AccountId IN :accounts.values()])
			if(c.Gigaset_Pro__c == true) 
				accounts.get(c.AccountId).Gigaset_pro__c = true;
		
		update accounts.values();
	}
}