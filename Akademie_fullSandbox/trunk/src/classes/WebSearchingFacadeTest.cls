@isTest
private class WebSearchingFacadeTest {

    static testMethod void myUnitTest() {
    		WebSearchingFacade w = new WebSearchingFacade();
    		w.init();
    		w.buildquery();
    		w.getResult();
    		ApexPages.currentPage().getParameters().put('d', '2010-10-01');
    		ApexPages.currentPage().getParameters().put('q', 'mem');
    		ApexPages.currentPage().getParameters().put('c', 'slepc');
    		ApexPages.currentPage().getParameters().put('r', 'bayern');
    		ApexPages.currentPage().getParameters().put('g', '1');
    		ApexPages.currentPage().getParameters().put('e', '1');
    		w = new WebSearchingFacade();
    		w.init();
    		w.buildquery();
    		w.getResult();
    		
    }
}