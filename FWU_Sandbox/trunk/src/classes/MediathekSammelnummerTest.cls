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
private class MediathekSammelnummerTest {

	static testMethod void testTestData() {
		MTTestData testData = new MTTestData();
		// remove MedienpaketLizenzen created by trigger
		delete testData.mplizenzen;
		test.startTest();
			testData.createMedienpaketLizenz(testData.products);
			onProduct.inFutureContextStoredId='';
			MediathekSammelnummer.createMedienpaketLizenzenOnce=false;
	        MediathekSammelnummer.updatePricesOnce=false;
	        onProduct.inFutureContextStoredId='';
	        testData.updateProductRemoveFromMediathek();
	        onProduct.inFutureContextStoredId='';
	        testData.updateProductInsertToMediathek();
		test.stopTest();
	}

    static testMethod void addProduct2MTTest01() {
        // test with testdata
        test.startTest();
        	onProduct.inFutureContextStoredId='';
        	MTTestData testData = new MTTestData();
        test.stopTest();
        // if the trigger works as expected there have to be some Medienpaket Lizenzen
        System.assert(testData.checkforMedienpaketLizenz(testData.products));
        
    }
    
    static testMethod void addProduct2MTTest02() {
        // test with existing data
    }
    
    static testMethod void checkPriceMTTest01() {
        // test with testdata
        test.startTest();
	        MTTestData testData = new MTTestData();
	        MediathekSammelnummer.createMedienpaketLizenzenOnce=false;
	        MediathekSammelnummer.updatePricesOnce=false;
	        onProduct.inFutureContextStoredId='';
	        if(!testData.checkforMedienpaketLizenz(testData.products)) {
	        	MediathekSammelnummer.createMedienpaketLizenzenOnce=false;
	        	onProduct.inFutureContextStoredId='';
	        	MediathekSammelnummer.updatePricesOnce=false;
	        	testData.createMedienpaketLizenz(testData.products);
	        	//testData.updateProductRemoveFromMediathek();
	        }
	        MediathekSammelnummer.createMedienpaketLizenzenOnce=false;
	        MediathekSammelnummer.updatePricesOnce=false;
	        onProduct.inFutureContextStoredId='';
	        //testData.updateProductRemoveFromMediathek();
	        testData.updateProductInsertToMediathek();
        test.stopTest();
        // if the trigger works as expected the price of alle Medienpaket Lizenzen has to be the total price for the paket
        Double sum=0;
        set<id> mplids = new set<Id>();
        for (Medienpaket_Lizenz__c mpl:testData.mplizenzen) {
        	mplids.add(mpl.id);
        }
        for (Medienpaket_Lizenz__c mpl:[SELECT Id, Signatur__c, Lizenznummer__c, Medienpaket__c, VPR012__c, Untermedienart__c FROM Medienpaket_Lizenz__c WHERE Medienpaket__c = :testData.mtsammelnummer.id]) {
        	if (mpl.Medienpaket__c==testData.mtsammelnummer.id) sum=sum+mpl.VPR012__c;
        }
        System.assertEquals(testData.cs_mtsammelnummer.get(0).Gesamtpreis_Brutto__c,sum);
    }
}