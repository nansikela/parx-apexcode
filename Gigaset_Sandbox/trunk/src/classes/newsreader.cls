public class newsreader {

	public ContentItem__c ci { get; set; }
	private Transient String portal=System_Settings.portal;
	private Transient Boolean isPro=System_Settings.isPro;
	public String newsbackgroundurl { get; private set; }
	public Transient String moreInformationLabel { get; private set; }
	public Transient String homeLabel {get; private set; }
	public String newsid { get; set; }
	public transient String homeurl { get; private set; }

	public newsreader() {
		homeurl=System_Settings.goHome().getUrl();
		newsid='';
		if (ApexPages.currentPage().getParameters().containsKey('newsid')) {
			newsid=ApexPages.currentPage().getParameters().get('newsid');
		}
		newsbackgroundurl='';
		//moreInformationLabel='';
		moreInformationLabel=System_Settings.getLabel('newsMoreInformation');
		homeLabel=System_Settings.getLabel('home');
		if (newsid!='' && (newsid.length()==15 || newsid.length()==18)) {
			try {
				ci=[SELECT Id, Title__c, Abstract__c, Text__c, ImageURL__c, NewsURL__c FROM ContentItem__c 
						WHERE isActive__c=true AND Portal__c = :portal AND Id=:newsid];
			} catch (System.QueryException e) { if (System_Settings.isDebug) throw e; }
			
		} else {
			try {
				ci=[SELECT Id, Title__c, Abstract__c, Text__c, ImageURL__c, NewsUrl__c FROM ContentItem__c 
						WHERE isActive__c=true AND TopNews__c=true 
						AND isPro__c=:isPro 
						AND Portal__c=:portal 
						AND (release_date__c<=:System.today() OR release_date__c=null) 
						ORDER BY release_date__c desc limit 1];
				newsid=ci.id;
			} catch (System.QueryException e) { if (System_Settings.isDebug) throw e; }
		}
		if (ci!=null && ci.ImageURL__c!=null) newsbackgroundurl=ci.ImageURL__c;
	}
	
	public pageReference openNews() {
	// 	PageReference newsreaderpage = null;
    //	if (ci!=null && ci.NewsURL__c!=null && ci.NewsURL__c!='') {
    //		newsreaderpage = new PageReference(ci.NewsURL__c);
    //	}
    //   else
    //    	newsreaderpage = new PageReference(Page.page.getUrl() + '?pageid=' + System_Settings.newsreaderpageid + '&newsid=' + newsid);
	//	
    //    newsreaderpage.setRedirect(true);
	//	return newsreaderpage;
		return null;
	}
	
	public String getNewsreaderUrl() {
		if (ci!=null && ci.NewsURL__c!=null && ci.NewsURL__c!='') {
			return ci.NewsUrl__c;
		}
		return Page.page.getUrl() + '?pageid=' + System_Settings.newsreaderpageid + '&newsid=' + newsid;
	}
	 
	public pageReference goHome() {
		return System_Settings.goHome();
	}
}