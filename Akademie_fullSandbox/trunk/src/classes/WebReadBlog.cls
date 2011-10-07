global class WebReadBlog implements Schedulable
{
	global void execute(SchedulableContext SC) {
      readBlog();
   }
   public static PageReference readBlogAction()
   {
	   	readBlog();
	   	return null;
   }
	public static void readBlog()
	{
		
		HttpRequest req = new HttpRequest();
		req.setEndpoint('http://blog.die-akademie.de/feed/');
		req.setMethod('GET');
		try
		{
			List<AkademieBlog__c> blogElementList = new List<AkademieBlog__c>();
			Http http = new Http();
			HTTPResponse res = http.send(req);
			Dom.XMLNode rss = res.getBodyDocument().getRootElement();
			Dom.XMLNode channel = rss.getChildElement('channel', null);
			Integer i = 0;
			System.debug('*********ITEM'+channel.getName());
			for(Dom.XMLNode item : channel.getChildElements())
			{
				if(item.getName() =='item' && i<4)
				{
					i ++;
					String pubDateString = item.getChildElement('link', null).getText();
					pubDateString = pubDateString.replace('http://blog.die-akademie.de/', '');
					List<String> pubDateStringList = pubDateString.split('/');
					
					Date pubDate = Date.valueOf(pubDateStringList.get(0).subString(0,4)+'-'+ pubDateStringList.get(1).subString(0,2)+'-'+ pubDateStringList.get(2).subString(0,2));
					blogElementList.add(new AkademieBlog__c(name = 'Beitrag: '+String.valueOf(i), title__c = item.getChildElement('title', null).getText(), link__c = item.getChildElement('link', null).getText(), pubDate__c = pubDate.format()));
				}
			}
			delete AkademieBlog__c.getAll().values();
			insert blogElementList;
		}
		catch(Exception e)
		{}
	}
	
	static testMethod void test()
	{
		WebReadBlog.readBlog();
	}
}