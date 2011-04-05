public class DEprivacyController {
	public Boolean isAuthenticated { get; set; }
	
	public User u { get; set; }
	
	public String labelPrivacy { get; set; }
	public Integer step { get; set; }
	public String goHomeUrl { get; set; }
	public String privacypageurl { get; set; }
	public String portal {get; set; }
	
	public DEprivacyController() {
		portal=SystemSettings.portal;
		goHomeUrl=SystemSettings.goHome().getUrl();
		isAuthenticated=SystemSettings.isPortalUser();
		step=1;
		Schema.DescribeFieldResult f = Schema.sObjectType.User.fields.Datenschutzerkl_rung_zugestimmt__c;
		labelPrivacy=f.getLabel();
		privacypageurl=Site.getCurrentSiteUrl()+'page' + '?pageid=' + SystemSettings.privacyprotectionid;
		getCurrentUser();
	}
	
	public void getCurrentUser() {
		if (isAuthenticated) {
			//try {
			//	u=[SELECT Id, Datenschutzerkl_rung_zugestimmt__c, Zustimmung_Datenschutzerkl_rung_am__c FROM User WHERE Id=:UserInfo.getUserId()];
			//} catch (System.Queryexception e) {
			//	System.debug('PARX Could not read User Information!');
			//	ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.presetpage_syserror1);
	 		//	ApexPages.addMessage(apm);
			//	if (SystemSettings.isDebug) throw e;
			//}
			u=SystemSettings.getCurrentUpdatedUser();
			if (u!=null) {
				u.Datenschutzerkl_rung_zugestimmt__c=false;
				u.Zustimmung_Datenschutzerkl_rung_am__c=System.today();
			}
		}
	}
	
	private void updateUser() {
		System.debug('PARX Updating User Data!');
		if (u!=null) {
			try {
				update u;
			} catch (System.DmlException e) {
				System.debug('PARX Error updating user data: ' + e.getMessage());
				ApexPages.addMessages(e);
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
	
	public PageReference saveData() {
		Boolean hasErr=false;
		if (step==1) {
	 		if (!u.Datenschutzerkl_rung_zugestimmt__c) {
	 			hasErr=true;
	 			ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelPrivacy + ': ' + System.label.privacy_noaccesswithoutaccept);
		 		ApexPages.addMessage(apm);
	 		}
	 	}
	 	if (!hasErr) {
	 		step++;
	 		u.Zustimmung_Datenschutzerkl_rung_am__c=System.today();
	 		updateUser();
	 		if (!ApexPages.hasMessages()) return SystemSettings.goHome();
	 	} else
	 		step=99;
	 	return null;	 	
	}

	public PageReference previousStep() {
		if (step==99) step=1;
	 	else step=step--;
	 	return null;
	 }
	 
	 public PageReference init() {
	 	return null;
	 }
}