public with sharing class Build_Rep_WholesalerBannerGroup_Index {
	public void BuildIndex(string repUserName) {
		List<Banner_Group_Wholesaler_Junction__c> bwList = [SELECT Id FROM Banner_Group_Wholesaler_Junction__c];
		delete bwList;
		
		string soql = 'SELECT Id, Wholesaler__c, Banner_Partner__c, Account_Owner_Id__c, OwnerId FROM Account_Wholesaler__c ';
		if (repUserName != null && repUserName.length() > 0) {
			List<User> users = [SELECT Id FROM User WHERE UserName =:repUserName];
			if (users != null && users.size() > 0) {
				soql += ' WHERE Account_Owner_Id = \'' + users[0].Id + '\'';				
			}
		}
		
		soql += ' ORDER BY OwnerId';
		List<Account_Wholesaler__c> items = Database.query(soql);

		Set<String> combinations = null;		
		List<Banner_Group_Wholesaler_Junction__c> banList = new List<Banner_Group_Wholesaler_Junction__c>();
		Map<Id, Set<String>> uniqueKeys = new Map<Id, Set<String>>();		
		String uniqueKey = '';
		boolean keyFound = false;
		
		for(Account_Wholesaler__c aw: items) {
			uniqueKey = aw.Wholesaler__c + '-' + aw.Banner_Partner__c;
			combinations = uniqueKeys.get(aw.Account_Owner_Id__c);
			if (combinations == null) { combinations = new Set<String>(); }
			if (!combinations.contains(uniqueKey)) {
				combinations.add(uniqueKey);
				uniqueKeys.put(aw.Account_Owner_Id__c, combinations);
				
				Banner_Group_Wholesaler_Junction__c iObj = new Banner_Group_Wholesaler_Junction__c();
				//iObj.Banner_Group__c = aw.Banner_Partner__c;
				iObj.Wholesaler__c = aw.Wholesaler__c; 
				if (aw.Account_Owner_Id__c != null && aw.Account_Owner_Id__c.length() > 0) {
					iObj.OwnerId = aw.Account_Owner_Id__c;					
				} else {
					iObj.OwnerId = aw.OwnerId;
				}
				banList.add(iObj);						
			}
		}
		
		if (banList.size() > 0) {
			insert banList;
		}
	}
}