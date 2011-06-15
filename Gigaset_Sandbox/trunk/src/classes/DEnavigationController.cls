public class DEnavigationController {

	pageReference CMSpage = Page.page;
	
	public String kontaktpageid { get; set; }
	public String homepageid { get; set; }
	public String link01pageid { get; set; }
	public String link02pageid { get; set; }
	public String link03pageid { get; set; }
	public String link04pageid { get; set; }
	public String link05pageid { get; set; }
	public String werbemittelpageid { get; set; }  
	public String labellink01 { get; set; }
	public String labellink02 { get; set; }
	public String labellink03 { get; set; }
	public String labellink04 { get; set; }
	public String labellink05 { get; set; }
	public String linktootherportal { get; set; }
	public String labelwerbemittel { get; set; }
	public Boolean isAuthenticated { get; set; }
	public Boolean isPro { get; set; }
	public Boolean isProAttribute { get; set; }
	public String portal { get; set; }
	public String portalAttribute { get; set; }
	public Boolean showpmlink { get; set; }
	private List<CustomLabel__c> menuItems = new List<CustomLabel__c>();
	private List<Pages__c> menuLinks;
	public User u;
	
	public boolean ProAuthorizationSwitch {get;set;}
	public boolean ProAuthorisiert {get;set;}
	public Integer LinkHomeNumber {get;set;}
	
	public DEnavigationController() {
		isAuthenticated=isPortalUser();
		linktootherportal=getLinkToOtherPortal();
		if (isProAttribute!=null)
			isPro=isProAttribute;
		else 
			isPro=SystemSettings.isPro;
		if (portalAttribute!=null)
			portal=portalAttribute;
		else 
			portal=SystemSettings.portal;
		kontaktpageid=SystemSettings.kontaktpageid;
		homepageid=SystemSettings.homepageid;
		showpmlink=SystemSettings.showpmlink();
		link01pageid=SystemSettings.link01pageid;
		link02pageid=SystemSettings.link02pageid;
		link03pageid=SystemSettings.link03pageid;
		link04pageid=SystemSettings.link04pageid;
		link05pageid=SystemSettings.link05pageid;
		werbemittelpageid=SystemSettings.werbemittelpageid;	
		
		labellink01=SystemSettings.getCurrentNavigationPointLabel(link01pageid) != '' ? SystemSettings.getCurrentNavigationPointLabel(link01pageid) : (SystemSettings.getExternalURL('link01') != '' ? SystemSettings.getLabel('link01') : '' );
		labellink02=SystemSettings.getCurrentNavigationPointLabel(link02pageid) != '' ? SystemSettings.getCurrentNavigationPointLabel(link02pageid) : (SystemSettings.getExternalURL('link02') != '' ? SystemSettings.getLabel('link02') : '' );
		labellink03=SystemSettings.getCurrentNavigationPointLabel(link03pageid) != '' ? SystemSettings.getCurrentNavigationPointLabel(link03pageid) : (SystemSettings.getExternalURL('link03') != '' ? SystemSettings.getLabel('link03') : '' );
		labellink04=SystemSettings.getCurrentNavigationPointLabel(link04pageid) != '' ? SystemSettings.getCurrentNavigationPointLabel(link04pageid) : (SystemSettings.getExternalURL('link04') != '' ? SystemSettings.getLabel('link04') : '' );
		labellink05=SystemSettings.getCurrentNavigationPointLabel(link05pageid) != '' ? SystemSettings.getCurrentNavigationPointLabel(link05pageid) : (SystemSettings.getExternalURL('link05') != '' ? SystemSettings.getLabel('link05') : '' );
			
		labelwerbemittel=SystemSettings.getCurrentNavigationPointLabel(werbemittelpageid);
		
		//String searchTag = isPro ? 'ProTopNavi%' : 'ExtranetTopNavi%';
		//System.debug('MenuItem Selektion, isPro: ' + isPro + ' / Portal: ' + SystemSettings.portal+ ' / LanguageCode: '+ SystemSettings.setLanguage());
		//menuItems = [SELECT Label__c, ExternalUrl__c FROM CustomLabel__c WHERE isPro__c = :isPro AND Portal__c = :SystemSettings.portal AND LanguageCode__c = :SystemSettings.setLanguage() AND CommonCode__c LIKE :searchTag ORDER BY CommonCode__c];
		User u0 = [select Contact.Account.Pro_Authorisiert__c from User where Id=:UserInfo.getUserId()];

		ProAuthorisiert = false;
	      ProAuthorizationSwitch = false;
	      for (GlobalSettings__c l:GlobalSettings__c.getAll().values()) {
			if (l.Portal__c==portal 
				&& l.isPro__c == isPro 
				&& isPro 
				&& l.Pro_Authorization_Switch__c) {
				ProAuthorizationSwitch = true;	
				if( u0.Contact.Account.Pro_Authorisiert__c == true) {
					ProAuthorisiert = true;
				}	
				else
					ProAuthorisiert = false;
				break;
			}
		}

		if(homepageid == link01pageid)
			LinkHomeNumber = 1;
		else if(homepageid == link02pageid)
			LinkHomeNumber = 2;
		else if(homepageid == link03pageid)
			LinkHomeNumber = 3;
		else if(homepageid == link04pageid)
			LinkHomeNumber = 4;
		else if(homepageid == link05pageid)
			LinkHomeNumber = 5;

	}
	
	
	// getter
	public String getBaseTopNaviUrl() {
		if (isProAttribute!=null)
			isPro=isProAttribute;
		else 
			isPro=SystemSettings.isPro;
		if (portalAttribute!=null)
			portal=portalAttribute;
		else 
			portal=SystemSettings.portal;
		if(isPro)
			return SystemSettings.baseurl+'pro/'+portal.substring(0,2)+'/'+SystemSettings.setLanguage()+'/';
		else
			return SystemSettings.baseurl+portal.substring(0,2)+'/'+SystemSettings.setLanguage()+'/';
	}
	
	public list<CustomLabel__c> getMenuItems() {
		if (isProAttribute!=null)
			isPro=isProAttribute;
		else 
			isPro=SystemSettings.isPro;
		if (portalAttribute!=null)
			portal=portalAttribute;
		else 
			portal=SystemSettings.portal;
		String searchTag = isPro ? 'ProTopNavi%' : 'ExtranetTopNavi%';
		menuitems=[SELECT Label__c, ExternalUrl__c FROM CustomLabel__c WHERE isPro__c = :isPro AND Portal__c = :portal AND LanguageCode__c = :SystemSettings.setLanguage() AND CommonCode__c LIKE :searchTag ORDER BY CommonCode__c];
		return menuItems;
	}
	
	public String getPicturemanagemantUrl() {
		return DEInterfaceLinks.generatePictureURL();
	}
	
	public String getWerbemittelUrl() {
		return SystemSettings.werbemittelpageid!=null ? CMSpage.getUrl() + '?pageid=' + SystemSettings.werbemittelpageid:'';
	}
	
	public String getKontaktformularUrl() {
		return SystemSettings.kontaktpageid!=null ? CMSpage.getUrl() + '?pageid=' + SystemSettings.kontaktpageid:'';
	}
	
	public String getLink01Url() {
		return SystemSettings.link01pageid!=null ? CMSpage.getUrl() + '?pageid=' + SystemSettings.link01pageid : SystemSettings.getExternalURL('link01');		
	}
	
	public String getLink02Url() {
		return SystemSettings.link02pageid!=null ? CMSpage.getUrl() + '?pageid=' + SystemSettings.link02pageid : SystemSettings.getExternalURL('link02');
	}
	
	public String getLink03Url() {
		return SystemSettings.link03pageid!=null ? CMSpage.getUrl() + '?pageid=' + SystemSettings.link03pageid : SystemSettings.getExternalURL('link03');
	}
	
	public String getLink04Url() {
		return SystemSettings.link04pageid!=null ? CMSpage.getUrl() + '?pageid=' + SystemSettings.link04pageid : SystemSettings.getExternalURL('link04');
	}
	
	public String getLink05Url() {
		return SystemSettings.link05pageid!=null ? CMSpage.getUrl() + '?pageid=' + SystemSettings.link05pageid : SystemSettings.getExternalURL('link05');
	}
	
	private Boolean isPortalUser() {
		if (UserInfo.getUserId()!=null) u=[SELECT Id, UserType, ContactId, IsPortalEnabled, Handelskanal__c FROM User WHERE Id =:UserInfo.getUserId()];
		
		if (u!=null) {
			return u.IsPortalEnabled;
		}
		else return false;
	}
	
	private String getLinkToOtherPortal() {
		String tld=SystemSettings.portal + '.%';
		String link='';
		Contact c;
		if (isAuthenticated && u!=null && u.ContactId!=null) {
			try {
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
				SystemSettings.logError('PARX No Sites found! ' + e.getMessage(),'DEnavigationController','constructor','','DEBUG');
				if (SystemSettings.isdebug) throw e;
			}
		}
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