@isTest
private class navigationTest {

    static testMethod void myUnitTest() {
        User u = [Select Id From User Where ContactId != null and isactive=true limit 1];
        System.runas(u){
        	System_Settings.isTest=true;
        	navigationController ctrl = new navigationController();
        	
        	ctrl.getHomeUrl();
        	ctrl.getLink01Url();
        	ctrl.getLink02Url();
        	ctrl.getLink03Url();
        	ctrl.getLink04Url();
        	ctrl.getLink05Url();
        	ctrl.getLink06Url();
        	
        	ctrl.getBaseTopNaviUrl();
        }
    }
}