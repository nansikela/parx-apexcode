global class InhouseProductUpdateBatch implements Database.Batchable<sObject>  {
	
	private static String query =  'SELECT ID FROM Inhouse_Produkt__c';
	public InhouseProductUpdateBatch(Date start, Date ende)
	{
		query+='WHERE Beginndatum__c >='+start + 'AND Beginndatum__c<='+ende;
	}
	

	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Inhouse_Produkt__c> productList){
     	update productList;
    }
     global void finish(Database.BatchableContext BC){
   }
}