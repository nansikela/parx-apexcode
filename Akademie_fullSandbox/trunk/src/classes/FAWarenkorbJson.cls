/**
 * Firmenakademie FAWarenkorbJson.
 *
 * @author Christian Deckert
 * @version 1.0
 */
public class FAWarenkorbJson 
{
	private String userId;
	public PageReference upseartUser()
	{
		Person__c tempPerson = FAHelper.getCurrentPerson();
		userId = tempPerson.id;
		if(FAHelper.userIsTemp || userId == 'a0e200000018X13AAE')
		{
			Person__c currentPerson = new Person__c(Firma__c = tempPerson.Firma__c, name = 'WebSiteUser', Vorname__c = 'Nicht bekannt', recordTypeId = tempPerson.recordTypeId);
			insert currentPerson;
			userId = currentPerson.id;
			//FAIdentityManagement.setPersonCookie(userId);
		}
		return null;
	}
	
	public String getUserId()
	{
		if(userId!= null)
		{
			return userId;
		}
		return null;
		
	}
	public Integer getWarenkorbCouner()
	{
		return FAHelper.getWarenkorbAnzahl();
	}
	
	static testMethod void testFaHelper() {
		FAWarenkorbJson controller = new FAWarenkorbJson();
		controller.upseartUser();
		controller.getWarenkorbCouner();
		controller.getUserId();
	}
}