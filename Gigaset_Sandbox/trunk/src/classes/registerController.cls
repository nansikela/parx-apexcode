public class registerController {

	public Boolean isAuthenticated { get; set; }
	public Integer step { get; set; }
	public Lead l { get; set; }
	public String messages { get; set; }
	public Integer backcounter { get; set; }
	public Boolean showShippingAddress { get; set; }
	public Boolean showShippingAddressDummy { get; set; }
	public Boolean disabledStep1 { get; set; }
	public Boolean disabledStep2 { get; set; }
	public Boolean disabledStep3 { get; set; }
	public Boolean showPhoneErr { get; set; }
	public Boolean showFaxErr { get; set; }
	public Boolean showMobileErr { get; set; }
	public Boolean showHotlineErr { get; set; }
	public Boolean showDistributionErr { get; set; }
	public String labelPhone { get; set; }
	public String labelMobile { get; set; }
	public String labelHotline { get; set; }
	public String labelPrivacy { get; set; }
	public String errorText { get; set; }
	public String errorBase='<strong>' + System.Label.site.Error2 + ':</strong> ';
	public String stdErrorText='';
	public Set<String> gfks = new Set<String>();
	public Boolean showDistribution { get; set; }
	public String selectedGfk { get; set; }
	public String[] selectedDistribution { get; set; }
	public Set<String> distributionValues { get; set; }
	public Set<String> distributionLabels { get; set; }
	public Map<String, String> distributionMap = new Map<String, String>();
	public String goHomeUrl { get; set; }
	public Boolean isPro { get; set; }
	public string portal { get; set; }
	public String privacypageurl { get; set; }
	public Boolean showprivacy { get; set; }
	public String marginleft { get; set; }

	
	// constructor
	public registerController() {
		isPro=System_Settings.isPro;
		portal=System_Settings.portal;
		if (isPro) marginleft='0px';
		marginleft='210px';
		showprivacy=System_Settings.showPrivacyAnonymous();
		//showprivacy=false;
		goHomeUrl=System_Settings.goHome().getUrl();
		l=new Lead();
		l.Portal__c=System_Settings.portal;
		l.Country=System_Settings.PortalCountry;
		l.Land_Auswahl__c=System_Settings.PortalCountry;
		l.Gigaset_Extranet__c=!isPro;
		l.Gigaset_Pro__c=isPro;
		if (showprivacy) step=0;
		else step=1;
		backcounter=-1;
		messages='';
		isAuthenticated=System_Settings.isPortalUser();
		showShippingAddress=false;
		if (showprivacy) disabledStep1=true;
		else disabledStep1=false;
		disabledStep2=true;
		disabledStep3=true;
		showPhoneErr=false;
		showFaxErr=false;
		showMobileErr=false;
		showHotlineErr=false;
		showDistributionErr=false;
		errorText=errorBase + System.label.registration_errormsg;
		stdErrorText=errorText;
		Schema.DescribeFieldResult f = Schema.sObjectType.User.fields.Telefon_Kontakt__c;
		labelPhone=f.getLabel();
		f = Schema.sObjectType.User.fields.MobilePhone_Kontakt__c;
		labelMobile=f.getLabel();
		f = Schema.sObjectType.User.fields.Sonstige_Telefonnummer__c;
		labelHotline=f.getLabel();
		f = Schema.sObjectType.User.fields.Datenschutzerkl_rung_zugestimmt__c;
		labelPrivacy=f.getLabel();
		showDistribution=false;
		selectedGfk='';
		selectedDistribution=new String[]{};
		fillGfks();
		fillDistributions();
		//privacypageurl=Page.page.getUrl() + '?pageid=' + System_Settings.privacyprotectionid;
		privacypageurl=Site.getCurrentSiteUrl()+'page' + '?pageid=' + System_Settings.privacyprotectionid;
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
	
	private Integer insertLead() {
		Integer retval=99;
		if (l!=null) {
			try {
				insert l;
				l=new Lead();
				retval=step;
			} catch (Exception e) {
				System.debug('PARX Could not save request!');
				// custom label
				ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.register_not_send);
	 			ApexPages.addMessage(apm);
				//messages=System.label.register_not_send;
				//if (System_Settings.isDebug) throw e;
			}
		}
		return retval;
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
	
	private String returnErrorMsg(String error) {
		String errmsg=error;
		String validationerr='FIELD_CUSTOM_VALIDATION_EXCEPTION';
		Integer startindex=error.indexOf(validationerr);
		// custom validation errror found?
		if (startindex!=-1) {
			startindex=startindex+validationerr.length()+2;
			Integer lastindex=error.lastIndexOf(': [');
			errmsg=error.substring(startindex,lastindex);
		}
		return errmsg;
	}
	
	// getter
	public String getActive0() {
		if (step==0) return 'active';
		else return 'inactive';
	}
	
	public String getActive1() {
		if (step==1) return 'active';
		else return 'inactive';
	}
	
	public String getActive2() {
		if (step==2) return 'active';
		else return 'inactive';
	}
	
	public String getActive3() {
		if (step==3) return 'active';
		else return 'inactive';
	}
	
	public String getServiceHotlineUrl() {
		pageReference basispage = Page.page;
		if (basispage!=null) 
			return Page.page.getUrl() + '?pageid=' + System_Settings.servicehotlineinfopageid;
		else 
			return '';
	}
		
	public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		for (String label: distributionMap.keySet()) {
			options.add(new SelectOption(distributionMap.get(label),label));
		}
		return options;
	}
	
	// actions
	public PageReference saveLead() {
	 	step=insertLead();
	 	backcounter=backcounter-4;
	 	return null;
	 }
	 
	 public PageReference nextStep() {
	 	messages='';
	 	Boolean hasErr=false;
	 	showPhoneErr=false;
	 	showFaxErr=false;
	 	showMobileErr=false;
	 	showHotlineErr=false;
	 	showDistributionErr=false;
	 	errorText=stdErrorText;
	 	if (step==0) {
	 		if (!l.Datenschutzerkl_rung_zugestimmt__c) {
	 			hasErr=true;
	 			ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelPrivacy + ': ' + System.label.privacy_noaccesswithoutaccept);
		 		ApexPages.addMessage(apm);
	 		} else {
	 			l.Zustimmung_Datenschutzerkl_rung_am__c=System.today();
	 		}
	 	}
	 	// distribution selection
	 	if (step==3) {
	 		if (!selectedDistribution.isEmpty() && selectedDistribution!=null) l.Distribution__c=putDistributions();
	 		else if (showDistribution) {
	 			showDistributionErr=true;
	 			hasErr=true;
	 		} else {
	 			showDistributionErr=false;
	 			hasErr=false;
	 		}
	 	}
	 	if (step==2 && ((l.Anmeldung_Hotlinetelefon__c && (l.Sonstige_Telefonnummer__c==null || l.Sonstige_Telefonnummer__c==''))||(l.Anmeldung_Telefon__c && (l.Telefon_Kontakt__c==null || l.Telefon_Kontakt__c=='')) || (l.Anmeldung_Mobiltelefon__c && (l.MobilePhone==null || l.MobilePhone=='')))) {
	 		if (l.Anmeldung_Telefon__c && (l.Telefon_Kontakt__c==null || l.Telefon_Kontakt__c=='')) {
	 			//ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelPhone + ': ' + System.label.registration_errormsg);
		 		//ApexPages.addMessage(apm);
	 			showPhoneErr=true;
	 			hasErr=true;
	 		}
	 		if (l.Anmeldung_Mobiltelefon__c && (l.MobilePhone==null || l.MobilePhone=='')) {
	 			//ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelMobile + ': ' + System.label.registration_errormsg);
		 		//ApexPages.addMessage(apm);
	 			showMobileErr=true;
	 			hasErr=true;
	 		}
	 		if (l.Anmeldung_Hotlinetelefon__c && (l.Sonstige_Telefonnummer__c==null || l.Sonstige_Telefonnummer__c=='')) {
	 			//ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelHotline + ': ' + System.label.registration_errormsg);
		 		//ApexPages.addMessage(apm);
	 			showHotlineErr=true;
	 			hasErr=true;
	 		}
	 	}
	 	if (!hasErr) {
	 		// Company Phone / Fax
	 		Request__c rq = new Request__c();
	 		if (step==1) {
 				if (l.Phone!=null && l.Phone!='') {
 					rq.Telefon__c=l.Phone;
	 				try {
	 					upsert rq;
	 				} catch (System.DmlException e) {
	 					errorText=errorBase + returnErrorMsg(e.getMessage());
	 					showPhoneErr=true;
	 					hasErr=true;
	 				}
 				}
				if (l.Fax!=null && l.Fax!='') {
					rq.Telefon__c=l.Fax;
					try {
	 					upsert rq;
	 				} catch (System.DmlException e) {
	 					errorText=errorBase + returnErrorMsg(e.getMessage());
	 					showFaxErr=true;
	 					hasErr=true;
					}
 				}
	 		} else 
	 		// Contact Phone / MobilePhone / Fax
	 		if (step==2) {
 				if (l.Telefon_Kontakt__c!=null && l.Telefon_Kontakt__c!='') {
 					rq.Telefon__c=l.Telefon_Kontakt__c;
	 				try {
	 					upsert rq;
	 				} catch (System.DmlException e) {
	 					errorText=errorBase + returnErrorMsg(e.getMessage());
	 					showPhoneErr=true;
	 					hasErr=true;
	 				}
 				}
				if (l.Fax_Kontakt__c!=null && l.Fax_Kontakt__c!='') {
					rq.Telefon__c=l.Fax_Kontakt__c;
					try {
	 					upsert rq;
	 				} catch (System.DmlException e) {
	 					errorText=errorBase + returnErrorMsg(e.getMessage());
	 					showFaxErr=true;
	 					hasErr=true;
	 				}
				}
 				if (l.MobilePhone!=null && l.MobilePhone!='') {
 					rq.Telefon__c=l.MobilePhone;
	 				try {
	 					upsert rq;
	 				} catch (System.DmlException e) {
	 					errorText=errorBase + returnErrorMsg(e.getMessage());
	 					showMobileErr=true;
	 					hasErr=true;
	 				}
 				}
 				if (l.Sonstige_Telefonnummer__c!=null && l.Sonstige_Telefonnummer__c!='') {
 					rq.Telefon__c=l.Sonstige_Telefonnummer__c;
	 				try {
	 					upsert rq;
	 				} catch (System.DmlException e) {
	 					errorText=errorBase + returnErrorMsg(e.getMessage());
	 					showHotlineErr=true;
	 					hasErr=true;
	 				}
 				}
	 		}
	 		if (rq!=null && rq.id!=null) try {
	 			delete rq;
	 		} catch (Exception e) {}
	 	}
	 	if (!hasErr) {
		 	step=step+1;
		 	if (step==1) disabledStep1=false;
		 	if (step==2) disabledStep2=false;
		 	if (step==3) disabledStep3=false;
		 	if (step==4) {
		 		step=insertLead();
		 		backcounter=backcounter-2;
		 	}
	 	}
	 	return null;
	 }
	 
	 public PageReference previousStep() {
	 	step=step-1;
	 	return null;
	 }
	 
	 public PageReference goToStep() {
	 	return null;
	 }
	 
	 public PageReference showShippingAddressAction() {
	 	showShippingAddress=!showShippingAddress;
	 	showShippingAddressDummy=showShippingAddress; 
	 	return null;
	 }
	 
	 public PageReference relationshipSelectionAction() {
	 	showDistribution=false;
	 	l.Handelskanal__c=selectedGfk;
	 	if (!gfks.contains(selectedGfk) && System_Settings.portal=='de') {
	 		showDistribution=true;
	 	}
	 	return null;
	 }
	 
	 public PageReference init() {
	 	return null;
	 }
}