public class WebSiteSearchRequestSender {
	public String query {get; set;}
	
	public PageReference sendToSiteSearch()
	{
		String page = '/sitesearch/';
		if(query != null && query != '' && query !='sitesearch')
		{
			page = '/sitesearch/'+query;
		}
		if(page == '/sitesearch/')
		{
			page+= 'die-akademie';
		}
		return new PageReference(page);
	}
	static testMethod void test() 
    {
    	WebSiteSearchRequestSender controller = new WebSiteSearchRequestSender();
    	controller.sendToSiteSearch();
    }
}