global with sharing class promotionHelperClass
{
    webservice static void setPromotionUserLookups(ID[] promIds)
    {
        Set<ID> ownerIds = new Set<ID>();
        Map<ID,Promotion__c> mapProm = new Map<ID,Promotion__c>([Select Id, OwnerId from Promotion__c where Id in: promIds]);
    for(Promotion__c p : mapProm.values())
        {
            ownerIds.add(p.OwnerId);
        }
        
        Map<ID,User> mapUser = new Map<ID,User>([Select Id, Brand_Manager__c, Finance_Manager__c, Sales_Manager__c from User where Id in: ownerIds]);
        for(Promotion__c p : mapProm.values())
        {
            User u = mapUser.get(p.OwnerId);  
            if(u==null){continue;}
            p.Brand_Manager__c = u.Brand_Manager__c;
            p.Finance_Manager__c = u.Finance_Manager__c;
            p.Sales_Manager__c = u.Sales_Manager__c;            
        }
        update mapProm.values();
    }

	public static void calculateAccountBrandTotals(Set<ID> myIDS)
	{
		try{
			SYNCHcalculateAccountBrandTotals(myIDS);
     	}catch(AsyncException e){
			ASYNCHcalculateAccountBrandTotals(myIDS);
		}
	}
	
	@future (callout=true) 
	public static void ASYNCHcalculateAccountBrandTotals(Set<ID> myIDS)
	{

	}		
	public static void SYNCHcalculateAccountBrandTotals(Set<ID> myIDS)
	{

	}		
}