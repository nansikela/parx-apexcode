public class WebJsonHotelLocation 
{
	public static String getGenerateJsonHotel()
	{
		String json = '{';
		boolean isFirstState = true;
		for(AggregateResult a :[SELECT account__r.BillingCity city, region__c state FROM HOTEL__c WHERE region__c != '' AND Anzeige_auf_Website__c = true GROUP BY account__r.BillingCity, region__c ORDER BY region__c , account__r.BillingCity])
		{
			String state = String.valueOf(a.get('state'));
			String city = String.valueOf(a.get('city'));
			if(!json.contains(state))
			{
				if(isFirstState)
				{
					json+= '"states": [{"state":"'+state+'", "cities": [';
					isFirstState = false;
				}
				else
				{
					json+= ']}, {"state":"'+state+'", "cities": [';
				}
				json+= '{"city":'+'"'+city+'"}';
			}
			else
			{
				json+= ', {"city":'+'"'+city+'"}';
			}
		}
		json += ']}]}';
		
		return json;
	}
	
	static testMethod void myUnitTest() {
		getGenerateJsonHotel();
	}
}