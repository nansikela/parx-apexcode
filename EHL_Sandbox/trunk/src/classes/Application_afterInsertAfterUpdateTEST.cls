@isTest
private class Application_afterInsertAfterUpdateTEST {
	
	
	static testMethod void oppUpdateTestmethod(){
        try{
            Account a = new Account(Name = 'Test AG');
            insert a;
            
            Contact c = new Contact(AccountId = a.Id);
            c.Firstname = 'P';
            c.Lastname = 'Tester';
            insert c;
            
            List<Opportunity> oList = new List<Opportunity>();
            
            Opportunity o1 = new Opportunity();
            o1.Name = 'Test';
            o1.StageName = 'Admitted-open';
            o1.CloseDate = Date.today() + 30;
            oList.add(o1);
            
            Opportunity o2 = new Opportunity();
            o2.Name = 'Test2';
            o2.StageName = 'In Progress';
            o2.CloseDate = Date.today() + 30;
            oList.add(o2);
            
            Opportunity o3 = new Opportunity();
            o3.Name = 'Test3';
            o3.StageName = 'Proposal';
            o3.CloseDate = Date.today() + 30;
            oList.add(o3);
            
            insert oList;
            
            //APPApplication in progress
            Application__c app = new Application__c();
            app.Student__c = c.Id;
            app.Opportunity__c = o1.Id;
            app.Application_Code__c = 'APP';
            insert app;
            //check that stage is Application in progress
            Opportunity opp = [Select o.StageName from Opportunity o where o.Id = :o1.Id];
            System.assertEquals(opp.StageName, 'Application in progress');
            
            
            //SDP Application Selection in progress
            Application__c app2 = new Application__c();
            app2.Student__c = c.Id;
            app2.Opportunity__c = o2.Id;
            app2.Application_Code__c = 'SDP';
            insert app2;
            //check that stage is Application in progress
            opp = [Select o.StageName from Opportunity o where o.Id = :o2.Id];
            System.assertEquals(opp.StageName, 'Application Selection in progress');
            
            //WDR Application cancelled
            Application__c app3 = new Application__c();
            app3.Student__c = c.Id;
            app3.Opportunity__c = o3.Id;
            app3.Application_Code__c = 'WDR';
            insert app3;
            //check that stage is Application in progress
            opp = [Select o.StageName from Opportunity o where o.Id = :o3.Id];
            System.assertEquals(opp.StageName, 'Application cancelled');
            
            //RAS Application rejected
            app3.Application_Code__c = 'RAS';
            update app3;
            opp = [Select o.StageName from Opportunity o where o.Id = :o3.Id];
            System.assertEquals(opp.StageName, 'Application rejected');
            
        }catch(System.Exception e){
            System.debug('**** Exception: ' +e);
            System.assert(false);   
        }
    }
}