public with sharing class DealItem_Redirect_Controller {
	Group_Promotion_Item__c oi;
	
	public DealItem_Redirect_Controller(ApexPages.StandardController controller) {
		this.oi = (Group_Promotion_Item__c)controller.getRecord();
		this.oi = [SELECT Group_Promotion__c, Group_Promotion__r.Account__c, Group_Promotion__r.RecordTypeId, Group_Promotion__r.Account__r.Market__r.Name FROM Group_Promotion_Item__c WHERE Id =:oi.Id];
	}
	
	public PageReference Redirect() {
		PageReference ref = Page.dealItem;
		ref.getParameters().put('Id', oi.Group_Promotion__c);
		return ref;
	}
}