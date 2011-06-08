public class LeadConvertController {
  
  public class ConvertException extends Exception {}
  
  public class AccountItem{
    private String Id;
    private String Name;
    
    public AccountItem(String Id, String Name){
      this.Id = Id;
      this.Name = Name;
    }
    
    public String getId(){
      return Id;
    }
    
    public String getName(){
      return Name;
    }
  }
  
  private final Id leadId;
  private User loggedUser;
  
  public Account fakeAcc{get;set;}
  public Lead selectedLead {get;set;}
  public LeadStatus convertStatus {get;set;}
  public Task t {get;set;}
  
  public Boolean deactivateOpportunities {get;set;}
  public Boolean notifyEmail {get;set;}
  public Boolean leadNotFocused {get;set;}
  public Boolean isAbleCreateOpps {get;set;}
  public Boolean contactMergeNeeded {get;set;}
  public Boolean overwriteContact {get;set;}
  public Boolean sendTaskEmail {get;set;}
  public Boolean missing_opp_name {get;set;}
  
  private Boolean initPhase = true;
  private Boolean forceAccMerging = false;
  
  public String selAcc {get;set;}  //WIRD NICHT MEHR VERWENDET... NUR FÜR DEN UNITTEST NOCH DA!
  public String selectedState {get;set;}
  public String accName {get;set;}
  public String selCon {get;set;}
  public String convertStatusRes {get;set;}
  public String selectedAccId {get;set;}
  public String oppPrefix {get;set;}
  
  private List<Account> matchedAccs = new List<Account>();
  private List<Contact> contacts = new List<Contact>();
  private List<AccountItem> options = new List<AccountItem>();
  
  private Account selectedAcc;
  private Boolean isKnown = false;
  private static Database.LeadConvert lc;
  
  /*
  public LeadConvertController(){
    leadId = getParam('LeadId');
    if(leadId == null)
      leadId = getParam('id');
    leadNotFocused = false;
    
    contactMergeNeeded = false;
    notifyEmail=true;
    
    if(leadId != null){
      selectedLead = [SELECT Id, Name, FirstName, LastName, Status, Company, OwnerId, RecordType.Name FROM Lead WHERE Id = :leadId];
      convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
      
      String searchTag = '%' + selectedLead.Company + '%';
          
          if(selectedLead.Company.length() <= 3)
            matchedAccs = [SELECT Id, Name, RecordType.Name FROM Account WHERE Name = :selectedLead.Company];
          else if(selectedLead.Company.length() > 3)  
            matchedAccs = [SELECT Id, Name, RecordType.Name FROM Account WHERE Name LIKE :searchTag];
      
      oppPrefix = selectedLead.Company + '-';
      
      fakeAcc = new Account(OwnerId = Userinfo.getUserId(), Name = selectedLead.Company);
      
      t = new Task(Priority = 'Normal', Status = 'Nicht begonnen');
      
      overwriteContact = false;
      
      if(selectedLead.RecordTypeId == '012D0000000JEeV'){
        deactivateOpportunities = true;
        isAbleCreateOpps = false;
      }else{
        isAbleCreateOpps = true;
        deactivateOpportunities = false;
      }
      
    }else{
      leadNotFocused = true;  
      System.debug('Lead not in focus. Please check parameter passing of Lead Id');
    }
  }
  */
  public LeadConvertController(ApexPages.StandardController controller){
    System.debug('Constructor!');
    //selectedLead = (Lead) controller.getRecord();
    	
    missing_opp_name = false;
    leadNotFocused = false;
    contactMergeNeeded = false;
    notifyEmail = true;
    
    	try{
    		if(ApexPages.currentPage().getParameters().get('id') == null)
    			throw new ConvertException();
    			
    		selectedLead = [SELECT Id, Name, FirstName, LastName, Status, Company, OwnerId, RecordType.Name FROM Lead WHERE Id = :ApexPages.currentPage().getParameters().get('id') AND isConverted = false];
    		
    		if(selectedLead != null){
      			selectedLead = [SELECT Id, Name, FirstName, LastName, Status, Company, OwnerId, RecordType.Name FROM Lead WHERE Id = :ApexPages.currentPage().getParameters().get('id') AND isConverted = false];
    	
    			convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
      
      			leadId = selectedLead.Id;
      	
      			String searchTag = '%' + selectedLead.Company + '%';
          
        	  	if(selectedLead.Company.length() == 1)
        	    	matchedAccs = [SELECT Id, Name, RecordType.Name FROM Account WHERE Name = :selectedLead.Company limit 9000];
          		else if(selectedLead.Company.length() > 1)  
            		matchedAccs = [SELECT Id, Name, RecordType.Name FROM Account WHERE Name LIKE :searchTag limit 9000];
      
      			oppPrefix = selectedLead.Company + '-';
      
      			fakeAcc = new Account(OwnerId = Userinfo.getUserId(), Name = selectedLead.Company);
      
      			t = new Task(Priority = 'Normal', Status = 'Nicht begonnen');
      
      			overwriteContact = false;

      			if(selectedLead.RecordTypeId == '012D0000000JEeV'){
        			deactivateOpportunities = true;
        			isAbleCreateOpps = false;
      			}else{
        			isAbleCreateOpps = true;
        			deactivateOpportunities = false;
      			}

    		}else{
      			leadNotFocused = true;  
      			System.debug('Lead not in focus. Please check parameter passing: Lead Id');
    		}	
    	} catch(Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Lead found or Lead is already converted! Please contact PARX!'));
   		}	 	
  }
  
  public PageReference addAccount(){
    String name = getParam('accountName');
    String id = getParam('accountId');
    
    if(options.size() > 0){
      options.add(0, new AccountItem(id, name));
    }else{
      options.add(new AccountItem(id, name));
    }
    return null;
  }
  
  public List<AccountItem> getAccounts(){
    List<AccountItem> temp = new List<AccountItem>();
    
    if(initPhase){
    	try{
    		if(selectedLead.Company == null)
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead does not contain company information. Please contact PARX!'));
    	} catch(Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead does not contain company information. Please contact PARX!'));
    		return temp;
    	}
    	
      options.add(new AccountItem('-', System.Label.lc_new_account+': '+selectedLead.Company));
    
      for(Account item : matchedAccs)
             options.add(new AccountItem(item.Id , System.Label.lc_old_account+': '+item.Name));
    
      initPhase = false;
    }
   
    for(AccountItem item : options)
           if(item.getId() == selectedAccId){
             if(temp.size() > 0)  
               temp.add(0, item);
             else
               temp.add(item);
           }else
        temp.add(item);
        return temp;  
  }
  
  public List<SelectOption> getContacts(){
    List<SelectOption> options = new List<SelectOption>();
    try{
    	if(selectedLead.Lastname == null)
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead does not contain lastname information. Please contact PARX!'));
    } catch(Exception e) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead does not contain lastname information. Please contact PARX!'));
    	return options;
    }
    options.add(new SelectOption('-', System.Label.lc_new_contact+': '+selectedLead.Lastname));
    
    for(Contact item : contacts)
           options.add(new SelectOption(item.Id ,System.Label.lc_old_contact+': '+item.Lastname));
        
        return options;  
  }
  
  private String getParam(String name) {
    return ApexPages.currentPage().getParameters().get(name);  
  }
  
  public void removeWarning(){
    Apexpages.getMessages().clear();
    forceAccMerging = false;
  }
  
  public PageReference changeLeadFocus(){
    leadNotFocused = true;
    return null;
  } 
  
  public Boolean checkLeadID(){
  		if(selectedLead == null) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'LeadId is missing!'));
        	return false;
    	}
    	return true;
  }
  
  public void debugger(){
  	System.debug('Starting lead conversion with Id: '+ selectedAccId);
        map<String, String> test = ApexPages.currentPage().getParameters();
        
        for(String s:test.keySet())
        	system.debug(s +': ' + test.get(s));
  }
  
  
  public Boolean checkSelectedAccount() {
  		if(selectedAccId != null && !selectedAccId.equals('') && !selectedAccId.equals('-')){
          	selectedAcc = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :selectedAccId limit 1];    
          	return true;
  		}
  		return false;	
  }
  
  
  public Boolean checkAccountsRecordType(){
  	
  		if(selectedAcc.RecordType.Name == selectedLead.RecordType.Name) 		
  			return true;
 
  		return false;
  }
  
  
  public Boolean checkIfAnyContactsExist() {
  		contacts = [SELECT Id, Lastname FROM Contact WHERE Lastname = :selectedLead.LastName AND AccountId = :selectedAcc.Id limit 9000];
      
        if(contacts != null && contacts.size() > 0 && !contactMergeNeeded)
        	contactMergeNeeded = true;	
        else
        	contactMergeNeeded = false;
        	
  		return contactMergeNeeded;
  }
  
  
  public Boolean validateSelectedContact(){
  		if(!contactMergeNeeded && selCon != '-' && selCon != null && selCon != '')
  			return true;
  			
  		return false;	
  }
  
  
  public Boolean checkIfSelectedAccountIsKnown(){
        
        for(AccountItem item : options)
        {
        	System.debug('item ID: '+item.getId() + ' / selectedAcc ID: '+selectedAcc.Id);
        	
        	if(item.getId().equals(selectedAcc.Id))
        	{
            	isKnown = true;
            	System.debug('isKnown');
          	}
        }
          
        if(!isKnown)
        {
        	if(options.size() > 0)
            	options.add(0, new AccountItem(selectedAcc.Id, System.Label.lc_old_account+': ' + selectedAcc.Name));
          	else
            	options.add(new AccountItem(selectedAcc.Id, System.Label.lc_old_account+': ' + selectedAcc.Name));
        }
        
        return isKnown;	
  }
  
  
  public PageReference alertAccountRecordTypeMismatch(){
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.lead_convert_merge_mismatch));
        ApexPages.currentPage().getParameters().put('id', selectedLead.Id);
        forceAccMerging = true;
        		
    	return null;	
  }
  
  public PageReference convert() { 
  		System.debug('forceAccMerging: ' + forceAccMerging);   
       	if(!checkLeadID())
          	return null;
        
        debugger();
        
        lc = new database.LeadConvert();
    	System.debug('selectedAccId: '+selectedAccId);
        
        if(checkSelectedAccount()) 
        {	
        	System.debug('forceAccMerging: ' + forceAccMerging);
        	if((forceAccMerging || checkAccountsRecordType())) 
        	{
        		System.debug('RecordType accepted!');
        		removeWarning();
        		
        		System.debug('Account selected! ' + selectedAcc.Id);
        		lc.setAccountId(selectedAcc.Id);
        		oppPrefix = selectedAcc.Name + '-';
  			
        		checkIfSelectedAccountIsKnown();
        		
        		if(!checkIfAnyContactsExist()) 
        		{
        			System.debug('There is an existing contact!');
        			if(validateSelectedContact()) 
        			{
        				System.debug('An existing contact ' + contacts.get(0).Id + ' was selected!');
        				lc.setContactId(contacts.get(0).Id);
        				lc.setOverwriteLeadSource(overwriteContact);
        			} else {		
        				System.debug('A new Contact will be created!');
        			}
        		} else {
        			//Wenn zumindest ein Kontakt mit ähnlichem Nachnamen gefunden wurde, dann halte an und lass Anwender auswählen!
        			System.debug('Contacts found! Let user select one!');
        			return null;
        		}
        	} else {
        		//Wenn zwar ein Account gefunden wurde, jedoch der RecordType nicht gestimmt hat, dann alarmiere den Anwender darüber!
        		return alertAccountRecordTypeMismatch();
        	}
        }
        /*
        if(selectedAccId != null && !selectedAccId.equals('') && !selectedAccId.equals('-')){
          	Account selectedAcc = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :selectedAccId limit 1];    
         
        	if(forceAccMerging || selectedAcc.RecordType.Name == selectedLead.RecordType.Name){
        		System.debug('Account selected! ' + selectedAcc.Id);
        		lc.setAccountId(selectedAcc.Id);
        		oppPrefix = selectedAcc.Name + '-';
        
        		contacts = [SELECT Id, Lastname FROM Contact WHERE Lastname = :selectedLead.LastName AND AccountId = :selectedAcc.Id limit 9000];
      
        		if(contacts != null && contacts.size() > 0 && !contactMergeNeeded){
          			contactMergeNeeded = true;
          			return null;  
        		}
        
        		if(contactMergeNeeded && selCon != '-' && selCon != null && selCon != ''){
          			lc.setContactId(contacts.get(0).Id);
          			lc.setOverwriteLeadSource(overwriteContact);
        		}
      
      		} else {
        		
        		return alertAccountRecordTypeMismatch();
      		}  
        }
        */
        lc.setLeadId(selectedLead.Id);
    	lc.setOwnerId(Userinfo.getUserId());
    	lc.setConvertedStatus(convertStatusRes);
    
    	lc.setSendNotificationEmail(notifyEmail);
    	lc.setDoNotCreateOpportunity(deactivateOpportunities);
    	if(!deactivateOpportunities)
      		lc.setOpportunityName(oppPrefix);
    
    	if((oppPrefix.trim().equals('') || oppPrefix == null) && !deactivateOpportunities){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.lead_convert_missing_required_field));
    		//ApexPages.currentPage().getParameters().put('id', selectedLead.Id);
    		missing_opp_name = true;
    		return null;
    	}
    
    	System.debug(lc);
      	Database.LeadConvertResult lcr = Database.convertLead(lc);
      
      	if(lcr.isSuccess()){
        	Account acc = [SELECT Id, RecordTypeId FROM Account WHERE Id = :lcr.getAccountId()];
        
        	if((selectedLead.RecordTypeId != null || selectedLead.RecordTypeId != '') && (selectedAccId == null || selectedAccId == '' || selectedAccId == '-')){
           		RecordType rType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = :selectedLead.RecordType.Name];
        		acc.RecordTypeId = rType.Id;  
        		update acc;
        	}
        
        	if(t.Subject != null && t.Subject != ''){  
          		if(!deactivateOpportunities)
            		t.WhatId = lcr.getOpportunityId();
          
          		t.WhoId = lcr.getContactId();
          
          		insert t;
        	}
        
      		return new ApexPages.Standardcontroller(acc).view();
      	}
      	return null;  
	}
    
    
    public PageReference cancel(){
    	return new ApexPages.Standardcontroller(selectedLead).view();
    }
    
    public PageReference resetForcing(){
        forceAccMerging = false;
        return null;
    }
}