public with sharing class artPDF_controller {

	public ID imageURL{ get;set; } 
	public Art_Asset__c art;
	
    public artPDF_controller(ApexPages.StandardController controller) {
    	art = (Art_Asset__c)controller.getRecord();
    	for(Attachment a: [Select a.Id From Attachment a where a.ParentId =: art.Id]){
    		imageURL = a.Id;
    		break;
    	}
    }
}