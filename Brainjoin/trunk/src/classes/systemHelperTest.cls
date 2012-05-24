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
private class systemHelperTest {

	static testMethod void testIsPauschale() {
		String kategorieFALSCH='Test';
		// CR NP
		String kategorieWAHR='Seminar Pauschale';
		
		System.assert(!systemHelper.isPauschale(kategorieFALSCH));
		System.assert(systemHelper.isPauschale(kategorieWAHR));
	}
	
	static testMethod void testIsAbklaerungPauschal() {
		// CR NP
		String kategorieFALSCH='Seminar Pauschale';
		String kategorieWAHR='Abklärung Pauschal';
		
		System.assert(!systemHelper.isAbklaerungPauschal(kategorieFALSCH));
		System.assert(systemHelper.isAbklaerungPauschal(kategorieWAHR));
	}
	
	static testMethod void testIsCoachingActivity() {
		String kategorieFALSCH='Test';
		String kategorieWAHR='Coaching';
		
		System.assert(!systemHelper.isCoachingActivity(kategorieFALSCH));
		System.assert(systemHelper.isCoachingActivity(kategorieWAHR));
	}
	
	static testMethod void testIsVerrechenbareLeistung() {
		String kategorieFALSCH='Test';
		String kategorieWAHR='Coaching';
		
		System.assert(!systemHelper.isVerrechenbareLeistung(kategorieFALSCH));
		System.assert(systemHelper.isVerrechenbareLeistung(kategorieWAHR));
		System.assert(systemHelper.isVerrechenbareLeistung('Wegentschädigung'));
	}

    static testMethod void sendEmailTest() {
       systemHelper.sendApexWarnEmail('message');
    }
}