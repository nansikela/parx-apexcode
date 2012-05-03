@RestResource(urlMapping='/Wombat/Status/*')
global class wombat_UpdateSessionStatus {
	@HttpPost
	global static wombat_Sync_Object updateSessionStatus(String sessionID, String userID, Integer status) {
		wombat_Sync_Object wso = new Wombat_Sync_Object();
		wso.Success = true; 
		
		try {
			User u = [SELECT LastTransactionStatus__c FROM User WHERE Id = :userID LIMIT 1];
			if (u != null) {
				u.Wombat_Sync_Session_ID__c = sessionID;
				u.LastTransactionStatus__c = status;
				update u;
			}			
		} catch(Exception ex) {
			wso.Success = false;
			wso.Messages.add(ex.getMessage());
		}
		
		return wso;
	}
}