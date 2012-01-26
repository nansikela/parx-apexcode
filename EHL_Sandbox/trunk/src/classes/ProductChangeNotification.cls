public class ProductChangeNotification {
@future (callout = true)

	//Called from OpportunityLineItem_afterInsert.trigger (no test class needed)
	public static void sendNotification(String data, String targetUrl)
	{
		try
		{
			HttpRequest req = new HttpRequest();
			Http http = new Http();
			String requestBody = 'data=' + data;
			
			req.setMethod('POST');
			req.setBody(requestBody);
			
			System.debug('**** data to be sent is: '+ data);
			
			// add the endpoint to the request
			req.setEndpoint(targetUrl);
			
			// create the response object
			HTTPResponse resp = http.send(req);
			
		}catch(System.Exception e)	
		{
			System.debug('**** Exception: ' + e);
		}		
	
	}

}