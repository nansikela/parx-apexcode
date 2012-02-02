public with sharing class NewOpportunityButtonController {

	private Opportunity opp;

	public NewOpportunityButtonController(ApexPages.StandardController stdController) {
		this.opp = (Opportunity)stdController.getRecord();
		
	}

	public pageReference init() {

		pageReference page=new pageReference('/006/e?retUrl=%2F006%2Fo&opp3=%3Cwird berechnet%3E&opp11=in%20Erstellung&opp9=' + System.today().addMonths(1).format() +  '&opp12=0&nooverride=1');
		page.setRedirect(true);
		return page;
		//return null;
	}
	
	static testmethod void  NewOpportunityButtonControllerTest() {
		Opportunity opp = new Opportunity();
		ApexPages.Standardcontroller stdcontroller = new ApexPages.Standardcontroller(opp);
		NewOpportunityButtonController ctrl =  new NewOpportunityButtonController(stdcontroller);
		ctrl.init();
	}
	

}