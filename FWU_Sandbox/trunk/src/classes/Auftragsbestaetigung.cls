global class Auftragsbestaetigung {
	
	webservice static String init(String[] ids) {
		String result='';
		if (ids!=null && !ids.isEmpty()) {
			doIt(Ids);
		}
		return result;
	}
	
	private static void doIt(String[] ids) {
		list<Opportunity> opps = new list<Opportunity>([select id, Conga_Workflow_Trigger__c from Opportunity where Id IN: ids AND StageName = 'Bereit zur Freigabe' AND LFKZ2A__c = True]);
		for(Opportunity o:opps) {
			o.Conga_Workflow_Trigger__c = True;
		}
		if(!opps.isEmpty())
			update opps;
	}
	
	static testmethod void  NewProductButtonControllerTest() {
		String AccId = testData.creationAccount();
		Opportunity opp = new Opportunity(AccountId = AccId, Name = 'test', StageName = 'In Erstellung', CloseDate = system.today());
		insert opp;
		list<String> ids = new list<String>();
		ids.add(opp.id);
		Auftragsbestaetigung.init(ids);

	}
}