global class OpportunityFreigabeFakturierungRun {
/*
	private static String[] sourceIds=new list<String>();
	static final String oppwherecond=' StageNamePosition__c!=4 AND StageNamePosition__c!=0 AND LFKZ2A__c=false AND Zahlerkennzeichen__c<>\'S\'';
	static final String oppwhereorder=' ORDER BY WE_Kundennummer__c';
	
	webservice static String fak(String[] ids) {
		String result='';
		if (ids!=null && !ids.isEmpty()) {
			sourceIds=ids.clone();
			result=collectDataAuftraege();
		}
		return result;
	}
	
	webservice static String fakone(String oppid) {
		String result='';
		if (oppid!=null && oppid!='') {
			String query='SELECT ';
			query+=getOppFields() + ' FROM Opportunity WHERE ' + oppwherecond + ' AND Id = \'' + oppid + '\'' + oppwhereorder;
			//List<sObject> L = Database.query(query);
			OpportunityFreigabeFakturierung.OpportunityFreigabeFakturierungRun(query);
		}
		return result;
	}
	
	webservice static String fakall() {
		String result='';
		result=collectDataAuftraege();
		return result;
	}

	private static String collectDataAuftraege() {
		// we got oppids to get suitable opportunities
		String query='SELECT ';
		// create dynamic query
		if (getOppIdListString()!='')
			query+=getOppFields() + ' FROM Opportunity WHERE ' + oppwherecond + ' AND Id IN ' + getOppIdListString() + oppwhereorder;
		else
			query+=getOppFields() + ' FROM Opportunity WHERE ' + oppwherecond + oppwhereorder;
		//query='SELECT ' + getOppFields() + ' FROM Opportunity WHERE ID=\'006R0000005Cp6b\'';
		OpportunityFreigabeFakturierungBatch fak=new OpportunityFreigabeFakturierungBatch(query);
		fak.Query=query;
		ID batchprocessid = Database.executeBatch(fak, 20);
		System.assert(batchprocessid!=null);
		return batchprocessid;
	}
	
	public static String getOppFields() {
		String fieldnames='';
		
		Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
		
		for (String fname: M.keySet()) {
			if (M.get(fname).getDescribe().isAccessible()
				) {
				if (fieldnames=='') fieldnames+=fname;
				else fieldnames+=', ' + fname;
			}
		}
		
		return fieldnames;
	}
	
	public static String getOppIdListString() {
		String idlist='';
		
		if (!sourceIds.isEmpty()) {
			for (String sid: sourceIds) {
				if (idlist=='') idlist+='( \'' + sid;
				else idlist+='\', \''+ sid;
			}
		}
		
		if (idlist.length()>0) idlist+= '\' )';
		SystemSettings.insertErrors();
		return idlist;
	}
	*/
}