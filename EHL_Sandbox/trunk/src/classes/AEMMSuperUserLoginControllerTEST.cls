public class AEMMSuperUserLoginControllerTEST {
	
	static testMethod void aemmLoginTestmethod(){
		
		String AEMMURL = 'https://apply.ehl.ch/superuser.php?key=';
		try{
			Account a = new Account();
	    	a.Name = 'Test AG';
	    	insert a;
	    	
	    	Contact c = new Contact();
	    	c.Firstname = 'parx';
	    	c.Lastname = 'Muster';
	    	c.AccountId = a.Id;
	    	c.AEMM_ID__c = '3605';
	    	insert c;
	    	
	    	Application__c app = new Application__c();
	    	app.Student__c = c.Id;
	    	app.AEMM_ID__c = '3605';
	    	insert app;
	    	
		    
		    ApexPages.standardController stdController1 = new ApexPages.standardController(app);     
		    AEMMSuperUserLoginController controller1 = new AEMMSuperUserLoginController(stdController1);
		    PageReference loginURL = controller1.aemmLogin();
			if(loginURL != null){
			    System.assert(loginURL.getUrl().contains(AEMMURL));
		    }else{
		    	System.assert(false);
		    }
			
			//check that superLogin is created
		    List<aemmsuperuserlogin__c> logList = [Select a.Student__c from aemmsuperuserlogin__c a where a.Student__c = :c.Id];
		    if(logList.isEmpty()){
		    	System.assert(false);
		    }
		    
		    
		    //error, not a application that is inserted
		    ApexPages.standardController stdController2 = new ApexPages.standardController(new Application__c());     
		    AEMMSuperUserLoginController controller2 = new AEMMSuperUserLoginController(stdController2);
			System.assert(ApexPages.hasMessages());
		    
			
		}catch(System.Exception e){
            System.debug('** Exception : ' + e.getMessage());
            System.assert(false);
        }
	}
   
}