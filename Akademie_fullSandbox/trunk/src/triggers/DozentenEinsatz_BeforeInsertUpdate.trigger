trigger DozentenEinsatz_BeforeInsertUpdate on Dozenteneinsatz_Inhouse__c (after insert, after update) {
	try{
	List<Inhouse_Produkt__c> inhouseProductList = new List<Inhouse_Produkt__c>();
	for(Dozenteneinsatz_Inhouse__c d : trigger.new)
	{
		
		if(d.Inhouse_Produkt__c!= null)
		{
			inhouseProductList.add( new Inhouse_Produkt__c(id = d.Inhouse_Produkt__c));
		}
	}
	if(inhouseProductList.size()>0)
	{
		
		update inhouseProductList;
	}
	}
	catch (Exception e){}
}