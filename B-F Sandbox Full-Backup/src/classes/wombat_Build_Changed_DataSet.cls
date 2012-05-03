@RestResource(urlMapping='/Wombat/SyncChanges/*')
global with sharing class wombat_Build_Changed_DataSet {

	@HttpPost
	global static wombat_Sync_Object buildChangeDataSet(string sessionId, string ownerId, string lastSyncDate, List<List<String>> objectDescribeInfo, List<List<String>> filterInfo) {
		List<wombat_Sync_Audit__c> auditLog = new List<wombat_Sync_Audit__c>();

		wombat_Sync_Object wso = new wombat_Sync_Object();
		wombat_Sync_Item wsi;
		wombat_Sync_Item rtiwi;
		
		List<String> recordTypeInfoColumnNames = new String[]{'SObjectType','Id','Name','IsAvailable','IsDefaultRecordTypeMapping'};
		
		String whereClause = '';
		DateTime dt = DateTime.valueOf(lastSyncDate);
		string dtGMT = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
				
		updateAuditLog(auditLog, sessionId, 'Getting any data that has been changed since ' + dtGMT);
		
		try {
			String soql = '';
			Map<String, Schema.SObjectType> go = Schema.getGlobalDescribe();
			//updateAuditLog(auditLog, sessionId, 'Number of items to check: ' + go.size());
			for(List<String> o: objectDescribeInfo) {
				wsi = new wombat_Sync_Item();
				wsi.Object_API_Name = o[0];
				o.remove(0);
	
				
				updateAuditLog(auditLog, sessionId, 'building soql for ' + wsi.Object_API_Name);
				if (go.containsKey(wsi.Object_API_Name)) {
					Schema.Sobjecttype targetType = go.get(wsi.Object_API_Name);
					Schema.Describesobjectresult describeResult = targetType.getDescribe();				
					//Map<String, SObjectField> flds = targetType.getDescribe().fields.getMap();
					Map<String, SObjectField> flds = describeResult.fields.getMap();
					
					//updateAuditLog(auditLog, sessionId, 'Object_API_Name: ' + wsi.Object_API_Name + ', targetType: ' + targetType + ', number of fields: ' + flds.size() + ', number of fields in object describe: ' + o.size());
					soql = '';
					for(String s: o) { 
						if (flds.containsKey(s)) {
							soql += s + ', ';					
						}
					}
					
					if (soql.length() > 0) {
						integer pos = soql.lastIndexOf(',');
						if (pos >= 0) {
							soql = soql.substring(0, pos);					
						}
					
						soql = 'SELECT ' + soql + ' FROM ' + wsi.Object_API_Name;
						
						whereClause = '';
						for(List<String> fo: filterInfo) {
							if (fo[0] == wsi.Object_API_Name) {
								whereClause = fo[3];
								integer numberOfStrings = fo.size();
								for (Integer ii = 4; ii < numberOfStrings; ii++) {
									whereClause = whereClause.replace('?', '\'' + String.escapeSingleQuotes(fo[ii]) + '\'');							
								}
								break;
							}
							System.debug('fo: ' + fo);
						}
						
						if (whereClause.length() > 0) {
							whereClause += ' AND LastModifiedDate > ' + dtGMT;
						} else {
							whereClause = ' WHERE LastModifiedDate > ' + dtGMT;						
						}
						/*
						if (selectByOwner == true) {
							if (ownerFieldName.length() == 0) { ownerFieldName = 'OwnerId'; }
							if (flds.containsKey(ownerFieldName)) {
								whereClause += ' AND ' + ownerFieldName + ' = \'' + ownerId + '\'';
							}					
						}
						*/
						soql += whereClause;
					
						//soql += ' LIMIT 10';
						//updateAuditLog(auditLog, sessionId, 'soql: ' + soql);
						//updateAuditLog(auditLog, sessionId, 'whereClause: ' + whereClause);
						wsi.records = Database.query(soql);
						//updateAuditLog(auditLog, sessionId, 'number of rows with changes: ' + wsi.records.size() + ' for object ' + wsi.Object_API_Name);
						wso.Items.add(wsi);
						
					}
					
					/*
					// Get RecordTypeInfos for object
					List<Schema.RecordTypeInfo> infos = describeResult.getRecordTypeInfos();
					for(Schema.RecordTypeInfo rtiInfo: infos) {
						rtiwi = new wombat_Sync_Item();
						rtiwi.Object_API_Name = 'Salesforce_RecordType_Infos';
						rtiwi.ColumnNames.addAll(recordTypeInfoColumnNames);
						rtiwi.ColumnValues.add(wsi.Object_API_Name);
						rtiwi.ColumnValues.add(rtiInfo.getRecordTypeId());
						rtiwi.ColumnValues.add(rtiInfo.getName());
						rtiwi.ColumnValues.add(String.valueOf(rtiInfo.isAvailable()));
						rtiwi.ColumnValues.add(String.valueOf(rtiInfo.isDefaultRecordTypeMapping()));
	
						wso.Items.add(rtiwi);
					}
					*/
				} else {
					System.debug(wsi.Object_API_Name + ' does not exist');
				}			
			}
		
			updateAuditLog(auditLog, sessionId, 'Number of items to check: ' + go.size() + ', checked ' + wso.totalItems);	
		} catch (Exception ex) {
			updateAuditLog(auditLog, sessionId, 'Exception raised trying to get data changes. ' + ex.getMessage());
		} finally {
			insert auditLog;			
		}
		
		
		return wso;
	}
	
	private static void updateAuditLog(List<wombat_Sync_Audit__c> auditLog, String sessionID, String message) {
		wombat_Sync_Audit__c wsa = new wombat_Sync_Audit__c();
		wsa.wombat_Sync_Session__c = sessionId;
		wsa.Message__c = message;
		
		auditLog.add(wsa);
	}
	
}