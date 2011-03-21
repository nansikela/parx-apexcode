public class newsreader extends ComponentControllerBase {

	public Id newsid { get; set; }
	public ContentItem__c ci { get; set; }
	private String portal=System_Settings.portal;
	private Boolean isPro=System_Settings.isPro;

	public newsreader() {
		if (newsid!=null && newsid!='') {
			try {
				ci=[SELECT Id, Title__c, Abstract__c, Text__c FROM ContentItem__c WHERE Id=:newsid];
			} catch (System.QueryException e) {}
		} else {
			try {
				ci=[SELECT Id, Title__c, Abstract__c FROM ContentItem__c WHERE isActive__c=true AND TopNews__c=true AND isPro__c=:isPro AND Portal__c=:portal AND (release_date__c<=:System.today() OR release_date__c=null) ORDER BY release_date__c desc limit 1];
			} catch (System.QueryException e) {}
		}
	}
	
	static testmethod void newsreadertest() {
	 	User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
	 	newsreader ctrl = new newsreader();

	 	}
	 }
}