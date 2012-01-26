global class AccountAddressEnrichSchedulable implements Schedulable{
    
   global void execute(SchedulableContext SC) {
        AccountAddressEnrichBatchable batchJob = new AccountAddressEnrichBatchable();
        Database.executeBatch(batchJob, 1);  //batch size is only 1
   }

}