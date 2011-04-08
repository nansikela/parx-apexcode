public class CRD_MarketingController extends PageControllerBase {

	// component communication
	public werbemittelController myComponentController { get; set; }
	     
	  public override void setComponentController(ComponentControllerBase compController) {
	    myComponentController = (werbemittelController)compController;
	  }
	     
	  public override ComponentControllerBase getMyComponentController() {
	    return myComponentController;
	  }
	     
	  //public PageReference callComponentControllerMethod() {
	  //  myComponentController.incrementValue();
	  //  return null;
	  //} 

	public String tabLabelSalesActions { get; private set; }
	public String tabLabelSalesSupport { get; private set; }
	public String tabLabelCampaignMaterial { get; private set; }
	public String tabLabelEventCalendar { get; private set; }
	
	public Boolean showTabSalesActions { get; private set; }
	public Boolean showTabSalesSupport { get; private set; }
	public Boolean showTabCampaignMaterial { get; private set; }
	public Boolean showTabEventCalendar { get; private set; }
	public Boolean onOrder { get; set; }

	public CRD_MarketingController() {
		tabLabelSalesActions=System_Settings.getLabel('tabLabelSalesActions');
		tabLabelSalesSupport=System_Settings.getLabel('tabLabelSalesSupport');
		tabLabelCampaignMaterial=System_Settings.getLabel('tabLabelCampaignMaterial');
		tabLabelEventCalendar=System_Settings.getLabel('tabLabelEventCalendar');
		showTabSalesActions=false;
		showTabSalesSupport=hasPageItemFor('salessupport');
		showTabCampaignMaterial=true;
		showTabEventCalendar=hasPageItemFor('eventcalendar');
		onOrder=false;
	}
	
	// helper
	public static Boolean hasPageItemFor(String contentname) {
		Boolean retval=false;
		try {
			if (ApexPages.currentPage().getParameters().containsKey('pageid')) {
				PageToItem__c pi=[SELECT Id FROM PageToItem__c WHERE Page__c=:ApexPages.currentPage().getParameters().get('pageid') AND Display_in_Contentblock__c=:contentname ];
				if (pi!=null) retval=true;
			}
		} catch (System.Queryexception e) {	}
		return retval;
	}
	
	// getter
	public Boolean getOnOrderComp() {
		onOrder=myComponentController.showsecondpage;
		return onOrder;
	}
}