@isTest
private class CRD_MarketingTest {

    static testMethod void myUnitTest() {
    	testData.initData mytestData = new testData.initData('de',false);
    	
    	ApexPages.currentPage().getParameters().put('pageid', mytestData.PagesSet.get(0).id);
		CRD_MarketingController ctrl = new CRD_MarketingController();
    }
}