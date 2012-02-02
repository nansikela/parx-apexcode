public class onOpportunityLineItemHelper {

	static list<OpportunityLineItem> olistoinsert = new list<OpportunityLineItem>();
	static map<Id, Opportunity> oppstoupdate = new map<Id, Opportunity>();
	static map<Id, Medienpaket_Lizenz__c> mplizenzmap = new map<Id, Medienpaket_Lizenz__c>();
	static map<Id, ArtikelLizenz__c> alizenzmap = new map<Id, ArtikelLizenz__c>();
	static map<String, PricebookEntry> pbemap = new map<String, PricebookEntry>();
	static map<Id, Opportunity> oppmap =new map<Id, Opportunity>();
	static Set<Id> alids=new set<ID>();
	static Set<String> snids=new set<String>();
	static set<String> artikelids=new set<String>();
	static set<String> lzns=new set<String>();
	
	public static Boolean alreadyRun=false;

	//
	// this method creates OpportunityLineItems with all Signatures form each sammelnummer
	// 
	// get all Medienpaket_Lizenz__c
	// get all dependend PricebookEntries
	// then create all necessary OpportunityLineItem
	// and insert them 
	
	//@future (callout=true)
	public static void start(List<String> Ids){
		map<Id, OpportunityLineItem> olimap = new map<Id, OpportunityLineItem>();
		list<OpportunityLineItem> trigg = new list<OpportunityLineItem>([select id
															, Produkttyp__c
															, OppStageName__c
															, Product2Id__c
					 										, OpportunityId
															, Quantity
															, UnitPrice
															, Lizenznummer__c
															, SCHL2D__c
															, Discount
															, OppRabatt__c
															, rabattfaehig__c
						 									, Lizenztext__c
															from OpportunityLineItem 
															where Id IN: Ids
															]);

		
		for (OpportunityLineItem oli: trigg) {
			if (oli.Produkttyp__c=='Sammelnummer' && oli.OppStageName__c=='In Erstellung') 
				olimap.put(oli.id,oli);
		}

		
		if (!olimap.isEmpty() && !onOpportunityLineItemHelper.alreadyRun) {
			onOpportunityLineItemHelper.alreadyRun=true;
			onOpportunityLineItemHelper.autoCreateOpportunityLineItems(olimap);
		}
	}
	// for the batch start
	public static void start(List<OpportunityLineItem> trigg){
		map<Id, OpportunityLineItem> olimap = new map<Id, OpportunityLineItem>();

		for (OpportunityLineItem oli: trigg) {
			if (oli.Produkttyp__c=='Sammelnummer' && oli.OppStageName__c=='In Erstellung') 
				olimap.put(oli.id,oli);
		}

		
		if (!olimap.isEmpty() && !onOpportunityLineItemHelper.alreadyRun) {
			onOpportunityLineItemHelper.alreadyRun=true;
			onOpportunityLineItemHelper.autoCreateOpportunityLineItems(olimap);
		}
	}
	
	@future (callout=true)
	public static void startfuture(List<String> Ids){
		map<Id, OpportunityLineItem> olimap = new map<Id, OpportunityLineItem>();
		list<OpportunityLineItem> trigg = new list<OpportunityLineItem>([select id
															, Produkttyp__c
															, OppStageName__c
															, Product2Id__c
					 										, OpportunityId
															, Quantity
															, UnitPrice
															, Lizenznummer__c
															, SCHL2D__c
															, Discount
															, OppRabatt__c
															, rabattfaehig__c
						 									, Lizenztext__c
															from OpportunityLineItem 
															where Id IN: Ids
															]);

		
		for (OpportunityLineItem oli: trigg) {
			if (oli.Produkttyp__c=='Sammelnummer' && oli.OppStageName__c=='In Erstellung') 
				olimap.put(oli.id,oli);
		}

		
		if (!olimap.isEmpty() && !onOpportunityLineItemHelper.alreadyRun) {
			onOpportunityLineItemHelper.alreadyRun=true;
			onOpportunityLineItemHelper.autoCreateOpportunityLineItems(olimap);
		}
	}
	
	
	public static void autoCreateOpportunityLineItems(map<Id, OpportunityLineItem> olimap) {
		for (OpportunityLineItem oli:olimap.values()) {
			if (!snids.contains(oli.Product2Id__c)) snids.add(oli.Product2Id__c);
			if (!lzns.contains(oli.Lizenznummer__c)) lzns.add(oli.Lizenznummer__c);
		}
		getMPLizenzen();
		getOpportunities(olimap);
		getPricebookEntries();
		createOpportunityLineItems(olimap);
		insertOpportunityLineItems();
		setSammelnummernbeschreibung(olimap);
		updateOpportunities();
		updateOpportunityLineItems();
		SystemSettings.insertErrors();
	}

	private static void getMPLizenzen() {
		if (!snids.isEmpty() && !lzns.isEmpty()) {
			
			try {
				for (Medienpaket_Lizenz__c mpl:[SELECT Id, Medienpaket__c, LZN012__c, Product2Id__c, Lizenznummer__c, VPR012__c, rabattfaehig__c, ALVPR__c FROM Medienpaket_Lizenz__c WHERE Medienpaket__c IN :snids AND Lizenznummer__c IN :lzns ]) {
					if (!alids.contains(mpl.LZN012__c)) alids.add(mpl.LZN012__c);
					if (!artikelids.contains(mpl.Product2Id__c)) artikelids.add(mpl.Product2Id__c);
					if (!mplizenzmap.containsKey(mpl.id)) mplizenzmap.put(mpl.id, mpl);
				}
			} catch (System.QueryException e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static void getOpportunities(map<Id, OpportunityLineItem> olimap) {
		set<id> oppids = new set<id>();
		if (!olimap.isEmpty()) {
			for (OpportunityLineItem oli: olimap.values()) {
				if (!oppids.contains(oli.OpportunityId)) oppids.add(oli.OpportunityId);
			}
			if (!oppids.isEmpty()) {
				for (Opportunity opp: [SELECT Id, Sammelnummernbeschreibung__c FROM Opportunity WHERE Id IN: oppids ]) {
					if (!oppmap.containsKey(opp.id)) oppmap.put(opp.id, opp);
				}
			}
		}
	}

	private static void getPricebookEntries() {
		if (!artikelids.isEmpty()) {
			Id pbid;
			try {
				pbid=[SELECT Id FROM Pricebook2 WHERE IsActive=true AND IsStandard=true limit 1].Id;
			} catch (System.QueryException e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
			try {
				if (pbid!=null) {
					for (PricebookEntry pbe: [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :artikelids AND Pricebook2Id=:pbid AND IsActive=true]) {
						if (!pbemap.containsKey(String.valueOf(pbe.Product2Id).substring(0,15))) pbemap.put(String.valueOf(pbe.Product2Id).substring(0,15), pbe);
					}
				}
			} catch (System.QueryException e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	

	private static void createOpportunityLineItems(map<Id, OpportunityLineItem> olimap) {
		if (!mplizenzmap.isEmpty() && !olimap.isEmpty() && !pbemap.isEmpty() && !alids.isEmpty()) {
			for (OpportunityLineItem oli: olimap.values()) {
				Double rabatt=oli.OppRabatt__c!=null?oli.OppRabatt__c:0;
				//if (oli.rabattfaehig__c==0) rabatt=0;
				for (Medienpaket_Lizenz__c mpl: mplizenzmap.values()) {
					System.debug('MPL/OLI mplln: ' + mpl.Lizenznummer__c + ' // oliln: '+ oli.Lizenznummer__c);
					if (String.valueOf(mpl.Medienpaket__c).startsWith(oli.Product2Id__c) && mpl.Lizenznummer__c.startsWith(oli.Lizenznummer__c)) {
						// for this mpl we have to create a new OLI for the opp of oli
						if (pbemap.containsKey(mpl.Product2Id__c)) {
							OpportunityLineItem noli=new OpportunityLineItem(
										OpportunityId=oli.OpportunityId, 
										PricebookEntryId=pbemap.get(mpl.Product2Id__c).id,
										Quantity =oli.Quantity, 
										SCHL2D__c=mpl.LZN012__c,
										// we need this to overcome the workflow that would overwrite our price
										isSammelnummernOli__c=true,
										UnitPrice=mpl.VPR012__c==null?mpl.ALVPR__c:mpl.VPR012__c,
										Discount=rabatt*mpl.rabattfaehig__c
										);

							olistoinsert.add(noli);
						}
						
					}
				}
				
			}
		} 
		
	}
	
	private static void setSammelnummernbeschreibung(map<Id, OpportunityLineItem> olimap) {
		// for each sn we write the license text to the opp
		for (OpportunityLineItem oli: olimap.values()) {
			if (!oppstoupdate.containsKey(oli.OpportunityId)) {
				Opportunity o=oppmap.get(oli.OpportunityId);
				if(oli.Lizenztext__c!=null) 
					o.Sammelnummernbeschreibung__c=oli.Lizenztext__c;
				oppstoupdate.put(o.id, o);
			}
		}
	}
	
	
	private static void insertOpportunityLineItems() {
		
		if (!olistoinsert.isEmpty()) {
			try {	
				insert olistoinsert;
			} catch (System.DmlException e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static void updateOpportunityLineItems() {
		
		if (!olistoinsert.isEmpty()) {
			list<OpportunityLineItem> olistoupdate = new list<OpportunityLineItem>();
			for (OpportunityLineItem oli: olistoinsert) {
				oli.isSammelnummernOLI__c=false;
				olistoupdate.add(oli);
			}
			try {	
				update olistoupdate;
			} catch (System.DmlException e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	private static void updateOpportunities() {
		
		if (!oppstoupdate.isEmpty()) {
			try {	
				update oppstoupdate.values();
			} catch (System.DmlException e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}  
}