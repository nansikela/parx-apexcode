public class newsreader {

	public ContentItem__c ci { get; set; }
	private String portal=System_Settings.portal;
	private Boolean isPro=System_Settings.isPro;
	public String newsbackgroundurl { get; private set; }
	public String moreInformationLabel { get; private set; }
	public String homeLabel {get; private set; }
	public String newsid { get; set; }

	public newsreader() {
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
				ci=[SELECT Id, Title__c, Abstract__c, Text__c, ImageURL__c FROM ContentItem__c 
						WHERE isActive__c=true AND Id=:newsid];
			} catch (System.QueryException e) { if (System_Settings.isDebug) throw e; }
			
		} else {
			try {
				ci=[SELECT Id, Title__c, Abstract__c, Text__c, ImageURL__c FROM ContentItem__c 
						WHERE isActive__c=true AND TopNews__c=true 
						//AND isPro__c=:isPro 
						//AND Portal__c=:portal 
						AND (release_date__c<=:System.today() OR release_date__c=null) 
						ORDER BY release_date__c desc limit 1];
				newsid=ci.id;
			} catch (System.QueryException e) { if (System_Settings.isDebug) throw e; }
		}
		if (ci!=null && ci.ImageURL__c!=null) newsbackgroundurl=ci.ImageURL__c;
	}
	
	public pageReference openNews() {
	 	PageReference newsreaderpage = null;
        
        newsreaderpage = new PageReference(Page.page.getUrl() + '?pageid=' + System_Settings.newsreaderpageid + '&newsid=' + newsid);
		
        newsreaderpage.setRedirect(true);
		return newsreaderpage;
	}
	 
	public pageReference goHome() {
		return System_Settings.goHome();
	}
}