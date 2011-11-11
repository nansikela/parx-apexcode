public with sharing class mobileOutletVisit_Controller {
    
    public mobileOutletVisit_Controller()
    {

    } 

    public List<Outlet_Visit__c> getRecentOVs() 
    {
        List<Outlet_Visit__c> optionList = new List<Outlet_Visit__c>();
        // Add a null option to force the user to make a selection. //
        //optionList.add(new SelectOption('None','--Please Choose--'));
        return [Select o.Visit_Date__c, o.Visit_Comments__c, o.SystemModstamp, o.OwnerId, o.Name, o.Met_With__c, o.LastModifiedDate, o.LastModifiedById, o.IsDeleted, o.Id, o.CurrencyIsoCode, o.CreatedDate, o.CreatedById, o.Competitor_Activity__c, o.Account__c, o.Account__r.Name From Outlet_Visit__c o where o.CreatedById =: userinfo.getUserId() and 
        (
        	(o.CreatedDate >=: date.today().adddays(-1) and o.CreatedDate <=: date.today().adddays(1)) 
        	or 
        	(
        		o.LastModifiedById  =: userinfo.getUserId() and 
        		(o.LastModifiedDate >=: date.today().adddays(-1) and o.LastModifiedDate <=: date.today().adddays(2))
        	)
        )];
    }   
    

}