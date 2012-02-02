global class MonatsAbschlussBatchStart {

	webservice static list<String> start() {
		list<String> result=new list<String>();
		result=startBatches();
		return result;
	}
	
	private static list<String> startBatches() {
		list<String> result=new list<String>();
		String res='';
		res=startAccounts();
		if (res==null) res='';
		result.add(res);
		res=startArtikel();
		if (res==null) res='';
		result.add(res);
		SystemSettings.insertErrors();
		return result;
	}

	private static String startAccounts() {
		String query='SELECT ';
		// create dynamic query
		query+=getAccFields() + ' FROM Account';
		MonatsAbschlussAccountBatch abatch = new MonatsAbschlussAccountBatch(query);
		abatch.Query=query;
		ID batchprocessid = Database.executeBatch(abatch);
		System.assert(batchprocessid!=null);
		return batchprocessid;
	}
	
	private static String startArtikel() {
		String query='SELECT ';
		// create dynamic query
		query+=getProdFields() + ' FROM Product2 WHERE Typ__c=\'Signatur\'';
		MonatsAbschlussArtikelBatch abatch = new MonatsAbschlussArtikelBatch(query);
		abatch.Query=query;
		ID batchprocessid = Database.executeBatch(abatch);
		System.assert(batchprocessid!=null);
		return batchprocessid;
	}
	private static String getAccFields() {
		String fieldnames='';
		
		Map<String, Schema.SObjectField> M = Schema.SObjectType.Account.fields.getMap();
		
		for (String fname: M.keySet()) {
			if (M.get(fname).getDescribe().isAccessible() && !fname.contains('__pc')
				) {
				if (fieldnames=='') fieldnames+=fname;
				else fieldnames+=', ' + fname;
			}
		}
		
		return fieldnames;
	}
	
	private static String getProdFields() {
		String fieldnames='';
		
		Map<String, Schema.SObjectField> M = Schema.SObjectType.Product2.fields.getMap();
		
		for (String fname: M.keySet()) {
			if (M.get(fname).getDescribe().isAccessible()
				) {
				if (fieldnames=='') fieldnames+=fname;
				else fieldnames+=', ' + fname;
			}
		}
		
		return fieldnames;
	}

}