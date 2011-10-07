public class FARegisterControllerStep3 {

	public PageReference savePassword()
	{
		try{
			
		
		User u = [SELECT ID, Firstname, Lastname, anrede__c, eMail, token__c, IsPortalEnabled, passwort__c FROM User WHERE Id = : WebURLEncoder.decodeParam('token')];
		u.IsPortalEnabled = true;
		update u;
		System.setPassword(u.id, u.passwort__c);
		FAMailSender.sendRegistrationMail(u);
		}catch(Exception e)
		{
			System.debug('**********e:'+e);
			
		}
		return null;
	}
	static testMethod void testRegistration() 
	{
		FARegisterControllerStep3 controller = new FARegisterControllerStep3();
		controller.savePassword();
		
	}
}