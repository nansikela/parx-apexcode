public with sharing class CRD_LogoPortletController {

	public Boolean showLogo {get; private set;}
	public String alternateAbsolutlyGigasetLogoText { get; private set; }
	public String alternateAbsolutlyGigasetLogoUrl { get; private set; }
	
	public CRD_LogoPortletController() {
		showLogo=getLogoFlag();
		setImageProperties();
	}
	
	private Boolean getLogoFlag() {
		Boolean retval=false;
		String portal = System_Settings.portal;
		Boolean isPro=System_Settings.isPro;
		if (portal!='') {
			for (GlobalSettings__c gs: GlobalSettings__c.getAll().values()) {
				if (gs.isPro__c==isPro && gs.Portal__c==portal)
					retval=gs.showAbsolutlyGigasetLogo__c;
			}
		}
		return retval;
	}

	private void setImageProperties() {
		alternateAbsolutlyGigasetLogoText=System_Settings.getLabel('alternateAbsolutlyGigasetLogoText');
		alternateAbsolutlyGigasetLogoUrl='/servlet/servlet.ImageServer?id=' + System_Settings.getLabel('alternateAbsolutlyGigasetLogoId') + '&oid=' + UserInfo.getOrganizationId();
	}
}