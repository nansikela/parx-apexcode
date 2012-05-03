@isTest
private class Test_triggerUpdateProject {
   static testMethod void test(){
        // Create a project
       Date startDate = Date.parse('01/01/2012');
       Date endDate = Date.parse('01/20/2012');
       Brand__c btest = new Brand__c(Name='Woodford Reserve');
       Market__c mtest = new Market__c(Name='testMarket', Evaluator_1__c='005300000046Egr');
       insert btest;
       insert mtest;
       Project_Opportunity__c testProject = new Project_Opportunity__c(Market__c=mtest.Id,Brand__c=btest.Id,Name='test',Category__c='Line Extension',Start_Date__c=startDate,End_Date__c=endDate);
       
       //insert project and run the trigger
       insert testProject;
       
       // See if the evaluators were imported
       Market__c selectedMarket = Database.Query('SELECT Name, Evaluator_1__c,Evaluator_2__c,Evaluator_3__c,Evaluator_4__c,Evaluator_5__c,Evaluator_6__c,Evaluator_7__c,Evaluator_8__c FROM Market__c WHERE Name = \'testMarket\'');
       System.AssertEquals('005300000046Egr', selectedMarket.Evaluator_1__c);
       //System.AssertEquals(testProject.Market__r.Name, selectedMarket.Name);
   }
}