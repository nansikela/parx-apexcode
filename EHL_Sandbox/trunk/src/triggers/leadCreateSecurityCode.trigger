trigger leadCreateSecurityCode on Lead (before update) {
	
	private String securityCode;
	private CreateSecurityCode securityCodeHelper = new CreateSecurityCode();
	
	for(Lead l : Trigger.new) {
		
		securityCode = '';
		securityCode = securityCodeHelper.calculateSecurityCode(String.valueOf(l.id));
		
		l.Preferences_Security_Link__c = securityCode;


	}

}