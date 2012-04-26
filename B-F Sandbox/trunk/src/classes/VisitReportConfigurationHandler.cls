global class VisitReportConfigurationHandler {

    static webservice string collectVisitItems(String visitreportconfigurationid) {
        string msg='';
        Visit_Report_Configuration__c vrc=[SELECT Id, Market__c, Channel__c, Group__c, Period1_From__c, Period1_To__c, Period2_From__c, Period2_To__c FROM Visit_Report_Configuration__c WHERE Id=:visitreportconfigurationid];
        delete [select id from configuration_to_visit__c WHERE Visit_Report_Configuration__c=:vrc.id];
        List<Configuration_to_Visit__c> ctovlist = new List<Configuration_To_Visit__c>();
        for (Outlet_Visit_Item__c ovi:[SELECT Id FROM Outlet_Visit_Item__c WHERE 
                        //Channel__c=:vrc.Channel__c AND Outlet_Visit__r.Market__c=:vrc.Market__C ANd
                (
                    (Outlet_Visit__r.Visit_Date__c>=:vrc.Period1_From__c AND Outlet_Visit__r.Visit_Date__c<=:vrc.Period1_To__c)
                    OR
                    (Outlet_Visit__r.Visit_Date__c>=:vrc.Period2_From__c AND Outlet_Visit__r.Visit_Date__c<=:vrc.Period2_To__c)
                )]) {
            Configuration_to_Visit__c ctov = new Configuration_to_Visit__c();
            ctov.Visit_Report_Configuration__c=vrc.id;
            ctov.Outlet_Visit_Item__c=ovi.id;
            ctovlist.add(ctov);
        }
        insert ctovlist;
        return msg;
    }
}