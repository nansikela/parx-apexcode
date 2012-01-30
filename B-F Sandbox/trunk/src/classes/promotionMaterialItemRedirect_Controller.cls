public with sharing class promotionMaterialItemRedirect_Controller {
	Promotion_Material_Item__c pm;
  
	public promotionMaterialItemRedirect_Controller (ApexPages.StandardController controller)
	{
		this.pm = (Promotion_Material_Item__c)controller.getRecord();
		pm = [Select Promotion__r.RecordTypeId, Promotion__c From Promotion_Material_Item__c p where Id=:pm.Id];
	}
    
	public PageReference Redirect()
	{
		String recordtypname = '';
		recordtypname = [select Id from RecordType where Name = 'National Promotion - US'][0].Id;
		if(recordtypname.equalsIgnoreCase(pm.Promotion__r.RecordTypeId)){
			PageReference p = Page.NPA_promotionMaterialCustomEdit;
			p.getParameters().put('id',pm.Id);
			p.getParameters().put('promotion','/'+pm.Promotion__c);
			p.setRedirect(true);
			return p;
		}
		else {
			Profile p = [Select Name From Profile Where ID = :UserInfo.getProfileId() limit 1];
			PageReference ref = Page.promotionMaterialItem;
			
			ref.getParameters().put('id',pm.Promotion__c);
			return ref;
		}
	}
}