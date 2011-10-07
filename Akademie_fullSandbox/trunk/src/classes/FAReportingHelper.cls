public class FAReportingHelper {

	private static List<ID> permissionCompanyIDList;
	private static List<Firma__c> permittedFirma;
	
	public static List<Firma__c> getPermittedFirma (){
		if(permittedFirma == null && FAHelper.getCurrentPerson().Personaler_Firma__c != null)
		{
			permittedFirma = [Select f.Id, f.name, (Select Id, name From FA_Firmen__r) From Firma__c f WHERE ID = :FAHelper.getCurrentPerson().Personaler_Firma__c];
		}
		return permittedFirma;
	}
	
	
	
	
	public static List<ID> getPossibleCompanyIds()
	{
		if(permissionCompanyIDList == null)
		{
			permissionCompanyIDList = new List<Id>();
			{
				for(Firma__c f :getPermittedFirma () )
				{
					permissionCompanyIDList.add(f.id);
					for(Firma__c ff: f.FA_Firmen__r)
					{
						permissionCompanyIDList.add(ff.id);
					}
				}
			}
		}
		return permissionCompanyIDList;
	}
}