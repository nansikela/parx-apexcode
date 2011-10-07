global class ProductUpdateBatch implements Database.Batchable<sObject>  {
	
	private static String query =  'SELECT ID FROM Product2';
	public ProductUpdateBatch(Date start, Date ende)
	{
		query+='WHERE Beginn__c >='+start + 'AND Beginn__c<='+ende;
	}
	

	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Product2> productList){
     	update productList;
    }
     global void finish(Database.BatchableContext BC){
   }
}