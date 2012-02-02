global class UmwandlungInVorausrechnungRun {

	private static String[] sourceIds=new list<String>();
	//static final String oppwherecond=' StageNamePosition__c!=4 AND StageNamePosition__c!=0 AND LFKZ2A__c=false AND Zahlerkennzeichen__c<>\'S\'';
	//static final String oppwhereorder=' ORDER BY WE_Kundennummer__c';
	static final Integer batchsize=100;
	
	webservice static String umw(String[] ids) {
		String result='';
		if (ids!=null && !ids.isEmpty()) {
			sourceIds=ids.clone();
			result=collectDataAuftraege();
		}
		return result;
	}
	
	//webservice static String fakall() {
	//	String result='';
	//	result=collectDataAuftraege();
	//	return result;
	//}

	private static String collectDataAuftraege() {
		// we got oppids to get suitable opportunities
		String query='SELECT ';
		// create dynamic query
		if (getOppIdListString()!='')
			query+=getOppFields() + ' FROM Opportunity WHERE Id IN ' + getOppIdListString();
		//query='SELECT ' + getOppFields() + ' FROM Opportunity WHERE ID=\'006R0000005Cp6b\'';
		UmwandlungInVorausrechnungBatch umw=new UmwandlungInVorausrechnungBatch(query);
		umw.Query=query;
		SystemSettings.logError('Umwandlung Query: ' + query);
		/* does not work, takes to long to process
		list<SObject> sopps= new list<SObject>();
		for (SObject sopp: Database.query(query)) {
			sopps.add(sopp);
		}
		UmwandlungInVorausrechnung.UmwandlungInVorausrechnungRun(sopps);
		*/
		ID batchprocessid = Database.executeBatch(umw);
		System.assert(batchprocessid!=null);
		
		return batchprocessid;
	}
	
	private static String getOppFields() {
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
	
	private static String getOppIdListString() {
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

}