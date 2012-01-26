global class ContactAddressEnrichSchedulable implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        ContactAddressEnrichBatchable batchJob = new ContactAddressEnrichBatchable();
        Database.executeBatch(batchJob, 1);  //batch size is only 1
    }
}