@isTest
private class CampaignStatusEditTest {

    static testMethod void CampaignStatusEdit() {
    	Campaign thecampaign = new Campaign();
    	thecampaign.name = 'Test42';
    	insert thecampaign;
    	
        CampaignStatusEdit controller = new CampaignStatusEdit();
        controller.searchObject.status = 'plan';
        controller.searchObject.StartDate = Date.today();
        controller.searchObject.EndDate = Date.today();
        controller.doSOQL();
        controller.newStatus.Status = '4711';
        controller.saveNewStatus();
        controller.getIsResult();
    }
    
   
}