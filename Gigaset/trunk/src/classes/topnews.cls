public class topnews extends ComponentControllerBase {

	private final Integer MAXNEWSNUMBER=3;

	private String portal=System_Settings.portal;
	private Boolean isPro=System_Settings.isPro;
	private list<ContentItem__c> cilist=new list<ContentItem__c>();
	public String newsid='';
	public String nid { get; set;}

	public topnews() {
		getTopNews();
		if (!cilist.isEmpty()) newsid=cilist.get(0).id;
		nid='';
	}
	
	// getter//setter
	public list<ContentItem__c> getTopNews() {
		if (cilist.isEmpty()) {
			try {
				cilist=[SELECT Id, Title__c, Abstract__c FROM ContentItem__c WHERE isActive__c=true AND TopNews__c=true AND isPro__c=:isPro AND Portal__c=:portal AND (release_date__c<=:System.today() OR release_date__c=null) ORDER BY release_date__c desc limit :MAXNEWSNUMBER];
			} catch (System.QueryException e) {
				System_Settings.logError(UserInfo.getUserId(), portal, e.getMessage());
			}
		}
		return cilist;
	}
	
	public String getNewsid() {
		return newsid;
	}
	
	public void setNewsid(String n) {
		newsid=n;
	}
	
	// actions
	public pageReference selectNews() {
		//newsid=ApexPages.currentPage().getParameters().get('newsid');
		return null;
	}
	
	// test
	static testmethod void topnewstest() {
	 	User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
	 	topnews ctrl = new topnews();
		ctrl.getNewsId();
		ctrl.setNewsId('id');
		ctrl.selectNews();
		ctrl.getTopNews();
	 	}
	 }
}