@isTest
private class Test_VisitReportGeneratorBatchable {
    static RecordType RT;
    static Market__c market;
    static Account acc;
    static Contact con;
    static Date visit_date;
    static Date visit_date2;
    static void dataInit() {
        RT = [select id from RecordType where sObjectType = 'Account' AND developerName = 'EUR_Outlets' limit 1];
        //market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '1', On_Channel__c = '1');
        //insert market;
        List<Market__c> markets = [SELECT Id, Name, Market_Code__c, Off_Channel__c, On_Channel__c FROM Market__c WHERE Name = 'Germany'];
        market = markets[0];
        acc = new Account(Name = 'PARX', Market__c = market.Id, RecordTypeId = RT.Id, Channel__c = 'On', BillingCountry = 'DE',Group__c = 'Liquor Store');
        insert acc;
        con = new Contact(LastName = 'Roger', AccountId = acc.Id);
        insert con;
        
        visit_date = system.today().addYears(-1).addMonths(-2);
           
        Outlet_Visit__c outlet = new Outlet_Visit__c(Visit_Date__c = visit_date);
        outlet.Account__c = acc.Id;
        outlet.Met_With__c = con.Id;
        outlet.Status__c = 'Complete';
        insert outlet;


        Outlet_Visit_Item__c item = new Outlet_Visit_Item__c();
        item.Outlet_Visit__c = outlet.Id;
        insert item;



        visit_date2 = system.today().addMonths(-1);
           
        Outlet_Visit__c outlet2 = new Outlet_Visit__c(Visit_Date__c = visit_date2);
        outlet2.Account__c = acc.Id;
        outlet2.Met_With__c = con.Id;
        outlet2.Status__c = 'Complete';
        insert outlet2;

    }
    

    static testMethod void dataCollectionTest() {
        dataInit();
    
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Market__c = market.Id;
        conf.LastRecalculation__c = null;
//      conf.CurrencyIsoCode=EUR
        conf.Channel__c = 'On';
        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = '';
        conf.Group__c = 'Convenience Store;Liquor Store';
        conf.Recurrence_Int__c = 'Monthly'; 
        conf.Name = 'Test';
        conf.All_Data__c = false;
        conf.Period1_From__c=visit_date.addMonths(-1);
        conf.Period1_To__c=visit_date.addMonths(1);
        conf.Period2_From__c=visit_date2.addMonths(-1);
        conf.Period2_To__c=visit_date2.addMonths(1);
        insert conf;
        
        
        Test.startTest();
        
//      VisitReportGeneratorBatchable.recalculationCheck(null);
        
        VisitReportGeneratorBatchable.collectVisitItems(conf.Id);
//      List<Configuration_to_Visit__c> ctov = [Select Id FROM Configuration_to_Visit__c where Visit_Report_Configuration__c = : outlet.Id];
//      System.debug('$$$$$$$$$$$$$$$$$$$$$$$$ctov: ' +ctov);
//      System.assert(ctov.size() > 0);
        
        Test.stopTest();
    }
    
    
    static testMethod void recurrent_Quarterly_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';

        conf.LastRecalculation__c = System.today().addMonths(-4);
        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Quarterly'; 

        conf.All_Data__c = false;
        conf.Period1_From__c = System.today().addMonths(-10).toStartOfMonth();
        conf.Period1_To__c = conf.Period1_From__c.addMonths(0).toStartOfMonth();
        conf.Period2_From__c = System.today().addMonths(-7).toStartOfMonth();
        conf.Period2_To__c = conf.Period2_From__c.addMonths(1).toStartOfMonth();
        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     
        
        Test.stopTest();
    }
    
    static testMethod void recurrent_Yearly_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';
        conf.All_Data__c = false;

        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Yearly'; 

        conf.LastRecalculation__c = System.today().addMonths(-14);
        conf.Period1_From__c = System.today().addMonths(-16).toStartOfMonth();
        conf.Period1_To__c = conf.Period1_From__c.addMonths(0).toStartOfMonth();
        conf.Period2_From__c = System.today().addMonths(-15).toStartOfMonth();
        conf.Period2_To__c = conf.Period2_From__c.addMonths(1).toStartOfMonth();
        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     


        Test.stopTest();
    }
    
    static testMethod void recurrent_Free_Year_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';
        conf.All_Data__c = false;

        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Free Selection'; 
        conf.Recurrence_Unit__c = 'Year(s)';
        conf.Recurrence_Number__c = 1;

        conf.LastRecalculation__c = System.today().addMonths(-14);
        conf.Period1_From__c = System.today().addMonths(-16).toStartOfMonth();
        conf.Period1_To__c = conf.Period1_From__c.addMonths(0).toStartOfMonth();
        conf.Period2_From__c = System.today().addMonths(-15).toStartOfMonth();
        conf.Period2_To__c = conf.Period2_From__c.addMonths(1).toStartOfMonth();

        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     



        Test.stopTest();
    }
    
    static testMethod void recurrent_Monthly_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';

        conf.LastRecalculation__c = System.today().addMonths(-2);
        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Monthly'; 

        conf.All_Data__c = false;
        conf.Period1_From__c = System.today().addMonths(-4).toStartOfMonth();
        conf.Period1_To__c = conf.Period1_From__c.addMonths(0).toStartOfMonth();
        conf.Period2_From__c = System.today().addMonths(-3).toStartOfMonth();
        conf.Period2_To__c = conf.Period2_From__c.addMonths(1).toStartOfMonth();
        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     
        
        Test.stopTest();
    }

    static testMethod void recurrent_Free_Month_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';

        conf.LastRecalculation__c = System.today().addMonths(-2);
        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Free Selection'; 
        conf.Recurrence_Unit__c = 'Month(s)';
        conf.Recurrence_Number__c = 1;

        conf.All_Data__c = false;
        conf.Period1_From__c = System.today().addMonths(-4).toStartOfMonth();
        conf.Period1_To__c = conf.Period1_From__c.addMonths(0).toStartOfMonth();
        conf.Period2_From__c = System.today().addMonths(-3).toStartOfMonth();
        conf.Period2_To__c = conf.Period2_From__c.addMonths(1).toStartOfMonth();
        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     
        
        Test.stopTest();
    }
    
    static testMethod void recurrent_Weekly_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';

        conf.LastRecalculation__c = System.today().addDays(-8);
        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Weekly'; 

        conf.All_Data__c = false;
        conf.Period1_From__c = System.today().addDays(-22);
        conf.Period1_To__c = System.today().addDays(-16);
        conf.Period2_From__c = System.today().addDays(-15);
        conf.Period2_To__c = System.today().addDays(-8);
        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     
        
        Test.stopTest();
    }

    static testMethod void recurrent_Free_Week_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';

        conf.LastRecalculation__c = System.today().addDays(-8);
        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Free Selection'; 
        conf.Recurrence_Unit__c = 'Week(s)';
        conf.Recurrence_Number__c = 1;

        conf.All_Data__c = false;
        conf.Period1_From__c = System.today().addDays(-22);
        conf.Period1_To__c = System.today().addDays(-16);
        conf.Period2_From__c = System.today().addDays(-15);
        conf.Period2_To__c = System.today().addDays(-8);
        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     
        
        Test.stopTest();
    }
    static testMethod void recurrent_Free_Day_Test() {
        Visit_Report_Configuration__c conf = new Visit_Report_Configuration__c();
        conf.Name = 'Test';

        conf.LastRecalculation__c = System.today().addDays(-8);
        conf.IsRecurrence__c = true;
        conf.Recurrence_Int__c = 'Free Selection'; 
        conf.Recurrence_Unit__c = 'Day(s)';
        conf.Recurrence_Number__c = 1;

        conf.All_Data__c = false;
        conf.Period1_From__c = System.today().addDays(-22);
        conf.Period1_To__c = System.today().addDays(-16);
        conf.Period2_From__c = System.today().addDays(-15);
        conf.Period2_To__c = System.today().addDays(-8);
        insert conf;
        
        
        Test.startTest();
        
        VisitReportGeneratorBatchable.recalculationCheck(null);     
        
        Test.stopTest();
    }
}