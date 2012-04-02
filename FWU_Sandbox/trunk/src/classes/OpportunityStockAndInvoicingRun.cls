global class OpportunityStockAndInvoicingRun {

	private static String[] sourceIds=new list<String>();
	static final String oppwherecond=' (Lizenznummer__c<>\'10206\' OR medienart_id__c<>\'55\') AND Opportunity.StageNamePosition__c!=0 AND Opportunity.StageNamePosition__c!=4 AND Opportunity.StageNamePosition__c!=5 AND Opportunity.LFKZ2A__c=false AND (Opportunity.Zahlerkennzeichen__c<>\'S\' OR (Opportunity.Zahlerkennzeichen__c=\'S\' AND Opportunity.RA_Lagerabgang__c=0))';
	// AND Opportunity.RechnungsartVorUmwandlung__c!=0
	// umgewandelte Opps dürfen nicht nochmals manuell fakturiert werden: AND Opportunity.RechnungsartVorUmwandlung__c!=0
	// AND StatusPosition__c<3
	// AND Opportunity.StageNamePosition__c!=4
	// (Lizenznummer__c<>\'10206\' OR (((KreisListe__c=\'\' OR KreisListe__c=null) AND medienart_id__c<>\'55\') OR ((medienart_55__c<>null OR medienart_55__c<>\'\') AND MedSig1Prod__c<>\'46\' AND medienart_id__c<>\'55\'))) AND
	// (((KreisListe__c=\'\' OR KreisListe__c=null) AND medienart_id__c<>\'55\') OR ((medienart_55__c<>null OR medienart_55__c<>\'\') AND MedSig1Prod__c<>\'46\' AND medienart_id__c<>\'55\')) AND
	static final String oppwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c';
	static final Integer batchsize=1200;
	
	webservice static String fak(String[] ids) {
		String result='';
		if (ids!=null && !ids.isEmpty()) {
			sourceIds=ids.clone();
			// unlock Opportunities to be sure that the will not selected twice in any batches
			result=unlockOpportunities();
			// if any of the opps could not be unlocked, do not run!
			if (result=='') result=collectDataAuftraege();
		}
		if (result==null) {
			result=unlockOpps(sourceIds);
		}
		return result;
	}
	
	webservice static String lockOpportunitiesAgainstOtherFak(String[] ids) {
		String result='';
		if (ids!=null && !ids.isEmpty()) {
			result=lockOpps(Ids);
		}
		return result;
	}
	
	private static String lockOpps(String[] ids) {
		String result='Success';
		list<Opportunity> opps = new list<Opportunity>([select id, Aktive_Fakturierung__c from Opportunity where Id IN: ids AND (StageName = 'Bereit zur Freigabe' OR StageName = 'Teillieferung') AND LFKZ2A__c=false AND (Zahlerkennzeichen__c<>'S' OR (Zahlerkennzeichen__c='S' AND RA_Lagerabgang__c=0))]);
		Boolean activeFaktura=false;
		for(Opportunity o:opps) {
			if (o.Aktive_Fakturierung__c) activeFaktura=true;
			else o.Aktive_Fakturierung__c = True;
		}
		if(!opps.isEmpty() && !activeFaktura)
			update opps;
		else
			result='Fakturierung kann nicht durchgeführt werden! Bitte versuchen Sie es eventuell später erneut!';
		return result;
	}
	
	public static String unlockOpps(String[] ids) {
		String result='Fakturierung kann nicht durchgeführt werden! Bitte versuchen Sie es eventuell später erneut!';
		list<Opportunity> opps = new list<Opportunity>([select id, Aktive_Fakturierung__c from Opportunity where Id IN: ids]);
		for(Opportunity o:opps) {
			o.Aktive_Fakturierung__c = false;
		}
		if(!opps.isEmpty())
			update opps;
		else
			result='Fakturierung kann nicht durchgeführt werden! Bitte versuchen Sie es eventuell später erneut!';
		return result;
	}
	
	//webservice static String fakone(String oppid) {
	//	String result='';
	//	if (oppid!=null && oppid!='') {
	//		String query='SELECT ';
	//		query+=getOpportunityLineItemFields() + ' FROM Opportunity WHERE ' + oppwherecond + ' AND Id = \'' + oppid + '\'' + oppwhereorder;
			//List<sObject> L = Database.query(query);
			//OpportunityStockAndInvoicing.Run(query);
	//	}
	//	return result;
	//}
	
	webservice static String fakall() {
		String result='';
		result=collectDataAuftraege();
		return result;
	}

	private static String collectDataAuftraege() {
		// we got oppids to get suitable opportunities
		String query='SELECT ';
		Id oppid;
		// create dynamic query
		if (getOppIdListString()!='')
			query+=getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + oppwherecond + ' AND OpportunityId IN ' + getOppIdListString() + oppwhereorder;
		else
			query+=getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + oppwherecond + oppwhereorder;
		//query='SELECT ' + getOppFields() + ' FROM Opportunity WHERE ID=\'006R0000005Cp6b\'';
		OpportunityStockAndInvoicingBatch fak=new OpportunityStockAndInvoicingBatch(query, sourceIds);
		//OpportunityStockAndInvoicingBatch fak=new OpportunityStockAndInvoicingBatch(query);
		//fak.Query=query;
		Id ApexClassId=[SELECT Id FROM ApexClass WHERE Name='OpportunityStockAndInvoicingBatch'].Id;
		ID batchprocessid;
		if ([SELECT count() FROM AsyncApexJob WHERE Status!='Completed' AND Status!='Aborted' AND ApexClassId=:ApexClassId]==0) {
			batchprocessid = Database.executeBatch(fak, batchsize);
			System.assert(batchprocessid!=null);
		}
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
	
	private static String unlockOpportunities() {
		map<Id, Opportunity> opportunities=getOpportunities();
		if (!opportunities.isEmpty()) {
			for (Id oppid: opportunities.keySet()) {
				if (opportunities.get(oppid).Locked__c && !opportunities.get(oppid).LFKZ2A__c)
					opportunities.get(oppid).Locked__c=false;
				else if (opportunities.get(oppid).Locked__c && opportunities.get(oppid).LFKZ2A__c)
					if (opportunities.get(oppid).Zahl_der_fakturierungen__c==null || opportunities.get(oppid).Zahl_der_fakturierungen__c==0)
						opportunities.get(oppid).Zahl_der_fakturierungen__c=1;
				else
					return 'Auftrag/Aufträge bereits in Faktura';
			}
		}
		try {
			update opportunities.values();
		} catch (System.Dmlexception e) {
			SystemSettings.logError(e.getMessage(),'DEBUG');
			//if (SystemSettings.isDebug) throw e;
			return 'Auftrag/Aufträge können nicht fakturiert werden, es ist ein Fehler aufgetreten. Versuchen Sie es später erneut.';
		}
		return '';
	}
	
	private static map<id, Opportunity> getOpportunities() {
		map<id, Opportunity> retmap = new map<id, opportunity>();
		if (!sourceIds.isEmpty()) {
			for (Opportunity opp: [SELECT Id, Locked__c, LFKZ2A__c FROM Opportunity WHERE 
				Id IN :sourceids
				//AND RechnungsartVorUmwandlung__c!=0 
				AND StageNamePosition__c!=0 
				AND StageNamePosition__c!=4 
				AND StageNamePosition__c!=5 
				AND LFKZ2A__c=false 
				AND (Zahlerkennzeichen__c<>'S' 
				OR (Zahlerkennzeichen__c='S' 
				AND RA_Lagerabgang__c=0))
				]) {
				if (!retmap.containsKey(opp.id)) retmap.put(opp.id, opp);
			}
		}
		return retmap;
	}
	
}