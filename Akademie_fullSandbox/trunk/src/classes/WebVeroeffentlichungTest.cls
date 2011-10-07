@isTest
private class WebVeroeffentlichungTest {

    static testMethod void myUnitTest() {
        
        ApexPages.currentPage().getParameters().put('trainerId', '0032000000BSQuXAAX');
        WebVeroeffentlichung w = new WebVeroeffentlichung();
        w.getTrainerVeroeffentlichung();
        w.getVeroeffentlichungen();
        
    }
}