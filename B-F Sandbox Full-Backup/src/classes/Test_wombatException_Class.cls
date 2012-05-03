@isTest
private class Test_wombatException_Class {
	static testMethod void unitTest1() {
        INFW_TestHelper helper = new INFW_TestHelper();
        User u1 = helper.createUser();
        Profile []p1 = [select id from Profile where Name = 'AUD-Customer Service (Platform)' LIMIT 1];        
        u1.ProfileID = p1[0].id;      
        insert u1;		

		System.runAs(u1) {
			test.startTest();
		
			wombat_Exception we = new wombat_Exception();
			we.isWombatException = true;
		
			System.assertEquals(we.isWombatException, true);
		
		test.stopTest();
		}
	}
}