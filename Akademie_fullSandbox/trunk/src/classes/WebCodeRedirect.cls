public class WebCodeRedirect 
{
	public static PageReference result;
	public static PageReference redirectToSeminar()
	{
		String code = WebURLEncoder.decodeParam('code').toUpperCase();
		return redirectToSeminar(code);
		
	}
	
	public static PageReference redirectToSeminar(String code)
	{
		if(result == null)
		{
			for(Portfolio2__c p : [SELECT id, URL__c FROM Portfolio2__c WHERE name = :code AND Live__c = true])
			{
				if(p.Url__c != null)
				{
					result = new PageReference(p.URL__c);
					return result;
				}
				
			}
			
			for(Gruppe__c g : [SELECT id, URL__c FROM Gruppe__c WHERE Name = :code ])
			{
				if(g.Url__c != null)
				{
					result = new PageReference(g.URL__c);
					return result;
				}
			}
			
			result = new PageReference('/');
		}
		return result;
	}
	
	
	public static testMethod void test()
	{
		ApexPages.currentPage().getParameters().put('code', 'FO120');
		WebCodeRedirect.redirectToSeminar();
	}
	public static testMethod void test2()
	{
		ApexPages.currentPage().getParameters().put('code', 'gmp');
		WebCodeRedirect.redirectToSeminar();
	}
	public static testMethod void test3()
	{
		ApexPages.currentPage().getParameters().put('code', 'abc');
		WebCodeRedirect.redirectToSeminar();
	}
}