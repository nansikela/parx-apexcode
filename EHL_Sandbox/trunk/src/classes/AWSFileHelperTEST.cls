@isTest
private class AWSFileHelperTEST {
    static testMethod void awsTestmethod(){
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
            
            
            
            
            //************** ERROR 1 --> appId id is missing
            PageReference pageRef1 = new PageReference('Page.awsGetFileEntries');
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('aemmId', '56');
            AWSFileHelper controller1 = new AWSFileHelper();
            System.assert(ApexPages.hasMessages());
            
            //************** ERROR 2 --> aemm id is missing
            PageReference pageRef3 = new PageReference('Page.awsGetFileEntries');
            Test.setCurrentPage(pageRef3);
            ApexPages.currentPage().getParameters().put('appId', app.Id);
            AWSFileHelper controller3 = new AWSFileHelper();
            System.assert(ApexPages.hasMessages());
            
            
            //*********** SUCCESS
            PageReference pageRef2 = new PageReference('Page.awsGetFileEntries');
            Test.setCurrentPage(pageRef2);
            ApexPages.currentPage().getParameters().put('aemmId', '56');
            ApexPages.currentPage().getParameters().put('appId', app.Id);
            AWSFileHelper controller2 = new AWSFileHelper();   
            System.debug('*** has error: '+ ApexPages.hasMessages());
            System.debug('*** error: '+ ApexPages.getMessages()[0]);
            
            //fake webservice call, not possible from testmethod
            List<AWSFileHelper.awsFile> fileList = new List<AWSFileHelper.awsFile>();
            fileList.add(new AWSFileHelper.awsFile('/path/image.jpg', 'the image', 'jpg', 'myCatgegory', Datetime.now()));
            fileList.add(new AWSFileHelper.awsFile('/path/pdf.pdf', 'the pdf', 'pdf', 'myCatgegory2', Datetime.now()));
            controller2.awsFileList = fileList;
            
            //write
            controller2.writeToSalesforce();
            
            //check that writing was successfull
            List<Application_Document__c> appDocSFList = [Select a.Category__c, a.Type__c, a.Title__c, a.Path__c, a.Last_Modified_Date__c, a.Id, a.Application__c From Application_Document__c a where a.Application__c = :app.Id];
            System.debug('*** appDocSFList size: ' +appDocSFList.size());
            System.assert(appDocSFList.size() >= 2);
            
            
            //*********** SUCCESS --> faking an update
            AWSFileHelper controller4 = new AWSFileHelper();   
            List<AWSFileHelper.awsFile> fileList2 = new List<AWSFileHelper.awsFile>();
            fileList2.add(new AWSFileHelper.awsFile('/path/image.jpg', 'the image', 'jpg', 'newCategory', Datetime.now()));
            fileList2.add(new AWSFileHelper.awsFile('/path/neuesdoc.doc', 'the file', 'doc', 'theCategory', Datetime.now()));
            controller4.awsFileList = fileList2;
            
            //write
            controller4.writeToSalesforce();
            
            
        }catch(System.Exception e){
            System.debug('**** Exception: ' +e);
            System.assert(false);   
        }
    }
}