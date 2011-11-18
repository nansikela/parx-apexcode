public class WarenkorbStatusCode 
{
	private static Map<String, BestellStatusCode__c>bestellStatusCodes;
	
	static
	{
		bestellStatusCodes = BestellStatusCode__c.getAll();
	}
	public static Integer getCode(String key)
	{
		if(bestellStatusCodes.containsKey(key))
		{
			Integer code = Integer.valueOf(bestellStatusCodes.get(key).Code__c);
			return code;
		}
		else
		{
			return null;
		}
	}
	
}