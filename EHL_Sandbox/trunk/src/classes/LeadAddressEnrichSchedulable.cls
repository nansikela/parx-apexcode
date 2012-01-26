global class LeadAddressEnrichSchedulable implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        LeadAddressEnrichBatchable batchJob = new LeadAddressEnrichBatchable();
        Database.executeBatch(batchJob, 1);  //batch size is only 1
    }
}