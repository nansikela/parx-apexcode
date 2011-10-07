public class WebGoogleAutocomplete {
	public String response{get ; set;}
	public void sendRequest()
	{
		HttpRequest req = new HttpRequest();
		String q = WebURLEncoder.decodeParam('q');
		String query = 'http://clients1.google.com/complete/search?xml=t&q='+q+'&hl=de&client=partner&source=gcsc&partnerid=005859830995933115925%3A9zeu8lawcj0&ds=cse';
		req.setEndpoint(query);
		req.setMethod('GET');
		try
		{
			Http http = new Http();
			HTTPResponse res = http.send(req);
			Dom.Document doc = res.getBodyDocument();
			Dom.XMLNode toplevel = doc.getRootElement();
			response = '{"complete": [';
				boolean isFirst = true;
				for(Dom.XMLNode child :toplevel.getChildren())
				{
					if(!isFirst)
					{
						response+=',';
					}
					else
					{
						isFirst = false;
					}
					response+='{"suggestion":"';
					for(Dom.XMLNode c :child.getChildren())
					{
						if(c.getName() == 'suggestion')
						{
							response+= c.getAttribute('data', null);
						}
					}
					
					response+= '"}';
				}
			
			response+= ']}';
			
			System.debug('***res.getBodyDocument();:'+response);
			if(response.contains('window.google.ac.h'))
			{
				response = response.replace('window.google.ac.h', 'suggestResult');
			}
		}catch(Exception e)
		{

		}
	}
}