@isTest
private class DEuserprofileportletControllerTest {
	public static testMethod void testDEuserprofileportletController() {
	 	testData.initData mytestData = new testData.initData('de',false);
	 	System.runAs(mytestData.testuser) {
		 	DEuserprofileportletController ctrl = new DEuserprofileportletController();
		 	ctrl.init();
		 	ctrl.getBenutzerdatenUrl();
		 	
	 	}
	 }
	public static testMethod void testDEuserprofileportletControllerNoAuth() {
	 	testData.initData mytestData = new testData.initData('de',false);

	 	DEuserprofileportletController ctrl = new DEuserprofileportletController();
	 	ctrl.init();
	 	ctrl.getBenutzerdatenUrl();
	 	
	 }

}