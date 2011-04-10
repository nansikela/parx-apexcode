@isTest
private class ActivationTest {
	static testMethod void ActivationUnitTest() {
		User u = [SELECT Id, ContactId FROM User WHERE contactId!=null AND IsActive=true limit 1];
		test.startTest();
		Activation.init(u.contactid, true);
		Activation.init(u.contactid, false);
		test.stopTest();
	}
	static testMethod void ActivationUnitTest2() {
		Account a=new Account(Name='Parx Test', BillingCity='test', BillingStreet='test', BillingCountry='Deutschland', BillingPostalCode='80337', Portal__c='de');
		insert a;
		Contact c=new Contact(Lastname='tester', AccountId=a.id, Gigaset_Extranet__c=true);
		insert c;
		if (c!=null) {
			test.startTest();
			Activation.init(c.id, true);
			c.Email='test@bla.de';
			update c;
			Activation.init(c.id, true);
			Activation.init(c.id, false);
			test.stopTest();
		}
	}
}