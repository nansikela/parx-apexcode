public class NewProductButtonController {
	
	private Product2 Prod;

	public NewProductButtonController(ApexPages.StandardController stdController) {
		this.Prod = (Product2)stdController.getRecord();
		
	}
	
	public pageReference init() {
		
		pageReference page=new pageReference('/01t/e?retUrl=%2F01t%2Fo&Name=%3Cwird berechnet%3E&nooverride=1&RecordType='+ Prod.RecordTypeId);
		page.setRedirect(true);
		return page;
		//return null;
	}
	
	static testmethod void  NewProductButtonControllerTest() {
		Product2 Prod = new Product2();
		ApexPages.Standardcontroller stdcontroller = new ApexPages.Standardcontroller(Prod);
		NewProductButtonController ctrl =  new NewProductButtonController(stdcontroller);
		ctrl.init();
	}
}