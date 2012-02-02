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
private class OpportunityFreigabeFakturierungTest {
/*
	static testMethod void idtest() {
		String s='01t20000001NTdN';
		ID sID=s;
		System.debug('sId: ' + sId);
		s='01t20000001NTdn';
		sId=s;
		System.debug('sId: ' + sId);
	}

	// Todo Test for KOL!

	static testMethod void runTest01() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    test.startTest();
	    OpportunityFreigabeFakturierungRun.fakone(initOpp.opp.id);
	    test.stopTest();
	}

    static testMethod void runTest() {
	    list<String> oppids=new list<String>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    OpportunityFreigabeFakturierungRun.fakone(initOpp.opp.id);
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        update initOpp.opp;
        test.startTest();
        OpportunityFreigabeFakturierungRun.fak(oppids);
        test.stopTest();
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
        update initOpp.opp;
        //test.startTest();
        OpportunityFreigabeFakturierungRun.fak(oppids);
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
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        update initOpp.opp;
        String query='SELECT ' + fieldnames + ' FROM Opportunity WHERE Id=\'' + initOpp.opp.id + '\'';
        
        //test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityFreigabeFakturierungBatch(query), 1);
        //test.stopTest();
    }
    
    static testMethod void initTest02() {
	    set<id> oppids=new set<id>();
	    testData.testOpportunity initOpp=new testData.testOpportunity();
	    System.assert(initOpp.hasData);
	    testData.testOli initOli=new testData.testOli(initOpp.opp.id);
	    System.assert(initOli.hasData);
	    oppids.add(initOpp.opp.id);
	    
        //test.startTest();
        OpportunityFreigabeFakturierung.OpportunityFreigabeFakturierungRun(oppids);
        //test.stopTest();
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
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        update initOpp.opp;
        String query='SELECT ' + fieldnames + ' FROM Opportunity WHERE Id=\'' + initOpp.opp.id + '\'';
        
        //test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityFreigabeFakturierungBatch(query), 1);
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
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        initOpp.opp.StageName='Bereit zur Freigabe';
        update initOpp.opp;
        String query='SELECT ' + fieldnames + ' FROM Opportunity WHERE Id=\'' + initOpp.opp.id + '\'';
        
        //test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityFreigabeFakturierungBatch(query), 1);
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
		
	Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
	
	for (String fname: M.keySet()) {
		if (M.get(fname).getDescribe().isAccessible()
			) {
			if (fieldnames=='') fieldnames+=fname;
			else fieldnames+=', ' + fname;
		}
	}
        
        Opp01.opp.StageName='Bereit zur Freigabe';
        update Opp01.opp;
        Opp03.opp.StageName='Bereit zur Freigabe';
        update Opp03.opp;
        Opp02.opp.REAR2A__c=3;
        update Opp02.opp;
        Opp02.opp.StageName='Bereit zur Freigabe';
        Opp02.opp.Teillieferung__c=false;
        update Opp02.opp;
        String query='SELECT ' + fieldnames + ' FROM Opportunity WHERE Id IN (\'' + Opp01.opp.id + '\',\'' + Opp03.opp.id + '\',\'' + Opp02.opp.id + '\')';
        
        //test.startTest();
        ID batchprocessid = Database.executeBatch(new OpportunityFreigabeFakturierungBatch(query), 1);
        //test.stopTest();
    }
    */
}