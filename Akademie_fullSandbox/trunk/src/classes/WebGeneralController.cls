public class WebGeneralController 
{
	public String metaDescription {get; set;}
	public String metaKeywords {get; set;}
	public boolean isPDF {get; set;}
	
	private static WebGeneralController instance {get; set;}
	public WebGeneralController()
	{
		String seminarCode= ApexPages.currentPage().getParameters().get('seminarCode');
		if(seminarCode == null)
		{
			String pageId = ApexPages.currentPage().getParameters().get('pageid');
			for(Page__c p : [SELECT ID, meta_description__c, meta_Keywords__c FROM Page__c WHERE ID = :pageId])
			{
				metaDescription = p.Meta_Description__c;
				metaKeywords = p.Meta_Keywords__c;
			}
		}
		else
		{
			for(Portfolio__c p : [SELECT ID, meta_Description__c, meta_Keywords__c FROM Portfolio__c p WHERE name = :seminarCode AND p.Portfolio_Jahr__c  = :WebConfig.getPortfolioYear()])
			{
				metaDescription = p.Meta_Description__c;
				metaKeywords = p.Meta_Keywords__c;
			}
		}
		if(metaDescription == null)
		{
			metaDescription = 'Die Akademie für Führungskräfte ist eines der grössten und renommiertesten Management Institute im deutschsprachigen Raum. Seit über 55 Jahren werden Fach- und Führungskräfte aller Branchen auf Ihrem beruflichen und persönlichen Entwicklungsweg begleitet.';
		}
		
		
		//try to Find PDF
		isPDF = true;
		if(ApexPages.currentPage().getParameters().containsKey('seminarCode'))
		{
			isPDF = true;
		}
	}
	
	public static WebGeneralController getInstance()
	{
		if(instance == null)
		{
			instance = new WebGeneralController();
		}
		return instance;
	}
}