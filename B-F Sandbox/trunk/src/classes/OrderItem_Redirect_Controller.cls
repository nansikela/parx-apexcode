public with sharing class OrderItem_Redirect_Controller {
	Order_Item__c oi;
	
	public OrderItem_Redirect_Controller(ApexPages.StandardController controller) {
		this.oi = (Order_Item__c)controller.getRecord();
		this.oi = [SELECT Order__c, Order__r.Account__c, Order__r.RecordTypeId, Order__r.Account__r.Market__r.Name FROM Order_Item__c WHERE Id =:oi.Id];
	}
	
	public PageReference Redirect() {
		PageReference ref = Page.orderItem;
		ref.getParameters().put('Id', oi.Order__c);
		return ref;
	}
}