public class BatchJobController {

    public PageReference startAccount() {
        AccountAddressEnrichBatch a = new AccountAddressEnrichBatch();
        a.startBatch();

        return new PageReference('/apexpages/setup/listAsyncApexJobs.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DMonitoring&setupid=AsyncApexJobs');
    }


    public PageReference startContact() {
        ContactAddressEnrichBatch c = new ContactAddressEnrichBatch();
        c.startBatch();
        
        return new PageReference('/apexpages/setup/listAsyncApexJobs.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DMonitoring&setupid=AsyncApexJobs');
    }

    public PageReference startLead() {
        LeadAddressEnrichBatch l = new LeadAddressEnrichBatch();
        l.startBatch();
        
        return new PageReference('/apexpages/setup/listAsyncApexJobs.apexp?retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DMonitoring&setupid=AsyncApexJobs');
    }
}