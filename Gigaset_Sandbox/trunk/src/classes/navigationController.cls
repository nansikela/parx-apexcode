public class navigationController {

	pageReference CMSpage = Page.page;
	
	public String kontaktpageid { get; set; }
	public String homepageid { get; set; }
	public String link01pageid { get; set; }
	public String link02pageid { get; set; }
	public String link03pageid { get; set; }
	public String link04pageid { get; set; }
	public String link05pageid { get; set; }
	public String link06pageid { get; set; }  
	public String labellink01 { get; set; }
	public String labellink02 { get; set; }
	public String labellink03 { get; set; }
	public String labellink04 { get; set; }
	public String labellink05 { get; set; }
	public String labellink06 { get; set; }
	public String labelhome { get; set; }
	public String homeurl { get; set; }
	public String linktootherportal { get; set; }
	public Boolean isAuthenticated { get; set; }
	public Boolean isPro { get; set; }
	public String portal { get; set; }
	public List<CustomLabel__c> menuItems {get;set;}
	private List<Pages__c> menuLinks;
	public User u;
	
	public navigationController() {
		isAuthenticated=isPortalUser();
		linktootherportal=getLinkToOtherPortal();
		homeurl=System_Settings.goHome().getUrl();
		isPro=System_Settings.isPro;
		portal=System_Settings.portal;
		kontaktpageid=System_Settings.kontaktpageid;
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

		String searchTag = isPro ? 'ProTopNavi%' : 'ExtranetTopNavi%';
		menuItems = [SELECT Label__c, ExternalUrl__c FROM CustomLabel__c WHERE isPro__c = :isPro AND Portal__c = :portal AND LanguageCode__c = :System_Settings.setLanguage() AND CommonCode__c LIKE :searchTag ORDER BY CommonCode__c];
	}
	
	
	// getter
	public String getBaseTopNaviUrl() {
		if(isPro)
			return System_Settings.baseurl+'pro/'+portal.substring(0,2)+'/'+String.valueOf(System_Settings.setLanguage()).substring(0,2)+'/';
		else
			return System_Settings.baseurl+portal.substring(0,2)+'/'+String.valueOf(System_Settings.setLanguage()).substring(0,2)+'/';
	}
	
	public String getHomeUrl() {
		return homepageid!=null ? CMSpage.getUrl() + '?pageid=' + homepageid : '#';
	}
	
	public String getKontaktformularUrl() {
		return System_Settings.kontaktpageid!=null ? CMSpage.getUrl() + '?pageid=' + System_Settings.kontaktpageid:'';
	}
	
	public String getLink01Url() {
		return System_Settings.link01pageid!=null ? CMSpage.getUrl() + '?pageid=' + System_Settings.link01pageid : System_Settings.getExternalURL('link01');		
	}
	
	public String getLink02Url() {
		return System_Settings.link02pageid!=null ? CMSpage.getUrl() + '?pageid=' + System_Settings.link02pageid : System_Settings.getExternalURL('link02');
	}
	
	public String getLink03Url() {
		return System_Settings.link03pageid!=null ? CMSpage.getUrl() + '?pageid=' + System_Settings.link03pageid : System_Settings.getExternalURL('link03');
	}
	
	public String getLink04Url() {
		return System_Settings.link04pageid!=null ? CMSpage.getUrl() + '?pageid=' + System_Settings.link04pageid : System_Settings.getExternalURL('link04');
	}
	
	public String getLink05Url() {
		return System_Settings.link05pageid!=null ? CMSpage.getUrl() + '?pageid=' + System_Settings.link05pageid : System_Settings.getExternalURL('link05');
	}
	
	public String getLink06Url() {
		return System_Settings.link06pageid!=null ? CMSpage.getUrl() + '?pageid=' + System_Settings.link06pageid : System_Settings.getExternalURL('link06');
	}
	
	private Boolean isPortalUser() {
		if (UserInfo.getUserId()!=null && System_Settings.currentuser==null) u=[SELECT Id, UserType, ContactId, IsPortalEnabled, Handelskanal__c FROM User WHERE Id =:UserInfo.getUserId()];
		else u=System_Settings.currentuser;
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
				System_Settings.logError('PARX No Sites found! ' + e.getMessage(),'DEnavigationController','constructor','','DEBUG');
				if (System_Settings.isdebug) throw e;
			}
		}
		if (link!='') link=link + '/' + System_Settings.portal;
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