public class FARegisterControllerStep2 
{
	private Contact contact;
	public String password {get; set;}
	public String passwordConfirm {get; set;}
	public FARegisterControllerStep2()
	{
		if(WebURLEncoder.decodeParam('token')!= null && WebURLEncoder.decodeParam('token')!='')
		{
			contact = [SELECT id,LastName, Firstname, eMail, Salutation From Contact WHERE ID = :WebURLEncoder.decodeParam('token') ];
		}
		
	}
	
	public PageReference toStep3()
	{
			
			if(passwordConfirm!= null && password!= null && passwordConfirm.trim() != password.trim())
			{
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
	        	ApexPages.addMessage(msg);
	            return null;
			}else{
				User u = new User();
				u.Firstname = contact.Firstname;
				u.LastName = contact.LastName;
				u.IsPortalSelfRegistered = true;
				//u.IsPortalEnabled = true;
		        u.Alias = 'CuPo';
		        u.Username = contact.Email;
		        u.Email = contact.Email;
		        u.ContactId = contact.id;
		        u.CommunityNickname = contact.Email;
		        u.ProfileId = '00e20000001QIym';
		        u.LanguageLocaleKey = 'de';
		        u.LocaleSidKey = 'de';
		        u.TimeZoneSidKey = 'Europe/Berlin';
		        u.EmailEncodingKey = 'UTF-8';
		        u.Token__c = FAHelper.generateToken();
		        u.passwort__c = password;
		        u.Anrede__c = contact.Salutation;
		        try{
		        insert u;
		        }
		        catch(Exception e)
		        {
		        	return new PageReference('/ERROR');
		        }
		        return new PageReference('https://die-akademie.secure.force.com/firmenakademie/FaRegisterStep3?token='+u.id);
			}
			
			
			return null;
		
	}
	
	static testMethod void testRegistration() 
	{
		Contact c = [SELECT ID FROM Contact LIMIT 1];
		ApexPages.currentPage().getParameters().put('token', c.id);
		FARegisterControllerStep2 controller = new FARegisterControllerStep2();
		controller.toStep3();
	}
}