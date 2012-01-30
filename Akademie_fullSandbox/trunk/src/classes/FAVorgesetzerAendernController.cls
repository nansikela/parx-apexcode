public class FAVorgesetzerAendernController 
{
	public Person__c currentPerson {get; set;}
	public Person__c currentVorgesetzter {get; set;}
	public String currentVorgesetzterName {get; set;}
	public FAVorgesetzerAendernController()
	{
		currentPerson = FAHelper.getCurrentPerson();
		if(currentPerson.Vorgesetzer__c != null)
		{
			currentVorgesetzter = [Select p.Id, name, anrede__c, Vorname__c, Firma__c, eMail_Adresse_Vorgesetzter__c, Vorgesetzer__c, Firma__r.id, Firma__r.name From Person__c p WHERE id = : currentPerson.Vorgesetzer__c LIMIT 1];
			currentVorgesetzterName = currentVorgesetzter.Anrede__c+' '+currentVorgesetzter.Vorname__c+' '+currentVorgesetzter.Name;
		}
	}
	
	
	public PageReference save()
	{
		List<Person__c> vorgesetzterList = [SELECT ID FROM Person__c WHERE eMail__c = :currentPerson.eMail_Adresse_Vorgesetzter__c AND Firma__c = :currentPerson.Firma__c LIMIT 200];
		if(vorgesetzterList.size()>0)
		{
			currentPerson.Vorgesetzer__c = vorgesetzterList.get(0).id;
		}
		update currentPerson;
		return new PageReference('/FAVorgesetzten_aendern');
	}
	public PageReference edit()
	{
		return new PageReference('/FAVorgesetzten_aendern?mode=edit');
	}
	public PageReference cancel()
	{
		return new PageReference('/FAVorgesetzten_aendern');
	}
	
	static testMethod void test()
	{
		Person__c p = [SELECT id, Benutzer__r.id FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		
		System.runAs(p.Benutzer__r){
		
			FAVorgesetzerAendernController controller = new FAVorgesetzerAendernController();
			controller.edit();
			controller.cancel();
			//controller.save();
		}
	}
}