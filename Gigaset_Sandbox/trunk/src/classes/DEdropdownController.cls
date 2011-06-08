public class DEdropdownController {
	public String active { get; set; }
	public String activeShortlabel { get; set; }
	public String activeLabel { get; set; }
	
	public class siteinfo {
		public String shortLabel { get; set; }
		public String label { get; set; }
		public String link { get; set; }
		siteinfo() {
			shortLabel='';
			label='';
			link='';
		}
	}
	
	public DEdropdownController() {
		active='active';
		activeShortlabel='';
		activeLabel='';
		
		if (Site.getCustomWebAddress()!=null) {
			Site activeSite;
			try {
				activeSite=[SELECT Id, MasterLabel, Name FROM Site WHERE TopLevelDomain LIKE :Site.getCustomWebAddress().substring(7,Site.getCustomWebAddress().length()-1)];
			} catch (System.QueryException e) {
				System.debug('PARX No active Site found!');
				SystemSettings.logError('PARX No active Site found! ' + e.getMessage(),'DEdropdownController','constructor','','ERROR');
				//if (SystemSettings.isdebug) throw e;
			} 
			if (activeSite!=null) {
				activeShortlabel=activeSite.Name;
				activeLabel=activeSite.MasterLabel;
			}
		}
		
		/*
		if (Site.getCustomWebAddress()!=null) {
			Sites__c activeSite;
			try {
				for (Sites__c s: [SELECT Label__c, Name, CustomWebAddress__c FROM Sites__c WHERE IsActive__c=true AND CustomWebAddress__c LIKE :Site.getCustomWebAddress().substring(7,Site.getCustomWebAddress().length()-1) limit 1]) {
					activeSite=s;
				}
			} catch (System.QueryException e) {
				System.debug('PARX No active Site found!');
				SystemSettings.logError('PARX No active Site found! ' + e.getMessage(),'DEdropdownController','constructor','','ERROR');
				if (SystemSettings.isdebug) throw e;
			} 
			if (activeSite!=null) {
				activeShortlabel=activeSite.Name;
				activeLabel=activeSite.Label__c;
			}
		}
		*/
	}
	/*
	public list<siteinfo> getSites() {
		list<siteinfo> sites=new list<siteinfo>();
		try {
			for (Sites__c s: [SELECT Label__c, Name, CustomWebAddress__c FROM Sites__c WHERE IsActive__c=true]) {
				siteinfo i=new siteinfo();
				i.label=s.Label__c;
				i.link='http://' + s.CustomWebAddress__c;
				i.shortLabel=s.Name;
				sites.add(i);
			}
		} catch (System.QueryException e) {
			System.debug('PARX No Sites found!');
			SystemSettings.logError('PARX No Sites found! ' + e.getMessage(),'DEdropdownController','constructor','','ERROR');
			if (SystemSettings.isdebug) throw e;
		}
		return sites;
	}
	*/
	
	public list<siteinfo> getSites() {
		list<siteinfo> sites=new list<siteinfo>();
		String tld='%.extranet.%';
		if (SystemSettings.isPro) tld='%.pro.%';
		try {
			for (Site s: [SELECT Id, MasterLabel, Name, TopLevelDomain FROM Site WHERE Status='Active' AND TopLevelDomain LIKE :tld ]) {
				siteinfo i=new siteinfo();
				i.label=s.MasterLabel;
				i.link='http://' + s.TopLevelDomain;
				i.shortLabel=s.Name;
				sites.add(i);
			}
		} catch (System.QueryException e) {
			System.debug('PARX No Sites found!');
			SystemSettings.logError('PARX No Sites found! ' + e.getMessage(),'DEdropdownController','constructor','','ERROR');
			//if (SystemSettings.isdebug) throw e;
		}
		return sites;
	}
	
	
	static testmethod void testDEdropdownController() {
		DEdropdownController ctrl = new DEdropdownController();
		ctrl.getSites();
	}
}