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
private class KreisOnlinePackageTest {

	static testMethod void codeCoverage() {
		testData.testKreisOnline initKOData=new testData.testKreisOnline();
	    System.assert(initKOData.hasData);
	    map<Id, OpportunityLineItem> initOlis=new map<Id, OpportunityLineItem>();
		KreisOnlinePackage kpg= new KreisOnlinePackage(initOlis);
		kpg= new KreisOnlinePackage(initKOData.olimap);
		
		test.startTest();
		
		for (Id oliid: initKOData.olimap.keySet()) {
			kpg.getKOpkgById(oliid);
		}
		
		Integer i=0;
		for (OpportunityLineItem oldOli: initKOData.olimap.values()) {
			System.debug('Test Oli Quantity Run ' + i + ':' + ' oldOli Id: ' + oldOli.id);
			OpportunityLineItem newOli=oldOli.clone(true, true, true, true);
			newOli.Quantity=oldOli.Quantity+1;
			kpg.syncPkg(oldOli, newOli);
			i++;
		}
		i=0;
		for (OpportunityLineItem oldOli: initKOData.olimap.values()) {
			System.debug('Test Oli Status Run ' + i + ':' + ' oldOli Id: ' + oldOli.id);
			OpportunityLineItem newOli=oldOli.clone(true, true, true, true);
			newOli.STAT2D__c='gelöscht';
			kpg.syncPkg(oldOli, newOli);
			i++;
		}
		i=0;
		for (OpportunityLineItem oldOli: initKOData.olimap.values()) {
			System.debug('Test Oli Status Run ' + i + ':' + ' oldOli Id: ' + oldOli.id);
			OpportunityLineItem newOli=oldOli.clone(true, true, true, true);
			newOli.Sperrkz__c=!newOli.Sperrkz__c;
			kpg.syncPkg(oldOli, newOli);
			i++;
		}
		initKOData.oppmap.values().get(0).StageName='Bereit zur Freigabe';
		update initKOData.oppmap.values().get(0);
		initKOData.updateOliData();
		i=0;
		for (OpportunityLineItem oldOli: initKOData.olimap.values()) {
			System.debug('Test Oli Quantity / Reserved Run ' + i + ':' + ' oldOli Id: ' + oldOli.id);
			OpportunityLineItem newOli=oldOli.clone(true, true, true, true);
			newOli.Quantity=oldOli.Quantity+1;
			if (kpg.getKOpkgById(newOli.id)!=null) kpg.getKOpkgById(newOli.id).isDeliverable();
			if (kpg.getKOpkgById(newOli.id)!=null) {
				kpg.getKOpkgById(newOli.id).updateOli(newOli);
				kpg.getKOpkgById(newOli.id).updateOli(kpg.getKOpkgById(newOli.id).getOliList());
				kpg.getTotalpriceById(newOli.id);
			}
			//kpg.syncPkg(newOli, oldOli);
			i++;
		}
		//kpg.finish();
		kpg.finish(initKOData.olimap);
		test.stopTest();
	}

}