global class ReportCalculationBatchStart {

	private static String queryolicond='';
	private static String queryrpcond='';
	private static ReportResult__c rresult = new ReportResult__c();
	private static ReportKonfiguration__c rkonf=new ReportKonfiguration__c();

	webservice static list<String> start(String rkonfid) {
		list<String> result=new list<String>();
		// get Report Konfiguration to construct the query
		getKonfiguration(rkonfid);
		initResult();
		buildOliCond();
		buildRPCond();
		result=startBatches();
		return result;
	}
	
	private static void initResult() {
		if (rresult.Report_Konfiguration__c==null && rkonf!=null) rresult.Report_Konfiguration__c=rkonf.id;
		if (rresult.ABLJ__c==null) rresult.ABLJ__c=0;
		if (rresult.ABLM__c==null) rresult.ABLM__c=0;
		if (rresult.ABVJ__c==null) rresult.ABVJ__c=0;
		if (rresult.ABVM__c==null) rresult.ABVM__c=0;
		if (rresult.INLJ__c==null) rresult.INLJ__c=0;
		if (rresult.INLM__c==null) rresult.INLM__c=0;
		if (rresult.INVJ__c==null) rresult.INVJ__c=0;
		if (rresult.INVM__c==null) rresult.INVM__c=0;
		if (rresult.LIAULJ__c==null) rresult.LIAULJ__c=0;
		if (rresult.LIAULM__c==null) rresult.LIAULM__c=0;
		if (rresult.LIAUVJ__c==null) rresult.LIAUVJ__c=0;
		if (rresult.LIAUVM__c==null) rresult.LIAUVM__c=0;
		if (rresult.LIINLJ__c==null) rresult.LIINLJ__c=0;
		if (rresult.LIINLM__c==null) rresult.LIINLM__c=0;
		if (rresult.LIINVJ__c==null) rresult.LIINVJ__c=0;
		if (rresult.LIINVM__c==null) rresult.LIINVM__c=0;
		if (rresult.UAULJ__c==null) rresult.UAULJ__c=0;
		if (rresult.UAULM__c==null) rresult.UAULM__c=0;
		if (rresult.UAUVJ__c==null) rresult.UAUVJ__c=0;
		if (rresult.UAUVM__c==null) rresult.UAUVM__c=0;
		if (rresult.UINLJ__c==null) rresult.UINLJ__c=0;
		if (rresult.UINLM__c==null) rresult.UINLM__c=0;
		if (rresult.UINVJ__c==null) rresult.UINVJ__c=0;
		if (rresult.UINVM__c==null) rresult.UINVM__c=0;
		if (rresult.X42LJ__c==null) rresult.X42LJ__c=0;
		if (rresult.X42LM__c==null) rresult.X42LM__c=0;
		if (rresult.X42VJ__c==null) rresult.X42VJ__c=0;
		if (rresult.X42VM__c==null) rresult.X42VM__c=0;
		if (rresult.X46LJ__c==null) rresult.X46LJ__c=0;
		if (rresult.X46LM__c==null) rresult.X46LM__c=0;
		if (rresult.X46VJ__c==null) rresult.X46VJ__c=0;
		if (rresult.X46VM__c==null) rresult.X46VM__c=0;
		if (rresult.X55LJ__c==null) rresult.X55LJ__c=0;
		if (rresult.X55LM__c==null) rresult.X55LM__c=0;
		if (rresult.X55VJ__c==null) rresult.X55VJ__c=0;
		if (rresult.X55VM__c==null) rresult.X55VM__c=0;
		if (rresult.X66LJ__c==null) rresult.X66LJ__c=0;
		if (rresult.X66LM__c==null) rresult.X66LM__c=0;
		if (rresult.X66VJ__c==null) rresult.X66VJ__c=0;
		if (rresult.X66VM__c==null) rresult.X66VM__c=0;
		if (rresult.XXXLJ__c==null) rresult.XXXLJ__c=0;
		if (rresult.XXXLM__c==null) rresult.XXXLM__c=0;
		if (rresult.XXXVJ__c==null) rresult.XXXVJ__c=0;
		if (rresult.XXXVM__c==null) rresult.XXXVM__c=0;
		insert rresult;
	}
	
	private static void buildOliCond() {
		// Auftragsbestand - offene Olis von Anbegin der Zeit bis heute!
		// allerdings interessieren nur Opportunities, die im fraglichen Zeitraum noch offen waren
		// wenn sie geschlossen sind (Vollständig Fakturiert) und das Datum der Letzten Rechnung liegt außerhalb des Betrachtungszeitraumes
		// brauchen wir diese opps nicht!
		queryolicond=' WHERE Opportunity.StageName!=\'In Erstellung\' AND Produkttyp__c=\'Signatur\' AND (Opportunity.RA_Statistik__c=1 OR (OppRechnungsArt__c=3 AND Opportunity.RechnungsartVorUmwandlung__c=0)) AND ';
		queryolicond+=' OppBestelldatum__c!=null AND ';
		queryolicond+='( ( OppBestelldatum__c <= ' + rkonf.APEX_QueryArea01End__c + ' AND ( Opportunity.Letzte_Rechnung__r.RED211__c=null OR ( Opportunity.Letzte_Rechnung__r.RED211__c<>null AND Opportunity.StageName!=\'Vollständig Fakturiert\') OR ( Opportunity.StageName like \'%Fakturiert\' AND Opportunity.Letzte_Rechnung__r.RED211__c >= ' + rkonf.APEX_QueryArea01Start__c + ' ) ) )';
		queryolicond+='OR ( OppBestelldatum__c <= ' + rkonf.APEX_QueryArea02End__c + ' AND ( Opportunity.Letzte_Rechnung__r.RED211__c=null OR ( Opportunity.Letzte_Rechnung__r.RED211__c<>null AND Opportunity.StageName!=\'Vollständig Fakturiert\' ) OR ( Opportunity.StageName like \'%Fakturiert\' AND Opportunity.Letzte_Rechnung__r.RED211__c >= ' + rkonf.APEX_QueryArea02Start__c + ' ) ) ) )';
	}
	
	private static void buildRPCond() {
		// Auftragsbestand - offene Olis von Anbegin der Zeit bis heute!
		queryrpcond=' WHERE RA_Statistik__c=1 ';
		queryrpcond+=' AND ( (Rechnungsdatum__c>= ' + rkonf.APEX_QueryArea01Start__c + ' AND Rechnungsdatum__c <= ' + rkonf.APEX_QueryArea01End__c + ' ) ';
		queryrpcond+=' OR (Rechnungsdatum__c>= ' + rkonf.APEX_QueryArea02Start__c + ' AND Rechnungsdatum__c <= ' + rkonf.APEX_QueryArea02End__c + ' ) )';
	}
	
	private static void getKonfiguration(String rkonfid) {
		if (rkonfid!='') {
			rkonf=[SELECT Id
							, APEX_QueryArea01Start__c
							, APEX_QueryArea01End__c
							, APEX_QueryArea02Start__c
							, APEX_QueryArea02End__c
							, Basisjahr__c
							, Vergleichsjahr__c
							, Basismonat_von__c
							, Basismonat_bis__c
							, Vergleichsmonat_von__c
							, Vergleichsmonat_bis__c 
							FROM ReportKonfiguration__c WHERE Id=:rkonfid];
		}
	}
	
	private static list<String> startBatches() {
		list<String> result=new list<String>();
		String res='';
		res=startOli();
		if (res==null) res='';
		result.add(res);
		res=startRP();
		if (res==null) res='';
		result.add(res);
		SystemSettings.insertErrors();
		return result;
	}
	
	private static String startOli() {
		String query='SELECT ';
		// create dynamic query
		query+=getOliFields() + ' FROM OpportunityLineItem' + queryolicond;
		System.debug('ReportCalculation Query: ' + query);
		ReportResult__c rresultOli = [SELECT Id, Name, Report_Konfiguration__c, ABLJ__c, ABLM__c, ABVJ__c, ABVM__c FROM ReportResult__c WHERE Id = :rresult.id];
		ReportCalculationOpportunityBatch rbatch = new ReportCalculationOpportunityBatch(query, rkonf, rresultOli);
		rbatch.Query=query;
		rbatch.rkonf=rkonf;
		ID batchprocessid = Database.executeBatch(rbatch,500);
		System.assert(batchprocessid!=null);
		return batchprocessid;
	}
	
	private static String startRP() {
		String query='SELECT ';
		// create dynamic query
		//query+=getRPFields() + ' FROM RechnungPosten__c' + queryrpcond;
		query+='Id, Rechnungsdatum__c, Medienart__c, SignaturZ_hlnummer__c, Umsatz_Ausland__c, Umsatz_Inland__c, RecordTypeId, ';
		query+='GNP212__c, Artikel__c ' + 'FROM RechnungPosten__c' + queryrpcond;
		System.debug('ReportCalculation Query: ' + query);
		ReportResult__c rresultRP = [SELECT Id, Name, Report_Konfiguration__c, 
								INLJ__c,
								INLM__c,
								INVJ__c,
								INVM__c,
								LIAULJ__c,
								LIAULM__c,
								LIAUVJ__c,
								LIAUVM__c,
								LIINLJ__c,
								LIINLM__c,
								LIINVJ__c,
								LIINVM__c,
								UAULJ__c,
								UAULM__c,
								UAUVJ__c,
								UAUVM__c,
								UINLJ__c,
								UINLM__c,
								UINVJ__c,
								UINVM__c,
								X42LJ__c,
								X42LM__c,
								X42VJ__c,
								X42VM__c,
								X46LJ__c,
								X46LM__c,
								X46VJ__c,
								X46VM__c,
								X55LJ__c,
								X55LM__c,
								X55VJ__c,
								X55VM__c,
								X66LJ__c,
								X66LM__c,
								X66VJ__c,
								X66VM__c,
								XXXLJ__c,
								XXXLM__c,
								XXXVJ__c,
								XXXVM__c
								FROM ReportResult__c WHERE Id = :rresult.id];
		ReportCalculationInvoiceBatch rbatch = new ReportCalculationInvoiceBatch(query, rkonf, rresultRP);
		rbatch.Query=query;
		rbatch.rkonf=rkonf;
		ID batchprocessid = Database.executeBatch(rbatch,500);
		System.assert(batchprocessid!=null);
		return batchprocessid;
	}
	
	private static String getOliFields() {
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
	
	private static String getRPFields() {
		String fieldnames='';
		
		Map<String, Schema.SObjectField> M = Schema.SObjectType.RechnungPosten__c.fields.getMap();
		
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