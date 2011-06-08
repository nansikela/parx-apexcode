public class PRM {
	public String defaultlanguage { get; set; }
	public String PortalURL { get; set; }
	
	public PRM() {
		defaultlanguage= [select LanguageLocaleKey from User where Id =: UserInfo.getUserId()].LanguageLocaleKey ;
        
		for (GlobalSettings__c l:GlobalSettings__c.getAll().values()) {
			if (l.Portal__c==SystemSettings.portal && l.isPro__c == SystemSettings.isPro) {
	
				PortalURL = l.URL_PRM__c;
				break;
			}
		}
	}
	
	@isTest
	public static void Testing() {
		User u=[SELECT Id FROM User WHERE ContactId!='' and isactive=true limit 1];
	   	
    	   	System.runAs(u) {
    	   		PRM p = new PRM();
    	   	}
	}

}