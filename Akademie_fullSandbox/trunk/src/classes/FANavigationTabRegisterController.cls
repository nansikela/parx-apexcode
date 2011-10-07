public class FANavigationTabRegisterController {
	public List<Navigation__c> navigation {get; set;}
	
	
	public FANavigationTabRegisterController()
	{
		navigation = [Select n.URL__c, n.Name, n.Id, n.Firma__c, n.Firma__r.name, (Select Id, Name, URL__c From Untergeordnet__r ORDER BY Anordnung__c) From Navigation__c n  WHERE Firma__c !='' ORDER BY Anordnung__c];
		
	}
}