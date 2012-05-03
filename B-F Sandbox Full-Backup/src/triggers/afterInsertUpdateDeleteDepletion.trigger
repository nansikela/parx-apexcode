trigger afterInsertUpdateDeleteDepletion on Depletion__c (after delete, after insert, after update) {

	Set<ID> myIDS = new Set<ID>();
	if(Trigger.isDelete)
	{
	    for(Integer x = 0; x<Trigger.old.size(); x++)
	    {
			myIDS.add(Trigger.old[x].Account__c);
	    }
        try{ 
            updateAccountBrandAsynch.updateAccountBrandAsynch(myIDS);
        }catch(AsyncException e)    
        {
            updateAccountBrandAsynch.updateAccountBrandSynch(myIDS);
        } 	    
    }else{
	    for(Integer x = 0; x<Trigger.new.size(); x++)
	    {
	    	myIDS.add(Trigger.new[x].Account__c);
	    }    	
        try{ 
            updateAccountBrandAsynch.updateAccountBrandAsynch(myIDS);
        }catch(AsyncException e)    
        {
            updateAccountBrandAsynch.updateAccountBrandSynch(myIDS);
        } 	    
    }
}