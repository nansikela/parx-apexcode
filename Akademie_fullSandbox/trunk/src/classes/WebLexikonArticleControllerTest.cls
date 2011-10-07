@isTest
private class WebLexikonArticleControllerTest {

    static testMethod void myUnitTest() {
    	ApexPages.currentPage().getParameters().put('test', 'true');
        WebLexikonArticleController w = new WebLexikonArticleController();
    }
}