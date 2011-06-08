@isTest
private class CRD_MarketingTest {

    static testMethod void myUnitTest() {
    	ApexPages.currentPage().getParameters().put('pageid', 'test');
		CRD_MarketingController ctrl = new CRD_MarketingController();
    }
}