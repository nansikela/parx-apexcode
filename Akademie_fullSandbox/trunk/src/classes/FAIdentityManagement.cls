/**
 * Firmenakademie Cookie für User Session
 *
 * @author Christian Deckert
 * @version 1.0
 */
public class FAIdentityManagement {
	
	public static String user;
	
	public FAIdentityManagement()
	{
		if(getPersonCookie()== null)
		{
			user = 'ie+'+String.valueOf(DateTime.now())+String.valueOf(Math.random());
			Cookie c = new Cookie('userId', user, '/', -1, false);
			List<Cookie> cookies = new List<Cookie>();
			cookies.add(c);
			ApexPages.currentPage().setCookies(cookies);
		}
		
	}
	
	public PageReference insertUser()
	{
		FAWarenkorbJson controller = new FAWarenkorbJson();
		controller.upseartUser();
		if(getPersonCookie() == null)
		{
			upsert new Person__c(Id = controller.getUserId(), Cookie_IE6__c = user);
		}
		return null;
	}	
	
	
	
	public static String getPersonCookie()
	{
		if(ApexPages.currentPage().getCookies().containsKey('userId'))
		{
			if(ApexPages.currentPage().getCookies().get('userId').getValue().contains('ie'))
			{
				if(ApexPages.currentPage().getCookies().get('userId').getValue() != null)
				{
					List<Person__c>personen = [SELECT ID FROM Person__c WHERE Cookie_IE6__c = :ApexPages.currentPage().getCookies().get('userId').getValue()];
					if(personen.size()>0)
					{
						return personen.get(0).id;
					}
					else
					{
						return null;
					}
				}
				else
				{
					return null;
				}
			}
		return ApexPages.currentPage().getCookies().get('userId').getValue();
		}
		else
		{
			return null;
		}
	}
	
	@isTest
	static void FAIdentityManagementTest() {
		Warenkorb_Element__c w = [SELECT Id, warenkorb__r.person__r.Benutzer__c,warenkorb__r.person__r.Benutzer__r.id FROM Warenkorb_Element__c WHERE warenkorb__r.person__r.Benutzer__c != null LIMIT 1];
		User u = w.warenkorb__r.person__r.Benutzer__r;
		System.runAs(u){
			FAIdentityManagement ctrl = new FAIdentityManagement();
			ctrl.insertUser();
			FAIdentityManagement.getPersonCookie();
		}
		
	}
}