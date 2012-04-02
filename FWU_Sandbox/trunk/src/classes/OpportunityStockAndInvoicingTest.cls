/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OpportunityStockAndInvoicingTest {

	static testMethod void helperTest01() {
		OpportunityStockAndInvoicingHelper.globalwrapper gw=new OpportunityStockAndInvoicingHelper.globalwrapper();
		list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    initOpp.opp.StageName='Bereit zur Freigabe';
	    initOpp.opp.Locked__c=false;
	    initOpp.opp.Aktive_Fakturierung__c=true;
	    update initOpp.opp;
	    gw.opportunities.put(initOpp.opp.id,initOpp.opp);
	    gw.opportunitiesNoFak.put(initOpp.opp.id, 1);
	   	Rechnung__c r = new Rechnung__c(KDW211__c=initOpp.opp.KDWE2A__c
								,AUN211__c=initOpp.opp.id
								,KDR211__c=initOpp.opp.AccountId
								//,MWB211__c=o.MWSt_Betrag__c // SOLVED by Rollup
								//,MWS211__c=o.MWST2A__c // SOLVED by Formular
								//,NRB211__c=o.Beleg_Nettobetrag__c  // // SOLVED by Rollup
								//,MWB211__c=o.Beleg_MWSt_Betrag__c
								,RED211__c=System.today()
								);
		insert r;
		gw.invoices.put(r.id,r);
		test.startTest();
		OpportunityStockAndInvoicingHelper.print(gw.opportunities, gw.opportunitiesNoFak, gw.invoices);
		OpportunityStockAndInvoicingHelper.lockOpportunities(gw);
		test.stopTest();
	}
	
	static testMethod void helperTest02() {
		OpportunityStockAndInvoicingHelper.globalwrapper gw=new OpportunityStockAndInvoicingHelper.globalwrapper();
		list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    initOpp.opp.StageName='Bereit zur Freigabe';
	    initOpp.opp.Locked__c=false;
	    initOpp.opp.Aktive_Fakturierung__c=true;
	    update initOpp.opp;
	    gw.opportunities.put(initOpp.opp.id,initOpp.opp);
	    gw.opportunitiesNoFak.put(initOpp.opp.id, 1);
	   	Rechnung__c r = new Rechnung__c(KDW211__c=initOpp.opp.KDWE2A__c
								,AUN211__c=initOpp.opp.id
								,KDR211__c=initOpp.opp.AccountId
								//,MWB211__c=o.MWSt_Betrag__c // SOLVED by Rollup
								//,MWS211__c=o.MWST2A__c // SOLVED by Formular
								//,NRB211__c=o.Beleg_Nettobetrag__c  // // SOLVED by Rollup
								//,MWB211__c=o.Beleg_MWSt_Betrag__c
								,RED211__c=System.today()
								);
		insert r;
		gw.invoices.put(r.id,r);
		test.startTest();
		OpportunityStockAndInvoicingHelper.freeOpportunities(oppids, gw);
		test.stopTest();
	}

	// Todo Test for KOL!

	static testMethod void runTest01() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    initOpp.opp.StageName='Bereit zur Freigabe';
	    initOpp.opp.Locked__c=false;
	    update initOpp.opp;
	    //test.startTest();
	    OpportunityStockAndInvoicingRun.fak(oppids);
	    //test.stopTest();
	}
	
	static testMethod void runTest02() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    initOpp.opp.StageName='Bereit zur Freigabe';
	    update initOpp.opp;
	    initOpp.opp.Aktive_Fakturierung__c=false;
	    initOpp.opp.Locked__c=false;
	    update initOpp.opp;
	    //test.startTest();
	    OpportunityStockAndInvoicingRun.lockOpportunitiesAgainstOtherFak(oppids);
	    //test.stopTest();
	}

    static testMethod void runTest() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    OpportunityStockAndInvoicingRun.fak(oppids);
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        initOpp.opp.Locked__c=false;
        update initOpp.opp;
        //test.startTest();
        OpportunityStockAndInvoicingRun.fak(oppids);
        //test.stopTest();
    }
    
    static testMethod void rabattgutschriftTest() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
        initOpp.opp.REAR2A__c=7;
        initOpp.opp.Rabattgutschrift__c=true;
        initOpp.opp.StageName='Bereit zur Freigabe';
        initOpp.opp.Locked__c=false;
        update initOpp.opp;
        //test.startTest();
        OpportunityStockAndInvoicingRun.fak(oppids);
        //test.stopTest();
    }
    
    static testMethod void initTest() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    
	    String fieldnames='';
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.OpportunityLineItem.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        initOpp.opp.Locked__c=false;
        update initOpp.opp;
        String query='SELECT ' + fieldnames + ' FROM OpportunityLineItem WHERE OpportunityId=\'' + initOpp.opp.id + '\'';
        
        //test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityStockAndInvoicingBatch(query, oppids),1);
        //test.stopTest();
    }
    
    static testMethod void initTest02() {
	    set<id> oppids=new set<id>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    initOpp.opp.StageName='Bereit zur Freigabe';
	    initOpp.opp.Locked__c=false;
	    update initOpp.opp;
	    //String oppwherecond=' (KreisListe__c=\'\' OR KreisListe__c=null) AND Opportunity.StageNamePosition__c!=4 AND Opportunity.StageNamePosition__c!=0 AND Opportunity.LFKZ2A__c=false AND Opportunity.Zahlerkennzeichen__c<>\'S\'';
		//String oppwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c LIMIT 50';
		String query='SELECT ';
		//query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + oppwherecond + oppwhereorder;
	    query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE OpportunityId =\'' + initOpp.opp.id + '\'';
        test.startTest();
        OpportunityStockAndInvoicing.Run(database.query(query),new OpportunityStockAndInvoicingHelper.globalwrapper());
        test.stopTest();
    }
    
    static testMethod void initTest03() {
	    set<id> oppids=new set<id>();
	    map<id, Opportunity> opps = new map<Id, Opportunity>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    opps.put(initOpp.opp.id, initOpp.opp);
	    initOpp.opp.StageName='Bereit zur Freigabe';
	    initOpp.opp.Locked__c=false;
	    update initOpp.opp;
	    //String oppwherecond=' (KreisListe__c=\'\' OR KreisListe__c=null) AND Opportunity.StageNamePosition__c!=4 AND Opportunity.StageNamePosition__c!=0 AND Opportunity.LFKZ2A__c=false AND Opportunity.Zahlerkennzeichen__c<>\'S\'';
		//String oppwhereorder=' ORDER BY Opportunity.WE_Kundennummer__c LIMIT 50';
		String query='SELECT ';
		//query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE ' + oppwherecond + oppwhereorder;
	    query+=OpportunityStockAndInvoicingRun.getOpportunityLineItemFields() + ' FROM OpportunityLineItem WHERE OpportunityId =\'' + initOpp.opp.id + '\'';
        test.startTest();
        OpportunityStockAndInvoicing.OppsRun(opps);
        test.stopTest();
    }
    
    static testMethod void initTestInventur01() {
    	Inventur__c iv=new Inventur__c(Name='IV00',Beginn__c=System.today());
    	insert iv;
    	
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    
	    String fieldnames='';
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.OpportunityLineItem.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        initOpp.opp.Locked__c=false;
        update initOpp.opp;
        String query='SELECT ' + fieldnames + ' FROM OpportunityLineItem WHERE OpportunityId=\'' + initOpp.opp.id + '\'';
        
        //test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityStockAndInvoicingBatch(query, oppids),1);
        //test.stopTest();
        delete iv;
    }
    
    static testMethod void initTestInventur02() {
    	Inventur__c iv=new Inventur__c(Name='IV00',Beginn__c=System.today(), Ende__c=System.today()+1);
    	insert iv;
    	
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    
	    String fieldnames='';
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.OpportunityLineItem.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        initOpp.opp.Locked__c=false;
        update initOpp.opp;
        String query='SELECT ' + fieldnames + ' FROM OpportunityLineItem WHERE OpportunityId=\'' + initOpp.opp.id + '\'';
        
        //test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityStockAndInvoicingBatch(query, oppids), 1);
        //test.stopTest();
        delete iv;
    }
    
    static testMethod void multiTest() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity Opp01=new testData.testOpportunity();
	    System.assert(Opp01.hasData);
	    testData.testOli Oli0101=new testData.testOli(Opp01.opp.id);
	    System.assert(Oli0101.hasData);
	    testData.testOli Oli0102=new testData.testOli(Opp01.opp.id);
	    System.assert(Oli0102.hasData);
	    
	    testData.testOpportunity Opp03=new testData.testOpportunity();
	    System.assert(Opp03.hasData);
	    testData.testOli Oli0301=new testData.testOli(Opp03.opp.id);
	    System.assert(Oli0301.hasData);
	    testData.testOli Oli0302=new testData.testOli(Opp03.opp.id);
	    System.assert(Oli0302.hasData);
	    //Opp03.opp.Teillieferung__c=false;
	    OpportunityLineItem tempoli= Oli0301.olimap.values().get(0);
	    tempoli.Quantity=20000;
	    tempoli.GELM2D__c=null;
	    update tempoli;
	    
	    testData.testOpportunity Opp02=new testData.testOpportunity();
	    System.assert(Opp02.hasData);
	    testData.testOli Oli0201=new testData.testOli(Opp02.opp.id);
	    System.assert(Oli0201.hasData);
	    testData.testOli Oli0202=new testData.testOli(Opp02.opp.id);
	    System.assert(Oli0202.hasData);
	    Oli0102.olimap.values().get(0).Quantity=500;
	    update Oli0102.olimap.values();
	    Oli0202.olimap.values().get(0).Quantity=500;
	    update Oli0202.olimap.values();
	    
	    
	    oppids.add(Opp01.opp.id);
	    oppids.add(Opp02.opp.id);
	    oppids.add(Opp03.opp.id);
	    
	    String fieldnames='';
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.OpportunityLineItem.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        Opp01.opp.StageName='Bereit zur Freigabe';
        Opp01.opp.Locked__c=false;
        update Opp01.opp;
        Opp03.opp.StageName='Bereit zur Freigabe';
        Opp03.opp.Locked__c=false;
        update Opp03.opp;
        Opp02.opp.REAR2A__c=3;
        Opp02.opp.Locked__c=false;
        update Opp02.opp;
        Opp02.opp.StageName='Bereit zur Freigabe';
        Opp02.opp.Teillieferung__c=false;
        Opp02.opp.Locked__c=false;
        update Opp02.opp;
        String query='SELECT ' + fieldnames + ' FROM OpportunityLineItem WHERE OpportunityId IN (\'' + Opp01.opp.id + '\',\'' + Opp03.opp.id + '\',\'' + Opp02.opp.id + '\')';
        
        test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityStockAndInvoicingBatch(query, oppids), 1);
        test.stopTest();
    }
}