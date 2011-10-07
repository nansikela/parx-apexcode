@isTest
private class WebLexikonOverviewControllerTest {

    static testMethod void myUnitTest() {
    	ApexPages.currentPage().getParameters().put('test', 'true');
    	WebLexikonOverviewController c = new WebLexikonOverviewController();
    }

}