public class WebGoogleSiteSearch 
{
	
	
	public List<SearchResultElement> googleResult {get; set;}
	public String query {get; set;}
	public void sendRequest()
	{
		HttpRequest req = new HttpRequest();
		query = WebURLEncoder.decodeParam('q');
		String query = 'http://www.google.com/cse?cx=005859830995933115925%3A9zeu8lawcj0&client=google-csbe&output=xml&num=100&q='+query;
		if(query != null && query != '')
		{
			req.setEndpoint(query);
			req.setMethod('GET');
			try{
			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug('res_'+res);
			System.debug('***res.getBodyDocument();:'+res.getBodyDocument());
			
			Dom.Document doc = res.getBodyDocument();
			Dom.XMLNode address = doc.getRootElement();
			googleResult = new List<SearchResultElement>();
			Dom.XMLNode gres = address.getChildElement('RES', null);
			
			for(Dom.XMLNode child : gres.getChildren())
			{
				if(child.getName() == 'R' && child.getAttribute('MIME', null)!= 'application/pdf' && child.getChildElement('U', null).getText() != 'http://www.die-akademie.de/')
				{
					SearchResultElement e = new SearchResultElement(child.getChildElement('T', null).getText(), child.getChildElement('U', null).getText(), child.getChildElement('S', null).getText());
					
					googleResult.add(e);
				}
			}
			}catch(Exception e){}
		}
		if(googleResult == null || googleResult.size()== 0)
		{
			googleResult = new List<SearchResultElement>();
			SearchResultElement element = new SearchResultElement();
			element.titel = 'Keine Ergebnisse gefunden.';
			element.content = 'Nutzen Sie unsere Direktsuche auf der rechten Seite oder kontaktieren Sie uns. ';
			element.url = 'http://www.die-akademie.de/service/kontakt';
			googleResult.add(element);
		}
	}
	
	
	class SearchResultElement{
		public String url {get; set;}
		public String titel {get; set;}
		public String content {get; set;}
		public SearchResultElement()
		{}
		
		public SearchResultElement(String titel, String url, String content)
		{
			this.titel = titel;
			if(this.titel != null && this.titel.contains(' - '))
			{
				this.titel = this.titel.subString(0, this.titel.indexOf(' - '));
			}
			
			this.url = url;
			this.content = content;
		}
	}
}