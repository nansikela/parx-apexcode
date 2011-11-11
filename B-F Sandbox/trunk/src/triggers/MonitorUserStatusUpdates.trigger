trigger MonitorUserStatusUpdates on User (before update) {
    for (Integer i = 0; i < trigger.new.size(); i++)
    {
        if ( trigger.new[i].CurrentStatus != null && trigger.old[i].CurrentStatus != trigger.new[i].CurrentStatus && trigger.new[i].CurrentStatus.contains('m.salesforce.com')) {
            trigger.new[i].CurrentStatus.addError('Unwanted Status: ' + trigger.new[i].CurrentStatus); // Prevent Update
        }
    }    
}