public class FAKontakdatenaendernController {
	public Person__c currentPerson {get; set;}
	
	public FAKontakdatenaendernController()
	{
		currentPerson = FAHelper.getCurrentPerson();
	}
	
	public PageReference save()
	{
		try{
		update currentPerson;
		}
		catch(Exception e)
		{
			for(Integer i = 0; i<e.getNumDml();i++)
			{
				ApexPages.addMessage(new ApexPages.Message(
	            ApexPages.Severity.ERROR, e.getDmlMessage(i)));
			}
			return null;
		}
		return new PageReference('/profil/kontaktdaten');
	}
	public PageReference edit()
	{
		return new PageReference('/profil/kontaktdaten?mode=edit');
	}
	public PageReference cancel()
	{
		return new PageReference('/profil/kontaktdaten');
	}
	
	static testMethod void testRegistration() 
	{
			
	}
	
	static testMethod void testFaHelper() {
		Person__c p = [SELECT Benutzer__c, Benutzer__r.id FROM Person__c WHERE Benutzer__c != null LIMIT 1];
		User u = p.Benutzer__r;
		System.runAs(u){
			FAKontakdatenaendernController controller = new FAKontakdatenaendernController();
			controller.save();
			controller.edit();
			controller.cancel();
		}
	}
	
}