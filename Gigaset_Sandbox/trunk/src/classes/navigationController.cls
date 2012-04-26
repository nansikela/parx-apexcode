public class navigationController {

	//pageReference CMSpage = Page.page;
	
	public Id kontaktpageid { get; set; }
	public Id homepageid { get; set; }
	public Id link01pageid { get; set; }
	public Id link02pageid { get; set; }
	public Id link03pageid { get; set; }
	public Id link04pageid { get; set; }
	public Id link05pageid { get; set; }
	public Id link06pageid { get; set; }  
	public String labellink01 { get; set; }
	public String labellink02 { get; set; }
	public String labellink03 { get; set; }
	public String labellink04 { get; set; }
	public String labellink05 { get; set; }
	public String labellink06 { get; set; }
	public String labelhome { get; set; }
	//public String homeurl { get; set; }
	public String linktootherportal { get; set; }
	public Boolean isAuthenticated { get; set; }
	public Boolean isPro { get; private set; }
	public String portal { get; private set; }
	public List<CustomLabel__c> menuItems {get;set;}
	private List<Pages__c> menuLinks;
	public User u;
	
	public navigationController() {
		isAuthenticated=isPortalUser();
		//homeurl=System_Settings.goHome().getUrl();
		isPro=System_Settings.isPro;
		portal=System_Settings.portal;
		
		String searchTag = isPro ? 'ProTopNavi%' : 'ExtranetTopNavi%';
		menuItems = [SELECT Label__c, ExternalUrl__c FROM CustomLabel__c WHERE isPro__c = :isPro AND Portal__c = :portal AND LanguageCode__c = :System_Settings.setLanguage() AND CommonCode__c LIKE :searchTag ORDER BY CommonCode__c];
		if (isAuthenticated || System_Settings.isTest) {
			linktootherportal=getLinkToOtherPortal();
			
			//kontaktpageid=System_Settings.kontaktpageid;
			homepageid=System_Settings.homepageid;
			link01pageid=System_Settings.link01pageid;
			link02pageid=System_Settings.link02pageid;
			link03pageid=System_Settings.link03pageid;
			link04pageid=System_Settings.link04pageid;
			link05pageid=System_Settings.link05pageid;
			link06pageid=System_Settings.link06pageid;
			
			labellink01=System_Settings.getCurrentNavigationPointLabel(link01pageid) != '' ? System_Settings.getCurrentNavigationPointLabel(link01pageid) : (System_Settings.getExternalURL('link01') != '' ? System_Settings.getLabel('link01') : '' );
			labellink02=System_Settings.getCurrentNavigationPointLabel(link02pageid) != '' ? System_Settings.getCurrentNavigationPointLabel(link02pageid) : (System_Settings.getExternalURL('link02') != '' ? System_Settings.getLabel('link02') : '' );
			labellink03=System_Settings.getCurrentNavigationPointLabel(link03pageid) != '' ? System_Settings.getCurrentNavigationPointLabel(link03pageid) : (System_Settings.getExternalURL('link03') != '' ? System_Settings.getLabel('link03') : '' );
			labellink04=System_Settings.getCurrentNavigationPointLabel(link04pageid) != '' ? System_Settings.getCurrentNavigationPointLabel(link04pageid) : (System_Settings.getExternalURL('link04') != '' ? System_Settings.getLabel('link04') : '' );
			labellink05=System_Settings.getCurrentNavigationPointLabel(link05pageid) != '' ? System_Settings.getCurrentNavigationPointLabel(link05pageid) : (System_Settings.getExternalURL('link05') != '' ? System_Settings.getLabel('link05') : '' );
			labellink06=System_Settings.getCurrentNavigationPointLabel(link06pageid) != '' ? System_Settings.getCurrentNavigationPointLabel(link06pageid) : (System_Settings.getExternalURL('link06') != '' ? System_Settings.getLabel('link06') : '' );
			labelhome=System_Settings.getCurrentNavigationPointLabel(homepageid);
		}
		
	}
	
	
	// getter
	public String getBaseTopNaviUrl() {
		if(isPro)
			return System_Settings.baseurl+'pro/'+portal.substring(0,2)+'/'+String.valueOf(System_Settings.setLanguage()).substring(0,2)+'/';
		else
			return System_Settings.baseurl+portal.substring(0,2)+'/'+String.valueOf(System_Settings.setLanguage()).substring(0,2)+'/';
	}
	
	public String getHomeUrl() {
		//return System_Settings.goHome().getUrl();
		return homepageid!=null ? Page.page.getUrl() + '?pageid=' + homepageid : '#';
	}
	
	//public String getKontaktformularUrl() {
	//	return kontaktpageid!=null ? CMSpage.getUrl() + '?pageid=' + kontaktpageid:'';
	//}
	
	public String getLink01Url() {
		return link01pageid!=null ? '?pageid=' + link01pageid : System_Settings.getExternalURL('link01');		
	}
	
	public String getLink02Url() {
		return link02pageid!=null ? '?pageid=' + link02pageid : System_Settings.getExternalURL('link02');
	}
	
	public String getLink03Url() {
		return link03pageid!=null ? '?pageid=' + link03pageid : System_Settings.getExternalURL('link03');
	}
	
	public String getLink04Url() {
		return link04pageid!=null ? '?pageid=' + link04pageid : System_Settings.getExternalURL('link04');
	}
	
	public String getLink05Url() {
		return link05pageid!=null ? '?pageid=' + link05pageid : System_Settings.getExternalURL('link05');
	}
	
	public String getLink06Url() {
		return link06pageid!=null ? '?pageid=' + link06pageid : System_Settings.getExternalURL('link06');
	}
	
	private Boolean isPortalUser() {
		u=System_Settings.currentuser;
		if (UserInfo.getUserId()!=null && u==null) u=[SELECT Id, UserType, ContactId, IsPortalEnabled, Handelskanal__c FROM User WHERE Id =:UserInfo.getUserId()];
		if (u!=null) {
			return u.IsPortalEnabled;
		}
		else return false;
	}
	
	private String getLinkToOtherPortal() {
		String tld=portal + '.%';
		String link='';
		Contact c;
		if (isAuthenticated && u!=null && u.ContactId!=null) {
			try {
				c=System_Settings.currentusercontact;
				c=[SELECT Id, Gigaset_Extranet__c, Gigaset_Pro__c FROM Contact WHERE Id=:u.ContactId];
			} catch (System.QueryException e) {
				// nothing to do here
			}
		}
		/*
		if (c!=null) {
			try {
				for (Site s: [SELECT Id, MasterLabel, Name, TopLevelDomain FROM Site WHERE Status='Active' AND TopLevelDomain LIKE :tld ]) {
					if (!Site.getCustomWebAddress().contains(s.TopLevelDomain)) link='http://' + s.TopLevelDomain;
					if (link.contains('pro') && !c.Gigaset_Pro__c) link='';
					else if (!link.contains('pro') && !c.Gigaset_Extranet__c) link='';
					else link=''; 
				}
			} catch (System.QueryException e) {
				System.debug('PARX No Sites found!');
				System_Settings.logError('PARX No Sites found! ' + e.getMessage(),'navigationController','constructor','','DEBUG');
				if (System_Settings.isdebug) throw e;
			}
		}
		*/
		if (link!='') link=link + '/' + portal;
		// for the moment ...
		link='';
		return link;
	}
	
	private static testMethod void testDEnavigationController() {
		DEnavigationController ctrl = new DEnavigationController();
		ctrl.getKontaktformularUrl();
		ctrl.getPicturemanagemantUrl();
		ctrl.getLink01Url();
		ctrl.getLink02Url();
		ctrl.getLink03Url();
		ctrl.getLink04Url();
		ctrl.getLink05Url();
		ctrl.getWerbemittelUrl();
	}
}