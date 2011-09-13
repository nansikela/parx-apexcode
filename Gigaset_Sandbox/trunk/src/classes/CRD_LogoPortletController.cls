public with sharing class CRD_LogoPortletController {

	public Transient Boolean showLogo {get; private set;}
	public Transient String alternateAbsolutlyGigasetLogoText { get; private set; }
	public Transient String alternateAbsolutlyGigasetLogoUrl { get; private set; }
	private Transient String portal = System_Settings.portal;
	private Transient Boolean isPro = System_Settings.isPro;
	
	public CRD_LogoPortletController() {
		showLogo=getLogoFlag();
		setImageProperties();
	}
	
	private Boolean getLogoFlag() {
		Boolean retval=false;
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