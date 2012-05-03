global class BatchTest implements Database.Batchable<sObject>{
	String query;
	String email;
	String oldValue; 
	String newValue;	

	global Database.querylocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
    }	

	global void execute(Database.BatchableContext BC, List<sObject> scope){
	    List<Outlet_Visit__c> accns = new List<Outlet_Visit__c>();
	
   		for(sObject s : scope) {
   			Outlet_Visit__c a = (Outlet_Visit__c)s;
	        if(a.Status__c==oldValue){
	            a.Status__c=newValue;
	            accns.add(a);
	        }
	    }
	
		update accns; 
	}
	
	global void finish(Database.BatchableContext BC){
	
	}

	static testMethod void myUnitTest() {
		user u = [SELECT ID, UserName FROM User 
             WHERE username='germany_consultant@b-f.com.config01'];

   		List <Outlet_Visit__c> ovs = new List<Outlet_Visit__c>();
      	for(integer i = 0; i<200; i++){
         	ovs.add(new Outlet_Visit__c(Visit_Date__c = system.today(), Ownerid = u.ID, Status__c = 'New'));
      	}
   		insert ovs;
   		
   		List <Outlet_Visit_Item__c> ovis = new List<Outlet_Visit_Item__c>();
   		for(Outlet_Visit__c ov : ovs) {
         	ovis.add(new Outlet_Visit_Item__c(Outlet_Visit__c = ov.ID));
         	ovis.add(new Outlet_Visit_Item__c(Outlet_Visit__c = ov.ID));
         	ovis.add(new Outlet_Visit_Item__c(Outlet_Visit__c = ov.ID));
   		}
   		insert ovis;
   		
   		system.runAs(u) {
   			Test.StartTest();
   			BatchTest reassign = new BatchTest();
   			reassign.query='SELECT ID, Name, Status__c, Ownerid ' +
        	    'FROM Outlet_Visit__c ' +
        	    'WHERE OwnerId=\'' + u.Id + '\'' +
        	    ' LIMIT 200';
   			reassign.oldValue = 'New';
   			reassign.newValue = 'Complete';
   			ID batchprocessid = Database.executeBatch(reassign);
   			Test.StopTest();
   		}
    }
}