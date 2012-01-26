@isTest
private class AWSGetFileEntriesWebserviceTEST {
	static testMethod void awsWebserviceTestmethod(){
        try{
            Account a = new Account(Name = 'Test AG');
            insert a;
            
            Contact c = new Contact(AccountId = a.Id);
            c.Firstname = 'P';
            c.Lastname = 'Tester';
            insert c;
            
            Application__c app = new Application__c();
            app.Student__c = c.Id;
            insert app;
            
            Boolean res = AWSGetFileEntriesWebservice.createApplicationDocument('xxx', app.Id);
            System.assert(res);
            
            //should not work, application is not valid
            res = AWSGetFileEntriesWebservice.createApplicationDocument('xxx', 'x455sdfxdfd');
            System.assert(!res);
            
        }catch(System.Exception e){
            System.debug('**** Exception: ' +e);
            System.assert(false);   
        }
    }

}