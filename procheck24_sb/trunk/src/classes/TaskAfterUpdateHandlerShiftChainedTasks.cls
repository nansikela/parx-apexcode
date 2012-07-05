/**
 After update handler on Task Sobject
*/
/**
* @author Jochen Schrader
* @date 11/06/2012
* @description Class handles AfterUpdate of Task Trigger
*/
public class TaskAfterUpdateHandlerShiftChainedTasks implements Triggers.Handler {
    // Prevent trigger from running twice on updates
    // Ref : http://raydehler.com/cloud/clod/prevent-an-apex-trigger-from-executing-twice.html
	static boolean firstRunForUpdate = true;
	
	public static final set<String> chainedtitles = new set<String>{ 'Welcome Call', 'Tech Call', '1. Review Call', '2. Review Call' };
	
	/**
	* @author Jochen Schrader
	* @date 11/06/2012
	* @description Method handles the updates for tasks to shift the chained Tasks
	*/
	public void handle() {
		if (firstRunForUpdate) {
			firstRunForUpdate=false;
		   System.debug(LoggingLevel.INFO, 'Post Update handling, NewItems: ' + Trigger.newMap + ', OldItems: ' + Trigger.oldMap );

			// find chained tasks that have been changed
		   map<Id, Task> newtasks = new map<Id, Task>();
		   map<Id, Task> oldtasks = new map<Id, Task>();
		   map<Id, Task> taskstoupdate =new map<Id, Task>();
		   set<Id> whoids = new set<Id>();
		   for (SObject o:trigger.newMap.values()) {
		   	Task newtask=(Task)o;
			Task oldtask=(Task)trigger.oldMap.get(newtask.id);
		   	if(newtask.ActivityDate>oldtask.ActivityDate && chainedtitles.contains(newtask.Subject) && !newtask.IsClosed) {
		   		newtasks.put(newtask.id, newtask);
		   		oldtasks.put(oldtask.id, oldtask);
		   		whoids.add(newtask.whoid);
		   	}
		   }
		   
		   // we have work to do
		   if (!newtasks.isEmpty()) {
		   	 // we need to get the other open chained tasks for whoids and change them
		   	 for (Task ct: [SELECT Id, ActivityDate, WhoId, WhatId, isClosed, Status, Subject, Description FROM Task WHERE isClosed=false AND Whoid IN :whoids AND Subject IN :chainedtitles AND ID NOT IN :newtasks.keySet()]) {
		   	 	for (Task nt:newtasks.values()) {
		   	 		// we don't care about the exact title because we have to move everything in the future
		   	 		// TODO may be this is not always the right solution
		   	 		if (ct.whoid==nt.whoid && ct.ActivityDate>oldtasks.get(nt.id).ActivityDate) {
		   	 			System.debug('ct: ' + ct.subject + ' ' + ct.Id + ' ' + ct.ActivityDate + ' ' + ct.whoid);
		   	 			ct.ActivityDate=ct.ActivityDate+(-1)*(nt.ActivityDate.daysBetween(oldtasks.get(nt.id).ActivityDate));
		   	 			taskstoupdate.put(ct.id, ct);
		   	 			System.debug('Diff: ' + (-1)*nt.ActivityDate.daysBetween(oldtasks.get(nt.id).ActivityDate));
		   	 		}
		   	 	}
		   	 }
		   }
		   
		   if (!taskstoupdate.isEmpty())
		   		update taskstoupdate.values();
		   
		}
	}
}