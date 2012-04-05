trigger triggerUpdateProject on Project_Opportunity__c (before insert, before update) {
/*
-------------------------------------------------------------------------------
Developer      Date      Description
-------------------------------------------------------------------------------
J Woodall   01-17-2012   This trigger will update the evaluator fields based on
                         the market that has been selected.
-------------------------------------------------------------------------------
*/  
for (Project_Opportunity__c myProject : Trigger.new) {
    Market__c selectedMarket = Database.Query('SELECT Evaluator_1__c,Evaluator_2__c,Evaluator_3__c,Evaluator_4__c,Evaluator_5__c,Evaluator_6__c,Evaluator_7__c,Evaluator_8__c FROM Market__c WHERE Id = \''+myProject.Market__c+'\'');
    myProject.Evaluator_1__c = selectedMarket.Evaluator_1__c;
    myProject.Evaluator_2__c = selectedMarket.Evaluator_2__c;
    myProject.Evaluator_3__c = selectedMarket.Evaluator_3__c;
    myProject.Evaluator_4__c = selectedMarket.Evaluator_4__c;
    myProject.Evaluator_5__c = selectedMarket.Evaluator_5__c;
    myProject.Evaluator_6__c = selectedMarket.Evaluator_6__c;
    myProject.Evaluator_7__c = selectedMarket.Evaluator_7__c;
    myProject.Evaluator_8__c = selectedMarket.Evaluator_8__c;
    }
}