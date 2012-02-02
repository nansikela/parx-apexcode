global with sharing class onOpportunitySammelnummerRun {
	
	private static String[] sourceIds=new list<String>();
	static final Integer batchsize=100;
	
	webservice static String Run(String[] ids) {
		String result='';
		if (ids!=null && !ids.isEmpty()) {
			sourceIds=ids.clone();
			result=collectDataAuftraege();
		}
		return result;
	}

	private static String collectDataAuftraege() {
		// we got oppids to get suitable opportunities
		String query='SELECT ';
		Id oppid;
		// create dynamic query
		if (getOppIdListString()!='')
			query+=getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE Id IN ' + getOppIdListString();
		//query='SELECT ' + getOppFields() + ' FROM Opportunity WHERE ID=\'006R0000005Cp6b\'';
		onOpportunitySammelnummerBatch sammelnummerninput=new onOpportunitySammelnummerBatch(query);
		ID batchprocessid = Database.executeBatch(sammelnummerninput, batchsize);
		System.assert(batchprocessid!=null);
		return batchprocessid;
	}
	
	public static String getOpportunityLineItemFields() {
		String fieldnames='';
		
		Map<String, Schema.SObjectField> M = Schema.SObjectType.OpportunityLineItem.fields.getMap();
		
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
}