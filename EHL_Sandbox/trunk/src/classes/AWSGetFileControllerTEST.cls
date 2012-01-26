@isTest
private class AWSGetFileControllerTEST {
	
	static testMethod void awsGetFileTestmethod(){
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
            
            
            Application_Document__c d = new Application_Document__c();
            d.Application__c = app.Id;
            d.Type__c = 'jpg';
            d.Title__c = 'ParxDoc.jpg';
            d.Path__c = 'D:/temp/ParxDoc.jpg';
            d.Category__c = 'OfficialTranslationsTranscripts';
            d.Last_Modified_Date__c = Datetime.now();
            insert d;
            
            
            
            //************** ERROR 1 --> adId id is missing
            PageReference pageRef1 = new PageReference('Page.getFile');
            Test.setCurrentPage(pageRef1);
            AWSGetFileController controller1 = new AWSGetFileController();
            System.assert(ApexPages.hasMessages());
            
            //************** ERROR 2 --> adId id is wrong
            PageReference pageRef3 = new PageReference('Page.getFile');
            Test.setCurrentPage(pageRef3);
            ApexPages.currentPage().getParameters().put('adId', 'txx354345');
            AWSGetFileController controller3 = new AWSGetFileController();
            System.assert(ApexPages.hasMessages());
            
            
            //*********** SUCCESS
            PageReference pageRef2 = new PageReference('Page.getFile');
            Test.setCurrentPage(pageRef2);
            ApexPages.currentPage().getParameters().put('adId', d.Id);
            AWSGetFileController controller2 = new AWSGetFileController();   
			System.assertNotEquals(controller2.url, null);

        }catch(System.Exception e){
            System.debug('**** Exception: ' +e);
            System.assert(false);   
        }
    }
}