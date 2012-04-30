global class processDatedOfflineOutletVisits implements Schedulable {
    
     global void execute(SchedulableContext ctx)
     {
        offlineOutletVisit.processDatedOOVIs();
     }
}