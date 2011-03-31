public class topnews {

	private final Integer MAXNEWSNUMBER=3;

	private String portal=System_Settings.portal;
	private Boolean isPro=System_Settings.isPro;
	private list<ContentItem__c> cilist=new list<ContentItem__c>();
	public String lastnewsid { get; private set; }
	public String selectedNewsId { get; set; }

	public topnews() {
		lastnewsid='';
		getTopNews();
		
		if (!cilist.isEmpty()) lastnewsid=cilist.get(cilist.size()-1).id;
		
	}
	
	// getter//setter
	public list<ContentItem__c> getTopNews() {
		if (cilist.isEmpty()) {
			try {
				cilist=[SELECT Id, Title__c, Abstract__c FROM ContentItem__c 
								WHERE isActive__c=true 
								AND TopNews__c=true 
								//AND isPro__c=:isPro 
								//AND Portal__c=:portal 
								//AND (release_date__c<=:System.today() OR release_date__c=null) 
								ORDER BY release_date__c desc 
								limit :MAXNEWSNUMBER];
			} catch (System.QueryException e) {
				System_Settings.logError(UserInfo.getUserId(), portal, e.getMessage());
			}
		}
		return cilist;
	}
	
	
	// actions
	public pageReference selectNews() {
		PageReference newsreaderpage = null;
        
        newsreaderpage = new PageReference(Page.page.getUrl() + '?pageid=' + System_Settings.newsreaderpageid + '&newsid=' + selectedNewsId);
		
        newsreaderpage.setRedirect(true);
		return newsreaderpage;
	}
	
	// test
	static testmethod void topnewstest() {
	 	User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
	 	topnews ctrl = new topnews();
		ctrl.selectNews();
		ctrl.getTopNews();
	 	}
	 }
}