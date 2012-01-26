trigger ContactCreateSecurityCode on Contact (before update) {
	
	private String securityCode;
	private CreateSecurityCode securityCodeHelper = new CreateSecurityCode();

	for(Contact c : Trigger.new) {
		
		securityCode = '';
		securityCode = securityCodeHelper.calculateSecurityCode(String.valueOf(c.id));
		
		c.Preferences_Security_Link__c = securityCode;

	}
		
}