@isTest
private class Test_Master_Data_Verified {

    static testMethod void myUnitTest() {
        Account account = new Account(Name = 'test');
        insert account;
        String test = Master_Data_Verified.init(account.Id);
        system.assertEquals('Your account has been updated', test);
    }
}