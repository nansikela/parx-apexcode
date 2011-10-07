public class FASiteFULLFacade {


	private static String description;
	private static String keywords;
	private static String title;
	
	private static String bereichId;
	private static String portfolioId;
	private static String groupId;
	private static String url;
	
	static
	{
		bereichId 		= WebURLEncoder.decodeParam('bereich');
		portfolioId 	= WebURLEncoder.decodeParam('portfolioId');
		groupId			= WebURLEncoder.decodeParam('groupId');
		url				= ApexPages.currentPage().getUrl();
	}
	
	
	private static void setDescriptionKeywords()
	{
		try
		{
			if(PortfolioId != null)
			{
				for(Portfolio2__c p : [SELECT id, Meta_Description__c, Meta_Keywords__c FROM Portfolio2__c WHERE id = :portfolioId])
				{
					description = p.Meta_Description__c;
					keywords = p.Meta_Keywords__c;
					return;
				}
			}
			if(groupId != null)
			{
				for(Gruppe__c p : [SELECT id, Meta_Description__c, Meta_Keywords__c FROM Gruppe__c WHERE id = :groupId])
				{
					description = p.Meta_Description__c;
					keywords = p.Meta_Keywords__c;
					return;
				}
			}
			
			for(Navigation__c p :[SELECT Meta_Description__c, Meta_Keywords__c FROM Navigation__c WHERE Url__c = :url])
			{
				description = p.Meta_Description__c;
				keywords = p.Meta_Keywords__c;
				return;
			}
		}catch(Exception e){}
	}
	
	
	public static PageReference identifyUser()
	{
		FAHelper.getCurrentPerson();
		return null;
	}
	
	public static String getMetaDescription()
	{
		if(description== null)
		{
			setDescriptionKeywords();
		}
		return description;
	}
	
	public static String getMetaKeywords()
	{
		if(keywords== null)
		{
			setDescriptionKeywords();
		}
		return keywords;
	}
	
	public static String getTitle()
	{
		if(title== null)
		{
			title = '';
			if((bereichId != null && bereichId!= '')|| (portfolioId != null && portfolioId != ''))
			{
				title += 'Seminar - ';
			}
			FaNavigationFacade controller = new FaNavigationFacade();
			for(Integer i = controller.breadCrumb.size()-1; i>=0; i--)
			{
				title+= controller.breadCrumb.get(i).item+' ';
			}
			
			
			title+= '- Die Akademie';
		}
		return title;
	}
	public List<AkademieBlog__c> getBlogArticle()
	{
		return AkademieBlog__c.getAll().values();
	}
	static testMethod void test(){
		FASiteFULLFacade.identifyUser();
		FASiteFULLFacade.getMetaDescription();
		FASiteFULLFacade.getMetaKeywords();
		FASiteFULLFacade.getTitle();
	}
}