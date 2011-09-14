public class ClearingController {
	
	public Boolean isAuthenticated { get; set; }
	public transient Boolean isPro { get; set; }
	public String portal {get; set; }
	public Boolean showProfields { get; set; }
	public Boolean showInClearing { get; set; }
	public Set<String> gfks = new Set<String>();
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
	
	public User u { get; set; }
	public Account a { get;set; }
	private Contact c;
	private Request__c rq;
	
	public Integer step { get; set; }
	
	public String goHomeUrl { get; set; }
	
	public ClearingController() {
		if (System_Settings.showClearing()) {
			portal=System_Settings.portal;
			isPro=System_Settings.isPro;
			showProfields=false;
			showInClearing=false;
			goHomeUrl=System_Settings.goHome().getUrl();
			step=1;
			isAuthenticated=System_Settings.isPortalUser();
			errorText=errorBase + System.label.registration_errormsg;
			stdErrorText=errorText;
			showDistributionErr=false;
			showDistribution=false;
			selectedGfk='';
			selectedDistribution=new String[]{};
			fillGfks();
			fillDistributions();
			getCurrentUser();
			if (u!=null){ 
				getContact(); 
				//getAccount(); 
				}
			rq=new Request__c();
			rq.Typ__c='Freischaltung';
			rq.Gigaset_Extranet__c=!System_Settings.isPro;
			rq.Gigaset_Pro__c=System_Settings.isPro;
			rq.Datum__c=System.today();
			if (u!=null && u.ContactId!=null) rq.Kontakt__c=u.contactid;
		}
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
	
	public void getCurrentUser() {
		if (isAuthenticated) {
			u=System_Settings.getCurrentUpdatedUser();
			if (u!=null) {
				u.Pro_Partner_Typ__c=null;
			}
		}
	}
	
	private void getContact() {
		if (u!=null) c=System_Settings.currentusercontact;
		if (u!=null && c==null && u.ContactId!=null) {
			try {
				c=[SELECT Id, In_Freischaltung__c, Gigaset_Extranet__c, Gigaset_Pro__c, AccountId FROM Contact WHERE Id=:u.ContactId];
			} catch (System.Queryexception e) {
				System.debug('PARX Could not read Contact Information!');
				ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.presetpage_syserror1);
	 			ApexPages.addMessage(apm);
				//if (System_Settings.isDebug) throw e;
			}
			if (c!=null && c.AccountId!=null) {
				u.In_Freischaltung__c=c.In_Freischaltung__c;
				if (!c.In_Freischaltung__c && isPro && !c.Gigaset_Pro__c) {
					showProfields=true;
				}
				if (c.In_Freischaltung__c) {
					showProfields=false;
					showInClearing=true;
				}
			}
		}
	}
	
	/*
	private void getAccount() {
		if (u!=null && a==null && u.AccountId!=null) {
			try {
				a=[SELECT Id, PRO_VAR_MITARBEITERTZAHL__c, PRO_VAR_ANZ_SUPPORT__c, PRO_VAR_KUNDEN_MA_ANZ__c, PRO_VAR_SCHWERPUNKT__c, PRO_VAR_SCHWERPUNKT_ANDERER__c, PRO_VAR_ERFAHRUNGEN__c, PRO_SYSTEM_LIEFERANTEN__c, PRO_VAR_SYSTEMPARTNER_WEITERE__c, Description FROM Account WHERE Id=:c.AccountId];
			} catch (System.Queryexception e) {
				System.debug('PARX Could not read Account Information!');
				ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.presetpage_syserror1);
	 			ApexPages.addMessage(apm);
				//if (System_Settings.isDebug) throw e;
			}
			
			if(a != null){
				u.PRO_VAR_MITARBEITERTZAHL__c = a.PRO_VAR_MITARBEITERTZAHL__c;
				u.PRO_VAR_ANZ_SUPPORT__c = a.PRO_VAR_ANZ_SUPPORT__c;
				u.PRO_VAR_KUNDEN_MA_ANZ__c = a.PRO_VAR_KUNDEN_MA_ANZ__c;
				u.PRO_VAR_SCHWERPUNKT__c = a.PRO_VAR_SCHWERPUNKT__c;
				u.PRO_VAR_SCHWERPUNKT_ANDERER__c = a.PRO_VAR_SCHWERPUNKT_ANDERER__c;
				u.PRO_VAR_ERFAHRUNGEN__c = a.PRO_VAR_ERFAHRUNGEN__c;
				u.PRO_SYSTEM_LIEFERANTEN__c = a.PRO_SYSTEM_LIEFERANTEN__c;
				u.PRO_VAR_SYSTEMPARTNER_WEITERE__c = a.PRO_VAR_SYSTEMPARTNER_WEITERE__c;
				u.Description__c = a.Description;
			}
		}
	}
	*/
	
	private void updateUser() {
		System.debug('PARX Updating User Data!');
		if (u!=null) {
			try {
				update u;
			} catch (System.DmlException e) {
				System.debug('PARX Error updating user data: ' + e.getMessage());
				ApexPages.addMessages(e);
				//if (System_Settings.isDebug) throw e;
			}
		}
	}
	
	private Boolean insertRequest() {
		Boolean retval=true;
		if (rq!=null) {
			try {
				rq.Portal__c=portal;
				insert rq;
				retval=false;
			} catch (Exception e) {
				System.debug('PARX Could not save request!');
				// custom label
				ApexPages.Message pm = new ApexPages.Message(ApexPages.Severity.FATAL,System.label.presetpage_error);
				ApexPages.addMessage(pm);
				//messages=System.label.callback_not_send;
				//if (System_Settings.isDebug) throw e;
			}
		}
		return retval;
	}
	
	public PageReference saveData() {
		Boolean hasErr=false;
		if (step==1) {
			if (!selectedDistribution.isEmpty() && selectedDistribution!=null) u.Distribution__c=putDistributions();
	 		else if (showDistribution) {
	 			showDistributionErr=true;
	 			hasErr=true;
	 		} else {
	 			showDistributionErr=false;
	 			hasErr=false;
	 		}
	 		if (!hasErr) {
				u.In_Freischaltung__c=true;
				hasErr=insertRequest();
				if (!hasErr) {
					updateUser();
					step++;
				}
	 		}
	 	}
	 	if (hasErr) step=99;
	 	return null;
	}
	
	public PageReference relationshipSelectionAction() {
	 	showDistribution=false;
	 	if (u!=null) {
		 	u.Handelskanal__c=selectedGfk;
		 	if (!gfks.contains(selectedGfk) && portal=='de') {
		 		showDistribution=true;
		 	}
	 	}
	 	return null;
	 }

	public PageReference previousStep() {
	 	step=step-1;
	 	return null;
	 }
	 
}