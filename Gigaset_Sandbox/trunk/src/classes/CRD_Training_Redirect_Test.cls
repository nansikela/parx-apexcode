@isTest
private class CRD_Training_Redirect_Test {

    static testMethod void myUnitTest() {
       	CRD_Training_Redirect_Controller ctrl = new CRD_Training_Redirect_Controller(new TemplateController());
       	ctrl.callTrainingModule();
    }
}