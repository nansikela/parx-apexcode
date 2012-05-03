/* Class Name : StoreCheckApproval
* Description: Webservice controller for diverse approval functionality
* Created By : Germany Consultant
* Created On : 04/16/12
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       		Date			Description
* ----------------------------------------------------------------------------------------------------------------------------
* Michael Mickiewicz 	04/16/2012		Creating the init method that creates manual sharings for sales rep. and owner 
* 						04/17/2012		Creating Unit Tests with source code documentation
*/ 
global class StoreCheckApproval {
	
	webService static String init(String[] ids) {
		
		if(ids == null || ids.size()  == 0)
			return Label.sc_approval_no_selection;
			
		//Query all store check records with necessary field information
		list<Store_Check__c> scs = [Select ID, sr__c, OwnerID From Store_Check__c Where ID IN :ids];
		//Map should help to identify all store check records that does not have a sales rep who is also the owner of the record!
		map<ID, Boolean> ownerSrEqualMap = new map<ID,Boolean>();
		//All managed sharing rules
		list<Store_Check__Share> sharingrules = new list<Store_Check__Share>();
		Database.SaveResult[] lsr;
		
		//Build the map
		for(Store_Check__c sc : scs)
			if(sc.OwnerID == sc.sr__c)
				ownerSrEqualMap.put(sc.ID, true);
			else
				ownerSrEqualMap.put(sc.ID, false);
		
		for(Store_Check__c sc : scs) {	
			// Create new sharing object for the custom object Job.   
     		Store_Check__Share scShr  = new Store_Check__Share();
    
      		// Set the ID of record being shared. 
      		scShr.ParentId = sc.ID;
         
      		// Set the ID of user or group being granted access. 
      		scShr.UserOrGroupId = sc.SR__c;
        
      		// Set the access level. 
      		scShr.AccessLevel = 'edit';
      		scShr.RowCause = Schema.Store_Check__Share.RowCause.Manual;
      		 
      		sharingrules.add(scShr);
		}
		try {
			lsr = Database.insert(sharingrules,false);
		} catch(Exception e) {
			system.debug(e);
			return Label.sc_approval_sharing_error;
		}

        String resultMsg = '';
		for(String id : ownerSrEqualMap.keySet())
			if(!ownerSrEqualMap.get(id))
				resultMsg = Label.sc_approval_sr_inconsistency;
		
		return resultMsg;
	}
	
	static testMethod void test() {
		//Focus test users
		User u1 = [Select ID From User Where Profile.Name = 'System Administrator' limit 1];
		User u2 = [Select ID From User Where Profile.Name LIKE 'DEU_%_Manager' limit 1];
		list<Store_Check__c> scs = new list<Store_Check__c>();
		
		//Run first test as system admin to create test data and avoid visibility 
		//of records for underlying roles
		system.runas(u1) {
			Account a = new Account(Name = 'Test German Account');
			insert a;
			
			scs.add(new Store_Check__c(SR__c = u1.ID, Account__c = a.ID));
			scs.add(new Store_Check__c(SR__c = u2.ID, Account__c = a.ID));
		
			insert scs;
			system.debug(scs);
		}
		
		//Check if the store check record is visible for the user who is assigned as sales rep.
		system.runas(u2) {
			list<Store_Check__c> temp = [Select ID From Store_Check__c WHERE ID = :scs.get(1).ID];
			
			system.debug(temp);
			system.assertEquals(0, temp.size());
		}
		
		//Let's create the manual sharing rule to test the webservice for the custom button
		//as system admin that is also the user seeing all created records
		system.runas(u1) {
			list<String> ids = new list<String>();
			
			String result = StoreCheckApproval.init(ids);
			system.assertEquals(result, Label.sc_approval_no_selection);
			
			for(Store_Check__c sc : scs)
				ids.add(sc.ID);

        	result = StoreCheckApproval.init(ids);
        	system.assertEquals(result, Label.sc_approval_sr_inconsistency);
		}
		
		//Check if the store check record is visibile that contains the second user as sales rep
		system.runas(u2) {
			list<Store_Check__c> temp = [Select ID From Store_Check__c WHERE ID = :scs.get(1).ID];
			system.assertEquals(1, temp.size());
		}
    }	
}