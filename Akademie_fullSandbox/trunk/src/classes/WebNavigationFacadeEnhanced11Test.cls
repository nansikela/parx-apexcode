@isTest
private class WebNavigationFacadeEnhanced11Test {

    static testMethod void myUnitTest() {
        WebNavigationFacadeEnhanced11 controller = new WebNavigationFacadeEnhanced11();
    }
    
    static testMethod void myUnitTest2() {
    	
    	ApexPages.currentPage().getParameters().put('pageid', 'a0M20000003XurU');
        WebNavigationFacadeEnhanced11 controller = new WebNavigationFacadeEnhanced11();
    }
}