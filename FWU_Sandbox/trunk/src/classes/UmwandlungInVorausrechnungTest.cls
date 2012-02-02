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
private class UmwandlungInVorausrechnungTest {

    static testMethod void initTest() {
    	  testData.testOpportunity testOpp = new testData.testOpportunity();
    	  System.assert(testOpp.hasData);
    	  testOpp.opp.CloseDate=System.today()+365;
    	  testOpp.opp.REAR2A__c=0;
    	  update testOpp.opp;
        testData.testSammelnummer mysn = new testData.testSammelnummer();
        System.assert(mysn.hasData);
        OpportunityLineItem sigoli=new OpportunityLineItem(OpportunityId=testOpp.opp.id,PricebookEntryId=mysn.pbemap.values().get(0).id,SCHL2D__c=mysn.pbetoal.get(mysn.pbemap.values().get(0).id),Quantity=1,UnitPrice=1);
        try {
        	insert sigoli;
        } catch (System.DMLException e) {
        	System.debug('PARX testmsg ' + e.getMessage());
        	if (SystemSettings.isDebug) throw e;
        }
        testOpp.opp.StageName='Bereit zur Freigabe';
    	//testOpp.opp.Locked__c=false;
    	update testOpp.opp;
        testOpp.opp.REAR2A__c=3;
        test.startTest();
        update testOpp.opp;
        test.stopTest();
        // system.asserts
        Opportunity oppresult=[SELECT Id, REAR2A__c FROM Opportunity WHERE Id=:testOpp.opp.id];
        System.assertEquals(3,oppresult.REAR2A__c);
        list<OpportunityLineItem> vorausolis=new list<OpportunityLineItem>();
        Id lieferanzeigeid=null;
        for (OpportunityLineItem oli: [SELECT Id, LieferanzeigeId__c FROM OpportunityLineItem WHERE OpportunityId=:oppresult.id]) {
        	vorausolis.add(oli);
        	//System.assertNotEquals(null,oli.LieferanzeigeId__c);
        	lieferanzeigeid=oli.LieferanzeigeId__c;
        }
        if (lieferanzeigeid!=null) {
       		Opportunity lieferanzeige=[SELECT Id, REAR2A__c FROM Opportunity WHERE Id=:lieferanzeigeid];
        	System.assertEquals(8,lieferanzeige.REAR2A__c);
        	System.assertNotEquals(0,[SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId=:lieferanzeigeid]);
        }
    }
}