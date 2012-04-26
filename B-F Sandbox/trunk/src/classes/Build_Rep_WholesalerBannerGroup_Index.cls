public with sharing class Build_Rep_WholesalerBannerGroup_Index {
	public void BuildIndex(string repUserName) {
		List<Banner_Group_Wholesaler_Junction__c> bwList = [SELECT Id FROM Banner_Group_Wholesaler_Junction__c];
		delete bwList;
		
		string soql = 'SELECT Id, Name, Banner_Group__c, (SELECT Id, Name, Wholesaler__c, Banner_Partner__c FROM Account_Wholesaler__c) FROM Account';
		if (repUserName != null && repUserName.length() > 0) {
			List<User> users = [SELECT Id FROM User WHERE UserName =:repUserName];
			if (users != null && users.size() > 0) {
				soql += ' WHERE OwnerId = \'' + users[0].Id + '\'';				
			}
		}
		
		soql += ' ORDER BY OwnerId';
		List<Account> accounts = Database.query(soql);

		Set<String> combinations = null;		
		List<Banner_Group_Wholesaler_Junction__c> banList = new List<Banner_Group_Wholesaler_Junction__c>();
		Map<Id, Set<String>> uniqueKeys = new Map<Id, Set<String>>();		
		String uniqueKey = '';
		boolean keyFound = false;
		
		for(Account a: accounts) {
			if (a.Wholesalers__r != null) {
				for(Account_Wholesaler__c aw: a.Wholesalers__r) {
					keyFound = false;
					uniqueKey = aw.Wholesaler__c + '-' + aw.Banner_Partner__c;
					combinations = uniqueKeys.get(a.OwnerId);
					if (combinations == null || combinations.size() == 0) {
						combinations = new Set<String>();
					}
					if (!combinations.contains(uniqueKey)) {
						combinations.add(uniqueKey);
						uniqueKeys.put(a.OwnerId, combinations);
						
						Banner_Group_Wholesaler_Junction__c iObj = new Banner_Group_Wholesaler_Junction__c();
						iObj.Banner_Group__c = aw.Banner_Partner__c;
						iObj.Wholesaler__c = aw.Wholesaler__c; 
						iObj.OwnerId = a.OwnerId;
						banList.add(iObj);						
					}
				}
			}
		}
		
		if (banList.size() > 0) {
			insert banList;
		}
	}
}