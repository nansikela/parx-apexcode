@isTest
private class WebEnhancedSearchTest {

    static testMethod void myUnitTest() 
    {
    	ApexPages.currentPage().getParameters().put('q', 'FO120');
        WebEnhancedSearch controller = new WebEnhancedSearch();
    }
}