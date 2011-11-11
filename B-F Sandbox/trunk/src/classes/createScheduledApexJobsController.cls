public with sharing class createScheduledApexJobsController {

    public void stopScheduledJobs()
    {
        Offline_Outlet_Visit_CRON_Settings__c cusSettings;
        cusSettings = Offline_Outlet_Visit_CRON_Settings__c.getOrgDefaults();
        
        for(CronTrigger a : [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where Id =: cusSettings.Job_ID__c])
        {
            system.abortJob(a.Id);
        }
        cusSettings.Job_ID__c = null;
        update cusSettings;
    }

    public void startScheduledJobs()
    {
        Offline_Outlet_Visit_CRON_Settings__c cusSettings;
        cusSettings = Offline_Outlet_Visit_CRON_Settings__c.getOrgDefaults();
        
        String seconds = '1'; //Execute at Zero Seconds
        String minutes = '1'; //Execute at every 5th minute of hour
        String hours = '1'; // Execute Every Hour
        String dayOfMonth = '15'; // Execute Every Day of the Month
        String month = '*'; //Execute only in November(11)
        String dayOfWeek = '?'; //Execute on all 7 days of the Week
        String year = '*'; //Execute only for year 2009
        
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '';
        //String sch = '0 5 * * * ? *';
        
        sch=seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
        String jobId = system.schedule('processDatedOfflineOutletVisits', sch, new processDatedOfflineOutletVisits());
        cusSettings.Job_ID__c = jobId;
        update cusSettings;
    }
}