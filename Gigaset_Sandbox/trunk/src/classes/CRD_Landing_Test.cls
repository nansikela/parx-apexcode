@isTest
private class CRD_Landing_Test {

    static testMethod void myUnitTest() {
    	ApexPages.currentPage().getParameters().put('pageid', System_Settings.homepageid);
        CRD_Landing_Controller ctrl = new CRD_Landing_Controller(new TemplateController());
        ctrl.goToLogin();
    }
}