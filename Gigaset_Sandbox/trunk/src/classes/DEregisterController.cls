public class DEregisterController {

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
  public Boolean showProDistributionErr { get; set; }
  public String labelPhone { get; set; }
  public String labelMobile { get; set; }
  public String labelHotline { get; set; }
  public String labelPrivacy { get; set; }
  public String errorText { get; set; }
  public String errorBase='<strong>' + System.Label.site.Error2 + ':</strong> ';
  public String stdErrorText='';
  public Set<String> gfks = new Set<String>();
  public Boolean showDistribution { get; set; }
  public Boolean show_DECT_Multizellen { get; set; }
  public Boolean show_DECT { get; set; }
  public String selectedGfk { get; set; }
  public String[] selectedDistribution { get; set; }
  public String[] selectedProDistributions { get; set; }
  
  public Set<String> distributionValues { get; set; }
  public Set<String> distributionLabels { get; set; }
  public Map<String, String> distributionMap = new Map<String, String>();
  public String goHomeUrl { get; set; }
  public Boolean isPro { get; set; }
  public string portal { get; set; }
  public String privacypageurl { get; set; }
  public String termsofuseurl { get; set; }
  public Boolean showprivacy { get; set; }
  public String marginleft { get; set; }
  public CustomLabel__c privacy {get;set;}
  public CustomLabel__c termsOfUse {get;set;}
	
  
  // constructor
  public DEregisterController() {
    isPro=SystemSettings.isPro;
    portal=SystemSettings.portal;
    if (isPro) marginleft='0px';
    marginleft='210px';
    showprivacy=SystemSettings.showPrivacyAnonymous();
    //showprivacy=false;
    goHomeUrl=SystemSettings.goHome().getUrl();
    l=new Lead();
    l.Portal__c=SystemSettings.portal;
    l.Country=SystemSettings.PortalCountry;
    l.Land_Auswahl__c=SystemSettings.PortalCountry;
    l.Gigaset_Extranet__c=!isPro;
    l.Gigaset_Pro__c=isPro;
    l.Info_per_Email__c = true;
    l.Verkauf_von_DECT_Multizellen__c = false;
    show_DECT = l.Verkauf_von_DECT_Multizellen__c;
    step=1;
    backcounter=-1;
    messages='';
    isAuthenticated=SystemSettings.isPortalUser();
    showShippingAddress=false;
    disabledStep1=false;
    disabledStep2=true;
    disabledStep3=true;
    showPhoneErr=false;
    showFaxErr=false;
    showMobileErr=false;
    showHotlineErr=false;
    showDistributionErr=false;
    showProDistributionErr=false;
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
    show_DECT_Multizellen = (isPro && portal == 'de') ? true : false ;
    selectedGfk='';
    selectedDistribution=new String[]{};
    selectedProDistributions=new String[]{};
    fillGfks();
    fillDistributions();
    //privacypageurl=Page.page.getUrl() + '?pageid=' + SystemSettings.privacyprotectionid;
	privacy = null;
	termsOfUse = null;
	system.debug(isPro+' / '+portal+' / '+System_Settings.setLanguage());
	try {
		for(CustomLabel__c cl : [SELECT Label__c, ExternalUrl__c FROM CustomLabel__c WHERE isPro__c = :isPro AND Portal__c = :portal AND LanguageCode__c = :System_Settings.setLanguage() AND CommonCode__c = 'extranet_privacy' ])
			privacy = cl;
		
		for(CustomLabel__c cl : [SELECT Label__c, ExternalUrl__c FROM CustomLabel__c WHERE isPro__c = :isPro AND Portal__c = :portal AND LanguageCode__c = :System_Settings.setLanguage() AND CommonCode__c = 'extranet_terms_of_use' ])
       		termsOfUse = cl;
	} catch(Exception e) {
		system.debug(e.getMessage());
	}
	system.debug('PRIVACY: '+privacy);
	system.debug('TERMS OF USE: '+termsOfUse);
  }
  
  public String getBaseTopNaviUrl() {
    	return System_Settings.baseurl+portal.substring(0,2)+'/'+String.valueOf(System_Settings.setLanguage()).substring(0,2)+'/';
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
      	l.HasOptedOutOfEmail = true;
        insert l;
        l=new Lead();
        retval=step;
      } catch (Exception e) {
        System.debug('PARX Could not save request!');
        // custom label
        ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.register_not_send);
         ApexPages.addMessage(apm);
        //messages=System.label.register_not_send;
        //if (SystemSettings.isDebug) throw e;
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
  
  private String putProDistributions() {
		String multi='';
		if (!selectedProDistributions.isEmpty()) {
			for (String s: selectedProDistributions) {
				multi=multi + ';' + s;
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
  public String getActive1() {
    if (step==1) return 'active';
    else return '';
  }
  
  public String getActive2() {
    if (step==2) return 'active';
    else return '';
  }
  
  public String getActive3() {
    if (step==3) return 'active';
    else return '';
  }
    
  public String getServiceHotlineUrl() {
    pageReference basispage = Page.page;
    if (basispage!=null) 
      return Page.page.getUrl() + '?pageid=' + SystemSettings.servicehotlineinfopageid;
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
  
  public List<SelectOption> getProDistributionPicklistItems() {
		List<SelectOption> options = new List<SelectOption>();
		for (String label: SystemSettings.getPicklistItems('account_lead_pro_distribution')) {
			options.add(new SelectOption(label,label));
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
    
     // distribution selection
     if (step==3) {
       if (!selectedDistribution.isEmpty() && selectedDistribution!=null) l.Distribution__c=putDistributions();
       else if (showDistribution) {
         showDistributionErr=true;
         hasErr=true;
       } else {
         showDistributionErr=false;
       }
       if (!selectedProDistributions.isEmpty() && selectedProDistributions!=null) l.Pro_Distribution__c=putProDistributions();
       else if (isPro) {
         showProDistributionErr=true;
         hasErr=true;
       } else {
         showProDistributionErr=false;
       }
       
       if(showPrivacy) {
	 		if (!l.Datenschutzerkl_rung_zugestimmt__c) {
	 			ApexPages.Message apm = new ApexPages.Message(ApexPages.Severity.FATAL, labelPrivacy + ': ' + System.label.privacy_noaccesswithoutaccept);
				ApexPages.addMessage(apm);
				hasErr=true;
	 		} else {
	 			l.Zustimmung_Datenschutzerkl_rung_am__c=System.today();
	 		}
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
   
   public PageReference DECTFieldUpdateAction() {
   	 system.debug('SHOW_DECT: '+show_DECT);
   	 l.Verkauf_von_DECT_Multizellen__c = show_DECT;
   	 return null;
   }
   
   public PageReference relationshipSelectionAction() {
     showDistribution=false;
     l.Handelskanal__c=selectedGfk;
     if (!gfks.contains(selectedGfk) && SystemSettings.portal=='de') {
       showDistribution=true;
     }
     return null;
   }
   
   public PageReference init() {
     return null;
   }
}