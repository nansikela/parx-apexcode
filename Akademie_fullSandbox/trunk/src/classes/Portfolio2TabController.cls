public class Portfolio2TabController 
{
	public List<Bereich__c> bereichList{get;set;}
	public List<Bereich__c> subbereichList{get; set;}
	private String bereichId;
	public Portfolio2TabController()
	{
		if(bereichList== null && WebURLEncoder.decodeParam('mode')==null || WebURLEncoder.decodeParam('mode')=='')
		{
				bereichList = [SELECT ID, name, Firma__c, Firma__r.name, Verantwortlicher__c, Verantwortlicher__r.name FROM BEREICH__c WHERE Hauptbereich__c = '' ORDER BY Anordnung__c];
		}
		else if(subbereichList== null && WebURLEncoder.decodeParam('mode')=='subbereich'){
			bereichId= WebURLEncoder.decodeParam('bereichId');
			querySubbereich();
		}
	}
	
	private  void querySubbereich()
	{
		subbereichList = [Select b.Verantwortlicher__r.Name, b.Verantwortlicher__c, b.Name, b.Id, (Select Id, name, Seminartitel__c, Anordnung__c From Firmenakademie_Portfolios__r WHERE LIVE__c = true ORDER BY Anordnung__c) From Bereich__c b WHERE Hauptbereich__c = :bereichId ORDER BY Anordnung__c];
	}
	
	public PageReference saveSubBereich()
	{
		List<Portfolio2__c> portfolioList = new List<Portfolio2__c>();
		for(Bereich__c b : subbereichList)
		{
			List<Portfolio2__c>p = b.Firmenakademie_Portfolios__r;
			portfolioList.addAll(p);
		}
		
		update portfolioList;
		this.querySubbereich();
		return new Pagereference('/apex/Portfolio2Tab');
	}
	static testMethod void testPortfolio2TabController() {
		Portfolio2TabController controller = new Portfolio2TabController();
		//controller.saveSubBereich();
	}
}