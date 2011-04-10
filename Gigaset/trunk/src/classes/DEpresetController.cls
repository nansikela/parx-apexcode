public class DEpresetController {
	
	public Boolean isAuthenticated { get; set; }
	
	public User u { get; set; }
	
	public Integer step { get; set; }
	
	public Set<String> gfks = new Set<String>();
	public String portal {get; set; }
	public Boolean showDistribution { get; set; }
	public Boolean showDistributionErr { get; set; }
	public String errorText { get; set; }
	public String errorBase='<strong>' + System.Label.site.Error2 + ':</strong> ';
	public String stdErrorText='';
	public String selectedGfk { get; set; }
	public String[] selectedDistribution { get; set; }
	public Set<String> distributionValues { get; set; }
	public Set<String> distributionLabels { get; set; }
	public Map<String, String> distributionMap = new Map<String, String>();
	public String goHomeUrl { get; set; }
	public Boolean isPro { get; private set; }
	
	public DEpresetController() {
		goHomeUrl=SystemSettings.goHome().getUrl();
		isAuthenticated=SystemSettings.isPortalUser();
		portal=SystemSettings.portal;
		isPro=SystemSettings.isPro;
		step=1;
		errorText=errorBase + System.label.registration_errormsg;
		stdErrorText=errorText;
		showDistributionErr=false;
		showDistribution=false;
		selectedGfk='';
		selectedDistribution=new String[]{};
		fillGfks();
		fillDistributions();
		getCurrentUser();
	}
	
	private void fillGfks() {
		gfks = new Set<String>();
		gfks.add('Warenhaus');
		gfks.add('Versandhandel (Katalog + Online)');
		gfks.add('Elektrofachmarkt (Filiale)');
		gfks.add('Elektrofachhändler (Kooperations- oder Verbandsgebunden)');
		gfks.add('TK oder IT-Distribution');
		gfks.add('Elektrogroßhandel');
		gfks.add('Prämienversender');
		gfks.add('OEM-Partner');
		gfks.add('Andere: Agenturen, Dienstleistungsunternehmen');
	}
	
	private void fillDistributions() {
		distributionValues=new Set<String>();
		distributionLabels=new Set<String>();
		Schema.DescribeFieldResult F = Lead.Distribution__c.getDescribe();
		for (Schema.Picklistentry pe: F.getPicklistValues()) {
			if (pe.isActive()) {
				distributionValues.add(pe.getValue());
				distributionLabels.add(pe.getLabel());
				distributionMap.put(pe.getLabel(),pe.getValue());
			}
		}
	}
	
	private String putDistributions() {
		String multi='';
		if (!selectedDistribution.isEmpty()) {
			for (String s: selectedDistribution) {
				multi=multi + ';' + distributionMap.get(s);
			}
		}
		return multi;
	}
	
	public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		for (String label: distributionMap.keySet()) {
			options.add(new SelectOption(distributionMap.get(label),label));
		}
		return options;
	}
	
	// get updated user
	public void getCurrentUser() {
		if (isAuthenticated) {
			//try {
			//	u=[SELECT Id, Handelskanal__c, Distribution__c FROM User WHERE Id=:UserInfo.getUserId()];
			//} catch (System.Queryexception e) {
			//	System.debug('PARX Could not read User Information!');
			//	ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.presetpage_syserror1);
	 		//	ApexPages.addMessage(apm);
			//	if (SystemSettings.isDebug) throw e;
			//}
			u=SystemSettings.getCurrentUpdatedUser();
			if (u!=null) {
				//u.Handelskanal__c=null;
				//u.Distribution__c=null;
				//u.Pro_Distribution__c=null;
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
		showDistributionErr=false;
		if (step==1) {
	 		if (!selectedDistribution.isEmpty() && selectedDistribution!=null) u.Distribution__c=putDistributions();
	 		else if (showDistribution) {
	 			showDistributionErr=true;
	 			hasErr=true;
	 		} else {
	 			showDistributionErr=false;
	 			hasErr=false;
	 		}
	 	}
	 	if (!hasErr) {
	 		step++;
	 		updateUser();
	 	} else 
	 		step=99;
	 	return null;
	}

	public PageReference previousStep() {
	 	step=step-1;
	 	return null;
	 }
	 
	 public PageReference goToStep() {
	 	return null;
	 }
	 
	 public PageReference relationshipSelectionAction() {
	 	showDistribution=false;
	 	if (u!=null) {
		 	u.Handelskanal__c=selectedGfk;
		 	if (!gfks.contains(selectedGfk) && SystemSettings.portal=='de') {
		 		showDistribution=true;
		 	}
	 	}
	 	return null;
	 }
	 
	 public PageReference init() {
	 	return null;
	 }
	 
}