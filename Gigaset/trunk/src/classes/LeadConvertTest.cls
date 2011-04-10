@isTest
private class LeadConvertTest {

    static testMethod void myUnitTest() {
    	
    	List<RecordType> r = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead'];
      		
    	Account a = new Account(Name = 'TestComp');
    	insert a;
    	Account a1 = new Account(Name = 'Blarb');
    	insert a1;
    	
    	Contact c = new Contact(Lastname = 'Rofl', Firstname = 'Test', AccountId = a.Id);
    	insert c;
    	 
    	if(r.size() > 0){
      		Lead l1 = new Lead(company = 'TestComp', Lastname = 'Blarb', RecordTypeId = r.get(0).Id);
      		insert l1;
      		Lead l2 = new Lead(company = 'TestComp', Lastname = 'Rofl', RecordTypeId = r.get(1).Id);
      		insert l2;
      		
    		User u = [SELECT Id FROM User WHERE Id = :Userinfo.getUserId() and isactive=true];
    	
    		System.runAs(u) {
   				LeadConvertController ctrl = new LeadConvertController(new ApexPages.StandardController(l1));
  			
  				ApexPages.currentPage().getParameters().put('accountName', a1.Name);
    			ApexPages.currentPage().getParameters().put('accountId', a1.Id);
  				ctrl.addAccount();
  			
  				ApexPages.currentPage().getParameters().put('selectedAccId', a1.Id);
  			
  				LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
  			
  				ctrl.getAccounts();
  				ctrl.getContacts();
    			ctrl.contactMergeNeeded = true;
    			ctrl.convertStatusRes = convertStatus.MasterLabel;
    			ctrl.convert();
    			ctrl.resetForcing();
    			ctrl.removeWarning();
    			ctrl.changeLeadFocus();
    		
    			ctrl.getAccounts().get(0).getId();
    			ctrl.getAccounts().get(0).getName();
    		
    			//Neuer Versuch um Company-Merge zu erzwingen!
    			ctrl = new LeadConvertController(new ApexPages.StandardController(l2));
  			
    			ctrl.getAccounts();
  				ctrl.getContacts();
  				ctrl.selCon = c.Id;
    			ctrl.contactMergeNeeded = true;
    			ctrl.convertStatusRes = convertStatus.MasterLabel;
    			ctrl.notifyEmail = false;
    			ctrl.sendTaskEmail = false;
    			ctrl.convert();
    		}
    	}
    }
}