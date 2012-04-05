@isTest
private class Test_project_prioritization {

   static testMethod void test(){
       //delete existing projects
       List<Project_Opportunity__c> existingProjects = [SELECT Id from Project_Opportunity__c];
       delete existingProjects;
       // Create some projects
       project_prioritization MyController = new project_prioritization();
       Id projectRtId = MyController.getProjectRtId();
       Date startDate = Date.parse('01/01/2012');
       Date endDate = Date.parse('01/20/2012');
       Brand__c btest = new Brand__c(Name='Southern Comfort');
       Market__c mtest = new Market__c(Name='Germany');
       List<Project_Opportunity__c> testProjects = new List<Project_Opportunity__c>();
       for (Integer i = 0;i<20;i++){
            Project_Opportunity__c newProject = new Project_Opportunity__c(Category__c='Single Serve',Market__r=mtest,Brand__r=btest,Name='test'+i,Start_Date__c=startDate,End_Date__c=endDate,RecordTypeId=projectRtId);   
            testProjects.add(newProject);
       }
       insert testProjects;
       
       List<Project_Opportunity__c> someProjects = MyController.getProjects();
       System.AssertEquals(someProjects[0].Category__c, 'Single Serve');
       
       List<selectOption> m = MyController.getMarketsList();
       System.AssertEquals(m[0].getValue(),'ALL');
       
       List<selectOption> b = MyController.getBrandsList();
       System.AssertEquals(b[0].getValue(),'ALL');
       
       List<selectOption> c = MyController.getCategoryList();
       System.AssertEquals(c[0].getValue(),'ALL');
       
       List<Project_Opportunity__c> p = MyController.getPipeline();
       System.AssertEquals(p[0].Category__c, 'Single Serve');
       
       String f = MyController.getFilter();
       System.AssertNotEquals(f, null);
       
       MyController.selBrand = 'Southern Comfort';
       MyController.selMarket = 'Germany';
       MyController.selCategory = 'Single Serve';
       MyController.refresh();
   }
}