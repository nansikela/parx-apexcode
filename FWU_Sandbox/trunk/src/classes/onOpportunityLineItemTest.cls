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
private class onOpportunityLineItemTest {

    static testMethod void initTest() {
    	  testData.testOpportunity testOpp = new testData.testOpportunity();
    	  System.assert(testOpp.hasData); 
        testData.testSammelnummer mysn = new testData.testSammelnummer();
        System.assert(mysn.hasData);
        
       // testOpp.opp.StageName = 'Bereit zur Freigabe';
        testOpp.opp.Lizenznummer__c = '10206';
        update testOpp.opp;
        mysn.mmap.values().get(0).Name = '46';
        update mysn.mmap.values();
        for(integer i = 0 ; i < mysn.almap.size() ; i ++)
        	mysn.almap.values().get(i).LZN015__c = '10206';
        update mysn.almap.values();
        
        OpportunityLineItem snoli=new OpportunityLineItem(OpportunityId=testOpp.opp.id,PricebookEntryId=mysn.snpbe.id,SCHL2D__c=mysn.pbetoal.get(mysn.snpbe.id),Quantity=1,UnitPrice=1, Sperrkz__c = false);
        try {
        //	test.startTest();
        	insert snoli;
       // 	test.stopTest();
        } catch (System.DMLException e) {
        	System.debug('PARX testmsg ' + e.getMessage());
        	if (SystemSettings.isDebug) throw e;
        }
        System.assertNotEquals(null,snoli.id);
        // now we can prove that all the Signatures (Products) from the sammelnummer has been created as LineItems for this opportunity
        map<Id, OpportunityLineItem> olimap=new map<Id, OpportunityLineItem>();
        Set<Id> pbeids=new Set<Id>();
        for (OpportunityLineItem oli: [SELECT Id, PricebookEntryId, SCHL2D__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId=:testOpp.opp.id]) {
        	if (!pbeids.contains(oli.PricebookEntryId)) pbeids.add(oli.PricebookEntryId);
        	if (!olimap.containsKey(oli.id)) olimap.put(oli.id,oli);
        }
      //  System.assertEquals(mysn.pbemap.size()+1,olimap.size());
    //    System.assertEquals(pbeids,mysn.pbemap.keySet());
        onOpportunityLineItem.inFutureContextStoredId = '';
        snoli.Sperrkz__c = true;
        update snoli;
        snoli.Sperrkz__c = false;
        onOpportunityLineItem.inFutureContextStoredId = '';
         update snoli;
         snoli.Quantity = 15;
         onOpportunityLineItem.inFutureContextStoredId = '';
         update snoli;
         testOpp.opp.StageName = 'Bereit zur Freigabe';
          update testOpp.opp;
        onOpportunityLineItem.inFutureContextStoredId = '';
        try{
        	delete snoli;
        }
        catch(exception e){}
        
        testData.testOpportunity testOpp2 = new testData.testOpportunity();
    	  System.assert(testOpp2.hasData); 
     //   testOpp2.opp.StageName = 'Bereit zur Freigabe';
      //  update testOpp2.opp;
        snoli=new OpportunityLineItem(OpportunityId=testOpp2.opp.id,PricebookEntryId=mysn.snpbe.id,SCHL2D__c=mysn.pbetoal.get(mysn.snpbe.id),Quantity=1,UnitPrice=1, Sperrkz__c = false);
      	insert snoli;
      	 system.debug('debuggin testopp2 ' + testOpp2.opp.StageName);
      	 testOpp2.opp.StageName = 'Bereit zur Freigabe';
       	 update testOpp2.opp;
       	 try{
      	delete snoli;
      	}
        catch(exception e){}
    }
    
    static testMethod void massTest01() {
    	  // insert two sn into one Opportunity at once
    	  testData.testOpportunity testOpp = new testData.testOpportunity();
    	  System.assert(testOpp.hasData); 
        testData.testSammelnummer mysn01 = new testData.testSammelnummer();
        System.assert(mysn01.hasData);
        testData.testSammelnummer mysn02 = new testData.testSammelnummer();
        System.assert(mysn02.hasData);
        list<OpportunityLineItem> snolis=new list<OpportunityLineItem>();
        OpportunityLineItem snoli01=new OpportunityLineItem(OpportunityId=testOpp.opp.id,PricebookEntryId=mysn01.snpbe.id,SCHL2D__c=mysn01.pbetoal.get(mysn01.snpbe.id),Quantity=1,UnitPrice=1);
        OpportunityLineItem snoli02=new OpportunityLineItem(OpportunityId=testOpp.opp.id,PricebookEntryId=mysn02.snpbe.id,SCHL2D__c=mysn02.pbetoal.get(mysn02.snpbe.id),Quantity=1,UnitPrice=1);
        snolis.add(snoli01);
        snolis.add(snoli02);
        try {
        	test.startTest();
        	onOpportunityLineItem.inFutureContextStoredId = '';
        	insert snolis;
        	test.stopTest();
        } catch (System.DMLException e) {
        	System.debug('PARX testmsg ' + e.getMessage());
        	if (SystemSettings.isDebug) throw e;
        }
        System.assertNotEquals(null,snolis.get(0).id);
        System.assertNotEquals(null,snolis.get(1).id);
        // now we can prove that all the Signatures (Products) from the sammelnummer has been created as LineItems for this opportunity
        map<Id, OpportunityLineItem> olimap=new map<Id, OpportunityLineItem>();
        Set<Id> pbeids=new Set<Id>();
        for (OpportunityLineItem oli: [SELECT Id, PricebookEntryId, SCHL2D__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId=:testOpp.opp.id]) {
        	if (!pbeids.contains(oli.PricebookEntryId)) pbeids.add(oli.PricebookEntryId);
        	if (!olimap.containsKey(oli.id)) olimap.put(oli.id,oli);
        }
        System.assertEquals(mysn01.pbemap.size()+mysn02.pbemap.size()+2,olimap.size());
    }
    
    static testMethod void massTest02() {
    	  // insert into two Opportunity each one sn at once
    	  testData.testOpportunity testOpp01 = new testData.testOpportunity();
    	  System.assert(testOpp01.hasData);
    	  testData.testOpportunity testOpp02 = new testData.testOpportunity();
    	  System.assert(testOpp02.hasData); 
    	  map<Id, Opportunity> oppmap=new map<Id, Opportunity>();
    	  oppmap.put(testOpp01.opp.id, testOpp01.opp);
    	  oppmap.put(testOpp02.opp.id, testOpp02.opp);
        testData.testSammelnummer mysn01 = new testData.testSammelnummer();
        System.assert(mysn01.hasData);
        testData.testSammelnummer mysn02 = new testData.testSammelnummer();
        System.assert(mysn02.hasData);
        list<OpportunityLineItem> snolis=new list<OpportunityLineItem>();
        OpportunityLineItem snoli01=new OpportunityLineItem(OpportunityId=testOpp01.opp.id,PricebookEntryId=mysn01.snpbe.id,SCHL2D__c=mysn01.pbetoal.get(mysn01.snpbe.id),Quantity=1,UnitPrice=1);
        OpportunityLineItem snoli02=new OpportunityLineItem(OpportunityId=testOpp02.opp.id,PricebookEntryId=mysn02.snpbe.id,SCHL2D__c=mysn02.pbetoal.get(mysn02.snpbe.id),Quantity=1,UnitPrice=1);
        snolis.add(snoli01);
        snolis.add(snoli02);
        try {
        	test.startTest();
        	onOpportunityLineItem.inFutureContextStoredId = '';
        	insert snolis;
        	test.stopTest();
        } catch (System.DMLException e) {
        	System.debug('PARX testmsg ' + e.getMessage());
        	if (SystemSettings.isDebug) throw e;
        }
        System.assertNotEquals(null,snolis.get(0).id);
        System.assertNotEquals(null,snolis.get(1).id);
        // now we can prove that all the Signatures (Products) from the sammelnummer has been created as LineItems for this opportunity
        map<Id, OpportunityLineItem> olimap=new map<Id, OpportunityLineItem>();
        Set<Id> pbeids=new Set<Id>();
        for (OpportunityLineItem oli: [SELECT Id, PricebookEntryId, SCHL2D__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN:oppmap.keySet()]) {
        	if (!pbeids.contains(oli.PricebookEntryId)) pbeids.add(oli.PricebookEntryId);
        	if (!olimap.containsKey(oli.id)) olimap.put(oli.id,oli);
        }
        System.assertEquals(mysn01.pbemap.size()+mysn02.pbemap.size()+2,olimap.size());
    }
   
}