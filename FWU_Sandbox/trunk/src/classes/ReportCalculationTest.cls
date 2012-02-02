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
private class ReportCalculationTest {

    static testMethod void ReportCalculationTest() {
    	testData.testOpportunity initOpp=new testData.testOpportunity();
    	testData.testOli initOlis= new testData.testOli(initOpp.opp.id);
    	testData.testInvoices initInvoices = new testData.testInvoices(initOpp.opp, initOlis.pmap.values(), 20);
    	map<id, opportunitylineitem> olis=new map<id, opportunityLineItem>();
    	for (opportunitylineitem oli:[SELECT Id, OppRechnungsArt__c, OpportunityId, OppBestelldatum__c, CreatedDate, Quantity, GELM2D__c, Verkaufspreis_Netto__c, STAT2D__c, Bericht_AU_Datum__c, Gesamtpreis_Netto__c FROM OpportunityLineItem limit 50]) {
    		olis.put(oli.id, oli);
    	}
    	ReportKonfiguration__c rk=new ReportKonfiguration__c(Name='MeinTest',
    								Basisjahr__c=String.valueOf(System.today().year()),
    								Vergleichsjahr__c=String.valueOf(System.today().year()-1),
    								Basismonat_von__c=Date.newInstance(System.today().year(),1,1),
    								Basismonat_bis__c=Date.newInstance(System.today().year(),1,2),
    								Vergleichsmonat_von__c=Date.newInstance(System.today().year()-1,1,1),
    								Vergleichsmonat_bis__c=Date.newInstance(System.today().year()-1,1,2)
    								);
    	insert rk;
    	rk=[SELECT Id
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
							FROM ReportKonfiguration__c WHERE Id=:rk.id];
    	ReportResult__c rr=new ReportResult__c();
        ReportCalculationOpportunity.ReportCalculationRun(olis.values(), rk, rr);
        ReportCalculationBatchStart.start(rk.id);
    }
}