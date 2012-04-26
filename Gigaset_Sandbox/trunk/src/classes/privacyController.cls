public class privacyController {
	public Boolean isAuthenticated { get; set; }
	
	public User u { get; set; }
	
	public Transient String labelPrivacy { get; set; }
	public Integer step { get; set; }
	public Transient String goHomeUrl { get; set; }
	public PageReference goHome=System_Settings.goHome();
	public Transient String privacypageurl { get; set; }
	public Transient String portal { get; set; }
	
	public privacyController() {
		if (System_Settings.showPrivacy() || System_Settings.isTest) {
			portal=System_Settings.portal;
			goHomeUrl=goHome.getUrl();
			isAuthenticated=System_Settings.isPortalUser();
			step=1;
			Schema.DescribeFieldResult f = Schema.sObjectType.User.fields.Datenschutzerkl_rung_zugestimmt__c;
			labelPrivacy=f.getLabel();
			privacypageurl=Site.getCurrentSiteUrl()+'page' + '?pageid=' + System_Settings.privacyprotectionid;
			getCurrentUser();
			
		}
	}
	
	public void getCurrentUser() {
		if (isAuthenticated) {
			u=System_Settings.getCurrentUpdatedUser();
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
	 		if (!ApexPages.hasMessages()) return goHome;
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