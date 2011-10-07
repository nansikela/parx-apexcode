@isTest
private class WebSeminarDetailEnhancedControllerTest {

    static testMethod void myUnitTest() {
    	
    	ApexPages.currentPage().getParameters().put('seminarCode', 'FO120');
        WebSeminarDetailEnhancedController controller = new WebSeminarDetailEnhancedController();
    }
}