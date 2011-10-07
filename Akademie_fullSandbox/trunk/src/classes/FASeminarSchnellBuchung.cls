public class FASeminarSchnellBuchung 
{
	public List<SelectOption>portfolioList {get; set;}
	public String url {get; set;}
	
	public FASeminarSchnellBuchung()
	{
		portfolioList = new List<SelectOption>();
		portfolioList.add(new SelectOption('', '- bitte Seminar wählen -'));
		for(Portfolio2__c p : [Select p.URL__c, p.Seminartitel__c, p.Name From Portfolio2__c p WHERE p.Buchbar__c = true AND Bereich__r.Hauptbereich__r.Firma__c = :FAHelper.getCurrentFirma().id AND Buchen_Deaktivieren__c = false ORDER BY Name])
		{
			portfolioList.add(new SelectOption(p.URL__c+'/order', p.Name+' '+p.Seminartitel__c));
		}
	}
	
	public PageReference goToBuchung()
	{
		if(url== null || url == '')
		{
			return null;
		}
		return new PageReference(url);
	}
	
	static testMethod void testMain() {
		FASeminarSchnellBuchung controller = new FASeminarSchnellBuchung();
		controller.goToBuchung();
	}
}