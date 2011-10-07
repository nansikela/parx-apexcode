public class FAPortfolioAjaxController {
	private String currentPortfolioURL;
	public Portfolio2__c currentPortfolio {get; set;}
	public String teilnehmer {get; set;}
	public String dauer {get; set;}
	
	public FAPortfolioAjaxController()
	{
		currentPortfolioURL = WebURLEncoder.decodeParam('url');
		List<Portfolio2__c> portfolioList = [SELECT ID, Beginn__c, Dauer_in_Tagen__c, Ende__c, Buchbar__c, Neu__c, Web_Preis__c, Englisch__c, Max_Teilnehmer__c FROM Portfolio2__c WHERE URL__c = : currentPortfolioURL];
		if(portfolioList.size()>0)
		{
			currentPortfolio = portfolioList.get(0);
			teilnehmer = String.valueOf(currentPortfolio.Max_Teilnehmer__c).replace('.0','');
			dauer = String.valueOf(currentPortfolio.Dauer_in_Tagen__c).replace('.0','');
		}
	}
}