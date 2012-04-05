@RestResource(urlMapping='/Wombat/Graveyard/*')
global class wombat_Graveyard {
	
	@HttpPost
	global static List<wombat_Graveyard_Item> getGraveyardItems(String objectName, String userId, String lastSyncDate) {
		List<wombat_Graveyard_Item> wgi;
		
			DateTime syncDate;
			System.debug('lastSyncDate: ' + lastSyncDate);
			try {
				syncDate = DateTime.valueOf(lastSyncDate);
				
				System.debug('syncdate parsed: ' + syncDate + ', lastSyncDate: ' + lastSyncDate);
			}catch(Exception ex) {
				syncDate = DateTime.now();
				System.debug('syncdate defaulted to ' + syncDate);
			}

		if (objectName == null || objectName.length() == 0) {
			List<wombat_Mobile_Config__c> wombatObjects = [SELECT Object_API_Name__c FROM wombat_Mobile_Config__c WHERE IsActive__c = true AND IsGraveyardable__c = true];
			if (wombatObjects.size() > 0) {
				for (wombat_Mobile_Config__c wmc: wombatObjects) {
					wgi = getObjectGraveyardItems(wmc.Object_API_Name__c, userId, syncDate, wgi);
				}				
			}
		} else {
			wgi = getObjectGraveyardItems(objectName, userId, syncDate, wgi);
		}
		
		return wgi;
	}
	
	private static List<wombat_Graveyard_Item> getObjectGraveyardItems(String objectName, String userId, DateTime lastSyncDate, List<wombat_Graveyard_Item> graveyardItems) {
		if (graveyardItems == null) { graveyardItems = new List<wombat_Graveyard_Item>(); }
		
		if (objectName == null || objectName.length() == 0) { return graveyardItems; }
		if (userId == null || userId.length() == 0) { return graveyardItems; }
		if (lastSyncDate == null) { lastSyncDate = DateTime.now(); }
		
		String m = String.valueOf(lastSyncDate.month());
		if (m.length() < 2) { m = '0' + m; }
		String d = String.valueOf(lastSyncDate.day());
		if (d.length() < 2) { d = '0' + d; }
		String h = String.valueOf(lastSyncDate.hour());
		if (h.length() < 2) { h = '0' + h; }
		String mi = String.valueOf(lastSyncDate.minute());
		if (mi.length() < 2) { mi = '0' + mi; }
		String s = String.valueOf(lastSyncDate.second());
		if (s.length() < 2) { s = '0' + s; }
		
		String soqlQuery = 'SELECT Id FROM ' + objectName + ' WHERE IsDeleted = true AND CreatedById = \'' + userId + '\'';
		soqlQuery += ' AND LastModifiedDate > ' + lastSyncDate.year() + '-' + m + '-' + d + 'T' + h + ':' + m + ':' + s + 'Z';
		soqlQuery += ' ALL ROWS';
		
		System.debug('soql: ' + soqlQuery);
		List<sObject> items = Database.query(soqlQuery);
		if (items != null) {
			wombat_Graveyard_Item i;
			for (sObject o: items) {
				i = new wombat_Graveyard_Item();
				i.Id = o.Id;
				i.ObjectName = String.valueOf(o.getSObjectType());
				graveyardItems.add(i);
			}
		}			
		
		return graveyardItems;
	}
}